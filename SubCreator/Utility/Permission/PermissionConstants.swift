import UIKit

enum PermissionStatus: String {
    case authorized    = "Authorized"
    case denied        = "Denied"
    case disabled      = "Disabled"
    case notDetermined = "Not Determined"
    
    internal init?(string: String?) {
        guard let string = string else { return nil }
        self.init(rawValue: string)
    }
}

extension PermissionStatus: CustomStringConvertible {
    public var description: String {
        return rawValue
    }
}

enum PermissionType {
    case nonePermission
    case camera
    case photos
}

extension PermissionType: CustomStringConvertible {
    public var description: String {
        if case .camera = self { return "Camera" }
        if case .photos = self { return "Photos" }
        fatalError()
    }
}
