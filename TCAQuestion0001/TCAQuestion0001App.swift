import ComposableArchitecture
import SwiftUI

/*
 Navigate to Intermediate A -> Show Leaf to get to Leaf Scene A
 Then open a deep link tca20221220://nothing
 See complaints in the logs
 */

final class AppDelegate: NSObject, UIApplicationDelegate {

    let store: Store<AppScene.State, AppScene.Action>

    override init() {

        let state = AppScene.State()

        self.store = Store(
            initialState: state,
            reducer: AppScene()
        )

        super.init()

    }
}

@main
struct TCAQuestion0001App: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            AppScene.View(store: appDelegate.store)
        }
    }

}
