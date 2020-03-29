//
//  String+Extension.swift
//  SlidePilot
//
//  Created by Pascal Braband on 29.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

extension String {
    
    mutating func fixSpecialChars() -> String {
        self = self.replacingOccurrences(of: " ̈a", with: "ä")
        self = self.replacingOccurrences(of: "`a", with: "à")
        self = self.replacingOccurrences(of: " ́a", with: "á")
        self = self.replacingOccurrences(of: "ˆa", with: "â")
        self = self.replacingOccurrences(of: " ̃a", with: "ã")
        self = self.replacingOccurrences(of: " ̊a", with: "å")
        self = self.replacingOccurrences(of: " ̄a", with: "ā")
        
        self = self.replacingOccurrences(of: " ̧c", with: "ç")
        self = self.replacingOccurrences(of: " ́c", with: "ć")
        self = self.replacingOccurrences(of: "ˇc", with: "č")
        
        self = self.replacingOccurrences(of: " ́e", with: "é")
        self = self.replacingOccurrences(of: "`e", with: "è")
        self = self.replacingOccurrences(of: "ˆe", with: "ê")
        self = self.replacingOccurrences(of: " ̈e", with: "ë")
        self = self.replacingOccurrences(of: "e ̇", with: "ė")
        
        self = self.replacingOccurrences(of: "ˆı", with: "î")
        self = self.replacingOccurrences(of: " ̈ı", with: "ï")
        self = self.replacingOccurrences(of: " ́ı", with: "í")
        self = self.replacingOccurrences(of: " ̄ı", with: "ī")
        self = self.replacingOccurrences(of: "`ı", with: "ì")
        
        self = self.replacingOccurrences(of: "n ̃", with: "ñ")
        self = self.replacingOccurrences(of: "n ́", with: "ń")
        
        self = self.replacingOccurrences(of: "o ̈", with: "ö")
        self = self.replacingOccurrences(of: "ˆo", with: "ô")
        self = self.replacingOccurrences(of: "`o", with: "ò")
        self = self.replacingOccurrences(of: " ́o", with: "ó")
        self = self.replacingOccurrences(of: "o ̃", with: "õ")
        self = self.replacingOccurrences(of: " ̄o", with: "õ")
        
        self = self.replacingOccurrences(of: " ́s", with: "ś")
        self = self.replacingOccurrences(of: "ˇs", with: "š")
        
        self = self.replacingOccurrences(of: "u ̈", with: "ü")
        self = self.replacingOccurrences(of: "uˆ", with: "û")
        self = self.replacingOccurrences(of: "u`", with: "ù")
        self = self.replacingOccurrences(of: "u ́", with: "ú")
        self = self.replacingOccurrences(of: "u ̄", with: "ū")
        
        self = self.replacingOccurrences(of: " ̈y", with: "ÿ")
        
        return self
    }
}
