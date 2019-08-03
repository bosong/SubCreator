import UIKit

class PermissionAlert {
    /// The permission.
    fileprivate let permission: Permission
    
    /// The status of the permission.
    fileprivate var status: PermissionStatus { return permission.status }
    
    fileprivate var callbacks: Permission.Callback { return permission.callbacks }
    
    /// The title of the alert.
    fileprivate var title: String?
    
    /// Descriptive text that provides more details about the reason for the alert.
    fileprivate var message: String?
    
    /// The title of the cancel action.
    fileprivate var cancel: String? {
        get { return cancelActionTitle }
        set { cancelActionTitle = newValue }
    }
    
    /// The title of the settings action.
    fileprivate var settings: String? {
        get { return defaultActionTitle }
        set { defaultActionTitle = newValue }
    }
    
    /// The title of the confirm action.
    fileprivate var confirm: String? {
        get { return defaultActionTitle }
        set { defaultActionTitle = newValue }
    }
    
    fileprivate var cancelActionTitle: String?
    fileprivate var defaultActionTitle: String?
    
    var controller: UIAlertController {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: cancelActionTitle, style: .cancel, handler: cancelHandler)
        controller.addAction(action)
        
        return controller
    }
    
    internal init(permission: Permission) {
        self.permission = permission
    }
    
    internal func present() {
        DispatchQueue.main.async {
            UIApplication.shared.presentViewController(self.controller)
        }
    }
    
    fileprivate func cancelHandler(_ action: UIAlertAction) {
        callbacks(status)
    }
}

internal class DisabledAlert: PermissionAlert {
   
    override init(permission: Permission) {
        super.init(permission: permission)
        
        title   = "\(permission) is currently disabled"
        message = "Please enable access to \(permission) in the Settings app."
        cancel  = "OK"
    }
}

internal class CameraDisabledAlert: DisabledAlert {
    override init(permission: Permission) {
        super.init(permission: permission)
        
        title    = NSLocalizedString("common_accessAlert_cameraTitle", comment: "")
        message  = NSLocalizedString("common_accessAlert_setDes", comment: "")
        cancel   = NSLocalizedString("common_button_cancel", comment: "")
        settings = NSLocalizedString("common_pageTitle_settings", comment: "")
    }
}

internal class AlbumDisabledAlert: DisabledAlert {
    override init(permission: Permission) {
        super.init(permission: permission)
        
        title    = NSLocalizedString("common_accessAlert_albumTitle", comment: "")
        message  = NSLocalizedString("common_accessAlert_setDes", comment: "")
        cancel   = NSLocalizedString("common_button_cancel", comment: "")
        settings = NSLocalizedString("common_pageTitle_settings", comment: "")
    }
}

internal class DeniedAlert: PermissionAlert {
    override var controller: UIAlertController {
        let controller = super.controller
        
        let action = UIAlertAction(title: defaultActionTitle, style: .default, handler: settingsHandler)
        controller.addAction(action)
        
        if #available(iOS 9.0, *) {
            controller.preferredAction = action
        }
        
        return controller
    }
    
    override init(permission: Permission) {
        super.init(permission: permission)
        
        title    = "Permission for \(permission) was denied"
        message  = "Please enable access to \(permission) in the Settings app."
        cancel   = "Cancel"
        settings = "Settings"
    }
    
    @objc func settingsHandler() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification)
        callbacks(status)
    }
    
    private func settingsHandler(_ action: UIAlertAction) {
        NotificationCenter.default.addObserver(self, selector: .settingsHandler, name: UIApplication.didBecomeActiveNotification)
        
        if let URL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        }
    }
}

internal class CameraDeniedAlert: DeniedAlert {
    override init(permission: Permission) {
        super.init(permission: permission)
        
        title    = NSLocalizedString("common_accessAlert_cameraTitle", comment: "")
        message  = NSLocalizedString("common_accessAlert_setDes", comment: "")
        cancel   = NSLocalizedString("common_button_cancel", comment: "")
        settings = NSLocalizedString("common_pageTitle_settings", comment: "")
    }
}

internal class AlbumDeniedAlert: DeniedAlert {
    override init(permission: Permission) {
        super.init(permission: permission)
        
        title    = NSLocalizedString("common_accessAlert_albumTitle", comment: "")
        message  = NSLocalizedString("common_accessAlert_setDes", comment: "")
        cancel   = NSLocalizedString("common_button_cancel", comment: "")
        settings = NSLocalizedString("common_pageTitle_settings", comment: "")
    }
}

internal class PrePermissionAlert: PermissionAlert {
    override var controller: UIAlertController {
        let controller = super.controller
        
        let action = UIAlertAction(title: defaultActionTitle, style: .default, handler: confirmHandler)
        controller.addAction(action)
        
        if #available(iOS 9.0, *) {
            controller.preferredAction = action
        }
        
        return controller
    }
    
    override init(permission: Permission) {
        super.init(permission: permission)
        
        title   = "\(Bundle.main.name) would like to access your \(permission)"
        message = "Please enable access to \(permission)."
        cancel  = "Cancel"
        confirm = "Confirm"
    }
    
    fileprivate func confirmHandler(_ action: UIAlertAction) {
        permission.requestAuthorization(callbacks)
    }
}
