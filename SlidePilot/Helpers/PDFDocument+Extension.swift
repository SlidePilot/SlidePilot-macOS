//
//  PDFDocument+Extension.swift
//  SlidePilot
//
//  Created by Pascal Braband on 24.06.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa
import PDFKit

extension PDFDocument {
    
    func notesPosition() -> DisplayController.NotesPosition? {
        guard let keywords = ((self.documentAttributes as? [String: Any])?["Keywords"] as? [Any]) else { return nil }
        
        for keyword in keywords {
            guard let keywordString = keyword as? String else { continue }
            if keywordString == "SP-Right" {
                return .right
            } else if keywordString == "SP-Left" {
                return .left
            } else if keywordString == "SP-Top" {
                return .top
            } else if keywordString == "SP-Bottom" {
                return .bottom
            }
        }
        
        return nil
    }
}
