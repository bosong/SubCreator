//
//  NSAttributedString+Ex.swift
//  SubCreator
//
//  Created by rpple_k on 2019/8/1.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import UIKit

extension NSAttributedString {
    public func contentSize(width: CGFloat) -> CGSize {
        let rect = boundingRect(with: CGSize(width: width,
                                             height: CGFloat.infinity),
                                options: [.usesLineFragmentOrigin,
                                          .usesFontLeading],
                                context: nil)
        return rect.size
    }
    
    static func attributedString(string: String?, font: UIFont = UIFont.systemFont(ofSize: 10), color: UIColor = .white) -> NSAttributedString? {
        guard let string = string else { return nil }
        
        let attributes = [NSAttributedString.Key.foregroundColor: color,
                          NSAttributedString.Key.font: font]
        
        let attributedString = NSMutableAttributedString(string: string, attributes: attributes)
        
        return attributedString
    }
}
