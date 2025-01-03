
import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @Binding var showProfileView: Bool
    @StateObject private var authenticationManager = AuthenticationManager()
    @StateObject private var databaseManager = DataBase()
    @State private var userInfo: (String, String, Bool) = ("", "", false)
    @State private var userEmail = ""
    @State private var userId = ""
    @State private var isAnonymous = false
    
    
    
    func getCurrentUser() async throws -> (String, String, Bool) {
        let authDataResult = try await  authenticationManager.getUserProfile().0
       
        if let userInfo = authDataResult {
            userId = userInfo.uid
            showProfileView = true
            if let email = userInfo.email {
                userEmail = email
                isAnonymous = false
                print("User is signed in: \(userId)")
            } else {
                isAnonymous = true
            }
            } else {
                showProfileView = false
                print("No user is signed in.")
            }
        return (userId, userEmail, isAnonymous)
    }
    
    var body: some View {
        if showProfileView {
            Text("UserID: \(userInfo.0)")
            Text("UserEmail: \(userInfo.1)")
            Text("Anonymous: \(userInfo.2)")
            NavigationLink("Choose Quiz", destination: QuizManagerView(showProfileView: $showProfileView))
            NavigationLink("Created Quizzes", destination: QuizzesCreatedPanel())
            .navigationTitle("Profile")
            .onAppear {
                Task {
                    userInfo = try await getCurrentUser()
                    /*userId = try await getCurrentUser()?.uid ?? ""
                    userEmail = try await getCurrentUser()?.email ?? "No email"
                    isAnonymous = try await getCurrentUser()?.isAnonymous ?? false
                     */
                                        
                    
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView(showProfileView: $showProfileView)
                    } label: {
                        Image(systemName: "gear")
                            .font(.headline)
                    }
                    
                }
            }
        } else {
            SignInScreen()
       }
    }
}

#Preview {
    NavigationStack {
        ProfileView(showProfileView: .constant(false))
    }
}
