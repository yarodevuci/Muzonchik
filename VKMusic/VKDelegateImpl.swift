import SwiftyVK
import UIKit

class VKDelegateImpl : VKDelegate {
    
    let appID = "5631246"
    let scope = [VK.Scope.audio,.offline]
    let window : AnyObject
    
    init(window_: AnyObject) {
        VK.defaults.logToConsole = false
        window = window_
        VK.configure(appID: appID, delegate: self)
    }
    
    func vkAutorizationFailedWith(error: VK.Error) {
        print("Autorization failed with error: \n\(error)")
    }
    
    func vkWillAuthorize() -> [VK.Scope] {
        print("\nWill Authorize Scope: \(scope)\n")
        return scope
    }
    
    func vkDidAuthorizeWith(parameters: Dictionary<String, String>) {
        print(parameters)
        print("access_token: \(parameters["access_token"]!)")
    }
    
    func vkDidUnauthorize() {}
    
    func vkShouldUseTokenPath() -> String? {
        return nil
    }
    
    func vkWillPresentView() -> UIViewController {
        return (self.window as! UIWindow).rootViewController!
    }
}
