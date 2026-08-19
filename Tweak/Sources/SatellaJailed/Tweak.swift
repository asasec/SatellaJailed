import Jinx
import UIKit

struct Tweak {
    static func ctor() {
        // Temel hook'lar bir kez çalıştırılır
        CanPayHook().hook()
        DelegateHook().hook()
        TransactionHook().hook()
        
        if Preferences.isPriceZero { ProductHook().hook() }
        if Preferences.isObserver { ObserverHook().hook() }
        if Preferences.isStealth { DyldHook().hook() }
        
        if Preferences.isReceipt {
            ReceiptHook().hook()
            URLHook().hook()
        }
        
        if #available(iOS 15, *) {
            if Preferences.isGesture {
                WindowHook().hook()
            }
            
            guard !Preferences.isHidden else {
                return
            }
            
            // İlk açılışta menüyü ekle
            showMenu()
            
            // Oyundan çık-gir yapıldığında veya sahneler arası geçişte kaybolmayı önlemek için
            // Uygulama her ön plana geldiğinde (aktif olduğunda) menüyü kontrol edip tekrar ekliyoruz.
            NotificationCenter.default.addObserver(
                forName: UIApplication.didBecomeActiveNotification,
                object: nil,
                queue: .main
            ) { _ in
                showMenu()
            }
        }
    }
    
    private static func showMenu() {
        DispatchQueue.main.async {
            // Güvenli pencere ve rootViewController bulma
            guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIApplication.shared.windows.first,
                  let rootVC = window.rootViewController else {
                return
            }
            
            // Eğer menü hali hazırda ekli değilse tekrar ekle (üst üste binmeyi önler)
            let controller = SatellaController.shared
            if controller.parent == nil {
                rootVC.add(controller)
            }
        }
    }
}

@_cdecl("jinx_entry")
func jinxEntry() {
    Tweak.ctor()
}
