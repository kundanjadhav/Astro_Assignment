//
//  AstroChannelsListViewController+Communication.swift
//  Astro_Assignment
//
//  Created by Kundan Jadhav on 7/3/17.
//  Copyright © 2017 Kundan. All rights reserved.
//

import Foundation
import Alamofire

extension AstroChannelsListViewController{
    
    func getChannelsList(){
        
        if !reachability.isReachable{
            self.showInAppNotification(title:"No Internet connection", isError : true, isSuccess: false)
            return
        }
        startAnimating()
        Alamofire.request(Router.channelsList()).responseJSON { response in
            self.stopAnimating()
            switch (response.result) {
            case .success(let success):
                if response.result.value != nil {
                    
                    let response = success as! NSDictionary
                    let getResponseParser:ResponseParser! = ResponseParser()
                    self.channelsListArray = getResponseParser.parseChannelDetails(response)
                    self.getUserPreferenceAndLoadData()
                }
            case .failure(let error):
                
                let alert = UIAlertController(title:"Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in
                    // perhaps use action.title here
                })
                self.present(alert, animated: true)
                
            }
        }
        
    }
    
    //Mark : API's to CRUD User Preferences in cloud // currently on EC2 instance
    
    func createUserWithFavChannel(channelObj : ChannelDetails?){
        var channelDetails : [[String : Any]] = []
        if (channelObj != nil){
            channelDetails = [["id":channelObj?.channelId!,"name":channelObj?.channelName!]]
            
        }else{
            channelDetails = []
        }
        let params = [
            "username" : Utils.getUsername()!,
            "channels" : channelDetails,
            "sort" : ["name" : Utils.getSortPreference().rawValue, "sortorder" : Utils.getDecendingSortPreference()],
            
            ] as [String : Any]
        if !reachability.isReachable{
            self.showInAppNotification(title:"No Internet connection", isError : true, isSuccess: false)
            return
        }
        startAnimating()
        Alamofire.request(Router.createUser(parameters: params)
            ).responseString { response in
                self.stopAnimating()
                switch (response.result) {
                case .success(let success):
                    if response.response != nil{
                        
                        if let JSON = response.result.value {
                            if JSON == "User Couldn't be created Successfully!"{  // User already created on sever  // temporary handled so it can be improved in future
                                if (self.selectedIndexPath != nil){
                                    self.addFavouriteChannel(channelObj: channelObj!, favouriteBtn: self.favBtn!)
                                    
                                }else{
                                    self.getUserDetails()
                                }
                                
                            }else{
                                
                                print("User ceated successfully")
                                if (self.selectedIndexPath != nil){
                                    if self.searchActive{
                                        if self.favBtn?.image == UIImage(named:"unfavourite_icon"){
                                            self.filteredChannelsListArray[(self.selectedIndexPath?.row)!].isChannelFav! = true
                                            self.favBtn?.image = UIImage(named:"favourite_Icon")
                                            
                                        }else{
                                            self.filteredChannelsListArray[(self.selectedIndexPath?.row)!].isChannelFav! = false
                                            self.favBtn?.image = UIImage(named:"unfavourite_icon")
                                        }
                                        Utils.setFavouriteList(ChNumber: self.filteredChannelsListArray[(self.selectedIndexPath?.row)!].channelId!)
                                    }
                                    else{
                                        if self.favBtn?.image == UIImage(named:"unfavourite_icon"){
                                            self.channelsListArray[(self.selectedIndexPath?.row)!].isChannelFav! = true
                                            self.favBtn?.image = UIImage(named:"favourite_Icon")
                                            
                                        }else{
                                            self.channelsListArray[(self.selectedIndexPath?.row)!].isChannelFav! = false
                                            self.favBtn?.image = UIImage(named:"unfavourite_icon")
                                        }
                                        Utils.setFavouriteList(ChNumber: self.channelsListArray[(self.selectedIndexPath?.row)!].channelId!)
                                    }
                                    
                                    
                                }else{
                                    print("New user created or unable to show option list because index path is invalid")
                                }
                                
                            }
                            
                            
                        }
                    }
                case .failure(let error):
                    let alert = UIAlertController(title:"Error", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in
                        // perhaps use action.title here
                    })
                    self.present(alert, animated: true)
                }
                
                
        }
    }
    
    func addFavouriteChannel(channelObj : ChannelDetails,favouriteBtn : UIImageView){
        let channelDetails = [["id":"\(channelObj.channelId!)","name":channelObj.channelName!]]
        if !reachability.isReachable{
            self.showInAppNotification(title:"No Internet connection", isError : true, isSuccess: false)
            return
        }
        favouriteBtn.image = nil
        let activity = self.createActivityIndicatorInButton(favouriteBtn: favouriteBtn)
        activity.startAnimating()
        Alamofire.request(Router.addChannelAsFavourite(username: Utils.getUsername()!, channelsList: channelDetails)).responseString { response in
            activity.stopAnimating()
            
            
            switch (response.result) {
            case .success(let success):
                if response.response != nil{
                    
                    if let JSON = response.result.value {
                        print("ADD CHANNEL JSON: \(JSON)")
                        
                        if self.searchActive{
                            //                            self.filteredChannelsListArray[(indexPath.row)].isChannelFav! = true
                            //                            favouriteBtn.image = UIImage(named:"favourite_Icon")
                            //                            let index = self.channelsListArray.index(where: { (item) -> Bool in
                            //                                item.channelId! == self.filteredChannelsListArray[(indexPath.row)].channelId!
                            //                            })
                            //                            self.channelsListArray[index!] = self.filteredChannelsListArray[(indexPath.row)]
                            //                            Utils.setFavouriteList(ChNumber: self.filteredChannelsListArray[(indexPath.row)].channelId!, isFav: false)
                            
                            
                            
                            
                            let indexChannelArr = self.channelsListArray.index(where: { (item) -> Bool in
                                item.channelId! == channelObj.channelId
                            })
                            self.channelsListArray[indexChannelArr!].isChannelFav = true
                            
                            let indexFilterArr = self.filteredChannelsListArray.index(where: { (item) -> Bool in
                                item.channelId! == channelObj.channelId
                            })
                            self.filteredChannelsListArray[indexFilterArr!].isChannelFav! = true
                            favouriteBtn.image = UIImage(named:"favourite_Icon")
                            Utils.setFavouriteList(ChNumber: channelObj.channelId!)
                            
                            
                        }
                        else{
                            //                            self.channelsListArray[(indexPath.row)].isChannelFav! = true
                            //                            favouriteBtn.image = UIImage(named:"favourite_Icon")
                            //                            Utils.setFavouriteList(ChNumber: self.channelsListArray[(indexPath.row)].channelId!, isFav: false)
                            
                            let indexChannelArr = self.channelsListArray.index(where: { (item) -> Bool in
                                item.channelId! == channelObj.channelId
                            })
                            self.channelsListArray[indexChannelArr!].isChannelFav! = true
                            favouriteBtn.image = UIImage(named:"favourite_Icon")
                            Utils.setFavouriteList(ChNumber: channelObj.channelId!)
                        }
                    }
                    if !Utils.isUserDetailsAvailable(){
                        self.getUserDetails()
                    }
                    
                    self.showInAppNotification(title:"\(channelObj.channelName!) marked favourite", isError : false, isSuccess: true)
                }
            case .failure(let error):
                let alert = UIAlertController(title:"Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in
                    // perhaps use action.title here
                })
                self.present(alert, animated: true)
            }
        }
    }
    
    func removeFavouriteChannel(channelObj : ChannelDetails,favouriteBtn : UIImageView){
        let channelDetails = [["id":"\(channelObj.channelId!)","name":channelObj.channelName!]]
        if !reachability.isReachable{
            self.showInAppNotification(title:"No Internet connection", isError : true, isSuccess: false)
            return
        }
        favouriteBtn.image = nil
        let activity = self.createActivityIndicatorInButton(favouriteBtn: favouriteBtn)
        activity.startAnimating()
        Alamofire.request(Router.removeChannelAsFavourite(username: Utils.getUsername()!, channelsList: channelDetails)).responseString { response in
            activity.stopAnimating()
            switch (response.result) {
            case .success(let success):
                if response.response != nil{
                    
                    if let JSON = response.result.value {
                        print("REMOVE CHANNEL JSON: \(JSON)")
                        if self.searchActive{
                            
                            let indexChannelArr = self.channelsListArray.index(where: { (item) -> Bool in
                                item.channelId! == channelObj.channelId
                            })
                            self.channelsListArray[indexChannelArr!].isChannelFav = false
                            
                            
                            let indexFilterArr = self.filteredChannelsListArray.index(where: { (item) -> Bool in
                                item.channelId! == channelObj.channelId
                            })
                            
                            self.filteredChannelsListArray[indexFilterArr!].isChannelFav! = false
                            favouriteBtn.image = UIImage(named:"unfavourite_icon")
                            Utils.setFavouriteList(ChNumber: channelObj.channelId!)
                        }
                        else{
                            
                            let indexChannelArr = self.channelsListArray.index(where: { (item) -> Bool in
                                item.channelId! == channelObj.channelId
                            })
                            self.channelsListArray[indexChannelArr!].isChannelFav! = false
                            favouriteBtn.image = UIImage(named:"unfavourite_icon")
                            Utils.setFavouriteList(ChNumber: channelObj.channelId!)
                            
                        }
                    }
                    self.showInAppNotification(title:"\(channelObj.channelName!) removed from favourite", isError : false, isSuccess: false)
                    
                }
            case .failure(let error):
                let alert = UIAlertController(title:"Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in
                    // perhaps use action.title here
                })
                self.present(alert, animated: true)
            }
            
        }
    }
    
    func getUserDetails(){
        if !reachability.isReachable{
            self.showInAppNotification(title:"No Internet connection", isError : true, isSuccess: false)
            return
        }
        startAnimating()
        
        Alamofire.request(Router.getUserPreferences(username:Utils.getUsername()!)).responseString { response in
            if response.response != nil{
                self.stopAnimating()
                switch (response.result) {
                case .success(let success):
                    if let JSON = response.result.value {
                        print("DETAILS JSON: \(JSON)")
                        let getResponseParser:ResponseParser! = ResponseParser()
                        getResponseParser.parseUserDetails(JSON)
                        self.setFavouriteChannelsList()
                        self.getUserPreferenceAndLoadData()
                        let indexPath = IndexPath(row: 0 , section: 0)
                        self.channelListTableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
                        Utils.setUserDetailsAvailable(isAvailable: true)
                    }
                    
                case .failure(let error):
                    let alert = UIAlertController(title:"Error", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in
                        // perhaps use action.title here
                    })
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    
    //update user preferences
    func updateUserPreferences(){
        let sortPreference = ["name": Utils.getSortPreference().rawValue,"sortorder":Utils.getDecendingSortPreference()] as [String : Any]
        if !reachability.isReachable{
            self.showInAppNotification(title:"No Internet connection", isError : true, isSuccess: false)
            return
        }
        
        // activity.startAnimating()
        Alamofire.request(Router.updateUserPreferences(username: Utils.getUsername()!, sortPreference: sortPreference)).responseString { response in
            //  activity.stopAnimating()
            switch (response.result) {
            case .success(let success):
                if response.response != nil{
                    
                    if let JSON = response.result.value {
                        print("SORT PREFERENCE JSON: \(JSON)")
                    }
                }
            case .failure(let error):
                let alert = UIAlertController(title:"Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default) { action in
                    // perhaps use action.title here
                })
                self.present(alert, animated: true)
            }
            
        }
    }
    
    
}
