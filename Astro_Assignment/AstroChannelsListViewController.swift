//
//  AstroChannelsListViewController.swift
//  Astro_Assignment
//
//  Created by Kundan on 6/11/17.
//  Copyright © 2017 Kundan. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
import DropDown
import SwiftMessages
import ReachabilitySwift
import NVActivityIndicatorView

class AstroChannelsListViewController: UIViewController , UITableViewDelegate , UITableViewDataSource,NVActivityIndicatorViewable{
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var channelListTableView: UITableView!
    private let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        
        return SessionManager(configuration: configuration)
    }()
    @IBOutlet var sortBtn: UIBarButtonItem!
    
    var channelsListArray : [ChannelDetails] = []
    var filteredChannelsListArray : [ChannelDetails] = []
    var searchActive : Bool = false
    var favChannelsList : [Int] = Utils.getFavouriteList()
    var sortDropDown: DropDown?
    var optionsDropDown: DropDown?
    var selectedIndexPath : IndexPath?
    var favBtn : UIImageView?
    let reachability = Reachability()!
    //var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initilize()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        self.setupDropDownSort()
        self.setupDropDownOptions()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initilize() {
        self.addPullToRefreshToWebView()
        self.getChannelsList()
        channelListTableView?.tableFooterView = UIView()
        
    }
    
    func addPullToRefreshToWebView(){
        let refreshController:UIRefreshControl = UIRefreshControl()
        
        refreshController.bounds = CGRect(x: 0, y: -10, width: refreshController.bounds.size.width, height: refreshController.bounds.size.height) // Change position of refresh view
        refreshController.addTarget(self, action: #selector(AstroChannelsListViewController.refreshWebView), for: UIControlEvents.valueChanged)
        refreshController.attributedTitle = NSAttributedString(string: "Pull down to refresh...")
        channelListTableView.addSubview(refreshController)
        
    }
    
    func refreshWebView(refresh:UIRefreshControl){
        self.getChannelsList()
        refresh.endRefreshing()
    }
    
    @IBAction func onSortChannels(_ sender: Any) {
        if Utils.isUserLoggedIn() == LoggedInWith.NONE {
            optionsDropDown?.dataSource = ["Sort","Login"]
        }else{
            optionsDropDown?.dataSource = ["Sort","Logout"]
        }
        optionsDropDown?.show()
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    // Mark : Table View Delegates
    // number of rows in table view
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.searchActive) {
            return self.filteredChannelsListArray.count
        }
        return self.channelsListArray.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:ChannelListTableCell = tableView.dequeueReusableCell(withIdentifier: "ChannelListTableCellID") as! ChannelListTableCell!
        if(self.searchActive) {
            cell.ChNameLabel.text = self.filteredChannelsListArray[indexPath.row].channelName
            cell.ChNumberLabel.text = "CH \(String(describing: self.filteredChannelsListArray[indexPath.row].channelNumber!))"
            cell.markFavBtn.tag = indexPath.row
            let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(AstroChannelsListViewController.markFavourite(_:)))
            singleTapGesture.numberOfTapsRequired = 1
            cell.markFavBtn.addGestureRecognizer(singleTapGesture)
            cell.markFavBtn.isUserInteractionEnabled = true;
            if self.filteredChannelsListArray[indexPath.row].isChannelFav == true{
                cell.markFavBtn.image = UIImage(named:"favourite_Icon")
            }else{
                cell.markFavBtn.image = UIImage(named:"unfavourite_icon")
            }
            cell.channelLogoImg.sd_setImage(with: URL(string: self.filteredChannelsListArray[indexPath.row].channelImgURL!), placeholderImage: UIImage(named: "filetype-audio-1"))
        }else{
            
            cell.ChNameLabel.text = self.channelsListArray[indexPath.row].channelName
            cell.ChNumberLabel.text = "CH \(String(describing: self.channelsListArray[indexPath.row].channelNumber!))"
            cell.markFavBtn.tag = indexPath.row
            let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(AstroChannelsListViewController.markFavourite(_:)))
            singleTapGesture.numberOfTapsRequired = 1
            cell.markFavBtn.addGestureRecognizer(singleTapGesture)
            cell.markFavBtn.isUserInteractionEnabled = true;
            if self.channelsListArray[indexPath.row].isChannelFav == true{
                cell.markFavBtn.image = UIImage(named:"favourite_Icon")
            }else{
                cell.markFavBtn.image = UIImage(named:"unfavourite_icon")
            }
            cell.channelLogoImg.sd_setImage(with: URL(string: self.channelsListArray[indexPath.row].channelImgURL!), placeholderImage: UIImage(named: "filetype-audio-1"))
        }
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func markFavourite(_ gesture: UIGestureRecognizer) {
        
        let favouriteBtn = gesture.view as? UIImageView
        favBtn = favouriteBtn
        guard (favouriteBtn != nil)  else {
            return
        }
        if gesture.state == UIGestureRecognizerState.ended {
            let touchPoint = gesture.location(in: channelListTableView)
            let indexPath = channelListTableView?.indexPathForRow(at: touchPoint)
            selectedIndexPath = indexPath
            if(self.searchActive) {
                if (indexPath != nil){
                    if Utils.isUserLoggedIn() == LoggedInWith.NONE {
                        self.showLoginViewController()
                        return
                    }
                    if favouriteBtn?.image == UIImage(named:"unfavourite_icon"){
                        //CRUD Preference to cloud
                        self.addFavouriteChannel(channelObj: self.filteredChannelsListArray[(indexPath?.row)!], favouriteBtn: favouriteBtn!)
                        
                    }else{
                        //CRUD Preference to cloud
                        self.removeFavouriteChannel(channelObj: self.filteredChannelsListArray[(indexPath?.row)!], favouriteBtn: favouriteBtn!)
                    }
                }else{
                    print("unable to show option list because index path is invalid")
                }
                
            }else{
                if (indexPath != nil){
                    if Utils.isUserLoggedIn() == LoggedInWith.NONE {
                        self.showLoginViewController()
                        return
                    }
                    if favouriteBtn?.image == UIImage(named:"unfavourite_icon"){
                        //CRUD Preference to cloud
                        self.addFavouriteChannel(channelObj: self.channelsListArray[(indexPath?.row)!], favouriteBtn: favouriteBtn!)
                        
                    }else{
                        //CRUD Preference to cloud
                        self.removeFavouriteChannel(channelObj: self.channelsListArray[(indexPath?.row)!], favouriteBtn: favouriteBtn!)
                    }
                    
                }else{
                    print("unable to show option list because index path is invalid")
                }
            }
            
        }
    }
    
    // setup dropDown
    func setupDropDownOptions(){
        if (self.optionsDropDown == nil) {
            let appearance = DropDown.appearance()
            appearance.cellHeight = 40
            appearance.backgroundColor = UIColor(white: 1, alpha: 1)
            appearance.selectionBackgroundColor = UIColor(red: 0.6494, green: 0.8155, blue: 1.0, alpha: 0.2)
            appearance.cornerRadius = 8
            appearance.shadowColor = UIColor(white: 0.8, alpha: 1)
            appearance.shadowOpacity = 1
            appearance.shadowRadius = 25
            appearance.animationduration = 0.25
            appearance.textColor = .darkGray
            appearance.separatorColor = UIColor(white: 0.0, alpha: 0.0)
            appearance.textFont = UIFont(name: "Georgia", size: 14)!
            let dropDown = DropDown()
            dropDown.anchorView = self.sortBtn
            dropDown.direction = .bottom
            dropDown.width = 110
            if (dropDown.anchorView != nil){
                dropDown.bottomOffset = CGPoint(x: 0, y:((dropDown.anchorView?.plainView.bounds.height)! + 15))
            }
            
            self.optionsDropDown = dropDown
            dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
                print("Selected item: \(item) at index: \(index)")
                //self.dropDown?.hide()
                switch index {
                case 0:
                    print("Sort Channels")
                    if Utils.getDecendingSortPreference(){
                        self.sortDropDown?.dataSource = ["By CH Name","By CH Number","By Favourite","By Ascending"]
                    }else{
                        self.sortDropDown?.dataSource = ["By CH Name","By CH Number","By Favourite","By Descending"]
                    }
                    self.sortDropDown?.show()
                    
                case 1:
                    print("Login/Logout")
                    
                    if Utils.isUserLoggedIn() == LoggedInWith.NONE {
                        self.showLoginViewController()
                    }else{
                        // Logout user
                        self.logoutAndClearUserPreferences()
                    }
                    
                default:
                    print("Default Setting")
                }
            }
        }
    }
    
    func logoutAndClearUserPreferences() {
        
        self.selectedIndexPath = nil
        Utils.logoutUser()
        self.clearFavouriteList()
        Utils.setDecendingSortPreference(isDecendingSort: false)
        Utils.setSortPreference(sortBy: SortPreference.CHNAME)
        self.sortByCHName()                                                     // Assuming default sortting method
        Utils.setUserDetailsAvailable(isAvailable: false)
        self.showInAppNotification(title:"Logged out successfully", isError : false, isSuccess: false)
    }
    
    func setupDropDownSort(){
        if (self.sortDropDown == nil) {
            let appearance = DropDown.appearance()
            appearance.cellHeight = 40
            appearance.backgroundColor = UIColor(white: 1, alpha: 1)
            appearance.selectionBackgroundColor = UIColor(red: 0.6494, green: 0.8155, blue: 1.0, alpha: 0.2)
            appearance.cornerRadius = 8
            appearance.shadowColor = UIColor(white: 0.8, alpha: 1)
            appearance.shadowOpacity = 1
            appearance.shadowRadius = 25
            appearance.animationduration = 0.25
            appearance.textColor = .darkGray
            appearance.separatorColor = UIColor(white: 0.0, alpha: 0.0)
            appearance.textFont = UIFont(name: "Georgia", size: 14)!
            let dropDown = DropDown()
            dropDown.anchorView = self.sortBtn
            dropDown.direction = .bottom
            dropDown.width = 140
            if (dropDown.anchorView != nil){
                dropDown.bottomOffset = CGPoint(x: 0, y:((dropDown.anchorView?.plainView.bounds.height)! + 15))
            }
            if Utils.getDecendingSortPreference(){
                self.sortDropDown?.dataSource = ["By CH Name","By CH Number","By Favourite","By Ascending"]
            }else{
                self.sortDropDown?.dataSource = ["By CH Name","By CH Number","By Favourite","By Descending"]
            }
            self.sortDropDown = dropDown
            dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
                print("Selected item: \(item) at index: \(index)")
                switch index {
                case 0:
                    print("By CH Name")
                    Utils.setDecendingSortPreference(isDecendingSort: false)
                    self.sortByCHName()
                    
                case 1:
                    print("By CH Number")
                    Utils.setDecendingSortPreference(isDecendingSort: false)
                    self.sortByCHNumber()
                    
                case 2:
                    print("By Fav")
                    Utils.setDecendingSortPreference(isDecendingSort: false)
                    self.sortByFavChannel()
                    
                case 3:
                    print("Ascending/Descending")
                    self.decendingSort()
                    
                default:
                    print("Default Setting")
                }
                
                self.updateUserPreferences()
                let indexPath = IndexPath(row: 0 , section: 0)
                self.channelListTableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
            }
        }
    }
    
    func sortByCHName(){
        
        if Utils.getDecendingSortPreference(){
            self.channelsListArray.sort { $0.channelName?.compare($1.channelName!, options: .regularExpression) == .orderedDescending }  // sort by name
        }else{
            self.channelsListArray.sort { $0.channelName?.compare($1.channelName!, options: .regularExpression) == .orderedAscending }  // sort by name
        }
        Utils.setSortPreference(sortBy: SortPreference.CHNAME)
        self.channelListTableView.reloadData()
    }
    
    func sortByCHNumber(){
        if Utils.getDecendingSortPreference(){
            self.channelsListArray = self.channelsListArray.sorted (by: {$0.channelNumber! > $1.channelNumber!})  // sort by channel number
        }else{
            self.channelsListArray = self.channelsListArray.sorted (by: {$0.channelNumber! < $1.channelNumber!})  // sort by channel number
        }
        Utils.setSortPreference(sortBy: SortPreference.CHNUMBER)
        self.channelListTableView.reloadData()
    }
    
    func sortByFavChannel(){
        if Utils.getDecendingSortPreference(){
            self.channelsListArray = self.channelsListArray.sorted { !$0.isChannelFav! && $1.isChannelFav! } //sort by favourite
        }else{
            self.channelsListArray = self.channelsListArray.sorted { $0.isChannelFav! && !$1.isChannelFav! } //sort by favourite
        }
        Utils.setSortPreference(sortBy: SortPreference.FAVOURITE)
        self.channelListTableView.reloadData()
    }
    
    func decendingSort(){
        if Utils.getDecendingSortPreference(){
            Utils.setDecendingSortPreference(isDecendingSort: false)
        }else{
            Utils.setDecendingSortPreference(isDecendingSort: true)
        }
        self.getUserPreferenceAndLoadData()
    }
    
    func getUserPreferenceAndLoadData(){
        
        switch Utils.getSortPreference(){
        case SortPreference.CHNAME:
            self.sortByCHName()      // sort by channel name
            
        case SortPreference.CHNUMBER:
            self.sortByCHNumber()    // sort by channel number
            
        case SortPreference.FAVOURITE:
            self.sortByFavChannel()   // sort by favourite channels
            
        default:
            self.channelListTableView.reloadData()   // not sorting channels as user has not made any preference before
        }
    }
    
    func clearFavouriteList(){
        
        for var i in 0..<channelsListArray.count {
            channelsListArray[i].isChannelFav = false
        }
    }
    func setFavouriteChannelsList(){
        let favChannelsList = Utils.getFavouriteList()
        for var i in 0..<channelsListArray.count {
            if favChannelsList.contains(channelsListArray[i].channelId!){
                channelsListArray[i].isChannelFav = true
                
            }
        }
    }
    func showLoginViewController(){
        
        if !reachability.isReachable{
            self.showInAppNotification(title:"No Internet connection", isError : true, isSuccess: false)
            return
        }
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc =  storyboard.instantiateViewController(withIdentifier: "AstroSignInViewControllerID") as! AstroSignInViewController
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    func createActivityIndicatorInButton(favouriteBtn : UIImageView) -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.lightGray
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        favouriteBtn.addSubview(activityIndicator)
        let xCenterConstraint = NSLayoutConstraint(item: favouriteBtn, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
        favouriteBtn.addConstraint(xCenterConstraint)
        
        let yCenterConstraint = NSLayoutConstraint(item: favouriteBtn, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
        favouriteBtn.addConstraint(yCenterConstraint)
        return activityIndicator
    }
    
}

extension AstroChannelsListViewController: MarkChannelFavDelegate{
    
    
    func markSelectedChannelFav() {
        self.showInAppNotification(title:"Logged in as \(String(describing: Utils.getUsername()!))", isError : false, isSuccess: true)
        
        if (selectedIndexPath != nil){
            if searchActive{
                self.createUserWithFavChannel(channelObj: filteredChannelsListArray[(selectedIndexPath?.row)!])
            }else{
                self.createUserWithFavChannel(channelObj: channelsListArray[(selectedIndexPath?.row)!])
            }
        }else{
            self.createUserWithFavChannel(channelObj: nil)
        }
        
        
    }
    
    func clearSelectedIndexPath() {
        selectedIndexPath = nil
    }
    
}
