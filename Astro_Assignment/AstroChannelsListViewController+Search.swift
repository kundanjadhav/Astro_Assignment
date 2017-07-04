//
//  AstroChannelsListViewController+Search.swift
//  Astro_Assignment
//
//  Created by Kundan Jadhav on 6/30/17.
//  Copyright © 2017 Kundan. All rights reserved.
//

import Foundation
// Mark : Search delegates
extension AstroChannelsListViewController : UISearchBarDelegate{
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        UIView.animate(withDuration: 0.3, animations: {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            
            self.channelListTableView?.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        }, completion: nil)
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchActive = false;
        searchBar.showsCancelButton = false
        searchBar.text = ""
        UIView.animate(withDuration: 0.3, animations: {
            
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            searchBar.resignFirstResponder()
            
            
        }, completion: nil)
        if Utils.getSortPreference() == SortPreference.FAVOURITE{
            self.sortByFavChannel()
        }else{
            self.channelListTableView?.reloadData()
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //MZDownloadManager.sharedInstance.searchActive = false;
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredChannelsListArray.removeAll()
        if searchText.characters.count > 0{
            self.searchActive = true;
            for obj in channelsListArray{              /// better solution to search by channel name and channel number
                if obj.channelName?.lowercased().range(of:searchText.lowercased()) != nil || obj.channelNumber?.lowercased().range(of:searchText.lowercased()) != nil{
                    filteredChannelsListArray.append(obj)
                }
            }
            
//            filteredChannelsListArray = channelsListArray.filter({ (channelDetails) -> Bool in
//                let searchbyName: NSString = channelDetails.channelName! as NSString
//                let byNumber: NSString = channelDetails.channelNumber! as NSString
//
//                let range = searchbyName.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
//                
//                searchbyName.contains(searchText)
//                return range.location != NSNotFound
//            })
            
            self.channelListTableView?.reloadData()
        }else{
            if Utils.getSortPreference() == SortPreference.FAVOURITE{
                self.sortByFavChannel()
            }else{
                self.searchActive = false;
                self.channelListTableView?.reloadData()
            }
        }
        
        
    }
}
