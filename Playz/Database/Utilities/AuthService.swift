//
//  AuthService.swift
//  Playz
//
//  Created by Johan on 30-04-18.
//  Copyright © 2018 Devmans. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseUI

class AuthService {
    
    static func signIn(email: String, password: String, onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (_, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            onSuccess()
        })
        
    }
    
    static func twitterLogin(credential: AuthCredential, onSucces: @escaping () -> Void, onError: @escaping(_ errorMessage: String?) -> Void) {
        Auth.auth().signInAndRetrieveData(with: credential) { (_, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            onSucces()
        }
    }
    
    static func googleLogin(credential: AuthCredential, onSucces: @escaping () -> Void, onError: @escaping(_ errorMessage: String?) -> Void) {
        Auth.auth().signInAndRetrieveData(with: credential) { (_, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            onSucces()
        }
        
    }
    
    static func facebookLogin(credential: AuthCredential, onSucces: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        Auth.auth().signInAndRetrieveData(with: credential) { (_, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            onSucces()
        }
    }
    
    static func signUp(username: String, email: String, password: String, imageData: Data, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (_, error) in
            
            // LOOK ON THE COMMENTED PART BELOW
            // THAT DOESNT WORK WITH THE UPDATED SDK
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            let uid = Auth.auth().currentUser?.uid
            let storageRef = Storage.storage().reference(forURL: DatabaseReferences.ds.REF_STORAGE_ROOT).child("profile_image").child(uid!)
            
            storageRef.putData(imageData, metadata: nil, completion: { (_, error) in
                if error != nil {
                    return
                }
                storageRef.downloadURL { (url, _) in
                    guard let profileImageUrl = url else {
                        // Uh-oh, an error occurred!
                        return
                    }
                    
                    self.setUserInfomation(profileImageUrl: profileImageUrl.absoluteString, username: username, email: email, uid: uid!, onSuccess: onSuccess)
                }
                
            })
            
        })
    }
    
    static func addUserToDatabaseTroughSocial(uid: String, profilePictureUrl: String, email: String, displayName: String, oncompletion : @escaping () -> Void) {
        DatabaseReferences.ds.REF_USERS.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value == nil {
                self.setUserInfomation(profileImageUrl: profilePictureUrl, username: displayName, email: email, uid: uid, onSuccess: {
                    print("FBDATABASE", "AddSocial value of snapshot was null , creating new user in database!" )
                })
            }
            
            print ("FBDATABASE", "AddSocial dataSnapshot : USER EXISTS ALREADY IN DATABASE. NOT ADDING NEW USER." )
            oncompletion()
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    static func checkIfuserAlrdyExistInDatabase(with uid: String, completion: @escaping (_ userExist: Bool, _ user: UserModel?) -> Void) {
        Database.database().reference().child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                //User exist
                completion(true, UserModel())
            } else {
                completion(false, nil)
                
            }
        }
    }
    
    static func setUserInfomation(profileImageUrl: String, username: String, email: String, uid: String, onSuccess: @escaping () -> Void) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users")
        let newUserReference = usersReference.child(uid)
        newUserReference.setValue(["user_name": username, "user_name_lowercase": username.lowercased(), "email": email, "profile_image_url": profileImageUrl])
        onSuccess()
    }
    
    static func updateUserProfile (type: String?, imageData: Data, onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
        let uid = UserObserver().CURRENT_USER?.uid
        let profileImage = (type == "Profile") ? "profile_image" : "profile_background_image"
        let profileImgUrlStr = (type == "Profile") ? "profile_image_url" : "background_image_url"
        let storageRef = Storage.storage().reference(forURL: DatabaseReferences.ds.REF_STORAGE_ROOT).child(profileImage).child(uid!)
        
        storageRef.putData(imageData, metadata: nil, completion: { (_, error) in
            if error != nil {
                return
            }
            storageRef.downloadURL { (url, _) in
                guard let imageUrl = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                
                self.updateProfileSettings (imageType: profileImgUrlStr, imageURL: imageUrl.absoluteString, onSuccess: onSuccess, onError: onError)
                
            }
        })
    }
    
    static func updateUserSettings(username: String, email: String, onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
        
        let dict = ["user_name": username, "email": email]
        UserObserver().REF_CURRENT_USER?.updateChildValues(dict, withCompletionBlock: { (error, _) in
            if error != nil {
                onError(error!.localizedDescription)
            } else {
                onSuccess()
            }
        })
        
    }
    
    static func updateProfileSettings(imageType: String, imageURL: String, onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
        
        let dict = [imageType: imageURL]
        UserObserver().REF_CURRENT_USER?.updateChildValues(dict, withCompletionBlock: { (error, _) in
            if error != nil {
                onError(error!.localizedDescription)
            } else {
                onSuccess()
            }
        })
        
    }
    
    static func updateUserInfor(username: String, email: String, imageData: Data, onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
        
        UserObserver().CURRENT_USER?.updateEmail(to: email, completion: { (error) in
            if error != nil {
                onError(error!.localizedDescription)
            } else {
                let uid = UserObserver().CURRENT_USER?.uid
                let storageRef = Storage.storage().reference(forURL: DatabaseReferences.ds.REF_STORAGE_ROOT).child("profile_image").child(uid!)
                
                storageRef.putData(imageData, metadata: nil, completion: { (_, error) in
                    if error != nil {
                        return
                    }
                    storageRef.downloadURL { (url, _) in
                        guard let profileImageUrl = url else {
                            // Uh-oh, an error occurred!
                            return
                        }
                        self.updateDatabase(profileImageUrl: profileImageUrl.absoluteString, username: username, email: email, onSuccess: onSuccess, onError: onError)
                    }
                })
            }
        })
    }
    
    static func updateDatabase(profileImageUrl: String, username: String, email: String, onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
        let dict = ["user_name": username, "user_name_lowercase": username.lowercased(), "email": email, "profile_image_url": profileImageUrl]
        UserObserver().REF_CURRENT_USER?.updateChildValues(dict, withCompletionBlock: { (error, _) in
            if error != nil {
                onError(error!.localizedDescription)
            } else {
                onSuccess()
            }
        })
    }
    
    static func logout(onSuccess: @escaping () -> Void, onError:  @escaping (_ errorMessage: String?) -> Void) {
        do {
            try Auth.auth().signOut()
            onSuccess()
            
        } catch let logoutError {
            onError(logoutError.localizedDescription)
        }
    }
}
