//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit
class BusinessesViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,FilterViewControllerDeleagte {
    
    //TODO: Variables
    @IBOutlet weak var mapListButton: UIBarButtonItem!
    @IBOutlet weak var tblView: UITableView!
   
    @IBOutlet weak var noResultLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var businesses: [Business]!
    var searchBar: UISearchBar!
    var isMoreDataLoading = false
    var filter = FilterData()
    var count: Int = 0
    var loadingMoreView:InfiniteScrollActivityView?
    var currentLocation = CLLocationCoordinate2DMake(37.785771,-122.406165)
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
               super.viewDidLoad()
        
       
        setSearchBar()
        setTableView()
        setMapView()
        setInfiniteScroll()
        loadMoreData(filter)
       
        
    }
    //MARK: IBActions
    @IBAction func onFilterClick(_ sender: UIBarButtonItem) {
    }

    @IBAction func onMapListToggle(_ sender: UIBarButtonItem) {
        
        if isListOpen(){
            mapView.isHidden = false
            tblView.isHidden = true
            sender.title = "List"
            UIView.transition(from: tblView, to: mapView, duration: 1.0, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: nil)
            updateMapView(_business: self.businesses)
        }
        else{
            mapView.isHidden = true
            tblView.isHidden = false
            sender.title = "Map"
             UIView.transition(from: mapView, to: tblView, duration: 1.0, options: [.transitionFlipFromRight, .showHideTransitionViews], completion: nil)
        }
    }
    //MARK: Search API calls
    func doSearch(strSearch:String){
        Helper.showHud(viewController: self)
        Business.searchWithTerm(term: strSearch, completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            self.businesses = businesses
            self.reloadTableMaps()
            Helper.hideHud(viewController: self)
            
            
            }
        )
        
    }
    //MARK: Mapview Update
    func updateMapView(_business:[Business]){
        
       
        let initialLocation = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate,
                                                                 regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
       

        
        //mapView.setRegion(region, animated: true)
        mapView.removeAnnotations(mapView.annotations)
        for busines in _business{
            if busines.coordinate == nil{
                print("cant add")
            }else{
                let annotation = MKPointAnnotation()
                annotation.coordinate = busines.coordinate!
                annotation.title = busines.name
                self.mapView.addAnnotation(annotation)
               

            }
        }
        
    }
    //MARK: FilterViewController delegate
    func filterViewController(_ filterViewController: FilterViewController, didUpdateFilters filter: FilterData) {
        
        Helper.showHud(viewController: self)
        Business.searchWithTerm(term: searchBar.text!, sort: filter.sort, radius:filter.radius, categories: filter.categories, deals: filter.deal,limit: 0,offset : 0, completion: { (businesses: [Business]?, error: Error?) -> Void in
            self.filter = filter
            self.businesses = businesses
            self.reloadTableMaps()

            Helper.hideHud(viewController: self)
            
            }
        )
    }
    //MARK: TableView Deleagtes
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.businesses != nil)
        {
            return self.businesses.count
        }
        else
        {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        cell.business = businesses[indexPath.row]
        cell.nameLabel.text = "\(indexPath.row+1). \(businesses[indexPath.row].name!)"
        return cell
    }
    
    // MARK: ScrollView
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tblView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tblView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tblView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                
                let frame = CGRect(x: 0, y: tblView.contentSize.height, width: tblView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // Code to load more results
                loadMoreData(self.filter)
            }
        }
    }
    
    
    func loadMoreData(_ filter: FilterData) {
        
        Helper.showHud(viewController: self)
        
        filter.radius = filter.radius ?? 0
        filter.sort = filter.sort ?? YelpSortMode.bestMatched
        filter.categories = filter.categories ?? []
        filter.deal = filter.deal ?? false
        
        if(self.businesses != nil){
            count = self.businesses.count
        }
        
        if(self.filter.radius != nil){
        Business.searchWithTerm(term: searchBar.text!, sort: filter.sort, radius:filter.radius, categories: filter.categories, deals: filter.deal, limit: 20, offset: count, completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            
           
            print(businesses?.count)
            // Update flag
            self.isMoreDataLoading = false
            
            // Stop the loading indicator
            self.loadingMoreView!.stopAnimating()
            self.loadingMoreView?.isHidden = true
            // ... Use the new data to update the data source ...
            if(self.businesses != nil){
                for busObj in businesses!{
                    self.businesses.append(busObj)
                }
            }
            else{
                self.businesses = businesses
            }
            
            
            //self.businesses.append(contentsOf: businesses!)
            self.count = self.businesses.count
            print(self.businesses.count)
            // Reload the tableView now that there is new data
            
            self.reloadTableMaps()
            
            Helper.hideHud(viewController: self)
            
            }
        )
        }else{
            print("all nil")
        }
    }
        
    

    
    
    //Mark: SetUp
    func reloadTableMaps(){
        if self.businesses.count == 0{
            noResultLabel.text = "No result found for \(searchBar.text!)"
            noResultLabel.isHidden = false
            tblView.isHidden = true
            mapView.isHidden = true
        }else{
            noResultLabel.isHidden = true
            if !isListOpen(){
                mapView.isHidden = false
                tblView.isHidden = true
                updateMapView(_business: self.businesses)
            }else{
                mapView.isHidden = true
                tblView.isHidden = false
                tblView.reloadData()
            }
           
        }
    }
    func setTableView(){
        self.tblView.estimatedRowHeight = 550
        self.tblView.rowHeight = UITableViewAutomaticDimension
    }
    func setSearchBar(){
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.sizeToFit()
        
        navigationItem.titleView = searchBar
    }
    func setInfiniteScroll(){
       
        let frame = CGRect(x: 0, y: tblView.contentSize.height, width: tblView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tblView.addSubview(loadingMoreView!)
        
        var insets = tblView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tblView.contentInset = insets
    }
    func setMapView(){
        mapView.isHidden = true
        mapView.setRegion(MKCoordinateRegionMake(currentLocation, MKCoordinateSpanMake(0.1, 0.1)), animated: false)
    }
    func isListOpen()->Bool
    {
        if mapListButton.title == "Map"{
            return true
        }else{
            return false
        }
        
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FilterViewController" {
            ((segue.destination as! UINavigationController).topViewController as! FilterViewController).delegate = self
        }
    }
    
}
// MARK: SearchBar methods
extension BusinessesViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        doSearch(strSearch: searchBar.text!)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //searchSettings.searchString = searchBar.text
        searchBar.resignFirstResponder()
        doSearch(strSearch: searchBar.text!)
    }
}
