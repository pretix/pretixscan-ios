//
//  PXDeviceInitialization.swift
//  pretixSCAN
//
//  Created by Konstantin Kostov on 04/02/2022.
//  Copyright © 2022 rami.io. All rights reserved.
//

import Foundation
import UIKit

final class PXDeviceInitialization {
    private let defaults: UserDefaults
    
    enum Keys: String, CaseIterable {
        /// The last version of the app which was used during initialization
        case publishedSoftwareVersion
    }
    
    init(_ defaults: UserDefaults) {
        self.defaults = defaults
    }

    
    func needsToUpdate() -> Bool {
        guard let publishedSoftwareVersion = defaults.string(forKey: Keys.publishedSoftwareVersion.rawValue) else {
            // no published version
            logger.warning("Needs to update: no known published version")
            return true
        }
        
        guard let softwareVersion = getSoftwareVersion() else {
            logger.warning("Needs to update: unable to determine software version")
            return false
        }
        
        logger.debug("Needs to update comparing '\(publishedSoftwareVersion)' to current '\(softwareVersion)'")
        return softwareVersion.compare(publishedSoftwareVersion) == .orderedAscending
    }
    
    func setPublishedVersion(_ version: String) {
        logger.debug("Setting last published version to '\(version)'")
        defaults.set(version, forKey: Keys.publishedSoftwareVersion.rawValue)
        defaults.synchronize()
    }
    
    func getSoftwareVersion() -> String? {
        Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
    }
    
    func getUpdateRequest() -> DeviceUpdateRequest? {
        return DeviceUpdateRequest(hardwareBrand: "Apple", hardwareModel: UIDevice.current.modelName, softwareBrand: Bundle.main.infoDictionary!["CFBundleName"] as? String ?? "n/a", softwareVersion: getSoftwareVersion() ?? "n/a")
    }
}

public struct DeviceUpdateRequest: Codable, Equatable {
    /// The hardware manufacturer
    public let hardwareBrand: String

    /// The device model
    public let hardwareModel: String

    /// The software manufacturer
    public let softwareBrand: String

    /// The software version
    public let softwareVersion: String

    private enum CodingKeys: String, CodingKey {
        case hardwareBrand = "hardware_brand"
        case hardwareModel = "hardware_model"
        case softwareBrand = "software_brand"
        case softwareVersion = "software_version"
    }
}
