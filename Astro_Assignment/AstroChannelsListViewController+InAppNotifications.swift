//
//  AstroChannelsListViewController+InAppNotifications.swift
//  Astro_Assignment
//
//  Created by Kundan on 7/2/17.
//  Copyright © 2017 Kundan. All rights reserved.
//

import Foundation
import SwiftMessages
import ReachabilitySwift


extension AstroChannelsListViewController {
    
    func showInAppNotification(title : String , isError : Bool , isSuccess : Bool){
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .viewController(self)
        config.duration = .seconds(seconds: 1)
        config.presentationStyle = .top
        config.dimMode = .none
        if isError{
            SwiftMessages.show(config: config, view: self.showSwiftMessageForError(message: title))
        }else if isSuccess{
            SwiftMessages.show(config: config, view: self.showSwiftMessageForSuccess(message: title))
        }else{
            SwiftMessages.show(config: config, view: self.showSwiftMessage(message: title))

        }
        
    }
    
    func setupReachability()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification,object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    
    
    func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        if reachability.isReachable {
            if reachability.isReachableViaWiFi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        } else {
            print("Network not reachable")
        }
    }
    
     func showSwiftMessage(message : String) -> MessageView {
        let view = MessageView.viewFromNib(layout: .StatusLine)
        // Theme message elements with the warning style.
        view.configureTheme(backgroundColor: UIColor.orange, foregroundColor: UIColor.white)
        // Add a drop shadow.
        view.configureDropShadow()
        
        view.configureContent(body: message)
        return view
    }
     func showSwiftMessageForSuccess(message : String) -> MessageView {
        let view = MessageView.viewFromNib(layout: .StatusLine)
        // Theme message elements with the warning style.
        view.configureTheme(backgroundColor: UIColor.blue, foregroundColor: UIColor.white)
        // Add a drop shadow.
        view.configureDropShadow()
        
        view.configureContent(body: message)
        return view
    }
     func showSwiftMessageForError(message : String) -> MessageView {
        let view = MessageView.viewFromNib(layout: .StatusLine)
        // Theme message elements with the warning style.
        view.configureTheme(backgroundColor: UIColor.red, foregroundColor: UIColor.white)
        // Add a drop shadow.
        view.configureDropShadow()
        
        view.configureContent(body: message)
        return view
    }
}
