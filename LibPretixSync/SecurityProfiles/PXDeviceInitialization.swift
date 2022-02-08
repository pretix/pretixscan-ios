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
    private weak var configStore: ConfigStore?
    
    var hardwareBrand: String = "Apple"
    
    var hardwareModel: String = UIDevice.current.modelName
    
    var softwareBrand: String = Bundle.main.infoDictionary!["CFBundleName"] as? String ?? "n/a"
    
    var softwareVersion: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "n/a"
    
    init(_ config: ConfigStore) {
        self.configStore = config
    }

    
    func needsToUpdate() -> Bool {
        guard let publishedSoftwareVersion = configStore?.publishedSoftwareVersion else {
            // no published version
            logger.warning("Needs to update: no known published version")
            return true
        }
        
        logger.debug("Needs to update comparing '\(publishedSoftwareVersion)' to current '\(self.softwareVersion)'")
        return softwareVersion.compare(publishedSoftwareVersion) == .orderedDescending
    }
    
    func setPublishedVersion(_ version: String) {
        logger.debug("Setting last published version to '\(version)'")
        configStore?.publishedSoftwareVersion = version
    }

    
    func getUpdateRequest() -> DeviceUpdateRequest? {
        return DeviceUpdateRequest(hardwareBrand: hardwareBrand, hardwareModel: hardwareModel, softwareBrand: softwareBrand, softwareVersion: softwareVersion)
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
