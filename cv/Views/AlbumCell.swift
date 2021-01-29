//
//  AlbumCell.swift
//  cv
//
//  Created by Dmitry on 1/27/21.
//

import UIKit

class AlbumCell: UITableViewCell {
    var viewModel : AlbumCellViewModel? {
        didSet {
            if (viewModel !== oldValue)
            {
                let isFreshImage = viewModel?.imageUrl != oldValue?.imageUrl
                DispatchQueue.main.async {[weak self] in
                    self?.updateView(isFreshImage: isFreshImage)
                }
            }
        }
    }
    
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var albumTitle: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    static let fService = FileService()
    
    public func updateView(isFreshImage: Bool) {
        if let viewModel = viewModel {
            albumTitle.text = viewModel.titleText
        }
        else {
            albumTitle.text = ""
        }
        if (isFreshImage)
        {
            self.albumImage.image = nil
        }
        viewModel?.getImage(completion: {[weak self] (image) in
            self?.albumImage.image = image
        })
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
