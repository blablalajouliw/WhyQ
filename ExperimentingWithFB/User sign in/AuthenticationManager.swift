
import Foundation
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import FirebaseFirestore

struct AuthDataResult {
    let uid: String
    let isAnonymous: Bool
    let email: String?
    let photoURL: String?
    
    init(user: User) {
        self.uid = user.uid
        self.isAnonymous = user.isAnonymous
        self.email = user.email
        self.photoURL = user.photoURL?.absoluteString
    }
}


final class AuthenticationManager: ObservableObject {
    var changeEmail: Bool = false
    var password: String = ""
    var email: String = ""
    
    func signInAnonymously() async throws -> AuthDataResult? {
        let authDataResult = try await Auth.auth().signInAnonymously()
        let user = authDataResult.user
        print("User succesfully signed in: \(user.uid)")
        do {
            let userData: [String: Any] = [
                "user_id" : user.uid,
                "email" : user.email ?? "nil",
                "log_in_dates": [Date()],
                "number_of_quizzes_attempted": 0
            ]
            
            
            let _: Void = try await Firestore.firestore().collection("users").document(user.uid).setData(userData)
            _ = Firestore.firestore().collection("users").document(user.uid).collection("quiz_activity").document("quizzes_attempted")
            
            _ = Firestore.firestore().collection("users").document(user.uid).collection("quizzes_created").document("quizzes_created")
            print("Document added with ID: \(user.uid)")
        } catch {
            print("Error adding document: \(error)")
        }
        return AuthDataResult(user: user)
    }
    
    
    func getUserProfile() async throws -> (AuthDataResult?, DocumentReference?) {
        var areasOfDifficulty: DocumentReference? = nil
        if let user = Auth.auth().currentUser {
            
            
            
            if let userEmail = user.email {
                print("\(userEmail)")
            }
            if user.photoURL != nil {
                print("Photo URL existent.")
            }
            do {
                let userData: [String: Any] = [
                    "user_id" : user.uid,
                    "email" : user.email ?? "nil",
                    "log_in_dates": [Date()],
                    "number_of_quizzes_attempted": 0
                ]
                
                
                let _: Void = try await Firestore.firestore().collection("users").document(user.uid).setData(userData)
                let newCollection = Firestore.firestore().collection("users").document(user.uid).collection("quiz_activity")
                _ = newCollection.document("quiz_activity")
                areasOfDifficulty = Firestore.firestore().collection("users").document(user.uid).collection("quiz_activity").document("areas_of_difficulty")
                _ = Firestore.firestore().collection("users").document(user.uid).collection("quizzes_created").document("quizzes_created")
                print("Document added with ID: \(user.uid)")
            } catch {
                print("Error adding document: \(error)")
            }
            return (AuthDataResult(user: user), areasOfDifficulty)
        }
        print("Couldn't find any user")
        return (nil, nil)
    }
    
    
    func signUpWithEmail(email: String, password: String) async throws -> AuthDataResult {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        /*do {
            let userData: [String: Any] = [
                "user_id" : user.uid,
                "email" : user.email ?? "nil",
                "log_in_dates": [Date()],
                "number_of_quizzes_attempted": 0
            ]
            
            
            let _: Void = try await Firestore.firestore().collection("users").document(user.uid).setData(userData)
            let newCollection = Firestore.firestore().collection("users").document(user.uid).collection("quiz_activity")
            _ = newCollection.document("quiz_activity")
            areasOfDifficulty = Firestore.firestore().collection("users").document(user.uid).collection("quiz_activity").document("areas_of_difficulty")
            _ = Firestore.firestore().collection("users").document(user.uid).collection("quizzes_created").document("quizzes_created")
            print("Document added with ID: \(user.uid)")
        } catch {
            print("Error adding document: \(error)")
        }
         */
        return AuthDataResult(user: authDataResult.user)
    }
    
    func signInWithEmail(email: String, password: String) async throws -> AuthDataResult {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResult(user: authDataResult.user)
    }
    
        
    func linkAnonymousToEmail(email: String, password: String) {
        guard let user = Auth.auth().currentUser else {
            print("No current user is logged in")
            return
        }
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            
            user.link(with: credential) { authResult, error in
                if let error = error {
                    print("Error linking anonymous account to email: \(error.localizedDescription)")
                    return
                }
                
                
                if let authResult = authResult {
                    print("Successfully linked anonymous user to email: \(authResult.user.email ?? "No Email")")
                }
            }
    }
    
    func signOut() async throws {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: \(signOutError)")
        }
    }
    
    func deleteAccount() {
        let user = Auth.auth().currentUser

        user?.delete { error in
          if let error = error {
            
              print(error)
          } else {
            
              print("The account was successfully deleted.")
          }
        }
    }
    
    func changeCredentials(email: String, password: String) {
        
        guard let user = Auth.auth().currentUser else {
            print("No current user is logged in")
            return
        }
        
        if changeEmail == false {
            Auth.auth().currentUser?.updatePassword(to: password) { error in
                if error != nil {
                    print("Couldn't change the user's password.")
                }
                self.password = password
            }
        } else {
            Auth.auth().currentUser?.sendEmailVerification(beforeUpdatingEmail: user.email ?? "") { error in
                if error != nil {
                    print("Couldn't change the user's email.")
                }
                self.email = password
            }
        }
    }
}
    
 //   func signInWithGoogle() {
        
  //  }

