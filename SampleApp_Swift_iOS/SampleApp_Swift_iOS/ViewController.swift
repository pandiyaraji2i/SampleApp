//
//  ViewController.swift
//  SampleApp_Swift_iOS
//
//  Created by Pandiyaraj on 13/10/16.
//  Copyright © 2016 Pandiyaraj. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var requestBtn: UIButton!
    @IBOutlet weak var showActivity: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //#-- by default it was hidden
        showActivity.hidden = true
       
        /* For making call like this
        /// Synchronous Request call
        let jsonObject =   NetworkUtilities.sendSynchronousRequestToServer("actionName", httpMethod: "POST", requestBody: nil, contentType: "application/json")
        print(jsonObject);
        
        
        /// Asynchronous Request call
        NetworkUtilities.sendAsynchronousRequestToServer("actionName", httpMethod: "POST", requestBody: nil, contentType: "application/json") { (obj) in
            
        }
        */
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showOrHideActivity(isShow : Bool) -> Void {
        if isShow {
            self.view.alpha = 0.7
            showActivity.startAnimating()
        }else{
            self.view.alpha = 1.0
            showActivity.stopAnimating()
        }
        showActivity.hidden = !isShow
    }
    
    @IBAction func sendButton(sender: UIButton) {
        
        self.showOrHideActivity(true)
        //#-- Asynchronous call request [GET]
        NetworkUtilities.sendAsynchronousRequestToServer("getText", httpMethod: "GET", requestBody: nil, contentType: "application/json") { (obj) in
            if obj.isKindOfClass(NSDictionary.classForCoder()){
                dispatch_async(dispatch_get_main_queue(), { 
                    self.showOrHideActivity(false)
                    self.resultLabel.text = obj.valueForKey("msg") as? String
                });
                
            }else{
                 //#-- Show error message
            }
        }
    }
    
    


}

