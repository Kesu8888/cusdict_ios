/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view displaying information about a hike, including an elevation graph.
*/

import SwiftUI

extension AnyTransition {
    static var moveAndFade: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing),
            removal: .slide.combined(with: .opacity)
        )
    }
}

struct HikeView: View {
    var hike: Hike
    @State private var showDetail = false

    var body: some View {
        VStack {
            HStack {
                HikeGraph(hike: hike, path: \.elevation)
                    .frame(width: 50, height: 30)

                VStack(alignment: .leading) {
                    Text(hike.name)
                        .font(.headline)
                    Text(hike.distanceText)
                }

                Spacer()

                Button {
                    // Any view that is associated with the showDetail variable is affected by the withAnimation func
                    withAnimation {
                        showDetail.toggle()
                    }
                } label: {
                    Label("Graph", systemImage: "chevron.right.circle")
                        .labelStyle(.iconOnly)
                        .imageScale(.large)
                        .rotationEffect(Angle(degrees: showDetail ? 90 : 0))
                        .padding()
                }
            }

            if showDetail {
                // transition slide has problem during disappearing so we use with a opacity change
                HikeDetail(hike: hike)
                    .transition(.moveAndFade)
            }
        }
    }
}

#Preview {
    VStack {
        HikeView(hike: ModelData().hikes[0])
            .padding()
        Spacer()
    }
}
