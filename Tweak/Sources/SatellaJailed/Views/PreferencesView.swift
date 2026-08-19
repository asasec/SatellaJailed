import SwiftUI

@available(iOS 15, *)
struct Preferences {
    static var isEnabled: Bool   = prefs.get(for: "tella_isEnabled",   default: true)
    static var isGesture: Bool   = prefs.get(for: "tella_isGesture",   default: true)
    static var isHidden: Bool    = prefs.get(for: "tella_isHidden",    default: false)
    static var isObserver: Bool  = prefs.get(for: "tella_isObserver",  default: false)
    static var isPriceZero: Bool = prefs.get(for: "tella_isPriceZero", default: false)
    static var isReceipt: Bool   = prefs.get(for: "tella_isReceipt",   default: false)
    static var isStealth: Bool   = prefs.get(for: "tella_isStealth",   default: false)
}
