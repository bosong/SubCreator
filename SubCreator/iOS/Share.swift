//
//  Share.swift
//  SubCreator
//
//  Created by rpple_k on 2019/8/3.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import Foundation

class Share {
    static func shareShow(controller: UIViewController, items: [Any]) {
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop, .mail, .message, .openInIBooks]
        activityViewController.popoverPresentationController?.sourceView = controller.view
        activityViewController.popoverPresentationController?.sourceRect = CGRect(origin: controller.view.center, size: .zero)
        controller.present(activityViewController, animated: true, completion: nil)
    }
}
