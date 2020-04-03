//
//  UINavigationWrapper.swift
//  Pods-Runner
//
//  Created by Roman Matroskin on 16.03.2020.
//

import Foundation
public class UINavigationWrapper: UINavigationController {
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        let backButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onBack(sender:)))
        rootViewController.navigationItem.leftBarButtonItem = backButton
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    @IBAction func onBack(sender:UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
