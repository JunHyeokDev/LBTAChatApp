//
//  LoginController+handlers.swift
//  LBTAChatApp
//
//  Created by 김준혁 on 2023/02/19.
//

import UIKit
import Firebase
import FirebaseStorage


extension LoginController : UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    
    @objc func handleSelectProfileImageView() {
        
        print(123)
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion:  nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker : UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        }
        
        else if let originalImage = info[.originalImage] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
            
        }
        dismiss(animated: true)
        
    }
    
    @objc func loginRegisterTapped() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else { return }
        
        
        Auth.auth().createUser(withEmail: email, password: password) { (FIRUser, error) in
            if error != nil {
                print(error ?? "hmm Error?")
                return
            }
            
            guard let uid = FIRUser?.user.uid else { return }
            let imageName = NSUUID().uuidString
            
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")

            guard let image = self.profileImageView.image else {
                print("Error: no image found")
                return
            }

            guard let imageData = image.jpegData(compressionQuality: 0.1) else {
                print("Error: failed to get image data")
                return
            }
  
            let uploadTask = storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    return
                }
                
                storageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        print("Error getting download URL: \(error?.localizedDescription ?? "unknown error")")
                        return
                    }
                    let myURL = downloadURL.absoluteString
                    let values = ["name" : name , "email" : email, "profileImageUrl" : myURL]
                    self.registerUserIntoDatabaseWithUID(uid: uid, values: values)
                }
                print("Image uploaded successfully")
            }
            uploadTask.resume()
            
            
        }
    }
    
    
    private func registerUserIntoDatabaseWithUID(uid : String, values : [String : String]) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid)
        usersReference.updateChildValues(values) { err, ref in
            if err != nil {
                print(err)
                return
            }
            
            //self.messagesController?.fetchUserAndSetupNavBarTitle()
//            self.messagesController?.navigationItem.title = values["name"] as? String
            
            let user = User()
            self.messagesController?.setupNavBarWithUser(user: user)
            
            self.dismiss(animated: true, completion: nil)
            print("saved user successfully into Firebase DB")
        }
    }
    
    
}
