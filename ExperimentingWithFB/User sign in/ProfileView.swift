
import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @Binding var showProfileView: Bool
    @StateObject private var authenticationManager = AuthenticationManager()
    @StateObject private var databaseManager = DataBase()
    @State private var userEmail = ""
    @State var userId = "" 
    @State private var isAnonymous = false
    
    
    
    func getCurrentUser() async throws -> AuthDataResult? {
        let authDataResult = try await  authenticationManager.getUserProfile().0
       
        if authDataResult != nil {
            userId = authDataResult?.uid ?? ""
            userEmail = authDataResult?.email ?? "Anonymous User"
                showProfileView = true
                print("User is signed in: \(userId)")
            } else {
                showProfileView = false
                print("No user is signed in.")
            }
        return authDataResult
    }
    
    var body: some View {
        if showProfileView {
            Text("UserID: \(userId)")
            Text("UserEmail: \(userEmail)")
            Text("Anonymous: \(isAnonymous)")
            NavigationLink("Choose Quiz", destination: QuizManagerView(showProfileView: $showProfileView))
            NavigationLink("Created Quizzes", destination: QuizzesCreatedPanel())
            .navigationTitle("Profile")
            .onAppear {
                Task {
                    userId = try await getCurrentUser()?.uid ?? ""
                    userEmail = try await getCurrentUser()?.email ?? "No email"
                    isAnonymous = try await getCurrentUser()?.isAnonymous ?? false
                    // There are three different loads which isn't scalable, I should find a way to load the data only once
                    
                    
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
