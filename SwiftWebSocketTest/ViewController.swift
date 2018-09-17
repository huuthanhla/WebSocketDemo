//
//  ViewController.swift
//  SwiftWebSocketTest
//
//  Created by Thành Lã on 9/17/18.
//  Copyright © 2018 MonstarLab. All rights reserved.
//

import UIKit
import SwiftWebSocket

class ViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    
    var messageNum: Int = 0
    
    var ws: WebSocket!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ws = WebSocket("wss://echo.websocket.org")
        
        ws.event.open = {
            print("opened")
            if let text = self.textView.text {
                self.textView.text = text + "\nOpened"
            }
        }
        ws.event.close = { code, reason, clean in
            print("close")
            if let text = self.textView.text {
                self.textView.text = text + "\nClosed"
            }
        }
        ws.event.error = { error in
            print("error \(error)")
            if let text = self.textView.text {
                self.textView.text = text + "\nError"
            }
        }
        ws.event.message = { message in
            if let recvText = message as? String {
                print("recv: \(recvText)")
                if let text = self.textView.text {
                    self.textView.text = text + "\n" + recvText
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func connect(_ sender: UIButton) {
        ws.open()
    }
    
    @IBAction func disconnect(_ sender: UIButton) {
        ws.close()
    }
    
    @IBAction func send(_ sender: UIButton) {
        let msg = Date().debugDescription
        print("send: \(msg)")
        ws.send(msg)
    }
}

