//
//  UIApplication_Extension.swift
//  FigaroEmploi
//
//  Created by BLIN Michael on 10/04/2021.
//

import UIKit

extension UIApplication {
	
	public func topMostViewController() -> UIViewController? {
		
		return UIApplication.shared.connectedScenes.flatMap { ($0 as? UIWindowScene)?.windows ?? [] }.first { $0.isKeyWindow }?.rootViewController?.topMostViewController()
	}
	
	public func hideKeyboard(){
		
		UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
	}
}
