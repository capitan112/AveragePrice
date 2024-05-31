//
//  AppDelegate.swift
//  AveragePriceV2
//
//  Created by Oleksiy Chebotarov on 31/05/2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var coordinator: MainCoordinator?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let navigationController = UINavigationController()
        coordinator = MainCoordinator()
        coordinator?.navigationController = navigationController

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        coordinator?.start()

        return true
    }
}
