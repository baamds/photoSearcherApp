//
//  PhotoCell.swift
//  photoSearchApp
//
//  Created by Amir Bakhshi on 2026-08-02.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    // In this context, static means the property belongs to the type itself (PhotoCell),
    // not to individual instances of the type.
    static let identifier = "PhotoCell"
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var containerView: UIView!

    private var representedPhotoID: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgView.contentMode = .scaleAspectFill
        containerView.backgroundColor = .systemBackground
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        profileImage.layer.cornerRadius = profileImage.bounds.width / 2
        profileImage.clipsToBounds = true
    }
    
    // reset all view components before using for new image
    override func prepareForReuse() {
        super.prepareForReuse()
        representedPhotoID = nil
        imgView.image = nil
        profileImage.image = nil
        name.text = nil
        likes.text = nil
        location.text = nil
    }
    
    func configure(with photo: JasonResult) {
        representedPhotoID = photo.id
        let representedImageUrl = photo.urls.small
        let profileImage = photo.user.profile_image.small
        let name = photo.user.name
        let likes = photo.likes
        let location = photo.user.location
        
        // fetch represented image
        ImageProvider.shared.fetchImage(url: representedImageUrl, completion: { [weak self] image in
            DispatchQueue.main.async {
                guard self?.representedPhotoID == photo.id else { return }
                self?.imgView.image = image
            }
        })
        
        // fetch profile image
        ImageProvider.shared.fetchImage(url: profileImage, completion: { [weak self] image in
            DispatchQueue.main.async {
                guard self?.representedPhotoID == photo.id else { return }
                self?.profileImage.image = image
                self?.name.text = name
                self?.likes.text = "\(likes)"
                self?.location.text = location
            }
        })
    }
}
