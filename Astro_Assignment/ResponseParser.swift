//
//  GetEventsResponseParser.swift
//  Astro_Assignment
//
//  Created by Kundan on 6/13/17.
//  Copyright © 2017 Kundan. All rights reserved.
//

import Foundation
import SwiftyJSON

class ResponseParser {
    
    
    fileprivate let CHANNEL_ID = "channelId"
    fileprivate let PROGRAM_TITLE = "programmeTitle"
    fileprivate let PROGRAM_ID = "programmeId"
    fileprivate let EVENT_ID = "eventID"
    fileprivate let LIVE = "live"
    fileprivate let CHANNEL = "channel"
    fileprivate let GET_EVENT = "getevent"
    fileprivate let SUB_SYSTEM = "subSystem"
    fileprivate let VALUE = "value"
    fileprivate let CHANNEL_NAME = "channelName"
    fileprivate let CHANNEL_NUMBER = "channelStbNumber"
    fileprivate let CHANNEL_TITLE = "channelTitle"
    fileprivate let CHANNEL_EXT_REF = "channelExtRef"
    fileprivate let CHANNEL_DESC = "channelDescription"
    fileprivate let IMAGE_TYPE = "Pos_600x370 "
    fileprivate let USERNAME = "username"
    fileprivate let SORT = "sort"
    fileprivate let CHANNELS = "channels"
    fileprivate let NAME = "name"
    fileprivate let SORT_ORDER = "sortorder"
    fileprivate let CHANNELID = "id"
    
    var channelId : Int?
    var programmeTitle : String?
    var channelNumber : Int = 0
    var channelTitle : String?

    var channelName : String?
    var programmeId : Int?
    var eventID : Int?
    var live : Bool = false
    
      
    func parseChannelDetails(_ response:NSDictionary) -> [ChannelDetails] {
        let favChannelsList : [Int] = Utils.getFavouriteList()
        var channels : [ChannelDetails] = []
        var channelObj : ChannelDetails = ChannelDetails()
        for (key,value):(Any, Any) in response{
            
            if key as! String == CHANNEL{
                
                for val in value as! NSArray{
                    
                    for (_,_):(Any, Any) in val as! NSDictionary
                    {
                        for (key,value):(Any, Any) in val as! NSDictionary
                        {
                            switch(key as! String){
                                
                            case CHANNEL_ID:
                                channelObj.channelId = value as? Int
                                if favChannelsList.contains((value as? Int)!){
                                    channelObj.isChannelFav = true
                                }else{
                                    channelObj.isChannelFav = false
                                }
                                
                            case CHANNEL_TITLE:
                                channelObj.channelName = value as? String
                                
                            case CHANNEL_NUMBER:
                                channelObj.channelNumber = value as? String
                                
                            case CHANNEL_DESC:
                                channelObj.channelDescription = value as? String

                            case  CHANNEL_EXT_REF:
                                for value in value as! NSArray
                                {
                                    var subSystem : String?
                                    var imagUrl : String?

                                    for (key,value):(Any, Any) in value as! NSDictionary{
                                        
                                        
                                        switch(key as! String){

                                         case SUB_SYSTEM:
                                            subSystem = value as? String
                                            
                                        case VALUE:
                                            imagUrl = value as? String

                                        default:
                                            print("")
                                        }
                                    }
                                    if subSystem  == IMAGE_TYPE  {
                                        channelObj.channelImgURL = imagUrl
                                        break
                                    }
                                }
                            default:
                                print("")
                            }
                        }
                    }
                    
                    channels.append(channelObj)
                }
            }
        }
        return channels
    }
    
    
    
    func parseUserDetails(_ response:String) {
        var favouriteChannelsList : [Int] = []
        var sortBy : String?
        var sortOrder : String?
        var username : String?
        if let data = response.data(using: .utf8) {
            do {
                let p = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                for (key,value):(Any, Any) in p! as NSDictionary{
                    switch(key as! String){
                        
                    case USERNAME:
                        username = value as? String
                    case SORT:
                        for (key,value):(Any, Any) in value as! NSDictionary{
                            if key as! String == NAME{
                                sortBy = value as? String
                                
                            }
                            if key as! String == SORT_ORDER{
                                sortOrder = value as? String
                            }
                        }
                        
                    case CHANNELS:
                        for val in value as! NSArray{
                            
                            for (key,value):(Any, Any) in val as! NSDictionary{
                                if key as! String == CHANNELID{
                                    favouriteChannelsList.append(value as! Int)
                                }
                            }
                        }
                        
                    default:
                        print("")
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        print(favouriteChannelsList,sortOrder!,sortBy!,username!)
        Utils.setSortPreference(sortBy: SortPreference(rawValue: Int(sortBy!)!)!)
        Utils.setDecendingSortPreference(isDecendingSort: Bool(sortOrder!)!)
        Utils.setUsername(username: username!)
        Utils.setFavouriteListForUser(list: favouriteChannelsList)
    }
}
