//
//  Helper.swift
//  Editing Tool
//
//  Created by Rajan Arora on 06/06/21.
//

import UIKit


class Helper {
    
    func setGradientColours(view : UIView) {
        
        //Colours
        let colors = [UIColor(displayP3Red: 72.0/255.0, green: 72.0/255.0, blue: 173.0/255.0, alpha: 1.0).cgColor,UIColor(displayP3Red: 60.0/255.0, green: 143.0/255.0, blue: 171.0/255.0, alpha: 1.0).cgColor]
        
        // Add Gradient Color
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func roundCorners(view : UIView) {
        view.layer.cornerRadius = view.bounds.size.height / 2.0
        view.clipsToBounds = true
    }
    
    func setGradientColoursAndRoundView(view : UIView) {
        roundCorners(view: view)
        setGradientColours(view: view)
    }
    
    func showAlert(viewController : UIViewController,title : String,message : String,style : UIAlertController.Style) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
        
    }
    
}
