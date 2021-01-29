//
//  AlbumsViewController.swift
//  cv
//
//  Created by Dmitry on 1/27/21.
//

import UIKit

class AlbumsViewController: UITableViewController, AlbumsViewModelDelegate {
    var viewModel : AlbumsViewModel = AlbumsViewModel(model: Albums())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        viewModel.loadData()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        switch viewModel.state {
            case .error( _):
                return 2
            default:
                return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if case .error(value: _) = viewModel.state {
            if section == 0 {
                return 1
            }
        }
        return viewModel.albumViewModels.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if case .error(value: let errorText) = viewModel.state {
            if indexPath.section == 0
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "IDError", for: indexPath)
                cell.textLabel?.text = errorText
                return cell
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "IDAlbumCell", for: indexPath)
        if let cell = cell as? AlbumCell
        {
            let cellVM = viewModel.albumViewModels[indexPath.row]
            cell.viewModel = cellVM
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if case .error(value: _) = viewModel.state {
            if indexPath.section == 0 {
                return
            }
        }
        viewModel.albumSelected(album: viewModel.albumViewModels[indexPath.row])
    }
    
    // MARK: - View model handlers
    
    func dataStateChanged(state: ViewModelState) {
        self.tableView.reloadData()
        //can control activity indicator, or handle error messages if it required
    }
    
    func navigateTo(route: AlbumRoute) {
        switch route {
        case .toDetails(let cellModel):
            let storyboard = UIStoryboard(name: "AlbumDetails", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "AlbumDetails") as? AlbumDetailsViewController
            {
                vc.viewModel = AlbumDetailsViewModel(cellViewModel: cellModel)
                vc.modalPresentationStyle = .fullScreen
                self.show(vc, sender: self)
            }
        }
        
    }
}
