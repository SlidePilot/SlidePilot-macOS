//
//  ConfigurationController.swift
//  SlidePilot
//
//  Created by Pascal Braband on 23.06.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class ConfigurationController: NSObject {
    
    // User Default
    private static let documentConfigurationSuiteName = (Bundle.main.bundleIdentifier ?? "de.pascalbraband.SlidePilot") + ".document-configuration"
    private static let documentConfigurations = UserDefaults.init(suiteName: documentConfigurationSuiteName)!

    // 4 weeks
    private static let documentConfigurationLifetime: TimeInterval = 2419200
    
    /**
     This method removes configurations saved for a document, if their `last opening date < current date - documentConfigurationLifetime`
     */
    public static func cleanUpDocumentConfigurations() {
        // Remove every configuration, which is older than the documentConfigurationLifetime.
        for (key, value) in documentConfigurations.dictionaryRepresentation() {
            guard let configurationData = value as? Data else { continue }
            guard let configuration = try? PropertyListDecoder().decode(DisplayController.Configuration.self, from: configurationData) else { continue }
            if configuration.lastUpdated < Date() - documentConfigurationLifetime {
                documentConfigurations.removeObject(forKey: key)
            }
        }
        documentConfigurations.synchronize()
    }
    
    
    /**
     Saves the given `Configuration` for a given key `filePath` to the UserDefaults.
     */
    public static func save(configuration: DisplayController.Configuration, for filePath: String) {
        // Gather Configuration from DisplayController and save them
        guard let configurationData = try? PropertyListEncoder().encode(configuration) else { return }
        documentConfigurations.set(configurationData, forKey: filePath)
        documentConfigurations.synchronize()
    }
    
    
    /**
     Returns the configuration for a given key `filePath` from the UserDefaults.
     */
    public static func getDocumentConfiguration(for filePath: String) -> DisplayController.Configuration? {
        // TODO: Get Configuration from the UserDefaults and return them
        if let configurationData = documentConfigurations.object(forKey: filePath) as? Data,
            let configuration = try? PropertyListDecoder().decode(DisplayController.Configuration.self, from: configurationData) {
            return configuration
        } else {
            return nil
        }
    }
}
