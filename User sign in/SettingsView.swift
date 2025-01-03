

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @StateObject private var authenticationManager = AuthenticationManager()
    @State private var newEmail = ""
    @State private var newPassword = ""
    @State private var showUpdateEmailAlert = false
    @State private var showUpdatePasswordAlert = false
    @State private var userIsAnonymous = false
    @State private var showAnonymousAlert = false
    @State private var showLinkingAddress = false
    @Binding var showProfileView: Bool
    @State private var userProfile: AuthDataResult? = nil
    @State private var showLogOutButton = false
    @State private var showLogOutAlert = false
    
    
    
    
    var body: some View {
        if showProfileView == false {
            SignInScreen()
            
        } else if userIsAnonymous {
            Button("Link profile to mail") {
                authenticationManager.changeEmail = true
                showAnonymousAlert.toggle()
            }
            .alert("Are you sure you want to link your profile to an exist email address or google account ?", isPresented: $showAnonymousAlert) {
                Button("OK") {
                    showLinkingAddress.toggle()
                }
                Button("Cancel", role: .cancel) { }
            }
            .alert("Type in your email address and password.", isPresented: $showLinkingAddress) {
                Button("Cancel", role: .cancel) { }
                TextField("Type in your email", text: $newEmail)
                TextField("Type in your password", text: $newPassword)
                Button("Done") {
                    if newEmail != "" && newPassword != "" {
                        authenticationManager.linkAnonymousToEmail(email: newEmail, password:  newPassword)
                    } else {
                        showLinkingAddress.toggle()
                    }
                }
            }
            
            Button("Log Out") {
                showLogOutAlert.toggle()
                                
            }
            .alert("Are you sure you want to log out of this account ?", isPresented: $showLogOutAlert) {
                Text("This action cannot be undone.")
                //Verification link to add
                Button("OK") {
                    Task {
                        try await authenticationManager.signOut()
                    }
                    showLogOutAlert.toggle()
                    showProfileView = false
                    
                }
                Button("Cancel", role: .cancel) {
                    showLogOutAlert.toggle()
                    
                }
            }
        } else if userIsAnonymous == false {
            
            Button("Update email") {
                authenticationManager.changeEmail = true
                showUpdateEmailAlert.toggle()
            }
            .alert("Are you sure you want to change your email ?", isPresented: $showUpdateEmailAlert) {
                Text("This action cannot be undone.")
                // Verification link to add
                TextField("Enter your new email.", text: $newEmail)
                Button("Change") {
                    authenticationManager.changeCredentials(email: newEmail, password: authenticationManager.password)
                    showUpdateEmailAlert.toggle()
                    
                }
                Button("Cancel", role: .cancel) {
                    showUpdateEmailAlert.toggle()
                    
                }
                
            }
            Button("Update password") {
                authenticationManager.changeEmail = false
                showUpdatePasswordAlert.toggle()
                
            }
            .alert("Are you sure you want to change your password ?", isPresented: $showUpdatePasswordAlert) {
                Text("This action cannot be undone.")
                // Verification link to add
                TextField("Enter your new password.", text: $newPassword)
                Button("Change") {
                    authenticationManager.changeCredentials(email: authenticationManager.email, password: newPassword)
                    showUpdatePasswordAlert.toggle()
                    showProfileView = true
                    
                }
                Button("Cancel", role: .cancel) {
                    showUpdatePasswordAlert.toggle()
                    
                }
            }
            
            Button("Log Out") {
                showLogOutAlert.toggle()
                
            }
            .alert("Are you sure you want to log out of this account ?", isPresented: $showLogOutAlert) {
                Text("This action cannot be undone.")
                // Verification link to add
                Button("OK") {
                    Task {
                        try await authenticationManager.signOut()
                    }
                    showLogOutAlert.toggle()
                    
                    
                }
                Button("Cancel", role: .cancel) {
                    showLogOutAlert.toggle()
                    
                }
            }
            
            
            .onAppear {
                Task {
                    if let userProfile = try await authenticationManager.getUserProfile().0 {
                        showLogOutButton.toggle()
                        showProfileView = true
                        if userProfile.isAnonymous {
                            userIsAnonymous.toggle()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(showProfileView: .constant(false))
    }
}
