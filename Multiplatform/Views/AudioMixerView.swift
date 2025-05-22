
import SwiftUI

#if !os(tvOS)
struct AudioMixerView: View {
    @EnvironmentObject var appCtx: AppContext

    var body: some View {
        Text("Mic audio mixer")
        HStack {
            Text("Mic")
            Slider(value: $appCtx.micVolume, in: 0.0 ... 1.0)
        }
        HStack {
            Text("App")
            Slider(value: $appCtx.appVolume, in: 0.0 ... 1.0)
        }
    }
}
#endif
