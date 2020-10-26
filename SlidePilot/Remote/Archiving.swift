//
//  Archiving.swift
//  SlidePilot
//
//  Created by Pascal Braband on 08.10.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

extension NSKeyedArchiver {
    
    static func archive(object: Any) -> Data? {
        if #available(OSX 10.13, *) {
            return try? NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: false)
        } else {
            return NSKeyedArchiver.archivedData(withRootObject: object)
        }
    }
}




extension NSKeyedUnarchiver {
    
    static func unarchive<T>(data: Data, of type: T.Type) -> T? where T: NSObject, T: NSCoding {
        if #available(OSX 10.13, *) {
            return try? NSKeyedUnarchiver.unarchivedObject(ofClass: T.self, from: data)
        } else {
            return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? T
        }
    }
}
