//
//  AlbumCellViewModel.swift
//  cv
//
//  Created by Dmitry on 1/28/21.
//

import UIKit

class AlbumCellViewModel: NSObject {
    var titleText : String = ""
    var imageUrl : String = ""
    
    let cache = NSCache<NSString, UIImage>()
    
    func getImage(completion: @escaping (_ data: UIImage?) -> Void) {
        if let cachedImage = cache.object(forKey: "CachedImage") {
            DispatchQueue.main.async {
                completion(cachedImage)
            }
        } else {
            AlbumCell.fService.getImageData(url: imageUrl) {[weak self] (imgData) in
                DispatchQueue.main.async {[weak self] in
                    guard let imgData = imgData else {
                        self?.cache.removeObject(forKey: "CachedImage")
                        completion(nil)
                        return
                    }
                    let image = UIImage(data: imgData)
                    if let image = image {
                        self?.cache.setObject(image, forKey: "CachedImage")
                    }
                    completion(image)
                }
            }
        }
    }
    
    init(albumModel: Album) {
        super.init()
        titleText = albumModel.title
        imageUrl = albumModel.url
    }
}
