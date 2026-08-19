import SwiftUI

@available(iOS 15, *)
struct SatellaShapeView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = SatellaShape(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
        view.backgroundColor = .clear
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
}

@available(iOS 15, *)
struct SatellaView: View {
    @ObservedObject var model: SatellaModel = .shared
    
    var body: some View {
        ZStack {
            if model.isShowing {
                PreferencesView(isShowing: $model.isShowing)
            } else {
                Button {
                    model.isShowing.toggle()
                } label: {
                    Color(red: 0.80, green: 0.63, blue: 0.87)
                        .mask {
                            SatellaShapeView()
                        }
                }
                .frame(width: 33, height: 33)
            }
        }
    }
}
