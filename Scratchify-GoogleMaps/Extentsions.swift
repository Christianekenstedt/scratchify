//
//  Extentsions.swift
//  Scratchify-GoogleMaps
//
//  Created by Christian Ekenstedt on 2017-01-08.
//  Copyright © 2017 Christian Ekenstedt. All rights reserved.
//

import Foundation
import UIKit

// LÅNAD EXTENSION! Need to fix.
public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
