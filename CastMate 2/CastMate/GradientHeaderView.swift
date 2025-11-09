import SwiftUI

struct GradientHeader: View {
    enum Style { case doubleCaps, wavy }
    var style: Style

    var body: some View {
        GeometryReader { geo in
            LinearGradient(colors: [DS.indigoDark, DS.indigoMid],
                           startPoint: .top, endPoint: .bottom)
                .mask(
                    Group {
                        if style == .doubleCaps {
                            VStack {
                                HStack {
                                    Circle()
                                        .frame(width: geo.size.width * 0.5)
                                        .offset(x: -geo.size.width * 0.25, y: geo.size.height * 0.4)
                                    Spacer()
                                    Circle()
                                        .frame(width: geo.size.width * 0.5)
                                        .offset(x: geo.size.width * 0.25, y: geo.size.height * 0.4)
                                }
                                Spacer()
                            }
                        } else {
                            // wavy
                            WaveShape()
                        }
                    }
                )
        }
        .ignoresSafeArea()
    }
}

struct WaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.height * 0.35))
        path.addCurve(
            to: CGPoint(x: 0, y: rect.height * 0.35),
            control1: CGPoint(x: rect.width * 0.65, y: rect.height * 0.6),
            control2: CGPoint(x: rect.width * 0.35, y: rect.height * 0.1)
        )
        path.closeSubpath()
        return path
    }
}
