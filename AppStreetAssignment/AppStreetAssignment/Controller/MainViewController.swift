//
//  MainViewController.swift
//  AppStreetAssignment
//
//  Created by Dipika on 7/28/18.
//  Copyright © 2018 dipika. All rights reserved.
//

import UIKit

protocol Photo {
    var thumbnailURL: URL? {get}
    var highResPhotoURL: URL? {get}
}

protocol MainViewControllerProtocol {
    func searchPhotos(forSearchString searchString: String, pageNumber: Int, andItemsPerPage itemsPerPage: Int, completion: @escaping ([Photo]?, String?)-> Void)
}

private struct MainViewControllerConstants{
    static let optionsForItemsPerRow: Array<Int> = [2, 3, 4]
    static let cellPadding: CGFloat = 10.0
    static let defaultNumberOfColumns = 4
    static let imageCollectionViewCell = "ImageCollectionViewCell"
    static let itemsPerPage = 25
    
    struct Messages{
    static let itemsNeededAlertSheetMessage = "How many items should each row have?"
    }
}


class MainViewController: UICollectionViewController {
    fileprivate var photosDataSource: [Photo]? = nil
    fileprivate var delegate: MainViewControllerProtocol? = nil
    fileprivate var itemsPerRow = MainViewControllerConstants.defaultNumberOfColumns
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    fileprivate var searchString: String? = nil
    fileprivate var searckTask: DispatchWorkItem? = nil
    fileprivate var isLoading: Bool = false
    fileprivate var isFulfillingSearchConditions: Bool{
        get{
            if let searchText = searchController.searchBar.text, searchText.count >= 3{
                searchString = searchText
                return true
            }else{
                return false
            }
        }
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = FlickrProvider()
        
        //If Search call needed on each update of search string change
        //searchController.searchResultsUpdater = self
        
        searchController.searchBar.delegate = self
        self.definesPresentationContext = true
        self.navigationItem.titleView = searchController.searchBar
        self.navigationItem.titleView?.tintColor = .white
        searchController.hidesNavigationBarDuringPresentation = false
    }
    
    @IBAction func optionsSelected(_ sender: Any) {
        let alertSheet = UIAlertController(title: nil, message: MainViewControllerConstants.Messages.itemsNeededAlertSheetMessage, preferredStyle: .actionSheet)
        for item in MainViewControllerConstants.optionsForItemsPerRow{
            alertSheet.addAction(UIAlertAction(title: String(item), style: .default, handler: {[weak self] action in
                self?.itemsPerRow = Int(action.title ?? "") ?? MainViewControllerConstants.defaultNumberOfColumns
                    self?.collectionView?.reloadData()
            }))
        }
        
        self.present(alertSheet, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let cell = sender as? ImageCollectionViewCell,
            let indexPath = self.collectionView?.indexPath(for: cell) {
            
            guard let detailViewController = segue.destination as? DetailViewController else{ return }
            detailViewController.photo = photosDataSource![indexPath.item]
        }
    }
    
    fileprivate func search(forPage pageNumber: Int, completion:@escaping ([Photo]?)->Void){
        guard let searchString = searchString else{return}
        delegate?.searchPhotos(forSearchString: searchString, pageNumber: pageNumber, andItemsPerPage: MainViewControllerConstants.itemsPerPage, completion: {[weak self](results, error) in
            self?.isLoading = false
            if let _ = error{
                //TODO: Show Error
            }else{
                completion(results)
            }
        })
        isLoading = true
    }
    
    @objc fileprivate func searchNextPage(){
        let currentPage = (photosDataSource?.count ?? 0)/MainViewControllerConstants.itemsPerPage
        search(forPage: currentPage+1, completion:{[weak self] (results) in
            guard let results = results else {return}
            DispatchQueue.main.async {
                self?.photosDataSource?.append(contentsOf: results)
                self?.collectionView?.reloadData()
            }
        })
    }
}

// MARK: - UICollectionViewDataSource implementation
extension MainViewController{
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return photosDataSource?.count ?? 0
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainViewControllerConstants.imageCollectionViewCell, for: indexPath)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let photo = photosDataSource![indexPath.item]
        (cell as! ImageCollectionViewCell).fillData(photo)
        
        guard let currentDataSourceSize = photosDataSource?.count else{return}
        if currentDataSourceSize - indexPath.row == (2 * itemsPerRow){
           searchNextPage()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
            return CGSize(width: collectionView.bounds.size.width, height: 55)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CustomFooterView", for: indexPath) as! CustomFooterView
        isLoading ? footerView.loader.startAnimating(): footerView.loader.stopAnimating()
        return footerView
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MainViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        let paddingPerRow = MainViewControllerConstants.cellPadding * CGFloat(itemsPerRow - 1)
        let availableSpace = self.view.frame.width - paddingPerRow
        let dimensionOfEachItem = availableSpace/CGFloat(itemsPerRow)
        
        return CGSize(width: dimensionOfEachItem, height: dimensionOfEachItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return MainViewControllerConstants.cellPadding
    }
}

//If Search call needed on each update of search string change
//extension MainViewController: UISearchResultsUpdating{
//    func updateSearchResults(for searchController: UISearchController) {
//        if isFulfillingSearchConditions{
//            search(forPage: 0, completion: {[weak self] results in
//                guard let results = results else{return}
//                DispatchQueue.main.async {
//                    self?.photosDataSource = results
//                    self?.collectionView?.reloadData()
//                }
//            })
//        }
//    }
//}

extension MainViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if isFulfillingSearchConditions{
            search(forPage: 0, completion: {[weak self] results in
                guard let results = results else{return}
                DispatchQueue.main.async {
                    self?.photosDataSource = results
                    self?.collectionView?.reloadData()
                }
            })
        }
        self.photosDataSource?.removeAll()
        self.collectionView?.reloadData()
        searchController.isActive = false
    }
}

