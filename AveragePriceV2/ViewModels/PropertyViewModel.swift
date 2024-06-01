//
//  PropertyViewModel.swift
//  AveragePriceV2
//
//  Created by Oleksiy Chebotarov on 31/05/2024.
//

import Combine
import Foundation

protocol PropertyViewModelProtocol: AnyObject {
    var averagePrice: String? { get set }
    var selectedBedrooms: Int? { get set }
    var uniqueBedrooms: [Int] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }

    var averagePricePublisher: Published<String?>.Publisher { get }
    var selectedBedroomsPublisher: Published<Int?>.Publisher { get }
    var uniqueBedroomsPublisher: Published<[Int]>.Publisher { get }
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var errorMessagePublisher: Published<String?>.Publisher { get }
    var style: PropertyViewModel.Style { get }

    func fetchProperties() async
    func calculateAveragePrice()
}

class PropertyViewModel: PropertyViewModelProtocol, ObservableObject {
    struct Style {
        let pickerViewAll: String = "All"
        let bedroomSingular: String = "bedroom"
        let bedroomPlural: String = "bedrooms"
        let question: String = "What is the average property price?"

        // Errors
        let invalidURL: String = "Invalid URL."
        let noData: String = "No data received."
        let invalidResponse: String = "Invalid response from server: "
        let failedDecodeJson: String = "Failed to decode JSON: "
        let unexpectedError: String = "Unexpected error:  "
    }

    @Published var averagePrice: String?
    @Published var selectedBedrooms: Int?
    @Published var uniqueBedrooms: [Int] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    var averagePricePublisher: Published<String?>.Publisher { $averagePrice }
    var selectedBedroomsPublisher: Published<Int?>.Publisher { $selectedBedrooms }
    var uniqueBedroomsPublisher: Published<[Int]>.Publisher { $uniqueBedrooms }
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var errorMessagePublisher: Published<String?>.Publisher { $errorMessage }

    private let url: String = "https://raw.githubusercontent.com/rightmove/Code-Challenge-iOS/master/properties.json"
    private let httpClient: HTTPClientProtocol
    private let numberFormatter: NumberFormatter
    let style: Style
    var properties: [Property] = []

    init(httpClient: HTTPClientProtocol = HTTPClient(),
         numberFormatter: NumberFormatter = NumberFormatter(),
         style: PropertyViewModel.Style = .init())
    {
        self.httpClient = httpClient
        self.numberFormatter = numberFormatter
        self.style = style
    }

    func fetchProperties() async {
        isLoading = true
        errorMessage = nil
        do {
            properties = try await httpClient.fetchProperties(url: url)
            updateUniqueBedrooms()
            calculateAveragePrice()
        } catch let error as NetworkError {
            switch error {
            case .invalidURL:
                errorMessage = style.invalidURL
            case .noData:
                errorMessage = style.noData
            case let .responseError(statusCode):
                errorMessage = "\(style.invalidResponse) + \(statusCode)."
            case let .decodingError(decodingError):
                errorMessage = "\(style.failedDecodeJson) + \(decodingError.localizedDescription)"
            }
        } catch {
            errorMessage = "\(style.unexpectedError) + \(error.localizedDescription)"
        }

        isLoading = false
    }

    func calculateAveragePrice() {
        let filteredProperties: [Property]
        if let selectedBedrooms = selectedBedrooms {
            filteredProperties = properties.filter { $0.bedrooms == selectedBedrooms }
        } else {
            filteredProperties = properties
        }

        guard !filteredProperties.isEmpty else {
            averagePrice = nil
            return
        }

        let totalPrices = filteredProperties.reduce(0) { $0 + $1.price }
        let average = Double(totalPrices) / Double(filteredProperties.count)
        averagePrice = numberFormatter.poundsFormattedPrice(price: average)
    }

    private func updateUniqueBedrooms() {
        let bedroomsSet = Set(properties.map { $0.bedrooms })
        uniqueBedrooms = Array(bedroomsSet).sorted()
    }
}
