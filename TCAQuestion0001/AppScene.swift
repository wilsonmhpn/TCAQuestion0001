import ComposableArchitecture
import SwiftUI

struct AppScene: ReducerProtocol {
    struct State: Equatable {
        var route: Route? = nil
        var navRoute: NavigationRoute? { route?.navRoute }
    }

    enum Action: Equatable {
        case presentIntermediateA(Bool)
        case presentIntermediateB(Bool)
        public enum ActionRoute: Equatable {
            case actionRouteIntermediateA(IntermediateScene.Action)
            case actionRouteIntermediateB(IntermediateScene.Action)
        }
        case actionRoute(ActionRoute)
        case openUrl(URL)
    }
}

extension AppScene.State: SceneRouter {

    enum Route: Equatable {

        case routeIntermediateA(IntermediateScene.State)
        case routeIntermediateB(IntermediateScene.State)

        var navRoute: NavigationRoute {
            switch self {

                case .routeIntermediateA:
                    return .routeIntermediateA

                case .routeIntermediateB:
                    return .routeIntermediateB

            }
        }
    }

    enum NavigationRoute: Equatable {
        case routeIntermediateA
        case routeIntermediateB
    }

    var stateIntermediateA: IntermediateScene.State? {
        routeStateFor(/Route.routeIntermediateA)
    }

    var stateIntermediateB: IntermediateScene.State? {
        routeStateFor(/Route.routeIntermediateB)
    }

}

extension AppScene {
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
                case .presentIntermediateA(true):
                    state.route = .routeIntermediateA(IntermediateScene.State(letterId: "A"))
                    return .none

                case .presentIntermediateB(true):
                    state.route = .routeIntermediateA(IntermediateScene.State(letterId: "B"))
                    return .none

                case .presentIntermediateA(false),
                        .presentIntermediateB(false):
                    state.route = nil
                    return .none

                case .actionRoute(.actionRouteIntermediateA(.dismiss)):
                    return Effect(value: .presentIntermediateA(false))

                case .actionRoute(.actionRouteIntermediateB(.dismiss)):
                    return Effect(value: .presentIntermediateB(false))

                case .actionRoute:
                    return .none

                case .openUrl(_):
                    // Starting from Intermediate A -> Leaf Scene A, hit the deep link tca20221220://nothing,
                    // pretend we parsed the URL here and decided we want to and drill down to IntermediateSceneB -> LeafSceneB
                    // It will complain that something "received a child action when child state was set to a different case"
                    state.route = .routeIntermediateB(IntermediateScene.State(
                        route: .routeLeaf(LeafScene.State(letterId: "B")),
                        letterId: "B"))
                    // This simpler case works:
                    //state.route = .routeIntermediateA(IntermediateScene.State(letterId: "B"))
                    return .none
            }
        }
        .ifLet(\.route, action: /Action.actionRoute) {
            EmptyReducer()
                .ifCaseLet(/State.Route.routeIntermediateA, action: /Action.ActionRoute.actionRouteIntermediateA) {
                    IntermediateScene()
                }
                .ifCaseLet(/State.Route.routeIntermediateB, action: /Action.ActionRoute.actionRouteIntermediateB) {
                    IntermediateScene()
                }
        }
    }
}

extension AppScene {

    public struct View: SwiftUI.View {

        private let store: Store<State, Action>

        public init(store: Store<State, Action>) {
            self.store = store
        }

        var body: some SwiftUI.View {

            NavigationView {
                ZStack {
                    WithViewStore(self.store, observe: { $0 }) { viewStore in
                        VStack {
                            Text("AppScene")
                            Button(action: { viewStore.send(.presentIntermediateA(true)) }) {
                                Text("Show Intermediate A")
                            }
                            Button(action: { viewStore.send(.presentIntermediateB(true)) }) {
                                Text("Show Intermediate B")
                            }
                        }
                        .onOpenURL { url in
                            viewStore.send(.openUrl(url))
                        }
                    }
                    navigationLink(
                        store: store,
                        navigationRoute: .routeIntermediateA,
                        presentationAction: Action.presentIntermediateA,
                        childState: \.stateIntermediateA,
                        childAction: { Action.actionRoute(.actionRouteIntermediateA($0)) },
                        childView: IntermediateScene.View.init(store:)
                    )
                    navigationLink(
                        store: store,
                        navigationRoute: .routeIntermediateB,
                        presentationAction: Action.presentIntermediateB,
                        childState: \.stateIntermediateB,
                        childAction: { Action.actionRoute(.actionRouteIntermediateB($0)) },
                        childView: IntermediateScene.View.init(store:)
                    )
                }
            }

        }
    }
}
