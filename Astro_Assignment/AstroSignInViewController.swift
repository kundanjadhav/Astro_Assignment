//
//  AstroSignInViewController.swift
//  Astro_Assignment
//
//  Created by Kundan Jadhav on 6/27/17.
//  Copyright © 2017 Kundan. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FacebookLogin
import GoogleSignIn

protocol MarkChannelFavDelegate {
    func markSelectedChannelFav()
    func clearSelectedIndexPath()

}
class AstroSignInViewController: UIViewController, GIDSignInUIDelegate , GIDSignInDelegate {
    /**
     Called when the button was used to logout.
     
     - parameter loginButton: Button that was used to logout.
     */
    var dict : [String : AnyObject]!
    var delegate : MarkChannelFavDelegate? = nil
    @IBOutlet weak var signInButton: GIDSignInButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Google SharedInstance
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        signInButton.style = .wide
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onLoginWithGoogle(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    @IBAction func onLoginWithFacebook(_ sender: AnyObject) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions != nil {
                    if(fbloginresult.grantedPermissions.contains("email"))
                    {
                        self.getFBUserData()
                        
                    }
                }
            }
        }
    }
    
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    self.dict = result as! [String : AnyObject]
                    Utils.setUserLoginStatus(username : self.dict["email"] as? String ,loggedInWith: LoggedInWith.FACEBOOK)
                    
                    self.dismiss(animated: true, completion: {
                        self.delegate?.markSelectedChannelFav()
                    })
                }
            })
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            let email = user.profile.email
            Utils.setUserLoginStatus(username: email!, loggedInWith: LoggedInWith.GOOGLE)
            self.dismiss(animated: true, completion: {
                self.delegate?.markSelectedChannelFav()
            })        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }

    @IBAction func onCancelAction(_ sender: Any) {
        
        self.dismiss(animated: true, completion: {
        self.delegate?.clearSelectedIndexPath()
        })
    }
    
    
    
}
