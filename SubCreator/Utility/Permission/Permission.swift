import UIKit
import AVFoundation
import Photos

class Permission: NSObject {
    
    public typealias Callback = (PermissionStatus) -> Void
    
    /// The permission to access the camera.
    static let camera = Permission(type: .camera)
    
    /// The permission to access the user's photos.
    static let photos = Permission(type: .photos)
    
    /// The permission domain.
    let type: PermissionType
    
    /// The permission status.
    var status: PermissionStatus {
        get {
            
            if case .camera = type {
                return statusCamera
            }
            
            if case .photos = type {
                return statusPhotos
            }
            
            if case .nonePermission = type {
                return .denied
            }
            
            fatalError()
        }
    }
    
    /// Determines whether to present the pre-permission alert.
    var presentPrePermissionAlert = false
    
    /// The pre-permission alert.
    lazy var prePermissionAlert: PermissionAlert = {
        return PrePermissionAlert(permission: self)
    }()
    
    /// Determines whether to present the denied alert.
    var presentDeniedAlert = true
    
    /// The alert when the permission was denied.
    lazy var deniedAlert: PermissionAlert = {
        switch type {
        case .camera:
            return CameraDeniedAlert(permission: self)
        case .photos:
            return AlbumDeniedAlert(permission: self)
        default:
            return DeniedAlert(permission: self)
        }
    }()
    
    /// Determines whether to present the disabled alert.
    var presentDisabledAlert = true
    
    /// The alert when the permission is disabled.
    lazy var disabledAlert: PermissionAlert = {
        switch type {
        case .camera:
            return CameraDisabledAlert(permission: self)
        case .photos:
            return AlbumDisabledAlert(permission: self)
        default:
            return DisabledAlert(permission: self)
        }
    }()
    
    internal var callback: Callback?
    
    /**
     Creates and return a new permission for the specified domain.
     
     - parameter domain: The permission domain.
     
     - returns: A newly created permission.
     */
    fileprivate init(type: PermissionType) {
        self.type = type
    }
    
    /**
     Requests the permission.
     
     - parameter callback: The function to be triggered after the user responded to the request.
     */
    func request(_ callback: @escaping Callback) {
        self.callback = callback
        
        let status = self.status
        
        checkPermission(status)
    }
    
    func checkPermission(_ status: PermissionStatus) {
        switch status {
        case .authorized:    callbacks(status)
        case .notDetermined: presentPrePermissionAlert ? prePermissionAlert.present() : requestAuthorization(callbacks)
        case .denied:        presentDeniedAlert ? deniedAlert.present() : callbacks(status)
        case .disabled:      presentDisabledAlert ? disabledAlert.present() : callbacks(status)
        }
    }
    
    func requestAuthorization(_ callback: @escaping Callback) {
        
        if case .camera = type {
            requestCamera(callback)
            return
        }
        
        if case .photos = type {
            requestPhotos(callback)
            return
        }
        
        fatalError()
    }
    
    internal func callbacks(_ status: PermissionStatus) {
        DispatchQueue.main.async {
            self.callback?(status)
        }
    }
}

extension Permission {

    override var description: String {
        return type.description
    }
    
    override var debugDescription: String {
        return "\(type): \(status)"
    }
}

extension Permission {
    
    fileprivate var statusCamera: PermissionStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:          return .authorized
        case .restricted, .denied: return .denied
        case .notDetermined:       return .notDetermined
        @unknown default:
            fatalError("status unknow!")
        }
    }
    
    fileprivate func requestCamera(_ callback: @escaping Callback) {
        guard let _ = Bundle.main.object(forInfoDictionaryKey: .cameraUsageDescription) else {
            print("WARNING: \(String.cameraUsageDescription) not found in Info.plist")
            return
        }
        
        AVCaptureDevice.requestAccess(for: .video) { _ in
            callback(self.statusCamera)
        }
    }
}

extension Permission {
    
    fileprivate var statusPhotos: PermissionStatus {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized:          return .authorized
        case .denied, .restricted: return .denied
        case .notDetermined:       return .notDetermined
        @unknown default:
            fatalError("status unknow!")
        }
    }
    
    fileprivate func requestPhotos(_ callback: @escaping Callback) {
        guard let _ = Bundle.main.object(forInfoDictionaryKey: .photoLibraryUsageDescription) else {
            print("WARNING: \(String.photoLibraryUsageDescription) not found in Info.plist")
            return
        }
        
        PHPhotoLibrary.requestAuthorization { _ in
            callback(self.statusPhotos)
        }
    }
}
