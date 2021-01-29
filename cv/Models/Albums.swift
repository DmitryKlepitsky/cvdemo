//
//  Albums.swift
//  cv
//
//  Created by Dmitry on 1/28/21.
//

import UIKit

enum ModelState {
  case loading
  case populated
  case error(Error)
}

protocol AlbumsModelDelegate : AnyObject {
    func dataStateChanged(state: ModelState)
}

class Albums : NSObject {
    var state: ModelState = .loading
    var data : [Album] = []
    let dataManager = DataManager()
    weak var delegate : AlbumsModelDelegate?

    public func loadData() {
        updateCachedData()
        self.changeState(newState: .loading)
        
        self.dataManager.getAlbumList { [weak self] (albums, error) in
            guard let self = self else { return }
            if let error = error {
                self.changeState(newState: .error(error))
            } else {
                DispatchQueue.main.async {[weak self] in
                    self?.updateCachedData()
                    self?.changeState(newState: .populated)
                }
            }
        }
    }
    
    private func updateCachedData()
    {
        self.dataManager.getCachedAlbumList { (albums) in
            DispatchQueue.main.async { [weak self] in
                self?.data = albums
            }
        }
    }
    
    private func changeState(newState: ModelState)
    {
        DispatchQueue.main.async {[weak self] in
            self?.state = newState
            self?.delegate?.dataStateChanged(state: newState)
        }
    }
}
