import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private let taskListViewModel = TaskListViewModel()
    private lazy var exerciseViewModel = ExerciseViewModel(taskViewModel: taskListViewModel)
    private lazy var statisticsViewModel = StatisticsViewModel(taskViewModel: taskListViewModel)

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let controller: UIViewController = {
            guard let lastUrl = SaveService.lastUrl, !lastUrl.absoluteString.isEmpty else {
                return LoadingSplash()
            }
            print("Last URL:", lastUrl)
            return WebviewVC(url: lastUrl)
        }()

        window.rootViewController = controller
        window.makeKeyAndVisible()
    }
}
