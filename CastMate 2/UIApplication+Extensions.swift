import UIKit

extension UIApplication {
    static var rootController: UIViewController {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        return window!.rootViewController!
    }
}
