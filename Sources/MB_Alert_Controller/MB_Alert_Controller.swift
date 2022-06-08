//
//  MB_Alert_Controller.swift
//  FigaroEmploi
//
//  Created by BLIN Michael on 07/05/2021.
//

import UIKit
import SnapKit
import MB_TextField
import MB_Button

/// Creates an alert with specific style, animations and content
open class MB_Alert_Controller: MB_ViewController {

	//MARK: - STYLE
	
	/// Define the style of the alert
	public enum MB_Alert_Controller_Style {
		
		/// Show as default UIAlertController
		case Alert
		/// Show as halfModal from bottom with gesture to dismiss
		case HalfModal
		/// Show as popover from a source
		case Popover
		/// Show as notification from top with gesture to dismiss
		case Notification
	}
	/// Define the style of the alert
	public var style:MB_Alert_Controller_Style = .Alert {
		
		didSet {
			
			isPanGestureEnabled = { isPanGestureEnabled }()
			
			panGestureView.snp.makeConstraints { (make) in
				
				if style == .Notification {
					
					make.top.equalTo(containerView.snp.bottom)
				}
				else if style == .HalfModal {
					
					make.bottom.equalTo(containerView.snp.top)
				}
			}
			
			updatePanGestureIndicatorViewBackgroundColor()
			
			timerProgressView.snp.makeConstraints { (make) in
				
				if style == .HalfModal {
					
					make.top.equalToSuperview().inset(1)
				}
				else {
					
					make.bottom.equalToSuperview().inset(1)
				}
			}
			
			containerView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner,.layerMaxXMaxYCorner,.layerMinXMaxYCorner]
			
			if style == .HalfModal {
				
				containerView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
			}
			
			if style == .Popover {
				
				containerView.layer.cornerRadius = 0
			}
		}
	}
	
	//MARK: - POPOVER
	
	/// View from where the popover is shown
	/// - Important: Only available for style == .Popover
	public var popoverSourceView:UIView? = nil
	/// BarButtonItem from where the popover is shown
	/// - Important: Only available for style == .Popover
	public var popoverSourceBarButtonItem:UIBarButtonItem? = nil
	
	//MARK: - ANIMATION
	
	/// Define the animation of the alert
	/// - Important: Only available for style == .Alert
	public enum MB_Alert_Controller_Alert_Animation {
		
		case None
		case Fade
		case Zoom
	}
	public enum MB_Alert_Controller_Alert_Direction {
		
		case None
		case TopLeft
		case Top
		case TopRight
		case Right
		case BottomRight
		case Bottom
		case BottomLeft
		case Left
	}
	public var inAlertAnimations:[MB_Alert_Controller_Alert_Animation] = [.Fade]
	public var inAlertDirection:MB_Alert_Controller_Alert_Direction = .None
	public var outAlertAnimations:[MB_Alert_Controller_Alert_Animation] = [.Fade]
	public var outAlertDirection:MB_Alert_Controller_Alert_Direction = .None
	public var animationDuration:TimeInterval = 0.3
	
	//MARK: - BACKGROUND
	
	private lazy var backgroundView:UIView = {
		
		let view:UIView = .init()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = backgroundViewColor
		view.addGestureRecognizer(backgroundViewTapGesture)
		return view
	}()
	private lazy var backgroundViewTapGesture:UITapGestureRecognizer = {
		
		let gestureRecognizer:UITapGestureRecognizer = .init { [weak self] (gestureRecognizer) in
			
			self?.dismiss(self?.dismissOnBackgroundViewTapHandler)
		}
		gestureRecognizer.isEnabled = shouldDismissOnBackgroundViewTap
		return gestureRecognizer
	}()
	public var backgroundViewColor:UIColor = UIColor.black.withAlphaComponent(0.5) {
		
		didSet {
			
			backgroundView.backgroundColor = backgroundViewColor
		}
	}
	public var shouldDismissOnBackgroundViewTap:Bool = true {
	
		didSet {
			
			backgroundViewTapGesture.isEnabled = shouldDismissOnBackgroundViewTap
		}
	}
	public var dismissOnBackgroundViewTapHandler:(()->Void)?
	
	//MARK: - CONTAINER
	
	private lazy var containerView:UIView = {
		
		let view:UIView = .init()
		view.backgroundColor = containerViewBackgroundColor
		view.layer.cornerRadius = containerViewCornerRadius
		view.layer.shadowColor = containerViewShadowColor.cgColor
		view.layer.shadowOpacity = containerViewShadowOpacity
		view.layer.shadowRadius = containerViewCornerRadius
		view.layer.shadowOffset = .zero
		
		let stackView:UIStackView = .init(arrangedSubviews: [titleStackView,stickyHeaderStackView,contentScrollView,stickyFooterStackView])
		stackView.axis = .vertical
		stackView.spacing = UI.Margins
		view.addSubview(stackView)
		
		stackView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
		}
		
		view.addSubview(timerProgressView)
		
		timerProgressView.snp.makeConstraints { (make) in
			make.right.left.equalToSuperview().inset(containerViewCornerRadius)
			make.height.equalTo(UI.Margins/5)
		}
		
		return view
	}()
	public var containerViewBackgroundColor:UIColor = Colors.Background {
		
		didSet {
			
			containerView.backgroundColor = containerViewBackgroundColor
		}
	}
	public var containerViewCornerRadius:CGFloat = 4*UI.CornerRadius {
		
		didSet {
			
			containerView.layer.cornerRadius = containerViewCornerRadius
			containerView.layer.shadowRadius = containerViewCornerRadius
		}
	}
	public var containerViewShadowColor:UIColor = Colors.Shadow {
		
		didSet {
			
			containerView.layer.shadowColor = containerViewShadowColor.cgColor
		}
	}
	public var containerViewShadowOpacity:Float = 0.25 {
		
		didSet {
			
			containerView.layer.shadowOpacity = containerViewShadowOpacity
		}
	}
	
	//MARK: - CONTENT
	
	private lazy var stickyHeaderStackView:UIStackView = {
		
		let stackView:UIStackView = .init()
		stackView.axis = .vertical
		stackView.spacing = UI.Margins
		return stackView
	}()
	private var contentSizeObserver:NSKeyValueObservation?
	private lazy var contentScrollView:UIScrollView = {
		
		let scrollView:UIScrollView = .init()
		scrollView.contentInsetAdjustmentBehavior = .never
		scrollView.addSubview(contentStackView)
		
		contentStackView.snp.makeConstraints { (make) in
			
			make.leading.trailing.top.bottom.equalToSuperview()
			make.width.equalToSuperview()
			make.height.equalToSuperview().priority(700)
		}
		
		return scrollView
	}()
	private lazy var contentStackView:UIStackView = {
		
		let stackView:UIStackView = .init()
		stackView.axis = .vertical
		stackView.spacing = UI.Margins
		return stackView
	}()
	private lazy var stickyFooterStackView:UIStackView = {
		
		let stackView:UIStackView = .init()
		stackView.axis = .horizontal
		stackView.spacing = UI.Margins
		stackView.distribution = .fillEqually
		return stackView
	}()
	
	//MARK: - TITLE
	
	private lazy var titleStackView:UIStackView = {
		
		let stackView:UIStackView = .init(arrangedSubviews: [titleImageView,titleLabel,closeButton])
		stackView.axis = .horizontal
		stackView.alignment = .center
		stackView.distribution = .fill
		stackView.spacing = UI.Margins
		return stackView
	}()
	private lazy var titleImageView:UIImageView = {
		
		let imageView:UIImageView = .init(image: titleImageViewImage)
		imageView.contentMode = .scaleAspectFit
		imageView.tintColor = titleImageViewColor
		imageView.isHidden = titleImageViewImage == nil
		imageView.snp.makeConstraints { (make) in
			make.width.height.equalTo(2*UI.Margins)
		}
		return imageView
	}()
	public var titleImageViewImage:UIImage? = nil {
		
		didSet {
			
			titleImageView.image = titleImageViewImage
			titleImageView.isHidden = titleImageViewImage == nil
			updateTitleStackView()
		}
	}
	public var titleImageViewColor:UIColor = Colors.Secondary {
		
		didSet {
			
			titleImageView.tintColor = titleImageViewColor
		}
	}
	private lazy var closeButton:UIButton = {
		
		let button:UIButton = .init(type: .close, primaryAction: .init(handler: { [weak self] _ in
			
			self?.dismiss(self?.closeButtonHandler)
		}))
		button.isHidden = !shouldDisplayCloseButton
		button.snp.makeConstraints { (make) in
			make.width.height.equalTo(2*UI.Margins)
		}
		return button
	}()
	public var shouldDisplayCloseButton:Bool = true {
		
		didSet {
			
			closeButton.isHidden = !shouldDisplayCloseButton
			updateTitleStackView()
		}
	}
	public var closeButtonHandler:(()->Void)?
	private lazy var titleLabel:UILabel = {
		
		let label:UILabel = .init()
		label.font = titleLabelFont
		label.textColor = titleLabelColor
		label.textAlignment = titleLabelTextAlignment
		label.text = title
		label.numberOfLines = 0
		return label
	}()
	public var titleLabelFont:UIFont = Fonts.Title.H2 {
		
		didSet {
			
			titleLabel.font = titleLabelFont
		}
	}
	public var titleLabelColor:UIColor = Colors.Title {
		
		didSet {
			
			titleLabel.textColor = titleLabelColor
		}
	}
	public var titleLabelTextAlignment:NSTextAlignment = .center {
		
		didSet {
			
			titleLabel.textAlignment = titleLabelTextAlignment
		}
	}
	public override var title: String? {
		
		didSet {
			
			titleLabel.text = title
			updateTitleStackView()
		}
	}
	private func updateTitleStackView() {
		
		titleStackView.isHidden = title?.isEmpty ?? true && !shouldDisplayCloseButton && titleImageViewImage == nil
	}
	
	//MARK: - LABEL
	
	public var labelFont:UIFont = Fonts.Content.Regular
	public var labelColor:UIColor = Colors.Text
	public var labelTextAlignment:NSTextAlignment = .center
	
	public func add(attributedString:NSAttributedString) {
		
		let label:UILabel = .init()
		label.font = labelFont
		label.textColor = labelColor
		label.textAlignment = labelTextAlignment
		label.attributedText = attributedString
		label.numberOfLines = 0
		add(view: label)
	}
	
	public func add(string:String) {
		
		add(attributedString: .init(string: string))
	}
	
	//MARK: - IMAGE
	
	public func add(image :UIImage?, color:UIColor? = nil, heightRatio:CGFloat = 0.4) {
		
		let imageView:UIImageView = .init(image: image)
		imageView.contentMode = .scaleAspectFit
		imageView.tintColor = color
		imageView.snp.makeConstraints { (make) in
			make.height.equalTo(imageView.snp.width).multipliedBy(heightRatio)
		}
		add(view: imageView)
	}
	
	//MARK: - TEXTFIELD
	public var textFieldTintColor:UIColor = .blue
	public var textFieldBackgroundColor:UIColor = Colors.Background
	public var textFieldTextColor = Colors.Text
	public var textFieldInvalidColor = Colors.Red
	public var textFieldMandatoryColor = Colors.Red
	public var textFieldBorderColor = Colors.Text.withAlphaComponent(0.25)
	public var textFieldPlaceholderColor = Colors.Text.withAlphaComponent(0.5)
	public var textFieldFont = Fonts.Content.Regular
	public var textFieldPlaceholderFont = Fonts.Content.Regular
	public var textFieldMandatoryFont = Fonts.Content.Bold
	public var textFieldToolbarFont = Fonts.Button.Navigation
	@discardableResult public func addTextField() -> MB_TextField {
		
		let textField:MB_TextField = .init()
		add(view: textField)
		return textField
	}
	
	//MARK: - BUTTON
	public var buttonTintColor:UIColor = .blue
	public var buttonTitleFont:UIFont = .boldSystemFont(ofSize: Fonts.Size.Default+2)
	public var buttonSubtitleFont:UIFont = .systemFont(ofSize: Fonts.Size.Default-1)
	@discardableResult private func getButton(title:String, image:UIImage? = nil, handler:((MB_Button?)->Void)? = nil) -> MB_Button {
		
		let button:MB_Button = .init(style: .solid, title: title, image: image) { button in
			
			handler?(button)
		}
		button.titleFont = buttonTitleFont
		button.subtitleFont = buttonSubtitleFont
		button.tintColor = buttonTintColor
		return button
	}
	@discardableResult public func addCancelButton(handler:((MB_Button?)->Void)? = nil) -> MB_Button {
		
		let button = addButton(title: "Annuler", handler:  { [weak self] button in
			
			self?.dismiss({
				
				handler?(button)
			})
		})
		button.style = .transparent
		return button
	}
	@discardableResult public func addDismissButton(handler:((MB_Button?)->Void)? = nil) -> MB_Button {
		
		let button = addButton(title: "Ok", handler:  { [weak self] button in
			
			self?.dismiss({
				
				handler?(button)
			})
		})
		button.style = .transparent
		return button
	}
	@discardableResult public func addButton(title:String, image:UIImage? = nil, handler:((MB_Button?)->Void)? = nil) -> MB_Button {
		
		let button:MB_Button = getButton(title: title, image: image, handler: handler)
		add(view: button)
		return button
	}
	@discardableResult public func addStickyCancelButton(handler:((MB_Button?)->Void)? = nil) -> MB_Button {
		
		let button = addStickyButton(title: "Annuler", handler:  { [weak self] button in
			
			self?.dismiss({
				
				handler?(button)
			})
		})
		button.style = .transparent
		return button
	}
	@discardableResult public func addStickyDismissButton(handler:((MB_Button?)->Void)? = nil) -> MB_Button {
		
		let button = addStickyButton(title: "Ok", handler:  { [weak self] button in
			
			self?.dismiss({
				
				handler?(button)
			})
		})
		button.style = .transparent
		return button
	}
	@discardableResult public func addStickyButton(title:String, image:UIImage? = nil, handler:((MB_Button?)->Void)? = nil) -> MB_Button {
		
		let button:MB_Button = getButton(title: title, image: image, handler: handler)
		stickyFooterStackView.addArrangedSubview(button)
		return button
	}
	
	//MARK: - TIMER
	
	private lazy var timerProgressView:UIProgressView = {
		
		let view:UIProgressView = .init(progressViewStyle: .default)
		view.tintColor = timerColor
		view.progressTintColor = timerColor
		view.trackTintColor = timerColor.withAlphaComponent(0.25)
		view.isHidden = timerDuration == nil || timerDuration == 0 || !(shouldDisplayProgressView ?? true)
		return view
	}()
	public var shouldDisplayProgressView:Bool? = true {
		
		didSet {
			
			timerProgressView.isHidden = timerDuration == nil || timerDuration == 0 || !(shouldDisplayProgressView ?? true)
		}
	}
	public var timerDuration:TimeInterval? = nil {
		
		didSet {
			
			timerProgressView.isHidden = timerDuration == nil || timerDuration == 0 || !(shouldDisplayProgressView ?? true)
			
			if let timerDuration = timerDuration, timerDuration != 0 {

				timerProgressView.setProgress(1.0, animated: false)

				DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {

					self.timerProgressView.setProgress(.leastNonzeroMagnitude, animated: false)

					UIView.animate(withDuration: timerDuration, delay: 0, options: [.curveEaseInOut]) {

						self.timerProgressView.layoutIfNeeded()

					} completion: { (finished) in

						self.dismiss(self.timerCompletion)
					}
				}
			}
		}
	}
	public var timerCompletion:(()->Void)?
	public var timerColor:UIColor = Colors.Secondary {
		
		didSet {
			
			timerProgressView.tintColor = timerColor
			timerProgressView.progressTintColor = timerColor
			timerProgressView.trackTintColor = timerColor.withAlphaComponent(0.25)
		}
	}
	
	//MARK: - PANGESTURE
	private lazy var panGestureView:UIView = {
		
		let view:UIView = .init()
		view.isHidden = isPanGestureEnabled
		view.addSubview(panGestureIndicatorView)
		view.addGestureRecognizer(panGestureRecognizer)
		
		panGestureIndicatorView.snp.makeConstraints { (make) in
			make.width.equalToSuperview().multipliedBy(0.25)
			make.centerX.equalToSuperview()
			make.top.bottom.equalToSuperview().inset(UI.Margins)
		}
		
		return view
	}()
	private lazy var panGestureIndicatorView:UIView = {
		
		let view:UIView = .init()
		view.layer.cornerRadius = 2
		
		view.snp.makeConstraints { (make) in
			make.height.equalTo(view.layer.cornerRadius*2)
		}
		
		return view
	}()
	private lazy var panGestureRecognizer:UIPanGestureRecognizer = {
		
		let gestureRecognizer:UIPanGestureRecognizer = .init { [weak self] (gestureRecognizer) in
			
			if let strongSelf = self, let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
				
				let velocity = gestureRecognizer.velocity(in: gestureRecognizer.view)
				
				if gestureRecognizer.state == .changed {
					
					let translation  = gestureRecognizer.translation(in: strongSelf.view)
					
					if abs(velocity.y) > abs(velocity.x) {
						
						if strongSelf.style == .Notification, translation.y <= 0 {
							
							strongSelf.containerView.snp.updateConstraints({ (make) in
								
								make.top.equalTo(strongSelf.view.safeAreaLayoutGuide).inset(translation.y)
							})
						}
						else if strongSelf.style == .HalfModal, translation.y >= 0 {
							
							strongSelf.containerView.snp.updateConstraints({ (make) in
								
								make.bottom.equalToSuperview().offset(translation.y)
							})
						}
					}
				}
				else if gestureRecognizer.state == .ended {
					
					let translation  = gestureRecognizer.translation(in: strongSelf.view)
					
					if strongSelf.style == .Notification {
						
						if velocity.y < -1300 || strongSelf.containerView.frame.size.height + translation.y < strongSelf.containerView.frame.size.height/2 {
							
							strongSelf.dismiss(strongSelf.panGestureHandler)
						}
						else{
							
							UIView.animate(withDuration: strongSelf.animationDuration, delay: 0.0, options: [.curveEaseInOut,.allowUserInteraction]) {
								
								strongSelf.containerView.snp.updateConstraints({ (make) in
									
									make.top.equalTo(strongSelf.view.safeAreaLayoutGuide)
								})
								
								strongSelf.view.layoutIfNeeded()
							}
						}
					}
					else if strongSelf.style == .HalfModal {
						
						if velocity.y > 1300 || strongSelf.containerView.frame.size.height - translation.y < strongSelf.containerView.frame.size.height/2 {
							
							strongSelf.dismiss(strongSelf.panGestureHandler)
						}
						else{
							
							UIView.animate(withDuration: strongSelf.animationDuration, delay: 0.0, options: [.curveEaseInOut,.allowUserInteraction]) {
								
								strongSelf.containerView.snp.updateConstraints({ (make) in
									
									make.bottom.equalToSuperview()
								})
								
								strongSelf.view.layoutIfNeeded()
							}
						}
					}
				}
			}
		}
		gestureRecognizer.isEnabled = isPanGestureEnabled
		return gestureRecognizer
	}()
	public var isPanGestureEnabled:Bool = true {
		
		didSet {
			
			panGestureView.isHidden = isPanGestureEnabled && !(style == .Notification || style == .HalfModal)
			panGestureRecognizer.isEnabled = isPanGestureEnabled && (style == .Notification || style == .HalfModal)
		}
	}
	public var panGestureHandler:(()->Void)?
	
	private func updatePanGestureIndicatorViewBackgroundColor(){
		
		panGestureIndicatorView.backgroundColor = (traitCollection.userInterfaceStyle == .dark || style == .HalfModal ? UIColor.white : UIColor.black).withAlphaComponent(0.25)
	}
	
	//MARK: - COMMON
	
	public var tintColor:UIColor = Colors.Secondary {
		
		didSet {
			
			timerColor = tintColor
			titleImageViewColor = tintColor
		}
	}
	
	deinit {
		
		contentSizeObserver?.invalidate()
		contentSizeObserver = nil
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		modalPresentationCapturesStatusBarAppearance = true
		modalPresentationStyle = .overFullScreen
		modalTransitionStyle = .crossDissolve
		
		view.backgroundColor = .clear
		
		view.addSubview(backgroundView)
		
		backgroundView.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
		}
		
		view.addSubview(containerView)
		
		view.addSubview(panGestureView)
		
		panGestureView.snp.makeConstraints { (make) in
			
			make.left.right.equalTo(containerView)
		}
		
		updatePanGestureIndicatorViewBackgroundColor()
		updateTitleStackView()
		
		setUp()
	}
	
	required public init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		
		super.traitCollectionDidChange(previousTraitCollection)
		
		containerViewShadowColor = { containerViewShadowColor }()
		updatePanGestureIndicatorViewBackgroundColor()
	}
	
	open func setUp() {
		
	}
	
	private func manageAlertAnimations(_ animations:[MB_Alert_Controller_Alert_Animation]) {
		
		if animations.contains(.Fade) {
			
			backgroundView.alpha = 0.0
			containerView.alpha = 0.0
		}
		
		if animations.contains(.Zoom) {
			
			containerView.transform = .init(scaleX: 0.01, y: 0.01)
		}
	}
	
	public override var keyboardHeight: CGFloat {
		
		didSet {
			
			UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut) { [weak self] in
				
				if let strongSelf = self {
					
					if strongSelf.style == .Alert {
						
						strongSelf.containerView.snp.remakeConstraints { (make) in
							
							make.width.equalTo(strongSelf.view.safeAreaLayoutGuide).inset(2*UI.Margins)
							make.centerX.equalTo(strongSelf.view.safeAreaLayoutGuide)
							make.centerY.equalTo(strongSelf.view.safeAreaLayoutGuide).inset(strongSelf.keyboardHeight)
							make.height.lessThanOrEqualTo(strongSelf.view.safeAreaLayoutGuide).inset((2*UI.Margins)+strongSelf.keyboardHeight/2)
						}
					}
					else if strongSelf.style == .Notification {
						
						strongSelf.containerView.snp.remakeConstraints { (make) in
							
							make.width.equalTo(strongSelf.view.safeAreaLayoutGuide).inset(UI.Margins)
							make.height.lessThanOrEqualTo(strongSelf.view.safeAreaLayoutGuide).multipliedBy(0.33).inset(strongSelf.keyboardHeight/2)
							make.centerX.equalTo(strongSelf.view.safeAreaLayoutGuide)
							make.top.equalTo(strongSelf.view.safeAreaLayoutGuide.snp.top)
						}
					}
					else if strongSelf.style == .HalfModal {
						
						strongSelf.containerView.snp.remakeConstraints { (make) in
							
							make.width.equalToSuperview()
							make.centerX.equalTo(strongSelf.view.safeAreaLayoutGuide)
							make.bottom.equalTo(strongSelf.view.snp.bottom).inset(strongSelf.keyboardHeight)
							make.height.lessThanOrEqualTo(strongSelf.view.safeAreaLayoutGuide).inset((2*UI.Margins)+strongSelf.keyboardHeight/2)
						}
					}
					
					strongSelf.view.layoutIfNeeded()
				}
			}
		}
	}
	
	private func manageAlertDirection(_ direction:MB_Alert_Controller_Alert_Direction) {
		
		containerView.snp.remakeConstraints { (make) in
			
			make.width.equalTo(view.safeAreaLayoutGuide).inset(2*UI.Margins)
			make.height.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(2*UI.Margins)
			
			if direction == .None {
				
				make.centerY.equalTo(view.safeAreaLayoutGuide)
				make.centerX.equalTo(view.safeAreaLayoutGuide)
			}
			if direction == .TopLeft {

				make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top)
				make.right.equalTo(view.safeAreaLayoutGuide.snp.left)
			}
			else if direction == .Top {

				make.centerX.equalTo(view.safeAreaLayoutGuide)
				make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top)
			}
			else if direction == .TopRight {

				make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top)
				make.left.equalTo(view.safeAreaLayoutGuide.snp.right)
			}
			else if direction == .Right {

				make.centerY.equalTo(view.safeAreaLayoutGuide)
				make.left.equalTo(view.safeAreaLayoutGuide.snp.right)
			}
			else if direction == .BottomRight {

				make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom)
				make.left.equalTo(view.safeAreaLayoutGuide.snp.right)
			}
			else if direction == .Bottom {

				make.centerX.equalTo(view.safeAreaLayoutGuide)
				make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom)
			}
			else if direction == .BottomLeft {

				make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom)
				make.right.equalTo(view.safeAreaLayoutGuide.snp.left)
			}
			else if direction == .Left {

				make.centerY.equalTo(view.safeAreaLayoutGuide)
				make.right.equalTo(view.safeAreaLayoutGuide.snp.left)
			}
		}

		view.layoutIfNeeded()
	}
	
	public func present(_ completion:(()->Void)? = nil) {
		
		UIApplication.shared.hideKeyboard()
		
		let presentClosure:((Bool)->Void) = { [weak self] animated in
			
			if let strongSelf = self {
				
				UI.MainController.present(strongSelf, animated: animated, completion: {
					
					completion?()
				})
			}
		}
		
		if style == .Alert {
			
			manageAlertAnimations(inAlertAnimations)
			manageAlertDirection(inAlertDirection)
				
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
			
				if let strongSelf = self {
					
					UIView.animate(withDuration: strongSelf.animationDuration, delay: 0.0, options: [.curveEaseInOut,.allowUserInteraction]) {
						
						if strongSelf.inAlertAnimations.contains(.Fade) {
							
							strongSelf.backgroundView.alpha = 1.0
							strongSelf.containerView.alpha = 1.0
						}
						
						if strongSelf.inAlertAnimations.contains(.Zoom) {
							
							strongSelf.containerView.transform = .identity
						}
						
						strongSelf.containerView.snp.remakeConstraints { (make) in
							
							make.width.equalTo(strongSelf.view.safeAreaLayoutGuide).inset(2*UI.Margins)
							make.height.lessThanOrEqualTo(strongSelf.view.safeAreaLayoutGuide).inset(2*UI.Margins)
							make.centerY.equalTo(strongSelf.view.safeAreaLayoutGuide)
							make.centerX.equalTo(strongSelf.view.safeAreaLayoutGuide)
						}
						
						strongSelf.view.layoutIfNeeded()
					}
				}
			}
			
			presentClosure(false)
		}
		else if style == .Notification {
			
			backgroundView.alpha = 0.0
			
			containerView.snp.remakeConstraints { (make) in
				
				make.width.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
				make.height.lessThanOrEqualTo(view.safeAreaLayoutGuide).multipliedBy(0.33)
				make.centerX.equalTo(view.safeAreaLayoutGuide)
				make.bottom.equalTo(view.snp.top)
			}
			
			view.layoutIfNeeded()
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
			
				if let strongSelf = self {
					
					UIView.animate(withDuration: strongSelf.animationDuration, delay: 0.0, options: [.curveEaseInOut,.allowUserInteraction]) {
						
						strongSelf.containerView.snp.remakeConstraints { (make) in
							
							make.width.equalTo(strongSelf.view.safeAreaLayoutGuide).inset(UI.Margins)
							make.height.lessThanOrEqualTo(strongSelf.view.safeAreaLayoutGuide).multipliedBy(0.33)
							make.centerX.equalTo(strongSelf.view.safeAreaLayoutGuide)
							make.top.equalTo(strongSelf.view.safeAreaLayoutGuide.snp.top)
						}
						
						strongSelf.view.layoutIfNeeded()
					}
				}
			}
			
			presentClosure(false)
		}
		else if style == .HalfModal {
			
			backgroundView.alpha = 0.0
			
			containerView.snp.remakeConstraints { (make) in
				
				make.width.equalToSuperview()
				make.height.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(2*UI.Margins)
				make.centerX.equalTo(view.safeAreaLayoutGuide)
				make.top.equalTo(view.snp.bottom)
			}
			
			view.layoutIfNeeded()
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
			
				if let strongSelf = self {
					
					UIView.animate(withDuration: strongSelf.animationDuration, delay: 0.0, options: [.curveEaseInOut,.allowUserInteraction]) {
						
						strongSelf.backgroundView.alpha = 1.0
						
						strongSelf.containerView.snp.remakeConstraints { (make) in
							
							make.width.equalToSuperview()
							make.height.lessThanOrEqualTo(strongSelf.view.safeAreaLayoutGuide).inset(2*UI.Margins)
							make.centerX.equalTo(strongSelf.view.safeAreaLayoutGuide)
							make.bottom.equalTo(strongSelf.view.snp.bottom)
						}
						
						strongSelf.view.layoutIfNeeded()
					}
				}
			}
			
			presentClosure(false)
		}
		else if style == .Popover {
			
			modalPresentationStyle = .popover
			popoverPresentationController?.delegate = self
			modalTransitionStyle = .crossDissolve
			
			if let popoverSourceView = popoverSourceView {
				
				popoverPresentationController?.sourceView = UI.MainController.presentedViewController?.view ?? UI.MainController.view
				popoverPresentationController?.sourceRect = .zero
				
				if var lc_frame = popoverSourceView.superview?.convert(popoverSourceView.frame, to: UI.MainController.presentedViewController?.view ?? UI.MainController.view) {
					
					lc_frame.origin = .init(x: lc_frame.midX, y: lc_frame.midY)
					lc_frame.size = .zero
					popoverPresentationController?.sourceRect = lc_frame
				}
			}
			else if let popoverSourceBarButtonItem = popoverSourceBarButtonItem {
				
				popoverPresentationController?.barButtonItem = popoverSourceBarButtonItem
			}
			
			backgroundView.alpha = 0.0
			
			containerView.snp.remakeConstraints { (make) in
				
				make.left.right.top.bottom.equalToSuperview()
			}
			
			preferredContentSize = .zero

			contentSizeObserver = contentScrollView.observe(\.contentSize) { [weak self] view, _ in

				DispatchQueue.main.async { [weak self] in
					
					self?.resizePopover()
				}
			}

			presentClosure(true)
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
				
				self?.resizePopover()
			}
		}
	}
	
	private func resizePopover() {
		
		titleStackView.layoutIfNeeded()
		contentScrollView.layoutIfNeeded()
		stickyHeaderStackView.layoutIfNeeded()
		stickyFooterStackView.layoutIfNeeded()
		
		var heights:[CGFloat] = .init()
		
		if !titleStackView.arrangedSubviews.isEmpty {
			heights.append(titleStackView.frame.size.height)
		}
		
		if !contentScrollView.subviews.isEmpty {
			heights.append(contentScrollView.contentSize.height)
		}
		
		if !stickyHeaderStackView.arrangedSubviews.isEmpty {
			heights.append(stickyHeaderStackView.frame.size.height)
		}
		
		if !stickyFooterStackView.arrangedSubviews.isEmpty {
			heights.append(stickyFooterStackView.frame.size.height)
		}
		
		var newItems = Array(heights.map { [$0] }.joined(separator: [UI.Margins]))
		newItems.insert(4*UI.Margins, at: 0)
		
		self.preferredContentSize = CGSize(width: UI.MainController.view.frame.size.width, height: newItems.reduce(0, +))
	}
	
	public func present(_ error:Error) {
		
		tintColor = Colors.Red
		titleImageView.image = UIImage(systemName: "exclamationmark.circle.fill")
		title = "Attention"
		add(image: UIImage(named: "error_placeholder"))
		add(string: error.localizedDescription)
		if let localizedFailureReason = (error as NSError).localizedFailureReason {
			
			add(string: localizedFailureReason)
		}
		addDismissButton()
		present()
	}
	
	public func dismiss(_ completion:(()->Void)? = nil) {
		
		UIApplication.shared.hideKeyboard()
		
		let dismissClosure:((Bool)->Void) = { [weak self] animated in
			
			self?.presentingViewController?.dismiss(animated: false, completion: completion)
		}
		
		if style == .Alert {
			
			if !inAlertAnimations.contains(.None) {
				
				UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.curveEaseInOut,.allowUserInteraction]) {
					
					self.manageAlertAnimations(self.inAlertAnimations)
					self.manageAlertDirection(self.outAlertDirection)
					
				} completion: { (finished) in
					
					dismissClosure(false)
				}
			}
			else{
				
				dismissClosure(false)
			}
		}
		else if style == .Notification {
			
			UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.curveEaseInOut,.allowUserInteraction]) {
				
				self.containerView.snp.remakeConstraints { (make) in
					
					make.width.equalTo(self.view.safeAreaLayoutGuide).inset(UI.Margins)
					make.height.lessThanOrEqualTo(self.view.safeAreaLayoutGuide).multipliedBy(0.33)
					make.centerX.equalTo(self.view.safeAreaLayoutGuide)
					make.bottom.equalTo(self.view.snp.top)
				}
				
				self.view.layoutIfNeeded()
				
			} completion: { (finished) in
				
				dismissClosure(false)
			}
		}
		else if style == .HalfModal {
			
			UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.curveEaseInOut,.allowUserInteraction]) {
				
				self.backgroundView.alpha = 0.0
				
				self.containerView.snp.remakeConstraints { (make) in
					
					make.width.equalToSuperview()
					make.height.lessThanOrEqualTo(self.view.safeAreaLayoutGuide).inset(2*UI.Margins)
					make.centerX.equalTo(self.view.safeAreaLayoutGuide)
					make.top.equalTo(self.view.snp.bottom)
				}
				
				self.view.layoutIfNeeded()
				
			} completion: { (finished) in
				
				dismissClosure(false)
			}
		}
		else if style == .Popover {
			
			dismissClosure(true)
		}
	}
	
	public func add(view:UIView) {
		
		contentStackView.addArrangedSubview(view)
	}
	
	public func addHeader(view:UIView) {
		
		stickyHeaderStackView.addArrangedSubview(view)
	}
}

extension MB_Alert_Controller : UIPopoverPresentationControllerDelegate {
	
	public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		
		return .none
	}
	
	public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
		
		dismissOnBackgroundViewTapHandler?()
	}
}
