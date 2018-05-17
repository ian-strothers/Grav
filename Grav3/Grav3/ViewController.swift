//
//  GameViewController.swift
//  Grav
//
//  Created by ian on 7/14/15.
//  Copyright (c) 2015 ian. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit
//import GoogleMobileAds

class GameViewController: UIViewController, GKGameCenterControllerDelegate {
    //ad units
    //var bannerView: GADBannerView!
    //var interstitial: GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*bannerView = GADBannerView(frame: CGRectMake(0, 0, self.view.frame.width, 50))
        bannerView.adUnitID = "ca-app-pub-1141677718674456/7466429325"
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.loadRequest(GADRequest())
        self.view.addSubview(bannerView)
        
        interstitial = createInterstitial()*/
        
        authenticateLocalPlayer() //authenticate player and set gce and lbid vars
        Globals.soundOn = (UserDefaults.standard.object(forKey: "Mute") as? Bool) ?? true //get sound on from saved data

        let scene = MenuScene(size: CGSize(width: self.view.frame.width, height: self.view.frame.height))
        // Configure the view.
        let skView = self.view as! SKView
        //skView.showsFPS = true
        //skView.showsNodeCount = true
        //skView.showsDrawCount = true
            
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
            
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .resizeFill
            
        skView.presentScene(scene) //present the scene
    }
    
    override func awakeFromNib() { //recieve notifications
        NotificationCenter.default.addObserver(self, selector: #selector(showLeaderBoard), name: NSNotification.Name(rawValue: "ShowLeaderboard"), object: nil)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(hideAd), name: "HideAd", object: nil)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showAd), name: "ShowAd", object: nil)
        //NotificationCenter.defaultCenter().addObserver(self, selector: #selector(presentInterstitial), name: "PresentInterstitial", object: nil)
        //#selector is for using functions that take objective c selectors, just go with it for now
    }

    override var shouldAutorotate:Bool {
        return true
    }

    override var supportedInterfaceOrientations:UIInterfaceOrientationMask {
        return .allButUpsideDown
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden:Bool {
        return true
    }
    
    @objc func showLeaderBoard() {
        let gcViewController = GKGameCenterViewController()
        
        gcViewController.gameCenterDelegate = self
        gcViewController.viewState = .leaderboards
        gcViewController.leaderboardIdentifier = Globals.LBID
        
        self.present(gcViewController, animated: true) {
            let scene = MenuScene(size: CGSize(width: self.view.frame.width, height: self.view.frame.height))
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.showsDrawCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .resizeFill
            
            skView.presentScene(scene) //present the scene
        }
    }
    
    /*@objc func hideAd() {
        bannerView.hidden = true
    }*/
    
    /*@objc func showAd() {
        bannerView.hidden = false
    }*/
    
    /*@objc func presentInterstitial() {
        print("attempting to present")
        if interstitial.isReady {
            print("presenting")
            interstitial.presentFromRootViewController(self)
        }
    }*/
    
    //interstitials are one time use, create a new one after each display
    /*func createInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-1141677718674456/5989696122")
        interstitial.delegate = self
        
        let request = GADRequest()
        // Requests test ads on test devices.
        request.testDevices = ["2077ef9a63d2b398840261c8221a0c9b"]
        interstitial.loadRequest(request)
        
        return interstitial
    }*/
    
    func authenticateLocalPlayer() {
        let localPlayer = GKLocalPlayer.localPlayer() //create player object
        
        localPlayer.authenticateHandler = {(viewController: UIViewController?, error: Error?) in //create function to run on player authentication
            if let vc = viewController { //vc not nil means player isn't authenticated so let them sign in to game center
                self.present(vc, animated: true, completion: nil)
                print("not AUT")
            } else {
                if localPlayer.isAuthenticated { //if player is authenticated
                    Globals.gcEnabled = true //allow game center
                    
                    localPlayer.loadDefaultLeaderboardIdentifier{(leaderBoardIdentifier:String?, error: Error?) in //load the leaderboard
                        if let e = error { //if there's an error, log it
                            print("\(e.localizedDescription)")
                            print("not AUT 1")
                        } else { //otherwise get the leaderboard identifier
                            
                            Globals.LBID = leaderBoardIdentifier!
                            print("AUT")
                        }
                    }
                } else { //if player isn't authenticated at this point, can't use gamecenter
                    Globals.gcEnabled = false
                    print("not AUT 2")
                }
            }
        }
    }
    
    //to conform to GKGameCenterControllerDelegate
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    //GADInterstitial func
    /*func interstitialDidDismissScreen(ad: GADInterstitial!) {
        interstitial = createInterstitial()
    }*/
}
