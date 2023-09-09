//
//  ScannerView.swift
//  ScanAnyQR
//
//  Created by Shreedharshan on 07/09/23.
//

import UIKit
import AVFoundation

class ScannerView: UIView {
    
    var view = UIView()
    var cameraView = UIView()
    var headerLbl = UILabel()
    
    var layoutDict = [String:Any]()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(_ baseView: UIView) {
        
        layoutDict["view"] = view
        view.translatesAutoresizingMaskIntoConstraints = false
        baseView.addSubview(view)
        
        cameraView.backgroundColor = .green
        layoutDict["cameraView"] = cameraView
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cameraView)
        
        headerLbl.text = "Scan Any QR"
        headerLbl.textAlignment = .center
        headerLbl.font = UIFont.boldSystemFont(ofSize: 18)
        headerLbl.textColor = .black
        headerLbl.backgroundColor = .white
        headerLbl.layer.cornerRadius = 8
        headerLbl.clipsToBounds = true
        layoutDict["headerLbl"] = headerLbl
        headerLbl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerLbl)
        
        view.topAnchor.constraint(equalTo: baseView.safeAreaLayoutGuide.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: baseView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        baseView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", metrics: nil, views: layoutDict))
        
        cameraView.topAnchor.constraint(equalTo: view.topAnchor ).isActive = true
        cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[cameraView]|", metrics: nil, views: layoutDict))
        
        headerLbl.topAnchor.constraint(equalTo: baseView.safeAreaLayoutGuide.topAnchor,constant: 18).isActive = true
        headerLbl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[headerLbl]-15-|", metrics: nil, views: layoutDict))
        
    }
    
}
