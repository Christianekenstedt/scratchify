//
//  ScratchImageView.swift
//  Scratchify
//
//  Created by Christian Ekenstedt on 2016-12-13.
//  Copyright © 2016 Christian Ekenstedt. All rights reserved.
//

import UIKit

class ScratchImageView : UIImageView {
    // Properties
    private var previousPoint : CGPoint?
    var lineShape : CGLineCap = .round
    var lineWidth : CGFloat = 10.0
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else{
            print("No first touch?")
            return
        }
        previousPoint = touch.location(in: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let point = previousPoint else{
            print("Didn't detect move")
            return
        }
        let currentPoint = touch.location(in: self)
        erase(from: point, toPoint: currentPoint)
        previousPoint = currentPoint
    }
    
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
