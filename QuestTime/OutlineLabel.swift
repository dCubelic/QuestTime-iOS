//
//  OutlineLabel.swift
//  QuestTime
//
//  Created by dominik on 07/03/2018.
//  Copyright © 2018 BlabLab. All rights reserved.
//

import UIKit

class OutlineLabel: UILabel {

    override func drawText(in rect: CGRect) {
        let newRect = CGRect(x: rect.minX, y: rect.minY, width: rect.width+4, height: rect.height+4)
        let shadowOffset = self.shadowOffset
        let textColor = self.textColor
        
        let c = UIGraphicsGetCurrentContext()
        c?.setLineWidth(2)
        c?.setLineJoin(CGLineJoin.round)
        
        c?.setTextDrawingMode(CGTextDrawingMode.stroke)
        self.textColor = UIColor(red: 25/255, green: 85/255, blue: 0, alpha: 1)
        super.drawText(in: rect)
        
        c?.setTextDrawingMode(CGTextDrawingMode.fill)
        self.textColor = textColor
        self.shadowOffset = CGSize(width: 0, height: 0)
        super.drawText(in: rect)
        
        self.shadowOffset = shadowOffset
//        CGContext.setLineWidth(c, 1)
//        CGContext.setLineJoin(c, kCGLineJoinRound)
        
        
//        CGSize shadowOffset = self.shadowOffset;
//        UIColor *textColor = self.textColor;
//
//        CGContextRef c = UIGraphicsGetCurrentContext();
//        CGContextSetLineWidth(c, 1);
//        CGContextSetLineJoin(c, kCGLineJoinRound);
//
//        CGContextSetTextDrawingMode(c, kCGTextStroke);
//        self.textColor = [UIColor whiteColor];
//        [super drawTextInRect:rect];
//
//        CGContextSetTextDrawingMode(c, kCGTextFill);
//        self.textColor = textColor;
//        self.shadowOffset = CGSizeMake(0, 0);
//        [super drawTextInRect:rect];
//
//        self.shadowOffset = shadowOffset;
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
