//
//  TabBarController.swift
//  SubCreator
//
//  Created by ripple_k on 2019/9/17.
//  Copyright © 2019 ripple_k. All rights reserved.
//

import RxSwift
import RxCocoa
import ESTabBarController_swift

class TabBarController: ESTabBarController {
    static let selectedIndex = TabBarController._selectedIndex.asObservable()
    private static let _selectedIndex = BehaviorSubject(value: 0)
    
    override var selectedIndex: Int {
        didSet {
            TabBarController._selectedIndex.onNext(self.selectedIndex)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.isTranslucent = false
        self.tabBar.backgroundColor = UIColor.white
        self.tabBar.shadowImage = UIImage()
        setChild()
    }
    
    private func setChild() {
        let home = HomepageViewController(reactor: HomepageViewReactor())
        let middle = GalleryViewControler(reactor: HomepageViewReactor())
        let me = MeViewController()
        home.tabBarItem = UITabBarItem(title: nil,
                                       image: R.image.home_normal()?.withRenderingMode(.alwaysOriginal),
                                       selectedImage: R.image.home_sel()?.withRenderingMode(.alwaysOriginal))
        
        let irregularity = IrregularityContentView()
        irregularity.renderingMode = .alwaysOriginal
        middle.tabBarItem = ESTabBarItem.init(irregularity,
                                              title: nil,
                                              image: R.image.middle_normal(),
                                              selectedImage: R.image.middle_sel())
        me.tabBarItem = UITabBarItem(title: nil,
                                     image: R.image.me_normal()?.withRenderingMode(.alwaysOriginal),
                                     selectedImage: R.image.me_sel()?.withRenderingMode(.alwaysOriginal))
        
//        shouldHijackHandler = { _, _, index in
//            return index == 2
//        }
//        didHijackHandler = { [weak self] _, _, index in
//            self?.present(middle, animated: true, completion: nil)
//        }
        
        let viewControllers = [home, middle, me]
            .map { BaseNavigationViewController(rootViewController: $0) }
        self.viewControllers = viewControllers
    }
}
