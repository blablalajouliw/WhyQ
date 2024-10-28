


import SwiftUI
import Firebase
import FirebaseCore
import FirebaseFirestore

@main
struct FirebaseBootcampApp: App {
    
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
        
    
    var body: some Scene {
        WindowGroup {
            SignInScreen()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
      print("Configured Firebase !")
      return true
  }
}
