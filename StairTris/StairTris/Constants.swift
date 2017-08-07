//
//  Constants.swift
//  StairTris
//
//  Created by George Hong on 8/4/17.
//  Copyright © 2017 George Hong. All rights reserved.
//

import Foundation

struct Products {
    public static let removeAds = "Hong.StairTris.RemoveAds"
    fileprivate static let productIdentifiers: Set<ProductIdentifier> = [Products.removeAds]
    public static let store = StoreService(productIds: Products.productIdentifiers)
}
