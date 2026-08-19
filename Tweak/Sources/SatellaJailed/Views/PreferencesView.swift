import SwiftUI

@available(iOS 15, *)
struct PreferencesView: View {
    // Başlangıçta hepsinin açık (true) olması için default değerleri true yapıldı
    @AppStorage("tella_isEnabled") private var isEnabled: Bool = true
    @AppStorage("tella_isGesture") private var isGesture: Bool = true
    @AppStorage("tella_isHidden") private var isHidden: Bool = false
    @AppStorage("tella_isObserver") private var isObserver: Bool = true
    @AppStorage("tella_isPriceZero") private var isPriceZero: Bool = true
    @AppStorage("tella_isReceipt") private var isReceipt: Bool = true
    @AppStorage("tella_isStealth") private var isStealth: Bool = true
    
    @Binding var isShowing: Bool
    @State private var isShowingOptions: Bool = false
    
    // Titreşimi engelleyen GestureState tabanlı sürüklenme konumları
    @State private var currentPosition = CGSize.zero
    @GestureState private var dragOffset = CGSize.zero

    var body: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea()
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
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation
                        }
                        .onEnded { value in
                            currentPosition.width += value.translation.width
                            currentPosition.height += value.translation.height
                        }
                )
                
                // 2. İçerik Alanı
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
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
                        
                        // Açıkken yeşil, kapalıyken kırmızı olan özel satırlar
                        Group {
                            CustomToggleRow(title: "3-Finger Gesture", isOn: $isGesture)
                            CustomToggleRow(title: "Observer Hook", isOn: $isObserver)
                            CustomToggleRow(title: "0,00 Price Hook", isOn: $isPriceZero)
                            CustomToggleRow(title: "Receipt Bypass", isOn: $isReceipt)
                            CustomToggleRow(title: "Stealth Mode", isOn: $isStealth)
                        }
                        
                        Button("Apply Changes / Options") {
                            isShowingOptions.toggle()
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.customDarkGray)
                        .alert("Select an action", isPresented: $isShowingOptions) {
                            Button("Apply & Restart App") {
                                exit(0)
                            }
                            Button("Hide Menu") {
                                isShowing.toggle()
                            }
                            Button("Cancel", role: .cancel) {}
                        }
                    }
                }
                .background(Color(red: 0.1, green: 0.1, blue: 0.12).opacity(0.85))
            }
            .frame(width: 260)
            .cornerRadius(0)
            .shadow(radius: 5)
            .offset(CGSize(
                width: currentPosition.width + dragOffset.width,
                height: currentPosition.height + dragOffset.height
            ))
            .allowsHitTesting(true)
        }
    }
}

// İstediğiniz gibi Açık: Yeşil, Kapalı: Kırmızı yanan özel satır bileşeni
@available(iOS 15, *)
struct CustomToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            HStack {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                Spacer()
                // Duruma göre renk değişimi (Yeşil / Kırmızı)
                RoundedRectangle(cornerRadius: 4)
                    .fill(isOn ? Color.green : Color.red)
                    .frame(width: 36, height: 20)
                    .overlay(
                        Circle()
                            .fill(Color.white)
                            .padding(2)
                            .offset(x: isOn ? 8 : -8)
                    )
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.blue.opacity(0.7))
        }
        .buttonStyle(.plain)
        .overlay(Rectangle().frame(height: 1).foregroundColor(.white.opacity(0.2)), alignment: .bottom)
    }
}

@available(iOS 13.0, *)
extension Color {
    static let customDarkGray = Color(red: 0.2, green: 0.2, blue: 0.22)
}
