//
//  GameViewController.swift
//  Project2
//
//  Created by 尚靖 on 2018/5/6.
//  Copyright © 2018年 尚靖. All rights reserved.
//

import Foundation

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        NotificationCenter.default.post(name: .loginSuccessfull, object: nil)
    }
    
    @IBAction func play(_ sender: Any) {
        LoginManager.shared.playMusic()
    }

}
