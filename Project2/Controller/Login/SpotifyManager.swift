//
//  LoginManager.swift
//  Project2
//
//  Created by 尚靖 on 2018/5/7.
//  Copyright © 2018年 尚靖. All rights reserved.
//

import Foundation

class SpotifyManager: UIViewController {

    static let shared = SpotifyManager()

    weak var delegate = UIApplication.shared.delegate as? AppDelegate

    var auth = SPTAuth.defaultInstance()!
    var authViewController = UIViewController()
    var player: SPTAudioStreamingController?
    var session: SPTSession!
    let clientID = "d030ac4b117b47ec835c425d436cb5c0"
    let redirectURL = "project2://callback"

    var recordInfo: RecordInfo?

    func setup() {
        self.auth = SPTAuth.defaultInstance()
        self.player = SPTAudioStreamingController.sharedInstance()
        self.auth.clientID = clientID
        self.auth.redirectURL = URL(string: redirectURL)!
        self.auth.sessionUserDefaultsKey = "current session"
        self.auth.requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistModifyPrivateScope, SPTAuthUserReadPrivateScope]
        self.player?.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(updateAfterLogin), name: .loginSuccessfull, object: nil)
    }

    func startAuthenticationFlow() {
//        if self.auth.session != nil {
            if self.auth.session.isValid() {
                self.player?.login(withAccessToken: self.auth.session.accessToken)
                delegate?.window?.rootViewController? = UIStoryboard.mainStoryboard().instantiateInitialViewController()!
//            }
        } else {
            let authURL: URL? = self.auth.spotifyWebAuthenticationURL()
            self.authViewController = SFSafariViewController.init(url: authURL!)
            delegate?.window?.rootViewController?.present(self.authViewController,
                                                         animated: true,
                                                         completion: nil)
        }
    }

    @objc func updateAfterLogin() {
        let userDefaults = UserDefaults.standard

        if let sessionObj: AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
            let sessionDataObj = sessionObj as? Data
            let firstTimesession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj!) as? SPTSession
            self.session = firstTimesession
            initializePlayer(authSession: session!)
            print(self.auth.session.accessToken)
        }
    }

    func initializePlayer(authSession: SPTSession) {
        self.player = SPTAudioStreamingController.sharedInstance()
        self.player!.playbackDelegate = self
        self.player!.delegate = self
        try? player!.start(withClientId: auth.clientID)
        self.player!.login(withAccessToken: authSession.accessToken)
    }

    func playMusic() {
        self.player?.playSpotifyURI("spotify:track:3V9SgblMQCt5LyepDyHyEV", startingWith: 0, startingWithPosition: 0, callback: { (_) in
        })
    }

    func playMusic2() {
        self.player?.playSpotifyURI("spotify:track:4dyx5SzxPPaD8xQIid5Wjj", startingWith: 0, startingWithPosition: 0, callback: { (_) in
        })
    }

    
    //move to a new file (get spttrack series)
    func getTrackInfo() {

//        var albumCover: URL?
//        var artist: String?
//        var trackName: String?

        SPTTrack.track(withURI: URL(string: "spotify:track:7plGWSHjz9qz2DMkZLZm2D"), accessToken: auth.session.accessToken, market: nil) { (error, response) in
            if response != nil {
                if let track = response as? SPTTrack, let trackArtist = track.artists as? [SPTPartialArtist] {
                    print(trackArtist)
                    print("---------------------^^")
                    let name = trackArtist[0].name
                    let title = track.name
                    print(title!)
                    print(name!)

                    self.recordInfo = RecordInfo(albumCover: nil, artist: name!, trackName: title!)
                }
            } else {
                print(error)
            }
        }

        SPTAlbum.album(withURI: URL(string: "spotify:album:2UQpIR7LhOlWecHpN494O5"), accessToken: auth.session.accessToken, market: nil, callback: { (error, success) in
            if success != nil {
                if let album = success as? SPTPartialAlbum {
                    print("================")
                    print(album.largestCover.imageURL!)
                    let cover = album.largestCover.imageURL

                }
            } else {
                print(error)
            }
        })

    }
}

extension SpotifyManager: SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {

    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate?.window?.rootViewController = UIStoryboard.mainStoryboard().instantiateInitialViewController()
    }

    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: String!) {
        NotificationCenter.default.post(name: .startPlayingTrack, object: nil)
    }

}
