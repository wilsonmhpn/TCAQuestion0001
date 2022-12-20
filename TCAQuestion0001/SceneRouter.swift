import CasePaths

protocol SceneRouter {

    associatedtype Route: Equatable
    associatedtype NavigationRoute: Hashable

    var route: Route? { get set }
    var navRoute: NavigationRoute? { get }

}

extension SceneRouter {

    func routeStateFor <DestState> (_ cp: CasePath<Route?, DestState>) -> DestState? {
        cp.extract(from: route)
    }

    func isRoutingTo <DestState> (_ cp: CasePath<Route?, DestState>) -> Bool {
        routeStateFor(cp) != nil
    }

}
