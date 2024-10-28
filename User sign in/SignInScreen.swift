
import SwiftUI
import FirebaseAuth

struct SignInScreen: View {
    @StateObject private var authenticationManager = AuthenticationManager()
    @State private var showProfileView = false
    @State private var hasAppeared = false
    @State private var userId = ""
    @State private var userEmail = ""
    @StateObject private var databaseManager = DataBase()
    
    func getCurrentUser() async throws -> AuthDataResult? {
        let authDataResult = try await  authenticationManager.getUserProfile().0
       
        if authDataResult != nil {
                showProfileView.toggle()
                print("User is signed in: \(userId)")
            } else {
                showProfileView.toggle()
                print("No user is signed in.")
            }
        return authDataResult
    }
    
    var body: some View {
        if showProfileView && hasAppeared {
            ProfileView(showProfileView: $showProfileView)
        } else {
            
            Button("Sign In Anonymously") {
                
                Task {
                    _ = try await authenticationManager.signInAnonymously()
                }
                showProfileView = true
                
            }
            .onAppear {
                if !hasAppeared {
                    hasAppeared = true
                    Task {
                        try await getCurrentUser()
                    }
                }
            }
            NavigationLink("Sign In With Email", destination: SignWithEmail(showProfileView: $showProfileView))
        }
    }
}
#Preview {
    NavigationStack {
        SignInScreen()
    }
}

/*private func handleUserProfile() async {
    do {
        if Auth.auth().currentUser != nil {
            let userProfile = try await authenticationManager.getUserProfile().0
            showProfileView.toggle()
            if let userProfile = userProfile {
                userId = userProfile.uid
                userEmail = userProfile.email ?? "No email"
                showProfileView.toggle()
            } else {
                showProfileView.toggle()
            }
        } else {
            showProfileView.toggle()
        }
    } catch {
        print("Failed to fetch user information: \(error.localizedDescription)")
    }
}
 */


