//
//  ViewController.swift
//  SwiftWebSocketTest
//
//  Created by Thành Lã on 9/17/18.
//  Copyright © 2018 MonstarLab. All rights reserved.
//

import UIKit
import SwiftWebSocket
import SocketRocket

class ViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    
    var messageNum: Int = 0
    
    var webSocket: WebSocket!
    var rocket: SRWebSocket!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initWebSocket()
//        initSocketRocket()
    }
    
    fileprivate func initSocketRocket() {
        rocket = SRWebSocket(url: URL(string: "wss://echo.websocket.org"))
        rocket.delegate = self
    }
    
    fileprivate func initWebSocket() {
        webSocket = WebSocket("wss://echo.websocket.org")
        
        webSocket.event.open = {
            self.socketOpened()
        }
        webSocket.event.close = { code, reason, clean in
            self.socketClosed()
        }
        webSocket.event.error = { error in
            self.socketError(error)
        }
        webSocket.event.message = { message in
            self.socketRecieved(message)
        }
    }
    
    fileprivate func socketRecieved(_ message: Any) {
        if let recvText = message as? String {
            print("recv: \(recvText)")
            if let text = self.textView.text {
                self.textView.text = text + "\n" + recvText
            }
        }
    }
    
    fileprivate func socketOpened() {
        print("Opened")
        if let text = self.textView.text {
            self.textView.text = text + "\nOpened"
        }
    }
    
    fileprivate func socketClosed() {
        print("Close")
        if let text = self.textView.text {
            self.textView.text = text + "\nClosed"
        }
    }
    
    fileprivate func socketError(_ error: Error) {
        print("error \(error.localizedDescription)")
        if let text = self.textView.text {
            self.textView.text = text + "\nError"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func connect(_ sender: UIButton) {
        webSocket.open()
//        rocket.open()
    }
    
    @IBAction func disconnect(_ sender: UIButton) {
        webSocket.close()
//        rocket.close()
    }
    
    @IBAction func send(_ sender: UIButton) {
        let msg = Date().debugDescription
        print("send: \(msg)")
        webSocket.send(msg)
//        rocket.send(msg)
    }
}

extension ViewController: SRWebSocketDelegate {
    
    func webSocketDidOpen(_ webSocket: SRWebSocket!) {
        print(webSocket.url)
        socketOpened()
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        socketClosed()
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didFailWithError error: Error!) {
        socketError(error)
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!) {
        socketRecieved(message)
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didReceivePong pongPayload: Data!) {
        
    }
}
