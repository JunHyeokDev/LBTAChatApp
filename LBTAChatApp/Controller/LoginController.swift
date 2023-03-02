//
//  LoginController.swift
//  LBTAChatApp
//
//  Created by 김준혁 on 2023/02/17.
//

import UIKit
import Firebase


class LoginController: UIViewController {

    var messagesController: MessagesController?
    
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor : NSLayoutConstraint?
    var emailTextFieldHeightAnchor : NSLayoutConstraint?
    var passwordTextFieldHeightAnchor : NSLayoutConstraint?

    var inputsContainerView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true //
        return view
    }()
    
    lazy var loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Register", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)

        return button
    }()

    
    let nameTextField : UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let nameSpeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        
    }()
    
    let emailTextField : UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let emailSpeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        
    }()
    
    let passwordTextField : UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        return tf
    }()
    
    
    // has to be lazy var but wait a sec
//    lazy var profileImageView : UIImageView = {
//        let imageView = UIImageView()
//        imageView.image = UIImage(named: "thor.png")
//        imageView.contentMode = .scaleAspectFit
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//
//        imageView.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
//        imageView.isUserInteractionEnabled = true
//
//
//        return imageView
//    }()
    
    lazy var profileImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "thor.png")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        imageView.isUserInteractionEnabled = true
        
        
        return imageView
    }()
    
   
    
    let loginRegisterSegmentedControl : UISegmentedControl = {
        // AHa 이런게있구먼 ㅎㅎ;;
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 1 // 아하 ㅋ 위에 로그인으로 보일지 레지스터로 보일지 ㅋ
        
        sc.addTarget(self, action: #selector(handleRegisterChange), for: .valueChanged)
        
        return sc
         
    }()
    
    @objc func handleLoginRegister() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            loginRegisterTapped()
        }
    }
    
    func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error)
                return
            }
            self.messagesController?.fetchUserAndSetupNavBarTitle()
            self.dismiss(animated: true,completion: nil)
        }
    }
    
    
    @objc func handleRegisterChange() {
        
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        
        // change height of inputContainerView, but how ?!?!?!
        inputsContainerViewHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        
        // change the height of tf
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        // change the height of tf
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        // change the height of tf
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    
    func setupLoginRegisterSegmentredControl() {
        NSLayoutConstraint.activate([
            loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12),
            loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor),
            loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(profileImageView)
        view.addSubview(loginRegisterSegmentedControl)
        
        
        setupInputContainerView()
        setupLoginRegisterButton()
        setProfileImageView()
        setupLoginRegisterSegmentredControl()
        
    }
    
    
//    override func preferredStatusBarStyle() -> UIStatusBarStyle {
//        return .lightContent
//    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    func setProfileImageView() {
        
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -12),
            profileImageView.widthAnchor.constraint(equalToConstant: 150),
            profileImageView.heightAnchor.constraint(equalToConstant: 150),
            
        ])
    }
    
    func setupInputContainerView() {
        // need x,y,width,height constraints
        
        
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameSpeparatorView)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSpeparatorView)
        inputsContainerView.addSubview(passwordTextField)
        
        
        NSLayoutConstraint.activate([
            inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24),
            //inputsContainerView.heightAnchor.constraint(equalToConstant: 150),
        ])
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerViewHeightAnchor?.isActive = true
        
        
        // nameTF
        NSLayoutConstraint.activate([
            nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12),
            nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor),
            nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor),

        ])
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        
        // nameSeperator
        NSLayoutConstraint.activate([
            nameSpeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor),
            nameSpeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor),
            nameSpeparatorView.heightAnchor.constraint(equalToConstant: 1),
            nameSpeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor),
        ])
        
        
        
        NSLayoutConstraint.activate([
            emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12),
            emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor),
            emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor),

        ])
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        NSLayoutConstraint.activate([
            emailSpeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor),
            emailSpeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor),
            emailSpeparatorView.heightAnchor.constraint(equalToConstant: 1),
            emailSpeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor),
        ])
        
        
        NSLayoutConstraint.activate([
            passwordTextField.topAnchor.constraint(equalTo: emailSpeparatorView.bottomAnchor),
            passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12),
            passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor),
            
        ])
        
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    func setupLoginRegisterButton() {
        NSLayoutConstraint.activate([
            loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12),
            loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor),
            loginRegisterButton.heightAnchor.constraint(equalToConstant: 50)
            
        ])
    }

}

extension UIColor {
    convenience init(r: CGFloat, g:CGFloat, b:CGFloat) {
        self.init(red : r/255, green : g/255, blue: b/255, alpha: 1)
    }
}




