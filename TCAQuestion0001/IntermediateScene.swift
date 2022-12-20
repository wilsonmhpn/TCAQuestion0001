import ComposableArchitecture
import SwiftUI

struct IntermediateScene: ReducerProtocol {
    struct State: Equatable {
        var route: Route? = nil
        var navRoute: NavigationRoute? { route?.navRoute }
        var letterId: String // "A" or "B"
    }

    enum Action: Equatable {
        case dismiss

        case presentLeaf(Bool)
        public enum ActionRoute: Equatable {
            case actionRouteLeaf(LeafScene.Action)
        }
        case actionRoute(ActionRoute)
    }
}

extension IntermediateScene.State: SceneRouter {

    enum Route: Equatable {

        case routeLeaf(LeafScene.State)

        var navRoute: NavigationRoute {
            switch self {

                case .routeLeaf:
                    return .routeLeaf

            }
        }
    }

    enum NavigationRoute: Equatable {
        case routeLeaf
    }

    var stateLeaf: LeafScene.State? {
        routeStateFor(/Route.routeLeaf)
    }

}

extension IntermediateScene {
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
                    
                case .presentLeaf(true):
                    state.route = .routeLeaf(LeafScene.State(letterId: state.letterId))
                    return .none

                case .presentLeaf(false):
                    state.route = nil
                    return .none

                case .actionRoute(.actionRouteLeaf(.dismiss)):
                    return Effect(value: .presentLeaf(false))

                case .actionRoute:
                    return .none

                case .dismiss:
                    // Parent takes care of this
                    return .none
            }
        }
        .ifLet(\.route, action: /Action.actionRoute) {
            EmptyReducer()
                .ifCaseLet(/State.Route.routeLeaf, action: /Action.ActionRoute.actionRouteLeaf) {
                    LeafScene()
                }
        }
    }
}

extension IntermediateScene {

    public struct View: SwiftUI.View {

        private let store: Store<State, Action>

        public init(store: Store<State, Action>) {
            self.store = store
        }

        var body: some SwiftUI.View {
            WithViewStore(self.store, observe: { $0 }) { viewStore in
                VStack {
                    Text("Intermediate Scene \(viewStore.state.letterId)")
                    Button(action: { viewStore.send(.presentLeaf(true)) }) {
                        Text("Show Leaf")
                    }
                    Button(action: { viewStore.send(.dismiss) }) {
                        Text("Dismiss")
                    }
                }
            }
            .sheet(
                store: store,
                navigationRoute: .routeLeaf,
                presentationAction: Action.presentLeaf,
                childState: \.stateLeaf,
                childAction: { Action.actionRoute(.actionRouteLeaf($0)) },
                childView: LeafScene.View.init(store:)
            )
        }
    }
}
