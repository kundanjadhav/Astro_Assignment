//
//  Utils.swift
//  Astro_Assignment
//
//  Created by Kundan Jadhav on 6/23/17.
//  Copyright © 2017 Kundan. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import SwiftMessages

public class Utils : NSObject{
    
    static func getFavouriteList() -> [Int]{
        
        if let favChannels = UserDefaults.standard.object(forKey: FAVOURITE_LIST) as? [Int] {
            return favChannels
        }
        return []
    }
    
    static func setFavouriteList(ChNumber: Int){
        
        if var favChannels = UserDefaults.standard.object(forKey: FAVOURITE_LIST) as? [Int] {
            
            if favChannels.contains(ChNumber){
                
                favChannels.remove(at: favChannels.index(of: ChNumber)!)
            }else{
                favChannels.append(ChNumber)
            }
            
            UserDefaults.standard.set(favChannels, forKey: FAVOURITE_LIST)
        }else{
            UserDefaults.standard.set([ChNumber], forKey: FAVOURITE_LIST)
            
        }
    }
    
    static func setFavouriteListForUser(list : [Int]){
        self.clearUserPreferences()
        UserDefaults.standard.set(list, forKey: FAVOURITE_LIST)
    }
    
    static func setSortPreference(sortBy : SortPreference){
        UserDefaults.standard.set(sortBy.rawValue, forKey: SORT_PREFERENCE)
    }
    
    static func setDecendingSortPreference(isDecendingSort : Bool){
        UserDefaults.standard.set(isDecendingSort, forKey: DECENDING_SORT)
    }
    
    static func getDecendingSortPreference() -> Bool{
        if UserDefaults.standard.bool(forKey: DECENDING_SORT){
            return true
        }
            return false
    }
    
    static func getSortPreference() -> SortPreference{
        let loginStatus = UserDefaults.standard.integer(forKey: SORT_PREFERENCE)
        
        switch loginStatus {
        case 0:
            return SortPreference.NONE   // order by channel name
            
        case 1:
            return SortPreference.CHNAME   // order by channel name
            
        case 2:
            return SortPreference.CHNUMBER  // order by channel number
            
        case 3:
            return SortPreference.FAVOURITE  // order by favourite channel
            
        default:
            return SortPreference.NONE    // order by server response
        }
    }
    
    
    static func clearUserPreferences(){
        
        UserDefaults.standard.set([], forKey: FAVOURITE_LIST)
    }
    
    static func setUserLoginStatus(username: String? ,loggedInWith : LoggedInWith) {
        UserDefaults.standard.set(username, forKey: LOGGED_IN_USER)
        UserDefaults.standard.set(loggedInWith.rawValue, forKey: LOGGED_IN_WITH)
    }
    static func isUserLoggedIn() -> LoggedInWith{
        
        let loginStatus = UserDefaults.standard.integer(forKey: LOGGED_IN_WITH)
        
        switch loginStatus {
        case 0:
            return LoggedInWith.NONE
            
        case 1:
            return LoggedInWith.FACEBOOK
            
        case 2:
            return LoggedInWith.GOOGLE
            
        default:
            return LoggedInWith.NONE

        }
    }
    
    static func logoutUser() {
        if self.isUserLoggedIn() == LoggedInWith.FACEBOOK{
            FBSDKLoginManager().logOut()
        }else{
            GIDSignIn.sharedInstance().signOut()
        }
        self.setUserLoginStatus(username: nil ,loggedInWith: LoggedInWith.NONE)
        self.clearUserPreferences()
        
    }
    
    static func setUsername(username : String){
        UserDefaults.standard.set(username, forKey: LOGGED_IN_USER)
    }
    static func getUsername() -> String?{
        if let username = UserDefaults.standard.value(forKey: LOGGED_IN_USER){
            return username as? String
        }
        return nil
    }
    static func setUserDetailsAvailable(isAvailable : Bool) {
        UserDefaults.standard.set(isAvailable, forKey: IS_USER_DETAILS_AVAILABLE)
    }

    static func isUserDetailsAvailable() -> Bool {
         return UserDefaults.standard.bool(forKey: IS_USER_DETAILS_AVAILABLE)
    }

}
