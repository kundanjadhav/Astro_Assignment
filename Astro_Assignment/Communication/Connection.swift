//
//  Connection.swift
//  Astro_Assignment
//
//  Created by Kundan on 6/11/17.
//  Copyright © 2017 Kundan. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


enum Router: URLRequestConvertible {
    case channelsList()
    case createUser(parameters: Parameters)
    case getUserPreferences(username: String)
    case addChannelAsFavourite(username : String, channelsList: [[String: String]])
    case removeChannelAsFavourite(username : String, channelsList: [[String: String]])
    case updateUserPreferences(username : String, sortPreference: [String: Any])

    static let baseURLString = BASE_URL()
    
    var method: HTTPMethod {
        switch self {
        case .channelsList:
            return .get
        case .createUser:
            return .post
        case .getUserPreferences:
            return .get
        case .addChannelAsFavourite:
            return .post
        case .removeChannelAsFavourite:
            return .post
        case .updateUserPreferences:
            return .post


        }
    }
    
    var path: String {
        switch self {
        case .channelsList():
            return "\(BASE_URL())ams/v3/getChannels"
        case .createUser(let parameters):
            return "http://ec2-54-186-242-53.us-west-2.compute.amazonaws.com:8080/astro/user/create"
        case .getUserPreferences(let username):
            return "http://ec2-54-186-242-53.us-west-2.compute.amazonaws.com:8080/astro/user?username=\(username)"
        case .addChannelAsFavourite(let username, _):
            return "http://ec2-54-186-242-53.us-west-2.compute.amazonaws.com:8080/astro/user/channel/add?username=\(username)"
        case .removeChannelAsFavourite(let username,_):
            return "http://ec2-54-186-242-53.us-west-2.compute.amazonaws.com:8080/astro/user/channel/remove?username=\(username)"
        case .updateUserPreferences(let username, _):
            return "http://ec2-54-186-242-53.us-west-2.compute.amazonaws.com:8080/astro/user/sortPref/add?username=\(username)"

        }
    }
    
    // MARK: URLRequestConvertible
    
    func asURLRequest() throws -> URLRequest {
        //let url = try Router.baseURLString.asURL()
        
        var urlRequest = URLRequest(url: URL.init(string: path)!)
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        switch self {
        case .channelsList():
            urlRequest = try URLEncoding.default.encode(urlRequest, with: nil)
        case .createUser(let parameters):
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                // No-op
            }            
        case .getUserPreferences(_):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: nil)
        case .addChannelAsFavourite(_, let channelsList):
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: channelsList, options: [])
            } catch(let error) {
                print("Invalid data \(error.localizedDescription)")
            }
        case .removeChannelAsFavourite(_, let channelsList):
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: channelsList, options: [])
            } catch {
                print("Invalid data \(error.localizedDescription)")
            }
            
            urlRequest = try URLEncoding.default.encode(urlRequest, with: nil)
        case .updateUserPreferences(_, let sortPreference):
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: sortPreference, options: [])
            } catch(let error) {
                print("Invalid data \(error.localizedDescription)")
            }

        default:
            break
        }
        
        return urlRequest
    }
}



