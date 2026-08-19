import SwiftUI

@available(iOS 15, *)
struct PreferencesView: View {
    @AppStorage("tella_isEnabled") private var isEnabled: Bool = true
    @AppStorage("tella_isGesture") private var isGesture: Bool = true
    @AppStorage("tella_isHidden") private var isHidden: Bool = false
    @AppStorage("tella_isObserver") private var isObserver: Bool = false
    @AppStorage("tella_isPriceZero") private var isPriceZero: Bool = false
    @AppStorage("tella_isReceipt") private var isReceipt: Bool = false
    @AppStorage("tella_isStealth") private var isStealth: Bool = false
    
    @Binding var isShowing: Bool
    @State private var isShowingOptions: Bool = false
    
    // Titreşimi engelleyen GestureState tabanlı sürükleme konumları
    @State private var currentPosition = CGSize.zero
    @GestureState private var dragOffset = CGSize.zero

    var body: some View {
        ZStack {
            // Menü dışındaki boşluklar tamamen şeffaf ve arkaya tıklanabilir
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
                        
                        Group {
                            ToggleRow(title: "3-Finger Gesture", isOn: $isGesture)
                            ToggleRow(title: "Observer Hook", isOn: $isObserver)
                            ToggleRow(title: "0,00 Price Hook", isOn: $isPriceZero)
                            ToggleRow(title: "Receipt Bypass", isOn: $isReceipt)
                            ToggleRow(title: "Stealth Mode", isOn: $isStealth)
                        }
                        
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
                            }
                            Button("Cancel", role: .cancel) {}
                        }
                    }
                }
                .background(Color(red: 0.1, green: 0.1, blue: 0.12).opacity(0.85)) // Şeffaf koyu tema
            }
            .frame(width: 260)
            .cornerRadius(0)
            .shadow(radius: 5)
            .offset(
                width: currentPosition.width + dragOffset.width,
                height: currentPosition.height + dragOffset.height
            )
            .allowsHitTesting(true) // Menünün içi tıklanabilir kalır
        }
    }
}

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
