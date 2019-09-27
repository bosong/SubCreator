import UIKit

extension UIApplication {
    fileprivate var topViewController: UIViewController? {
        var vc = delegate?.window??.rootViewController
        
        while let presentedVC = vc?.presentedViewController {
            vc = presentedVC
        }
        
        return vc
    }
    
    internal func presentViewController(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        topViewController?.present(viewController, animated: animated, completion: completion)
    }
}

extension Bundle {
    var name: String {
        return object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
    }
}

extension UIControl.State: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

extension String {
    static let photoLibraryUsageDescription      = "NSPhotoLibraryUsageDescription"
    static let cameraUsageDescription            = "NSCameraUsageDescription"
}

extension Selector {
    static let settingsHandler = #selector(DeniedAlert.settingsHandler)
}

extension NotificationCenter {
    func addObserver(_ observer: AnyObject, selector: Selector, name: NSNotification.Name?) {
        addObserver(observer, selector: selector, name: name!, object: nil)
    }
    
    func removeObserver(_ observer: AnyObject, name: NSNotification.Name?) {
        removeObserver(observer, name: name, object: nil)
    }
}
