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
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var disconnectButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    var reconnect: Bool = false
    
    var webSocket: WebSocket!
    
    var kgWebSocket: KGWebSocket!
    var factory: KGWebSocketFactory!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        initWebSocket()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appEnterToForceground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func appMovedToBackground() {
        print("App moved to background!")
        if kgWebSocket != nil, kgWebSocket.readyState() == KGReadyState_OPEN {
            kgWebSocket.close()
            reconnect = true
        } else {
            reconnect = false
        }
    }
    
    @objc func appEnterToForceground() {
        print("App Enter To Forceground!")
        
        if kgWebSocket != nil, kgWebSocket.readyState() == KGReadyState_OPEN {
            updateUIcomponents(isConnected: true)
        } else {
            if reconnect {
                createAndEstablishWebSocketConnection()
            }
        }
    }
    
    fileprivate func updateUIcomponents(isConnected: Bool) {
        self.disconnectButton.isEnabled = isConnected
        self.sendButton.isEnabled = isConnected
        self.connectButton.isEnabled = !isConnected
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func connect(_ sender: UIButton) {
//        webSocket.open()
        DispatchQueue.main.async {
            self.createAndEstablishWebSocketConnection()
        }
    }
    
    @IBAction func disconnect(_ sender: UIButton) {
//        webSocket.close()
        kgWebSocket.close()
    }
    
    @IBAction func clear(_ sender: UIButton) {
        textView.text = ""
    }
    
    @IBAction func send(_ sender: UIButton) {
        let msg = Date().debugDescription
        updateTextView(with: "SEND: [\(msg)]")
//        webSocket.send(msg)
        
        guard let socket = self.kgWebSocket, socket.readyState() == KGReadyState_OPEN else { return }
        
        DispatchQueue.global(qos: .default).async(execute: {
            socket.send(msg)
        })
    }
}

extension ViewController {
    fileprivate func createAndEstablishWebSocketConnection(url: String = "ws://echo.websocket.org") {
        factory = KGWebSocketFactory.create()
        guard let challengeHandler = createBasicChallengeHandler() else { return }
        factory.setDefaultChallengeHandler(challengeHandler)
        kgWebSocket = factory.createWebSocket(URL(string: url))
        
        updateTextView(with: "CONNECTING")
        setupKGWebSocketListeners()
        kgWebSocket.connect()
    }
    
    fileprivate func createBasicChallengeHandler() -> KGChallengeHandler? {
        let loginHandler = KGDemoLoginHandler()
        guard let challengeHandler = KGBasicChallengeHandler.create() as? KGBasicChallengeHandler else { return nil }
        challengeHandler.setLogin(loginHandler)
        return challengeHandler
    }
    
    fileprivate func setupKGWebSocketListeners() {
        kgWebSocket.didOpen = { webSocket in
            DispatchQueue.main.async {
                self.updateTextView(with: "CONNECTED")
                self.updateUIcomponents(isConnected: true)
            }
        }
        
        kgWebSocket.didReceiveMessage = { (webSocket, data) in
            DispatchQueue.main.async {
                self.updateTextView(with: "RECEIVED: [\(data!)]")
            }
        }
        
        kgWebSocket.didReceiveError = { (webSocket, error) in
            DispatchQueue.main.async {
                self.updateTextView(with: error!.localizedDescription)
            }
        }
        
        kgWebSocket.didClose = { (websocket, code, reason, wasClean) in
            DispatchQueue.main.async {
                self.updateTextView(with: "CLOSED \(code): REASON: \(reason ?? "")")
                self.updateUIcomponents(isConnected: false)
            }
        }
    }
    
    fileprivate func initWebSocket() {
        webSocket = WebSocket("wss://echo.websocket.org")
        
        webSocket.event.open = {
            self.updateTextView(with: "OPENED")
        }
        webSocket.event.close = { code, reason, clean in
            self.updateTextView(with: "CLOSED")
        }
        webSocket.event.error = { error in
            self.updateTextView(with: error.localizedDescription)
        }
        webSocket.event.message = { message in
            self.updateTextView(with: "RECEIVED: \(message)")
        }
    }
}

extension ViewController {
    func updateTextView(with str: String) {
        if let text = self.textView.text {
            self.textView.text = text + "\n" + str
        }
    }
}
