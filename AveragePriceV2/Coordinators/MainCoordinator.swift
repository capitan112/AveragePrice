//
//  MainCoordinator.swift
//  AveragePriceV2
//
//  Created by Oleksiy Chebotarov on 31/05/2024.
//

import Foundation
import UIKit

protocol Coordinator {
    var navigationController: UINavigationController? { get set }
    func start()
}

class MainCoordinator: Coordinator {
    var navigationController: UINavigationController?

    func start() {
        let viewModel = PropertyViewModel()
        let viewController = ViewController(viewModel: viewModel)
        viewController.coordinator = self
        navigationController?.pushViewController(viewController, animated: true)
    }
}
