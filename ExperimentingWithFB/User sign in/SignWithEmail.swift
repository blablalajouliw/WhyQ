
import SwiftUI
import FirebaseAuth

struct SignWithEmail: View {
    @StateObject var authenticationManager = AuthenticationManager()
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var showEmailAlert = false
    @Binding var showProfileView: Bool
    
    func EmailSignIn(email: String, password: String) async throws -> AuthDataResult? {
        let authDataResult = try await authenticationManager.signUpWithEmail(email: email, password: password)
        if let userEmail = authDataResult.email {
            print("The user is signed in: email: \(userEmail)")
            if userEmail != "" {
                showProfileView.toggle()
            }
        } else {
            print("The user isn't signed in")
        }
        return authDataResult
    }
    
    func linkEmailtoAnonymous(email: String, password: String) {
        Task {
            if let userProfile = try await authenticationManager.getUserProfile().0 {
                if userProfile.isAnonymous == true {
                    showAlert.toggle()
                    
                } else {
                    showProfileView = true
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            if showProfileView {
                ProfileView(showProfileView: $showProfileView) 
            } else {
                
                TextField("Enter you email", text: $email)
                TextField("Enter your password", text: $password)
                
                Button("Sign In With Email") {
                    Task {
                        _ = try await EmailSignIn(email: email, password: password)
                        showProfileView.toggle()
                    }
                    
                }
                .onAppear {
                    Task {
                        linkEmailtoAnonymous(email: email, password: password)
                    }
                }
                .alert("Do you want to create an account and link your current user data to it ?", isPresented: $showAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("OK") {
                        
                        showEmailAlert.toggle()
                    }
                }
                .alert("Type in your email address and password.", isPresented: $showEmailAlert) {
                    Button("Cancel", role: .cancel) { }
                    TextField("Type in your email", text: $email)
                    TextField("Type in your password", text: $password)
                    Button("Done") {
                        if email != "" && password != "" {
                            authenticationManager.linkAnonymousToEmail(email: email, password: password)
                            showProfileView.toggle()
                        } else {
                            showEmailAlert.toggle()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SignWithEmail(showProfileView: .constant(false))
}
