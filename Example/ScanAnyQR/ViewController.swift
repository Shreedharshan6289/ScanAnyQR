//
//  ViewController.swift
//  ScanAnyQR
//
//  Created by Shreedharshan on 09/09/2023.
//  Copyright (c) 2023 Shreedharshan. All rights reserved.
//

import UIKit
import ScanAnyQR

class ViewController: UIViewController {
    
    var capturedImageView = UIImageView()
    var qrLinkBtn = UIButton()
    
    var qrScreenshot = UIImage()
    var msgFromQr = String()
    
    var layoutDict = [String:Any]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        let c = ScannerVC()
        c.callback = {[unowned self]  img, msg in
            
            if let image = img {
                DispatchQueue.main.async {
                    print("IMG",image)
                    self.qrScreenshot = image
                    self.capturedImageView.image = self.qrScreenshot
    
                }
            }
           
            
            qrLinkBtn.isHidden = false
            msgFromQr = msg ?? ""
            qrLinkBtn.setTitle(msg, for: .normal)
            qrLinkBtn.addTarget(self, action: #selector(redirectToWeb(_ :)), for: .touchUpInside)
            
        }
        self.navigationController?.pushViewController(c, animated: true)
        
        
    }
    
    
    func setupViews() {
        
        self.view.backgroundColor = .white
    
//        capturedImageView.contentMode = .scaleAspectFit
        capturedImageView.layer.cornerRadius = 8
        layoutDict["capturedImageView"] = capturedImageView
        capturedImageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(capturedImageView)
        
        qrLinkBtn.isHidden = true
        qrLinkBtn.titleLabel?.numberOfLines = 0
        qrLinkBtn.titleLabel?.lineBreakMode = .byWordWrapping
        qrLinkBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        qrLinkBtn.setTitleColor(.white, for: .normal)
        qrLinkBtn.backgroundColor = .black.withAlphaComponent(0.4)
        qrLinkBtn.layer.cornerRadius = 8
        layoutDict["qrLinkBtn"] = qrLinkBtn
        qrLinkBtn.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(qrLinkBtn)
        
        
        capturedImageView.topAnchor.constraint(equalTo: self.view.topAnchor,constant: 20).isActive = true
        qrLinkBtn.bottomAnchor.constraint(equalTo: self.view.bottomAnchor,constant: -20).isActive = true
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[capturedImageView]-15-[qrLinkBtn]", metrics: nil, views: layoutDict))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[capturedImageView]-5-|", metrics: nil, views: layoutDict))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[qrLinkBtn]-15-|", metrics: nil, views: layoutDict))
        
    }

    @objc func redirectToWeb(_ gesture: UIButton) {
        
        if msgFromQr != "" {
            if msgFromQr.verifyUrl() {
                guard let url = URL(string: msgFromQr) else {
                    print("Url is not valid")
                    return //be safe
                }
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            } else {
                print("The app does not allow you to open this url")
            }
            
        }
    }
  

}

extension String {
    func verifyUrl () -> Bool {
        if let url = NSURL(string: self) {
            return UIApplication.shared.canOpenURL(url as URL)
        }
        return false
    }
}
