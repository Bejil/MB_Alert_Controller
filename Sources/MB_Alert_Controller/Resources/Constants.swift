//
//  Constants.swift
//
//
//  Created by BLIN Michael on 26/01/2022.
//

import UIKit

struct UI {
	
	static var MainController :UIViewController {
		
		return UIApplication.shared.topMostViewController()!
	}
	
	static let Margins:CGFloat = 15.0
	static let CornerRadius:CGFloat = Margins/2
}

struct Colors {
	
	static let Background:UIColor = UIColor(named: "Background")!
	static let Shadow:UIColor = UIColor(named: "Shadow")!
	static let Secondary:UIColor = UIColor(named: "Secondary")!
	static let Title:UIColor = UIColor(named: "Title")!
	static let Text:UIColor = UIColor(named: "Text")!
	static let Red:UIColor = UIColor(named: "Red")!
}

struct Fonts {
	
	struct Size {
		
		static let Default:CGFloat = 14.0
	}
	
	struct Content {
		
		static let Regular:UIFont = .systemFont(ofSize: Fonts.Size.Default)
		static let Bold:UIFont = .boldSystemFont(ofSize: Fonts.Size.Default)
	}
	
	struct Button {
		
		static let Navigation:UIFont = .boldSystemFont(ofSize: Fonts.Size.Default-1)
	}
	
	struct Title {
		
		static let H2:UIFont = .boldSystemFont(ofSize: Fonts.Size.Default+6)
	}
}
