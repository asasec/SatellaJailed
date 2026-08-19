import UIKit

@available(iOS 15, *)
final class SatellaController: UIViewController {
    static let shared: SatellaController = .init()
    
    var menuView: ImGuiStyleMenuView!
    
    override func loadView() {
        // PassthroughView yerine doğrudan bu tam ekran şeffaf menü yöneticisini kullanıyoruz
        view = PassthroughView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let size: CGSize = UIScreen.main.bounds.size
        view.frame = CGRect(origin: .zero, size: size)
        view.backgroundColor = .clear
        
        // Objective-C menüsünü ekrana ekle
        menuView = ImGuiStyleMenuView(frame: view.bounds)
        menuView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(menuView)
    }
}
