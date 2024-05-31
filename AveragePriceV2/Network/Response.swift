//
//  Response.swift
//  AveragePriceV2
//
//  Created by Oleksiy Chebotarov on 31/05/2024.
//

import Foundation

struct Response: Decodable {
    let properties: [Property]
}

struct Property: Decodable {
    let price: Int
    let bedrooms: Int
}
