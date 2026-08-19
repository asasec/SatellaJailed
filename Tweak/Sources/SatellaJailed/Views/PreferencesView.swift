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
    
    // Sürükleme (Drag) için konum state'leri
    @State private var offset = CGSize.zero
    @State private var lastOffset = CGSize.zero

    var body: some View {
        // En dıştaki katman tamamen transparan ve dokunulmaz (arkaya tıklanabilir) olmalı, 
        // ancak sadece menünün olduğu alan dokunmayı yakalamalı.
        ZStack {
            Color.clear
                .ignoresSafeArea()
                .contentShape(Rectangle())
                // Boşluklara tıklandığında arkaya geçmesi için interaction'ı serbest bırakıyoruz
                .allowsHitTesting(false) 

            VStack(spacing: 0) {
                // 1. Başlık Çubuğu (Sürüklenebilir Alan)
                HStack {
                    Text("SATELLA - MOD MENU")
                        .font(.system(size: 14, weight: .bold))
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
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(isEnabled ? Color.red : Color.gray)
                // Başlık çubuğundan tutup sürüklemek için gesture ekliyoruz
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            offset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
                
                // 2. İçerik Alanı
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        
                        // Ana Açma / Kapama Butonu
                        Button {
                            isEnabled.toggle()
                            isGesture = isEnabled
                            isObserver = isEnabled
                            isPriceZero = isEnabled
                            isReceipt = isEnabled
                            isStealth = isEnabled
                        } label: {
                            HStack {
                                Text(isEnabled ? "MOD MENU: ACTIVE" : "MOD MENU: DISABLED")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                                Spacer()
                                Circle()
                                    .fill(isEnabled ? Color.green : Color.red)
                                    .frame(width: 16, height: 16)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
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
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
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
                .background(Color(red: 0.1, green: 0.1, blue: 0.12).opacity(0.85)) // Hafif şeffaf koyu arkaplan
            }
            .frame(width: 260)
            .cornerRadius(0)
            .shadow(radius: 5)
            .offset(offset) // Sürükleme pozisyonunu uyguluyoruz
            .allowsHitTesting(true) // Menünün kendi içindeki butonlar tıklanabilir kalır
        }
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
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.blue.opacity(0.7))
        .overlay(Rectangle().frame(height: 1).foregroundColor(.white.opacity(0.2)), alignment: .bottom)
    }
}

@available(iOS 13.0, *)
extension Color {
    static let darkGrayCustom = Color(red: 0.2, green: 0.2, blue: 0.22)
}
