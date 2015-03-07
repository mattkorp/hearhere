//
//  SignInViewController.swift
//  HearHereApp
//
//  Created by Luyuan Xing on 3/5/15.
//  Copyright (c) 2015 LXing. All rights reserved.
//

import UIKit
import Parse

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Views
    var spinner: UIActivityIndicatorView!
    var username: UITextField!
    var password: UITextField!
    var loginSuccessErrorLabel: UILabel!
    var scrollView: UIScrollView!
    
    // MARK: Customizable view properties
    let paddingX:CGFloat     = 30
    let paddingY:CGFloat     = 20
    let cornerRadius:CGFloat = 10
    
    // MARK: VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Configuration.backgroundUIColor

        loadUI()
        
        spinner.hidden = true
        spinner.hidesWhenStopped = true
        
        username.delegate = self
        password.delegate = self
        
        var tapToDismissKeyboard = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tapToDismissKeyboard.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapToDismissKeyboard)
        
    }

    /**
    load UI elements
    */
    func loadUI() {
        let screenBounds = UIScreen.mainScreen().bounds

        // scrollview
        scrollView = UIScrollView(frame: CGRectMake(0, 0, screenBounds.width, screenBounds.height))
        scrollView.contentSize = CGSize(width: screenBounds.width, height: screenBounds.height + 500)
        scrollView.autoresizingMask = .FlexibleBottomMargin | .FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleTopMargin
        scrollView.scrollEnabled = false
        scrollView.userInteractionEnabled = true
        view.addSubview(scrollView)
        
        // spinner
        spinner = UIActivityIndicatorView()//frame: CGRectMake(screenBounds.width/2, screenBounds.height/2, 50, 50))
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        spinner.autoresizingMask = .FlexibleBottomMargin | .FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleTopMargin
        scrollView.addSubview(spinner)
        
        // title. replace with logo
        let titleLabel = UILabel(frame: CGRectMake(paddingX,topLayoutGuide.length+paddingY*3, screenBounds.width-paddingX*2, 50))
        titleLabel.text = "HearHere"
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.font = UIFont(name: "HelveticaNeue-Light", size: 50.0)
        titleLabel.autoresizingMask = .FlexibleBottomMargin | .FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleWidth
        scrollView.addSubview(titleLabel)
        
        // Error/Success label
        loginSuccessErrorLabel = UILabel(frame: CGRectMake(paddingX, titleLabel.frame.maxY+paddingY, screenBounds.width-paddingX*2, 20))
        loginSuccessErrorLabel.textAlignment = NSTextAlignment.Center
        scrollView.addSubview(loginSuccessErrorLabel)
        
        // text fields
        username = UITextField(frame: CGRectMake(paddingX*2, loginSuccessErrorLabel.frame.maxY+paddingY, screenBounds.width-paddingX*4, 50))
        username.autoresizingMask = .FlexibleBottomMargin | .FlexibleLeftMargin | .FlexibleRightMargin
        username.backgroundColor = UIColor.whiteColor()
        username.placeholder = "Username"
        username.textAlignment = NSTextAlignment.Center
        username.layer.cornerRadius = cornerRadius
        scrollView.addSubview(username)
        password = UITextField(frame: CGRectMake(paddingX*2, username.frame.maxY+paddingY, screenBounds.width-paddingX*4, 50))
        password.autoresizingMask = .FlexibleBottomMargin | .FlexibleLeftMargin | .FlexibleRightMargin
        password.backgroundColor = UIColor.whiteColor()
        password.placeholder = "Password"
        password.secureTextEntry = true
        password.textAlignment = NSTextAlignment.Center
        password.layer.cornerRadius = cornerRadius
        scrollView.addSubview(password)
        
        // Buttons
        var signInButton = UIButton(frame: CGRectMake(paddingX*2, password.frame.maxY+paddingY, screenBounds.width-paddingX*4, 50))
        signInButton.autoresizingMask = .FlexibleBottomMargin | .FlexibleLeftMargin | .FlexibleRightMargin
        signInButton.setTitle("Sign In", forState: .Normal)
        signInButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        signInButton.layer.cornerRadius = cornerRadius
        signInButton.backgroundColor = Configuration.buttonUIColor
        signInButton.addTarget(self, action: "signInPressed:", forControlEvents: .TouchUpInside)
        scrollView.addSubview(signInButton)
        
        var signUpButton = UIButton(frame: CGRectMake(0, signInButton.frame.maxY+paddingY, screenBounds.width, 30))
        signUpButton.autoresizingMask = .FlexibleBottomMargin | .FlexibleLeftMargin | .FlexibleRightMargin
        signUpButton.addTarget(self, action: "signUpTouched:", forControlEvents: .TouchUpInside)
        signUpButton.setTitle("Don't have an account? Sign up here.", forState: .Normal)
        signUpButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        scrollView.addSubview(signUpButton)
        
        var signInNowButton = UIButton(frame: CGRectMake(paddingX, signUpButton.frame.maxY+paddingY, screenBounds.width-paddingX*2, 30))
        signInNowButton.autoresizingMask = .FlexibleBottomMargin | .FlexibleLeftMargin | .FlexibleRightMargin
        signInNowButton.addTarget(self, action: "skipToAppTouched:", forControlEvents: .TouchUpInside)
        signInNowButton.setTitle("Skip for now.", forState: .Normal)
        signInNowButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        scrollView.addSubview(signInNowButton)
        
    }
    
    // MARK: Button Target methods
    func skipToAppTouched(sender: UIButton) {
        self.performSegueWithIdentifier("main", sender: self)
    }
    
    func signUpTouched(sender: UIButton) {
        self.performSegueWithIdentifier("signup", sender: self)
    }

    // Sign in user and send to main app upon success, otherwise give feedback
    func signInPressed(sender: UIButton?) {
        spinner.hidden = false
        spinner.startAnimating()
        PFUser.logInWithUsernameInBackground(username.text, password: password.text) {
            (user: PFUser!, error: NSError!) in
            if user != nil {
                self.performSegueWithIdentifier("main", sender: self)				
            } else {
                self.spinner.stopAnimating()
                self.displaySuccessErrorLabel("Invalid login credentials. Try again.", valid: false)
            }
        }
    }
    
    // Error label
    func displaySuccessErrorLabel(text: String, valid: Bool) {
        loginSuccessErrorLabel.text = text
        loginSuccessErrorLabel.textColor = valid ? UIColor.greenColor() : UIColor.redColor()
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: { self.loginSuccessErrorLabel.alpha = 1.0 }, completion: { _ in UIView.animateWithDuration(5.0) { self.loginSuccessErrorLabel.alpha = 0.0 } })
    }
    
    // MARK: TextFieldDelegate methods and keyboard behavior
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == username {
            password.becomeFirstResponder()
        } else {
            // TODO: Change this to LoginPressed
            textField.resignFirstResponder()
            signInPressed(nil)
        }
        return true
    }
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        username.resignFirstResponder()
        password.resignFirstResponder()
    }
    
    func dismissKeyboard() {
        touchesBegan(NSSet(), withEvent: UIEvent())
        textFieldDidEndEditing(username)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        var scrollTo: CGPoint = CGPointMake(0, loginSuccessErrorLabel.frame.origin.y)
        UIView.animateWithDuration(0.5) {
            self.scrollView.setContentOffset(scrollTo, animated: true)
        }
    }
    func textFieldDidEndEditing(textField: UITextField) {
        scrollView.setContentOffset(CGPointZero, animated: true)
    }

}
