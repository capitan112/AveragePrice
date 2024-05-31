//
//  NumberFormatter+poundsFormattedPrice.swift
//  AveragePriceV2
//
//  Created by Oleksiy Chebotarov on 31/05/2024.
//

import Foundation

extension NumberFormatter {
    func poundsFormattedPrice(price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "£"
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = " "
        formatter.locale = Locale(identifier: "en_GB")
        return formatter.string(from: NSNumber(value: price)) ?? "£0.00"
    }
}
