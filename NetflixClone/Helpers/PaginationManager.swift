//
//  PaginationManager.swift
//  NetflixClone
//
//  Created by Ritika Gupta on 27/11/24.
//

import Foundation
struct PaginationManager {
    private var sectionPaginationInfo: [Sections: PaginationInfo] = [:]
    
    mutating func updatePaginationInfo(for section: Sections, with content: ContentInfo) {
        sectionPaginationInfo[section] = PaginationInfo(
            currentPage: content.page,
            totalPages: content.totalPages
        )
    }
    
    func canFetchMoreContent(for section: Sections) -> Bool {
        sectionPaginationInfo[section]?.hasMoreContent ?? false
    }
    
    func getCurrentPage(for section: Sections) -> Int {
        sectionPaginationInfo[section]?.currentPage ?? 1
    }
    
    mutating func reset() {
        sectionPaginationInfo.removeAll()
    }
}
