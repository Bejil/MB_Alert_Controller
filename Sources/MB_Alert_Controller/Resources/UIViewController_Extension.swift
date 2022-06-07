//
//  UIViewController_Extension.swift
//  FigaroEmploi
//
//  Created by BLIN Michael on 26/04/2021.
//

import UIKit

extension UIViewController {
	
	func topMostViewController() -> UIViewController {
		
		if let presented = self.presentedViewController {
			
			return presented.topMostViewController()
		}
		
		if let navigation = self as? UINavigationController {
			
			return navigation.visibleViewController?.topMostViewController() ?? navigation
		}
		
		if let tab = self as? UITabBarController {
			
			return tab.selectedViewController?.topMostViewController() ?? tab
		}
		
		return self
	}
}
