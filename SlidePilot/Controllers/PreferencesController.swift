//
//  PreferencesController.swift
//  SlidePilot
//
//  Created by Pascal Braband on 23.06.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

class PreferencesController: NSObject {
    
    // User Default
    private static let documentPreferencesSuiteName = (Bundle.main.bundleIdentifier ?? "de.pascalbraband.SlidePilot") + ".document-preferences"
    private static let documentPreferences = UserDefaults.init(suiteName: documentPreferencesSuiteName)!

    // 4 weeks
    private static let documentPreferencesLifetime: TimeInterval = 2419200
    
    /**
     This method removes preferences saved for a document, if their `last opening date < current date - documentPreferencesLifetime`
     */
    public static func cleanUpDocumentPreferences() {
        // Remove every preference, which is older than the documentPreferencesLifetime.
        for (key, value) in documentPreferences.dictionaryRepresentation() {
            guard let prefData = value as? Data else { continue }
            guard let pref = try? PropertyListDecoder().decode(DisplayController.Preferences.self, from: prefData) else { continue }
            if pref.lastUpdated < Date() - documentPreferencesLifetime {
                documentPreferences.removeObject(forKey: key)
            }
        }
        documentPreferences.synchronize()
    }
    
    
    /**
     Saves the given `Preferences` for a given key `filePath` to the UserDefaults.
     */
    public static func save(preferences: DisplayController.Preferences, for filePath: String) {
        // Gather DocumentPreferences from DisplayController and save them
        guard let preferencesData = try? PropertyListEncoder().encode(preferences) else { return }
        documentPreferences.set(preferencesData, forKey: filePath)
        documentPreferences.synchronize()
    }
    
    
    /**
     Returns the preferences for a given key `filePath` from the UserDefaults.
     */
    public static func getDocumentPreferences(for filePath: String) -> DisplayController.Preferences? {
        // TODO: Get DocPrefs and return them
        if let preferencesData = documentPreferences.object(forKey: filePath) as? Data,
            let preferences = try? PropertyListDecoder().decode(DisplayController.Preferences.self, from: preferencesData) {
            return preferences
        } else {
            return nil
        }
    }
}
