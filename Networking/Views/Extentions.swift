//
//  Extentions.swift
//  Networking
//
//  Created by Adel Gainutdinov on 07.11.2021.
//

import UIKit

extension UIView {
    func addVerticalGradientLayer(topColor: UIColor, bottomColor: UIColor) {
        let gradient = CAGradientLayer()
        gradient.colors = [topColor.cgColor, bottomColor.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.frame = self.bounds
        self.layer.insertSublayer(gradient, at: 0)
    }
}

extension UIColor {
    
    convenience init? (hex: String, alpha: CGFloat = 1.0) {
        var clearString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (clearString.hasPrefix("#")) {
            clearString.remove(at: clearString.startIndex)
        }

        if ((clearString.count) != 6) {
            return nil
        }

        var rgbValue: UInt64 = 0
        Scanner(string: clearString).scanHexInt64(&rgbValue)

        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha
        )
        return
    }
}
