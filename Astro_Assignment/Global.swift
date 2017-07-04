//
//  Global.swift
//  Astro_Assignment
//
//  Created by Kundan on 6/11/17.
//  Copyright © 2017 Kundan. All rights reserved.
//

import Foundation

func BASE_URL() -> String{
    return "http://ams-api.astro.com.my/"
}

let FAVOURITE_LIST = "FAVOURITE_CHANNELS_LIST"
let SORT_PREFERENCE = "SORT_PREFERENCE"
let LOGGED_IN_WITH = "LOGGED_IN_WITH"
let DECENDING_SORT = "DECENDING_SORT"
let LOGGED_IN_USER = "LOGGED_IN_USER"
let IS_USER_DETAILS_AVAILABLE = "IS_USER_DETAILS_AVAILABLE"

enum LoggedInWith : Int {
    case NONE = 0, FACEBOOK, GOOGLE
}

enum SortPreference : Int {
    case NONE = 0, CHNAME, CHNUMBER, FAVOURITE
}
