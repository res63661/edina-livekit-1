
#if os(visionOS)

import RealityKit
import SwiftUI

struct ImmersiveView: View {
    var body: some View {
        ZStack {
            RealityView { content in

                let entity = Entity()
                entity.components.set(ModelComponent(
                    mesh: .generateSphere(radius: 1000),
                    materials: []
                ))

                entity.scale *= SIMD3(repeating: -1)
                content.add(entity)
            }
        }
    }
}
#endif
