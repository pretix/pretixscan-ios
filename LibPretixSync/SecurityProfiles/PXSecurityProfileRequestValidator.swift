//
//  PXSecurityProfileValidator.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 31/01/2022.
//  Copyright © 2022 rami.io. All rights reserved.
//

import Foundation

/// Allow validation of outgoing API requests against a security profile
final class PXSecurityProfileRequestValidator {
    
    
    /// Checks if the provided request signature is allowed for this security profile.
    ///
    ///
    /// - Parameter request: The `URLRequest` including url and HTTP method to validate
    /// - Parameter profile: The `PXSecurityProfile` restriction level
    ///
    /// - Returns: `true` if the request can be placed or `false` if the request violates the security profile and should not be placed
    static func isAllowed(_ request: URLRequest, profile: PXSecurityProfile) -> Bool {
        if profile == .full {
            return true
        }
        
        let endpoints = PXSecurityProfileRequestValidator.matchingEndpoints(for: request, profile: profile)
        
        if let permission = endpoints.first {
            logger.debug("➡️ Allowed requeset '\(permission.0) \(permission.1)'")
            return true
        } else {
            logger.debug("🚧 Violation of security profile '\(profile.rawValue)' for request: '\(request.httpMethod!) \(request.url!)'")
            return false
        }
    }
    
    typealias PXAllowedHttpMethod = String
    typealias PXAllowedEndpointName = String
    typealias PXEndpointRegExPattern = String
    
    
    /// Endpoint detection expressions
    static let EndpointExpressions: [PXAllowedEndpointName: PXEndpointRegExPattern] = [
        "api-v1:event-list": #"(\/v1\/organizers\/)(.+?(?=\/))(\/events\/)$"#,
        "api-v1:event-detail": #"\/v1\/organizers\/.+?(?=\/)\/events\/([^\/\s]+\/)$"#,
        "api-v1:subevent-list": #"\/v1\/organizers\/.+?(?=\/)\/events\/([^\/\s]+\/)subevents\/$"#,
        "api-v1:subevent-detail": #"\/v1\/organizers\/.+?(?=\/)\/events\/([^\/\s]+\/)subevents\/([^\/\s]+\/)$"#,
        "api-v1:itemcategory-list": #"\/v1\/organizers\/.+?(?=\/)\/events\/([^\/\s]+\/)categories\/$"#,
        "api-v1:item-list": #"\/v1\/organizers\/.+?(?=\/)\/events\/([^\/\s]+\/)items\/$"#,
        "api-v1:question-list": #"\/v1\/organizers\/.+?(?=\/)\/events\/([^\/\s]+\/)questions\/$"#,
        "api-v1:checkinlist-list": #"\/v1\/organizers\/.+?(?=\/)\/events\/([^\/\s]+\/)checkinlists\/$"#,
        "api-v1:checkinlist-status": #"\/v1\/organizers\/.+?(?=\/)\/events\/([^\/\s]+\/)checkinlists\/([^\/\s]+\/)status\/$"#,
        "api-v1:checkinlist-failed_checkins": #"\/v1\/organizers\/.+?(?=\/)\/events\/([^\/\s]+\/)checkinlists\/([^\/\s]+\/)failed_checkins\/$"#,
        "api-v1:checkinlistpos-list": #"\/v1\/organizers\/.+?(?=\/)\/events\/([^\/\s]+\/)checkinlists\/([^\/\s]+\/)positions\/$"#,
        "api-v1:checkinlistpos-redeem": #"\/v1\/organizers\/.+?(?=\/)\/events\/([^\/\s]+\/)checkinlists\/([^\/\s]+\/)positions\/([^\/\s]+\/)redeem\/$"#,
        "api-v1:revokedsecrets-list": #"\/v1\/organizers\/.+?(?=\/)\/events\/([^\/\s]+\/)revokedsecrets\/$"#,
        "api-v1:order-list": #"\/v1\/organizers\/.+?(?=\/)\/events\/([^\/\s]+\/)orders\/$"#,
    ]
    
    
    static let AllowListNoOrders: [(PXAllowedHttpMethod, PXAllowedEndpointName)] = [("GET", "api-v1:version"),
                                                                                    ("GET", "api-v1:device.eventselection"),
                                                                                    ("POST", "api-v1:device.update"),
                                                                                    ("POST", "api-v1:device.revoke"),
                                                                                    ("POST", "api-v1:device.roll"),
                                                                                    ("GET", "api-v1:event-list"),
                                                                                    ("GET", "api-v1:event-detail"),
                                                                                    ("GET", "api-v1:subevent-list"),
                                                                                    ("GET", "api-v1:subevent-detail"),
                                                                                    ("GET", "api-v1:itemcategory-list"),
                                                                                    ("GET", "api-v1:item-list"),
                                                                                    ("GET", "api-v1:question-list"),
                                                                                    ("GET", "api-v1:badgelayout-list"),
                                                                                    ("GET", "api-v1:badgeitem-list"),
                                                                                    ("GET", "api-v1:checkinlist-list"),
                                                                                    ("GET", "api-v1:checkinlist-status"),
                                                                                    ("POST", "api-v1:checkinlist-failed_checkins"),
                                                                                    ("GET", "api-v1:checkinlistpos-list"),
                                                                                    ("POST", "api-v1:checkinlistpos-redeem"),
                                                                                    ("GET", "api-v1:revokedsecrets-list"),
                                                                                    ("GET", "api-v1:orderposition-pdf_image"),
                                                                                    ("GET", "api-v1:event.settings"),
                                                                                    ("POST", "api-v1:upload")]
    
    static let AllowListKiosk: [(PXAllowedHttpMethod, PXAllowedEndpointName)] = [("GET", "api-v1:version"),
                                                                                 ("GET", "api-v1:device.eventselection"),
                                                                                 ("POST", "api-v1:device.update"),
                                                                                 ("POST", "api-v1:device.revoke"),
                                                                                 ("POST", "api-v1:device.roll"),
                                                                                 ("GET", "api-v1:event-list"),
                                                                                 ("GET", "api-v1:event-detail"),
                                                                                 ("GET", "api-v1:subevent-list"),
                                                                                 ("GET", "api-v1:subevent-detail"),
                                                                                 ("GET", "api-v1:itemcategory-list"),
                                                                                 ("GET", "api-v1:item-list"),
                                                                                 ("GET", "api-v1:question-list"),
                                                                                 ("GET", "api-v1:badgelayout-list"),
                                                                                 ("GET", "api-v1:badgeitem-list"),
                                                                                 ("GET", "api-v1:checkinlist-list"),
                                                                                 ("GET", "api-v1:checkinlist-status"),
                                                                                 ("POST", "api-v1:checkinlist-failed_checkins"),
                                                                                 ("POST", "api-v1:checkinlistpos-redeem"),
                                                                                 ("GET", "api-v1:revokedsecrets-list"),
                                                                                 ("GET", "api-v1:orderposition-pdf_image"),
                                                                                 ("GET", "api-v1:event.settings"),
                                                                                 ("POST", "api-v1:upload")]
    
    static let AllowListPretixScan: [(PXAllowedHttpMethod, PXAllowedEndpointName)] = [("GET", "api-v1:version"), // NOT USED BY THE APP
                                                                                      ("GET", "api-v1:device.eventselection"), // NOT USED BY THE APP
                                                                                      ("POST", "api-v1:device.update"), // NOT USED BY THE APP
                                                                                      ("POST", "api-v1:device.revoke"), // NOT USED BY THE APP
                                                                                      ("POST", "api-v1:device.roll"), // NOT USED BY THE APP
                                                                                      ("GET", "api-v1:event-list"), // OK
                                                                                      ("GET", "api-v1:event-detail"), // OK, POST?
                                                                                      ("GET", "api-v1:subevent-list"), // OK
                                                                                      ("GET", "api-v1:subevent-detail"), // OK
                                                                                      ("GET", "api-v1:itemcategory-list"), // OK
                                                                                      ("GET", "api-v1:item-list"), // OK
                                                                                      ("GET", "api-v1:question-list"), // OK
                                                                                      ("GET", "api-v1:badgelayout-list"), // NOT USED BY THE APP
                                                                                      ("GET", "api-v1:badgeitem-list"), // NOT USED BY THE APP
                                                                                      ("GET", "api-v1:checkinlist-list"), // OK
                                                                                      ("GET", "api-v1:checkinlist-status"), // OK
                                                                                      ("POST", "api-v1:checkinlist-failed_checkins"), // OK
                                                                                      ("GET", "api-v1:checkinlistpos-list"), // OK
                                                                                      ("POST", "api-v1:checkinlistpos-redeem"), // OK
                                                                                      ("GET", "api-v1:revokedsecrets-list"), // OK
                                                                                      ("GET", "api-v1:order-list"), // OK
                                                                                      ("GET", "api-v1:orderposition-pdf_image"), // NOT USED BY THE APP
                                                                                      ("GET", "api-v1:event.settings"), // NOT USED BY THE APP
                                                                                      ("POST", "api-v1:upload")]
    
    
    /// Returns a list of endpoint names applicable for the provided security profile
    ///
    ///
    /// - Parameter profile: The `PXSecurityProfile` restriction level
    ///
    /// - Returns: An empty array if no restriction should be applied or an array of `(PXAllowedHttpMethod, PXAllowedEndpointName)` values to which the security profile is restricted
    static func allowList(for profile: PXSecurityProfile) -> [(PXAllowedHttpMethod, PXAllowedEndpointName)] {
        switch profile {
        case .full:
            return []
        case .pretixscan:
            return AllowListPretixScan
        case .kiosk:
            return AllowListKiosk
        case .noOrders:
            return AllowListNoOrders
        }
    }
    
    static func matchingEndpoints(for request: URLRequest, profile: PXSecurityProfile) -> [(PXAllowedHttpMethod, PXAllowedEndpointName)] {
        let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: true)!
        let allowList = allowList(for: profile).filter({$0.0 == request.httpMethod})
        
        var results = [(PXAllowedHttpMethod, PXAllowedEndpointName)]()
        for expression in Self.EndpointExpressions {
            let regex = NSRegularExpression(expression.value)
            if regex.matches(components.path) {
                if let matchingEndpoint = allowList.first(where: {$0.1 == expression.key}) {
                    results.append(matchingEndpoint)
                }
            }
        }
        return results
    }
}

extension NSRegularExpression {
    convenience init(_ pattern: String) {
        do {
            try self.init(pattern: pattern)
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }
}

extension NSRegularExpression {
    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return firstMatch(in: string, options: [], range: range) != nil
    }
}
