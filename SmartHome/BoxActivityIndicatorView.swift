//
//  BoxActivityIndicatorView.swift
//  SmartHome
//
//  Created by Ritam Sarmah on 12/2/17.
//  Copyright © 2017 Bluetooth is OK. All rights reserved.
//

import UIKit

class BoxActivityIndicatorView: UIActivityIndicatorView {
    
    var disablesInteraction: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 10
        self.backgroundColor = UIColor(white: 0.3, alpha: 0.8)
        self.hidesWhenStopped = true
        self.activityIndicatorViewStyle = .whiteLarge
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    override func startAnimating() {
        super.startAnimating()
        if disablesInteraction {
            UIApplication.shared.beginIgnoringInteractionEvents()
        }
    }
    
    override func stopAnimating() {
        super.stopAnimating()
        if (disablesInteraction && UIApplication.shared.isIgnoringInteractionEvents) {
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
}
