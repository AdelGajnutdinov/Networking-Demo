//
//  SignUpViewController.swift
//  Networking
//
//  Created by Adel Gainutdinov on 14.11.2021.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    private var continueButtonCenter: CGPoint!
    lazy var continueButton: UIButton = {
        var button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        button.center = continueButtonCenter
        button.backgroundColor = .white
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(SECONDARY_COLOR, for: .normal)
        button.layer.cornerRadius = 4
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addVerticalGradientLayer(topColor: PRIMARY_COLOR, bottomColor: SECONDARY_COLOR)
        self.continueButtonCenter = CGPoint(x: view.center.x, y: view.frame.height - 200)
        view.addSubview(continueButton)
        setContinueButton(enabled: false, wait: false)
        
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = SECONDARY_COLOR
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = continueButton.center
        view.addSubview(activityIndicator)
        
        usernameTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        confirmPasswordTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillAppear),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    private func setContinueButton(enabled: Bool, wait: Bool) {
        if enabled {
            self.continueButton.alpha = 1
            self.continueButton.isEnabled = true
        } else  {
            self.continueButton.alpha = 0.5
            self.continueButton.isEnabled = false
        }
        
        if wait {
            continueButton.setTitle("", for: .normal)
            activityIndicator?.startAnimating()
        } else {
            continueButton.setTitle("Continue", for: .normal)
            activityIndicator?.stopAnimating()
        }
    }
    
    @objc private func handleSignUp() {
        setContinueButton(enabled: false, wait: true)
        
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let username = usernameTextField.text else { return }
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] user, error in
            if let error = error {
                print(error.localizedDescription)
                self?.setContinueButton(enabled: true, wait: false)
                return
            }
            print("Successfully logged into Firebase using email!")
            
            // change default Firebase username with provided by user
            if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                changeRequest.displayName = username
                changeRequest.commitChanges { [weak self] error in
                    if let error = error {
                        print(error.localizedDescription)
                        self?.setContinueButton(enabled: true, wait: false)
                        return
                    }
                    print("User display name changed!")
                    self?.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true)
                }
            }
        }
    }
    
    @objc private func textFieldChanged() {
        
        guard let username = self.usernameTextField.text,
              let email = self.emailTextField.text,
              let password = self.passwordTextField.text,
              let confirm = self.confirmPasswordTextField.text else { return }
        let isDisabled = username.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty || !password.elementsEqual(confirm)
        setContinueButton(enabled: !isDisabled, wait: false)
    }
    
    @objc func keyboardWillAppear(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        continueButton.center = CGPoint(x: view.center.x,
                                        y: view.frame.height - keyboardFrame.height - 16.0 - continueButton.frame.height / 2)
        activityIndicator.center = continueButton.center
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        continueButton.center = continueButtonCenter
        activityIndicator.center = continueButton.center
    }
}
