//
//  PhotoCell.swift
//  photoSearchApp
//
//  Created by Amir Bakhshi on 2026-08-02.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    
    static let identifier = "PhotoCell"
    
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        
        
        super.awakeFromNib()
        imgView.contentMode = .scaleAspectFill
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        containerView.backgroundColor = .secondarySystemBackground
    }
    
    override func prepareForReuse() {
        imgView.image = nil
    }

}
