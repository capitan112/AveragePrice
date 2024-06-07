//
//  AveragePriceV2Tests.swift
//  AveragePriceV2Tests
//
//  Created by Oleksiy Chebotarov on 31/05/2024.
//

import Combine
import XCTest

class PropertyViewModelTests: XCTestCase {
    var viewModel: PropertyViewModel!
    var mockHTTPClient: MockHTTPClient!

    override func setUp() {
        super.setUp()
        mockHTTPClient = MockHTTPClient()
        viewModel = PropertyViewModel(httpClient: mockHTTPClient)
    }

    override func tearDown() {
        viewModel = nil
        mockHTTPClient = nil
        super.tearDown()
    }

    func testFetchPropertiesSuccess() async {
        mockHTTPClient.shouldReturnError = false

        await viewModel.fetchProperties()

        XCTAssertEqual(viewModel.properties.count, 3)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testFetchPropertiesInvalidURL() async {
        mockHTTPClient.shouldReturnError = true
        mockHTTPClient.errorType = .invalidURL

        await viewModel.fetchProperties()

        XCTAssertEqual(viewModel.properties.count, 0)
        XCTAssertEqual(viewModel.errorMessage, viewModel.style.invalidURL)
    }

    func testFetchPropertiesNoData() async {
        mockHTTPClient.shouldReturnError = true
        mockHTTPClient.errorType = .noData

        await viewModel.fetchProperties()

        XCTAssertEqual(viewModel.properties.count, 0)
        XCTAssertEqual(viewModel.errorMessage, viewModel.style.noData)
    }

    func testFetchPropertiesResponseError() async {
        mockHTTPClient.shouldReturnError = true
        mockHTTPClient.errorType = .responseError(404)

        await viewModel.fetchProperties()

        XCTAssertEqual(viewModel.properties.count, 0)
        XCTAssertEqual(viewModel.errorMessage, "\(viewModel.style.invalidResponse) + 404.")
    }

    func testFetchPropertiesDecodingError() async {
        mockHTTPClient.shouldReturnError = true
        mockHTTPClient.errorType = .decodingError(NSError(domain: "", code: 0, userInfo: nil))

        await viewModel.fetchProperties()

        XCTAssertEqual(viewModel.properties.count, 0)
        XCTAssertEqual(viewModel.errorMessage, "\(viewModel.style.failedDecodeJson) + The operation couldn’t be completed. ( error 0.)")
    }
    
    func testCalculateUniqueBedroomsAndAveragePrice() {
        let properties = [
            Property(price: 100_000, bedrooms: 1),
            Property(price: 150_000, bedrooms: 2),
            Property(price: 200_000, bedrooms: 3),
        ]
        
        viewModel.properties = properties
        viewModel.calculateAveragePrice()
        viewModel.updateUniqueBedrooms()

        XCTAssertEqual(viewModel.uniqueBedrooms, [1, 2, 3])
        XCTAssertEqual(viewModel.averagePrice, "£150,000.00")
    }
}

class MockHTTPClient: HTTPClient {
    var shouldReturnError: Bool = false
    var errorType: NetworkError?

    override func fetchProperties(url _: String) async throws -> [Property] {
        if shouldReturnError, let error = errorType {
            throw error
        }

        let mockProperties = [
            Property(price: 100_000, bedrooms: 1),
            Property(price: 150_000, bedrooms: 2),
            Property(price: 200_000, bedrooms: 3),
        ]

        return mockProperties
    }
}
