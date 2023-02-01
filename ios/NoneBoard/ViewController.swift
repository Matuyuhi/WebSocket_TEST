//
//  ViewController.swift
//  NoneBoard
//
//  Created by yuhi y on 2022/11/29.
//

import UIKit
import Foundation
import UserNotifications

class ViewController: UIViewController {
    var webSocketTask: URLSessionWebSocketTask?

    let titleLabel: UILabel = {
        let view = UILabel.init()
        view.text = "Hello World!"
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
        return view
    }()
    let sendfield: UITextField = {
        let field = UITextField.init()
        field.frame = .init(x: 100, y: 620, width: 200, height: 40)
        field.layer.cornerRadius = 5
        field.leftView = UIView(frame: .init(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.placeholder = "入力"
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.black.cgColor
        return field
    }()
    
    let button: UIButton = {
        let view = UIButton.init()
        view.backgroundColor = UIColor.blue
        view.setTitle("This is button", for:UIControl.State.normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(tapButton(_:)), for: UIControl.Event.touchUpInside)
        return view
    }()
    
    func setupPos() {
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 300),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            button.widthAnchor.constraint(equalToConstant: 160.0),
            button.heightAnchor.constraint(equalToConstant: 40.0)
        ])
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        self.view.addSubview(button)
        self.view.addSubview(sendfield)
        self.view.addSubview(titleLabel)
        setupPos()
        
        connect()
        
    
    }
    // tapButton
    @objc func tapButton(_ sender: UIButton) {
        print("ボタンがタップされました。")
        sendMessage(for: "Hello from iosApp")
        
        
    }
    
    
    // MARK: - Connection
    private var textdata: String?
    
    func connect() { // 2
        let url = URL(string: "ws://localhost:8000/")! // 3
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.resume()
        receiveMessage()
    }
    func receiveMessage() {
        webSocketTask?.receive { result in
            switch result {
                case .failure(let error):
                    print("Failed to receive message: \(error)")
                case .success(let ms):
                    switch ms {
                        case .string(let text):
                        DispatchQueue.main.async {
                            if let oldtext = self.titleLabel.text {
                                self.titleLabel.text = oldtext + "\n\(text)"
                            }
                           
                        }
                            
                            
                            print("Received text message: \(text)")
                        case .data(let data):
                            print("Received binary message: \(data)")
                        @unknown default:
                            fatalError()
                    }
                    self.receiveMessage()  // <- 継続して受信するために再帰的に呼び出す
            }
        }
    }
    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
    }
    func sendMessage(for text:String) {
        if let text = sendfield.text {
            if(text==""){return}
            let message = URLSessionWebSocketTask.Message.string(text)
            webSocketTask?.send(message) { error in
                if let error = error {
                    print("WebSocket sending error: \(error)")
                }
            }
            sendfield.text = ""
        }
        
    }
    
    
}
