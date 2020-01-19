//
//  SpinnerViewController.swift
//  CatID
//
//  Created by Ismail Elmaliki on 1/18/20.
//  Copyright © 2020 Ismail Elmaliki. All rights reserved.
//
import Foundation
import UIKit
import SVProgressHUD

class SpinnerViewController {
	
	private var container: UIView = UIView()
	private var loadingView: UIView = UIView()
	private var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
	
	
	
	func showActivityIndicatory(uiView: UIView) {
		SVProgressHUD.show()
		container.frame = uiView.frame
		container.center = uiView.center
		container.backgroundColor = UIColorFromHex(rgbValue: 0xffffff, alpha: 0.3)

		loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
		loadingView.center = uiView.center
		loadingView.backgroundColor = UIColorFromHex(rgbValue: 0x444444, alpha: 0.7)
		loadingView.clipsToBounds = true
		loadingView.layer.cornerRadius = 10

		activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
		activityIndicator.style =
			UIActivityIndicatorView.Style.medium
		activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2,
								y: loadingView.frame.size.height / 2);
		
		loadingView.addSubview(activityIndicator)
		container.addSubview(loadingView)
		uiView.addSubview(container)
		activityIndicator.startAnimating()
	}
	
	func hideActivityIndicator(uiView: UIView) {
        activityIndicator.stopAnimating()
        container.removeFromSuperview()
    }
	
	private func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
}
