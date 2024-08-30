//
//  UIImage+Extensions.swift
//  Calendar Cats
//
//  Created by Eric Eddy on 2024-08-30.
//

import UIKit

extension UIImage {
    // from https://stackoverflow.com/a/47884962 - with augmentations to include min height
    func resizeTopAlignedToFill(newWidth: CGFloat, minHeight: CGFloat) -> UIImage? {
        let newHeight = size.height * newWidth / size.width
        var newSize = CGSize(width: newWidth, height: newHeight)
        
        if newHeight < minHeight {
            let fixedWidth = size.width * minHeight / size.height
            newSize = CGSize(width: fixedWidth, height: minHeight)
        }
        
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
