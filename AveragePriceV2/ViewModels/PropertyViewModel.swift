//
//  PropertyViewModel.swift
//  AveragePriceV2
//
//  Created by Oleksiy Chebotarov on 31/05/2024.
//

import Combine
import Foundation
import UIKit

protocol PropertyViewModelProtocol: AnyObject {
    var selectedBedrooms: Int? { get set }
    var uniqueBedrooms: [Int] { get }
    var errorMessage: String? { get }
    
    var averagePrice: PassthroughSubject<String?, Never> { get  set }
    var isLoading: PassthroughSubject<Bool, Never> { get  set }
    var selectedBedroomsPublisher: Published<Int?>.Publisher { get }
    var uniqueBedroomsPublisher: Published<[Int]>.Publisher { get }
    
    var errorMessagePublisher: Published<String?>.Publisher { get }
    var style: PropertyViewModel.Style { get }

    func fetchProperties() async
    func calculateAveragePrice()
    func bedroomFormating(row: Int) -> String
}

class PropertyViewModel: PropertyViewModelProtocol, ObservableObject {
    struct Style {
        let pickerViewAll: String = "All"
        let bedroomSingular: String = "bedroom"
        let bedroomPlural: String = "bedrooms"
        let question: String = "What is the average property price?"
        let labelTextColor: UIColor = UIColor(red: 38 / 255, green: 38 / 255, blue: 55 / 255, alpha: 1)
        let labelFont: UIFont = UIFont.systemFont(ofSize: 14)

        // Errors
        let invalidURL: String = "Invalid URL."
        let noData: String = "No data received."
        let invalidResponse: String = "Invalid response from server: "
        let failedDecodeJson: String = "Failed to decode JSON: "
        let unexpectedError: String = "Unexpected error:  "
    }

    @Published var selectedBedrooms: Int?
    @Published var uniqueBedrooms: [Int] = []
    @Published var errorMessage: String?
    
    var averagePrice = PassthroughSubject<String?, Never>()
    var isLoading = PassthroughSubject<Bool, Never>()
    
    var selectedBedroomsPublisher: Published<Int?>.Publisher { $selectedBedrooms }
    var uniqueBedroomsPublisher: Published<[Int]>.Publisher { $uniqueBedrooms }
    var errorMessagePublisher: Published<String?>.Publisher { $errorMessage }

    private let url: String = "https://raw.githubusercontent.com/capitan112/AveragePrice/main/properties.json"
    private let httpClient: HTTPClientProtocol
    private let numberFormatter: NumberFormatter
    var properties: [Property] = []
    let style: Style

    init(httpClient: HTTPClientProtocol = HTTPClient(),
         numberFormatter: NumberFormatter = NumberFormatter(),
         style: PropertyViewModel.Style = .init())
    {
        self.httpClient = httpClient
        self.numberFormatter = numberFormatter
        self.style = style
    }

    func fetchProperties() async {
        isLoading.send(true)
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

        isLoading.send(false)
    }
    
    func bedroomFormating(row: Int) -> String {
        let bedrooms = uniqueBedrooms[row - 1]
        let bedroomString = bedrooms == 1 ? style.bedroomSingular : style.bedroomPlural
        
        return "\(bedrooms) \(bedroomString)"
    }

    func calculateAveragePrice() {
        let filteredProperties: [Property]
        if let selectedBedrooms = selectedBedrooms {
            filteredProperties = properties.filter { $0.bedrooms == selectedBedrooms }
        } else {
            filteredProperties = properties
        }

        guard !filteredProperties.isEmpty else {
            averagePrice.send("")
            return
        }
        

        let totalPrices = filteredProperties.reduce(0) { $0 + $1.price }
        let average = Double(totalPrices) / Double(filteredProperties.count)
        averagePrice.send(numberFormatter.poundsFormattedPrice(price: average))
    }

    func updateUniqueBedrooms() {
        let bedroomsSet = Set(properties.map { $0.bedrooms })
        uniqueBedrooms = Array(bedroomsSet).sorted()
    }
}
