//
//  TitleCollectionViewCell.swift
//  NetflixClone
//
//  Created by Ritika Gupta on 18/11/24.
//

import UIKit
import SDWebImage

class TitleCollectionViewCell: UICollectionViewCell {
    static let identifier = "TitleCollectionViewCell"
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with posterURL: String) {
        let url = "https://image.tmdb.org/t/p/w500/\(posterURL)"
        imageView.sd_setImage(with: URL(string: url))
    }
    
}
