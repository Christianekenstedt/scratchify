//
//  ScratchImageView.swift
//  Scratchify-GoogleMaps
//
//  Created by Christian Ekenstedt on 2016-12-13.
//  Copyright © 2016 Christian Ekenstedt. All rights reserved.
//

import UIKit

/*
 *  Custom UIImageView that makes it possible to erase from one point to another.
 */

class ScratchImageView : UIImageView {
    // Properties
    private var previousPoint : CGPoint?
    var lineShape : CGLineCap = .round
    var lineWidth : CGFloat = 10.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /*
     *  Erase function. From point, to point.
     */
    func erase(from point: CGPoint, toPoint : CGPoint){
        UIGraphicsBeginImageContext(self.frame.size)
        
        image?.draw(in: self.bounds)
        
        let path = CGMutablePath()
        path.move(to: point)
        path.addLine(to: toPoint)
        
        let context = UIGraphicsGetCurrentContext()!
        context.setShouldAntialias(true)
        context.setLineCap(lineShape)
        context.setLineWidth(lineWidth)
        context.setBlendMode(.clear)
        context.addPath(path)
        context.setAlpha(0)
        context.strokePath()
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
    }
}
