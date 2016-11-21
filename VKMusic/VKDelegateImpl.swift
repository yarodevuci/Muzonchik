import SwiftyVK
import UIKit

class VKDelegateImpl:  VKDelegate {
    
    let appID = "5631246"
    let scope: Set<VK.Scope> = [.offline, .audio]
    
    init() {
        
        VK.configure(withAppId: appID, delegate: self)
    }
    
    func vkAutorizationFailedWith(error: AuthError) {
        print("Autorization failed with error: \n\(error)")
    }
    
    func vkWillAuthorize() -> Set<VK.Scope> {
        print("\nWill Authorize Scope: \(scope)\n")
        return scope
    }
    
    func vkDidAuthorizeWith(parameters: Dictionary<String, String>) {
        print(parameters)
        print("access_token: \(parameters["access_token"]!)")
        _ = VK.API.Stats.trackVisitor([.token : parameters["access_token"]! ])
        
    }
    
    func vkDidUnauthorize() {}
    
    func vkShouldUseTokenPath() -> String? {
        return nil
    }
    
    func vkWillPresentView() -> UIViewController {
        return UIApplication.shared.delegate!.window!!.rootViewController!
    }
    
}
