
import SwiftUI

extension Binding where Value: OptionSet & Sendable, Value == Value.Element {
    func bindedValue(_ options: Value) -> Bool {
        wrappedValue.contains(options)
    }

    func bind(
        _ options: Value,
        animate: Bool = false
    ) -> Binding<Bool> {
        .init { () -> Bool in
            self.wrappedValue.contains(options)
        } set: { newValue in
            let body = {
                if newValue {
                    self.wrappedValue.insert(options)
                } else {
                    self.wrappedValue.remove(options)
                }
            }
            guard animate else {
                body()
                return
            }
            withAnimation {
                body()
            }
        }
    }
}
