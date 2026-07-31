//
//  imageCollectionViewCell.swift
//  photo-search
//
//  Created by Amir Bakhshi on 2026-07-30.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    
    static let reuseIdentifier: String = "ImageCollectionViewCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        setup(with: "")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    
    func setup(with urlString: String) {
        guard let url = URL(string: urlString) else { return }
        imageView.image = nil
        imageView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] Data, _, error in
            guard let data = Data, error == nil else { return }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self?.imageView.image = image
            }
        }
        task.resume()
    }
    
    
}
