//
//  MB_ViewController.swift
//  FigaroEmploi
//
//  Created by BLIN Michael on 09/04/2021.
//

import UIKit

public class MB_ViewController: UIViewController {

	public var keyboardHeight: CGFloat = 0
	
	deinit {
		
		NotificationCenter.default.removeObserver(self)
	}
	
	public override func loadView() {
		
		super.loadView()
		
		setNeedsStatusBarAppearanceUpdate()
		
		navigationItem.largeTitleDisplayMode = .always
		
		modalPresentationCapturesStatusBarAppearance = true

		view.backgroundColor = Colors.Background
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		setNeedsStatusBarAppearanceUpdate()
	}
	
	public override func viewWillDisappear(_ animated: Bool) {
		
		super.viewWillDisappear(animated)
		
		UIApplication.shared.hideKeyboard()
	}
	
	public override var preferredStatusBarStyle: UIStatusBarStyle {
		
		return .lightContent
	}
	
	@objc public func keyboardWillShow(notification: NSNotification) {
		
		if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
			
			keyboardHeight = keyboardSize.height - (tabBarController?.tabBar.frame.size.height ?? 0)
		}
	}
	
	@objc public func keyboardWillHide(notification: NSNotification){
		
		keyboardHeight = 0
	}
}
