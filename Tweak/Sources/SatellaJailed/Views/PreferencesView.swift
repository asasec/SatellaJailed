import SwiftUI

@available(iOS 15, *)
struct PreferencesView: View {
    // Tüm özellikleri tek bir butonla kontrol etmek için AppStorage
    @AppStorage("tella_isEnabled") private var isEnabled: Bool = true
    @AppStorage("tella_isGesture") private var isGesture: Bool = true
    @AppStorage("tella_isHidden") private var isHidden: Bool = false
    @AppStorage("tella_isObserver") private var isObserver: Bool = false
    @AppStorage("tella_isPriceZero") private var isPriceZero: Bool = false
    @AppStorage("tella_isReceipt") private var isReceipt: Bool = false
    @AppStorage("tella_isStealth") private var isStealth: Bool = false
    
    @Binding var isShowing: Bool
    @State private var isShowingOptions: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Başlık Çubuğu (Kırmızı Kısım - İstediğiniz gibi dikdörtgen)
            HStack {
                Text("SATELLA - MOD MENU")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button {
                    isShowing.toggle()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .bold))
                }
            }
            .padding()
            .background(isEnabled ? Color.red : Color.gray) // Duruma göre renk değişimi
            
            // 2. İçerik Alanı (Mavi/Koyu Tonlar)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // Ana Açma / Kapama Butonu (Tüm hook'ları tetikler)
                    Button {
                        isEnabled.toggle()
                        // Toplu olarak diğer ayarları da ana duruma göre güncelleyebiliriz
                        isGesture = isEnabled
                        isObserver = isEnabled
                        isPriceZero = isEnabled
                        isReceipt = isEnabled
                        isStealth = isEnabled
                    } label: {
                        HStack {
                            Text(isEnabled ? "MOD MENU: ACTIVE" : "MOD MENU: DISABLED")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                            Circle()
                                .fill(isEnabled ? Color.green : Color.red)
                                .frame(width: 20, height: 20)
                        }
                        .padding()
                        .background(Color.blue)
                    }
                    .buttonStyle(.plain)
                    
                    Divider().background(Color.white)
                    
                    // Detaylı Toggle Satırları
                    Group {
                        ToggleRow(title: "3-Finger Gesture", isOn: $isGesture)
                        ToggleRow(title: "Observer Hook", isOn: $isObserver)
                        ToggleRow(title: "0,00 Price Hook", isOn: $isPriceZero)
                        ToggleRow(title: "Receipt Bypass", isOn: $isReceipt)
                        ToggleRow(title: "Stealth Mode", isOn: $isStealth)
                    }
                    
                    // Uygula / Seçenekler Butonu
                    Button("Apply Changes / Options") {
                        isShowingOptions.toggle()
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.darkGrayCustom)
                    .alert("Select an action", isPresented: $isShowingOptions) {
                        Button("Apply & Restart App") {
                            abort()
                        }
                        Button("Hide Menu") {
                            isShowing.toggle()
                            SatellaController.shared.host.removeFromSuperview()
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                }
            }
            .background(Color(red: 0.1, green: 0.1, blue: 0.12))
        }
        // Dikdörtgen görünüm için köşe yuvarlatmasını kaldırıyoruz (veya çok az tutuyoruz)
        .cornerRadius(0) 
        .frame(width: 280)
        .shadow(radius: 10)
    }
}

// Yardımcı Satır Bileşeni
@available(iOS 15, *)
struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color.blue.opacity(0.7))
        .overlay(Rectangle().frame(height: 1).foregroundColor(.white.opacity(0.2)), alignment: .bottom)
    }
}

extension Color {
    static let darkGrayCustom = Color(red: 0.2, green: 0.2, blue: 0.22)
}
