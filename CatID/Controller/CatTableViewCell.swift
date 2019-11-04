//
//  CatTableViewCell.swift
//  CatID
//
//  Created by Ismail Elmaliki on 10/29/19.
//  Copyright © 2019 Ismail Elmaliki. All rights reserved.
//

import UIKit
import Kingfisher

class CatTableViewCell: UITableViewCell {
	
	@IBOutlet weak var catBreed: UITextField!
	@IBOutlet weak var catBreedPhoto: UIImageView!
	
	var aspectConstraint: NSLayoutConstraint? {
        didSet {
            if oldValue != nil {
                catBreedPhoto.removeConstraint(oldValue!)
            }
            if aspectConstraint != nil {
                catBreedPhoto.addConstraint(aspectConstraint!)
            }
        }
    }
    
    // clear
    override func prepareForReuse() {
        super.prepareForReuse()
		catBreedPhoto.kf.cancelDownloadTask()
		catBreedPhoto.image = nil
    }
    
    // set image, called in cellForRow
    func setCustomImage(url: URL, width: CGFloat, height: CGFloat) {
//		let cache = ImageCache.default
//		let cached = cache.isCached(forKey: url.absoluteString)
//
//		// To know where the cached image is:
//		let cacheType = cache.imageCachedType(forKey: url.absoluteString)
//		// `.memory`, `.disk` or `.none`.
//		print("Cache status for \(url.absoluteString): \(cacheType)")
		
        let aspect = width / height
        
        let constraint = NSLayoutConstraint(
			item: catBreedPhoto!,
            attribute: .width,
            relatedBy: .equal,
            toItem: catBreedPhoto,
            attribute: .height,
            multiplier: aspect,
            constant: 0.0
        )
        
        constraint.priority = UILayoutPriority(999)
        aspectConstraint = constraint
		let processor = DownsamplingImageProcessor(size: CGSize(width: 100, height: 100))
        // kf
        OperationQueue.main.addOperation {
            self.catBreedPhoto.kf.setImage(
                with: url,
                placeholder: nil,
                options: [.processor(processor), .transition(.fade(0.3))],
                progressBlock: nil,
                completionHandler: { _ in
					self.setNeedsLayout()

					self.catBreedPhoto.layer.masksToBounds = false
					self.catBreedPhoto.layer.cornerRadius = self.catBreedPhoto.frame.size.width / 2
					self.catBreedPhoto.clipsToBounds = true
					self.catBreedPhoto.contentMode = UIView.ContentMode.scaleAspectFill
			})
		}
    }
}
