//
//  ViewController.swift
//  AveragePriceV2
//
//  Created by Oleksiy Chebotarov on 31/05/2024.
//

import Combine
import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    weak var coordinator: MainCoordinator?
    private var viewModel: PropertyViewModelProtocol
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: PropertyViewModelProtocol = PropertyViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var questionLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.style.question
        label.textAlignment = .center
        label.textColor = viewModel.style.labelTextColor
        label.font = viewModel.style.labelFont
        label.alpha = 0
        return label
    }()

    private lazy var answerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = viewModel.style.labelTextColor
        label.font = viewModel.style.labelFont
        label.alpha = 0
        return label
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.hidesWhenStopped = true
        return spinner
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .red
        label.font = viewModel.style.labelFont
        label.numberOfLines = 0
        label.alpha = 0
        return label
    }()

    private let pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.alpha = 0
        return picker
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addPickerView()
        addQuestionLabel()
        addAnswerLabel()
        addActivityIndicator()
        addErrorLabel()
        bindViewModel()
        Task {
            await self.viewModel.fetchProperties()
        }
    }

    private func addPickerView() {
        view.addSubview(pickerView)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
        pickerView.delegate = self
        pickerView.dataSource = self
    }

    private func addQuestionLabel() {
        view.addSubview(questionLabel)
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            questionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            questionLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func addAnswerLabel() {
        view.addSubview(answerLabel)
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            answerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            answerLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 10)
        ])
    }

    private func addActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func addErrorLabel() {
        view.addSubview(errorLabel)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.topAnchor.constraint(equalTo: answerLabel.bottomAnchor, constant: 10),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func bindViewModel() {
        viewModel.averagePricePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] averagePrice in
                self?.errorLabel.text = nil
                self?.answerLabel.text = averagePrice
                self?.animateAppearance(for: self?.answerLabel)
            }
            .store(in: &cancellables)

        viewModel.selectedBedroomsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.viewModel.calculateAveragePrice()
            }
            .store(in: &cancellables)

        viewModel.uniqueBedroomsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.pickerView.reloadAllComponents()
                self?.animateAppearance(for: self?.pickerView)
            }
            .store(in: &cancellables)

        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    self?.questionLabel.alpha = 0
                    self?.answerLabel.alpha = 0
                    self?.pickerView.alpha = 0
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.animateAppearance(for: self?.questionLabel)
                }
            }
            .store(in: &cancellables)

        viewModel.errorMessagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let errorMessage = errorMessage {
                    self?.errorLabel.text = errorMessage
                    self?.answerLabel.text = nil
                    self?.animateAppearance(for: self?.errorLabel)
                }
            }
            .store(in: &cancellables)
    }

    private func animateAppearance(for view: UIView?) {
        UIView.animate(withDuration: 0.5) {
            view?.alpha = 1
        }
    }

    // MARK: - UIPickerViewDataSource

    func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        return viewModel.uniqueBedrooms.count + 1
    }

    // MARK: - UIPickerViewDelegate

    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        if row == 0 {
            return viewModel.style.pickerViewAll
        } else {
            return viewModel.bedroomFormating(row: row)
        }
    }

    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        if row == 0 {
            viewModel.selectedBedrooms = nil
        } else {
            viewModel.selectedBedrooms = viewModel.uniqueBedrooms[row - 1]
        }
    }
}
