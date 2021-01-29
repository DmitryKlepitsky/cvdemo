//
//  AlbumsViewModel.swift
//  cv
//
//  Created by Dmitry on 1/28/21.
//

import UIKit

enum ViewModelState {
  case loading
  case populated
  case error(String)
}

enum AlbumRoute {
    case toDetails(cellModel: AlbumCellViewModel)
}

protocol AlbumsViewModelDelegate : AnyObject {
    func dataStateChanged(state: ViewModelState)
    func navigateTo(route: AlbumRoute)
}

class AlbumsViewModel: NSObject, AlbumsModelDelegate {
    weak var delegate : AlbumsViewModelDelegate?
    var state: ViewModelState = .loading
    
    var model : Albums
    
    var albumViewModels : [AlbumCellViewModel] = []

    func dataStateChanged(state: ModelState) {
        self.albumViewModels = model.data.map{ AlbumCellViewModel(albumModel: $0) }
        var newState = ViewModelState.loading
        switch state {
            case .loading:
                newState = .loading
            case .populated:
                newState = .populated
            case.error(_):
                newState = .error(NSLocalizedString("Can't load album list \n Working in offline mode", comment: "Error Message: offline mode"))
        }
        self.changeState(newState: newState)
    }
    
    public func loadData() {
        self.model.loadData()
    }
    
    init(model : Albums) {
        self.model = model
        super.init()
        model.delegate = self
    }
    
    private func changeState(newState: ViewModelState)
    {
        DispatchQueue.main.async {[weak self] in
            self?.state = newState
            self?.delegate?.dataStateChanged(state: newState)
        }
    }
    
    func albumSelected(album: AlbumCellViewModel) {
        self.navigateToDetails(album: album)
    }
    
    private func navigateToDetails(album: AlbumCellViewModel) {
        //usually better to use some kind of router, which will inject all dependencies
        DispatchQueue.main.async {[weak self] in
            self?.delegate?.navigateTo(route: .toDetails(cellModel: album))
        }
    }
 
}
