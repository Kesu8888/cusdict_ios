import SwiftUI

enum SampleOptions: Int, CaseIterable, Identifiable, Hashable, CustomStringConvertible {
    case main
    case background
    case foreground
    case font
    case alignment
    case effects
    
    var id: Self {
        self
    }
    
    var description: String {
        return switch self {
        case .main:
            "main"
        case .background:
            "background"
        case .foreground:
            "foreground"
        case .font:
            "font"
        case .alignment:
            "alignment"
        case .effects:
            "effects"
        }
    }
}

struct DemoView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedOption: SampleOptions
    @State private var tabbarScrollState: SampleOptions? = nil
    
    @Namespace private var ns
    
    var body: some View {
        
        let backgroundColor = colorScheme == .dark ? CustomColor.colorFromHex(hex: "2E2E2E") : CustomColor.colorFromHex(hex: "e2e2e2")
        let backgroundActiveColor = colorScheme == .dark ? CustomColor.colorFromHex(hex: "606060") : CustomColor.colorFromHex(hex: "ffffff")
        let foregroundColor = Color.primary
        let foregroundActiveColor = Color.primary
        
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack(spacing: 0) {
                    
                    ForEach(SampleOptions.allCases) { item in
                        
                        Group {
                            if item == selectedOption {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 9, style: .continuous).fill(backgroundActiveColor).frame(height: .infinity)
                                        .matchedGeometryEffect(id: "anim_pill", in: ns)
                                    
                                    Text(item.description)
                                        .font(.caption.bold())
                                        .layoutPriority(1)
                                        .padding(0)
                                        .foregroundStyle(foregroundActiveColor)
                                }
                            } else {
                                Button(action: {
                                    withAnimation(.snappy) {
                                        selectedOption = item
                                    }
                                }, label: {
                                    Text(item.description)
                                        .font(.caption.bold())
                                        .foregroundStyle(foregroundColor)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                })
                            }
                        }
                        .frame(width: 100, height: 28)
                    }
                }
            }
            .scrollDisabled(true)
            .scrollTargetLayout()
            .padding(2)
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }
}

fileprivate struct testView: View {
    @State var opt = SampleOptions.main
    var body: some View {
        DemoView(selectedOption: $opt)
    }
}

#Preview {
    testView()
}
