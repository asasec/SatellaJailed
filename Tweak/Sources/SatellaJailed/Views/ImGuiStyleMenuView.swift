import UIKit

// Tweak.mm veya Tweak.swift içindeki FreeIAP fonksiyon köprüsü ile haberleşir
@_silgen_name("FreeIAP")
func FreeIAP(_ enabled: Bool)

@available(iOS 15.0, *)
public class ImGuiStyleMenuView: UIView {
    public var menuWindow: UIView!
    public var floatingIcon: UIButton!
    public var speedSlider: UISlider!
    
    private var titleBar: UIView!
    private var masterSwitch: UISwitch!
    private var gestureSwitch: UISwitch!
    private var observerSwitch: UISwitch!
    private var priceZeroSwitch: UISwitch!
    private var receiptSwitch: UISwitch!
    private var stealthSwitch: UISwitch!

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        loadPreferences() // Başlangıçta kayıtlı tercihleri yükle
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        loadPreferences()
    }

    private func setupUI() {
        backgroundColor = .clear
        
        // --- Ana Mod Menü Penceresi ---
        menuWindow = UIView(frame: CGRect(x: 50, y: 80, width: 280, height: 320))
        menuWindow.backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.10, alpha: 0.97)
        menuWindow.layer.cornerRadius = 16.0
        menuWindow.layer.borderWidth = 1.5
        menuWindow.layer.borderColor = UIColor(red: 0.30, green: 0.60, blue: 1.00, alpha: 1.0).cgColor
        menuWindow.layer.shadowColor = UIColor.black.cgColor
        menuWindow.layer.shadowOffset = CGSize(width: 0, height: 8)
        menuWindow.layer.shadowOpacity = 0.5
        menuWindow.layer.shadowRadius = 10.0
        menuWindow.clipsToBounds = false
        menuWindow.isHidden = true
        addSubview(menuWindow)

        let menuPan = UIPanGestureRecognizer(target: self, action: #selector(handleMenuPan(_:)))
        menuWindow.addGestureRecognizer(menuPan)

        // --- Başlık Çubuğu ---
        titleBar = UIView(frame: CGRect(x: 0, y: 0, width: 280, height: 40))
        titleBar.backgroundColor = UIColor(red: 0.85, green: 0.20, blue: 0.20, alpha: 1.0)
        
        let path = UIBezierPath(roundedRect: titleBar.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 16.0, height: 16.0))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        titleBar.layer.mask = maskLayer
        menuWindow.addSubview(titleBar)

        let titleLabel = UILabel(frame: CGRect(x: 16, y: 0, width: 200, height: 40))
        titleLabel.text = "🐻 SATELLA - MOD MENU"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 13)
        titleBar.addSubview(titleLabel)

        // Kapatma / Küçültme Butonu
        let closeBtn = UIButton(type: .system)
        closeBtn.frame = CGRect(x: 240, y: 8, width: 24, height: 24)
        closeBtn.setTitle("✕", for: .normal)
        closeBtn.setTitleColor(.white, for: .normal)
        closeBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        closeBtn.addTarget(self, action: #selector(minimizeMenu), for: .touchUpInside)
        titleBar.addSubview(closeBtn)

        // --- Ana Özellik: FreeIAP (Master Switch) ---
        let masterText = UILabel(frame: CGRect(x: 16, y: 55, width: 170, height: 24))
        masterText.text = "FreeIAP (Master Switch)"
        masterText.textColor = .white
        masterText.font = UIFont.boldSystemFont(ofSize: 13)
        menuWindow.addSubview(masterText)

        masterSwitch = UISwitch(frame: CGRect(x: 210, y: 52, width: 0, height: 0))
        masterSwitch.isOn = false
        masterSwitch.onTintColor = UIColor(red: 0.20, green: 0.80, blue: 0.20, alpha: 1.0)
        masterSwitch.addTarget(self, action: #selector(masterSwitchChanged(_:)), for: .valueChanged)
        menuWindow.addSubview(masterSwitch)

        // --- Diğer Alt Hooklar ---
        let startY: CGFloat = 95
        let spacing: CGFloat = 40
        
        gestureSwitch = createRow(title: "3-Finger Gesture", y: startY, action: #selector(gestureChanged(_:)))
        observerSwitch = createRow(title: "Observer Hook", y: startY + spacing, action: #selector(observerChanged(_:)))
        priceZeroSwitch = createRow(title: "0,00 Price Hook", y: startY + (spacing * 2), action: #selector(priceZeroChanged(_:)))
        receiptSwitch = createRow(title: "Receipt Bypass", y: startY + (spacing * 3), action: #selector(receiptChanged(_:)))
        stealthSwitch = createRow(title: "Stealth Mode", y: startY + (spacing * 4), action: #selector(stealthChanged(_:)))

        // --- Yüzen Ayı Simgesi ---
        floatingIcon = UIButton(type: .system)
        floatingIcon.frame = CGRect(x: 40, y: 100, width: 54, height: 54)
        floatingIcon.backgroundColor = UIColor(red: 0.10, green: 0.10, blue: 0.13, alpha: 0.92)
        floatingIcon.setTitle("🐻", for: .normal)
        floatingIcon.titleLabel?.font = UIFont.systemFont(ofSize: 28)
        floatingIcon.layer.cornerRadius = 27.0
        floatingIcon.layer.borderWidth = 2.0
        floatingIcon.layer.borderColor = UIColor(red: 0.30, green: 0.60, blue: 1.00, alpha: 1.0).cgColor
        floatingIcon.layer.shadowColor = UIColor.black.cgColor
        floatingIcon.layer.shadowOffset = CGSize(width: 0, height: 4)
        floatingIcon.layer.shadowOpacity = 0.6
        floatingIcon.layer.shadowRadius = 8.0
        floatingIcon.isHidden = false
        floatingIcon.addTarget(self, action: #selector(restoreMenu), for: .touchUpInside)
        addSubview(floatingIcon)

        let iconPan = UIPanGestureRecognizer(target: self, action: #selector(handleIconPan(_:)))
        floatingIcon.addGestureRecognizer(iconPan)
    }

    private func createRow(title: String, y: CGFloat, action: Selector) -> UISwitch {
        let label = UILabel(frame: CGRect(x: 16, y: y, width: 180, height: 24))
        label.text = title
        label.textColor = UIColor(white: 0.90, alpha: 1.0)
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        menuWindow.addSubview(label)

        let sw = UISwitch(frame: CGRect(x: 210, y: y - 2, width: 0, height: 0))
        sw.isOn = false
        sw.onTintColor = UIColor(red: 0.20, green: 0.60, blue: 1.00, alpha: 1.0)
        sw.addTarget(self, action: action, for: .valueChanged)
        menuWindow.addSubview(sw)
        return sw
    }

    private func loadPreferences() {
        // Preferences sınıfındaki güncel değerleri arayüze yansıt
        gestureSwitch.isOn = Preferences.isGesture
        observerSwitch.isOn = Preferences.isObserver
        priceZeroSwitch.isOn = Preferences.isPriceZero
        receiptSwitch.isOn = Preferences.isReceipt
        stealthSwitch.isOn = Preferences.isStealth
    }

    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self {
            return nil 
        }
        return hitView
    }

    @objc private func handleMenuPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        if let view = gesture.view {
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        }
        gesture.setTranslation(.zero, in: self)
    }

    @objc private func handleIconPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        if let view = gesture.view {
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        }
        gesture.setTranslation(.zero, in: self)
    }

    @objc private func minimizeMenu() {
        menuWindow.isHidden = true
        floatingIcon.center = menuWindow.center
        floatingIcon.isHidden = false
    }

    @objc private func restoreMenu() {
        floatingIcon.isHidden = true
        menuWindow.center = floatingIcon.center
        menuWindow.isHidden = false
    }

    @objc private func masterSwitchChanged(_ sender: UISwitch) {
        let isOn = sender.isOn
        
        titleBar.backgroundColor = isOn ? UIColor(red: 0.15, green: 0.75, blue: 0.15, alpha: 1.0) : UIColor(red: 0.85, green: 0.20, blue: 0.20, alpha: 1.0)
        
        gestureSwitch.setOn(isOn, animated: true)
        observerSwitch.setOn(isOn, animated: true)
        priceZeroSwitch.setOn(isOn, animated: true)
        receiptSwitch.setOn(isOn, animated: true)
        stealthSwitch.setOn(isOn, animated: true)
        
        Preferences.isGesture = isOn
        Preferences.isObserver = isOn
        Preferences.isPriceZero = isOn
        Preferences.isReceipt = isOn
        Preferences.isStealth = isOn
        
        FreeIAP(isOn)
    }

    @objc private func gestureChanged(_ sender: UISwitch) {
        Preferences.isGesture = sender.isOn
    }

    @objc private func observerChanged(_ sender: UISwitch) {
        Preferences.isObserver = sender.isOn
    }

    @objc private func priceZeroChanged(_ sender: UISwitch) {
        Preferences.isPriceZero = sender.isOn
    }

    @objc private func receiptChanged(_ sender: UISwitch) {
        Preferences.isReceipt = sender.isOn
    }

    @objc private func stealthChanged(_ sender: UISwitch) {
        Preferences.isStealth = sender.isOn
    }
}
