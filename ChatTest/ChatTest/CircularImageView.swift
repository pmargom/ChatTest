
import UIKit

@IBDesignable class CircularImageView: UIImageView {
    
    override var image: UIImage? {
        didSet {
            super.image = image?.circularImage(size: nil)
        }
    }
}

extension UIImage {
    
    func circularImage(size size: CGSize?) -> UIImage {
        let newSize = size ?? self.size
        
        let minEdge = min(newSize.height, newSize.width)
        let size = CGSize(width: minEdge, height: minEdge)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        self.drawInRect(CGRect(origin: CGPoint.zero, size: size), blendMode: .Copy, alpha: 1.0)
        
        CGContextSetBlendMode(context, .Copy)
        CGContextSetFillColorWithColor(context, UIColor.clearColor().CGColor)
        
        let rectPath = UIBezierPath(rect: CGRect(origin: CGPoint.zero, size: size))
        let circlePath = UIBezierPath(ovalInRect: CGRect(origin: CGPoint.zero, size: size))
        rectPath.appendPath(circlePath)
        rectPath.usesEvenOddFillRule = true
        rectPath.fill()
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
    }
    
    var uncompressedPNGData: NSData      { return UIImagePNGRepresentation(self)!        }
    var highestQualityJPEGNSData: NSData { return UIImageJPEGRepresentation(self, 1.0)!  }
    var highQualityJPEGNSData: NSData    { return UIImageJPEGRepresentation(self, 0.75)! }
    var mediumQualityJPEGNSData: NSData  { return UIImageJPEGRepresentation(self, 0.5)!  }
    var lowQualityJPEGNSData: NSData     { return UIImageJPEGRepresentation(self, 0.25)! }
    var lowestQualityJPEGNSData:NSData   { return UIImageJPEGRepresentation(self, 0.0)!  }
    
    static func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func reducedImage(image: UIImage) -> NSData {
        
        //let resizeImage = UIImage.resizeImage(image, newWidth: widthReducedImage)
        let resizeImage = UIImage.resizeImage(image, newWidth: 600)
        return resizeImage.mediumQualityJPEGNSData
    }
}
