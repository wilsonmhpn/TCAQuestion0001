import ComposableArchitecture
import SwiftUI

struct LeafScene: ReducerProtocol {

    struct State: Equatable {
        var letterId: String // "A" or "B"
    }

    enum Action: Equatable {
        case dismiss
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {

        switch action {

            case .dismiss:
                // Parent takes care of this
                return .none

        }
    }

    public struct View: SwiftUI.View {

        private let store: Store<State, Action>

        public init(store: Store<State, Action>) {
            self.store = store
        }

        var body: some SwiftUI.View {
            WithViewStore(self.store, observe: { $0 }) { viewStore in
                VStack {
                    Text("Leaf Scene \(viewStore.state.letterId)")
                    Button(action: { viewStore.send(.dismiss) }) {
                        Text("Dismiss")
                    }
                }
            }
        }
    }
}
