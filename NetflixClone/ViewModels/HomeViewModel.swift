//
//  HomeViewModel.swift
//  NetflixClone
//
//  Created by Ritika Gupta on 27/11/24.
//

import Foundation
protocol HomeViewModelDelegate: AnyObject {
    func updateUI(with state: State)
    func reloadSection(index: IndexSet)
}

class HomeViewModel {
    weak var delegate: HomeViewModelDelegate?
    
    var contentList: [Sections: [Content]] = [:]
    
    var isLoadingFurtherContent = false
    
    var state: State = .loading {
        didSet {
            delegate?.updateUI(with: state)
        }
    }
    
    let contentRepository: ContentFetcher
    private var paginationManager = PaginationManager()
    
    init(contentRepository: ContentFetcher = ContentRepository()) {
        self.contentRepository = contentRepository
    }
    
    func getAllContentData(page: Int = 1) {
        self.contentList = [:]
        state = .loading
        
        let dispatchGroup = DispatchGroup()
        var errorSections: [Sections] = []
        
        Sections.allCases.forEach { section in
            dispatchGroup.enter()
            
            contentRepository.fetchContent(for: section, page: page) { [weak self] result in
                guard let self = self else { return }
                defer { dispatchGroup.leave() }
                switch result {
                case .success(let content):
                    self.contentList[section] = content.results
                    self.paginationManager.updatePaginationInfo(for: section, with: content)
                case .failure(_):
                    errorSections.append(section)
                    self.contentList[section] = []
                }
            }
            
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }

            // error for sections
            if !errorSections.isEmpty {
                self.state = .error(errorSections)
                return
            }
            
            // completely empty
            if self.contentList.values.allSatisfy({ $0.isEmpty }) {
                self.state = .empty
                return
            }
            
            self.state = .loaded
        }
    }
    
    func reloadSpecificSection(_ section: Sections, page: Int = 1) {
        contentRepository.fetchContent(for: section, page: page) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                switch result {
                case .success(let content):
                    self.contentList[section] = content.results
                    self.paginationManager.updatePaginationInfo(for: section, with: content)
                    // Reload the specific section
                    self.delegate?.reloadSection(index: IndexSet(integer: section.rawValue))
    
                case .failure(_):
                    self.delegate?.reloadSection(index: IndexSet(integer: section.rawValue))
                }
            }
        }
    }
    
    func canFetchMoreContent(for section: Sections) -> Bool {
        paginationManager.canFetchMoreContent(for: section) && !isLoadingFurtherContent
    }
    
    func getMoreContent(for section: Sections, completion: @escaping ((Bool) -> Void)) {
        isLoadingFurtherContent = true
        let page = self.paginationManager.getCurrentPage(for: section)
        contentRepository.fetchContent(for: section, page: page + 1) { [weak self] result in
            
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let content):
                    var existingContent = self.contentList[section]
                    existingContent?.append(contentsOf: content.results)
                    self.contentList[section] = existingContent
                    self.paginationManager.updatePaginationInfo(for: section, with: content)
                    completion(true)
                    
                case .failure(_):
                    completion(false)
                }
                
                self.isLoadingFurtherContent = false
            }
        }
    }
}

enum State {
    case loading
    case loaded
    case empty
    case error([Sections])
}
