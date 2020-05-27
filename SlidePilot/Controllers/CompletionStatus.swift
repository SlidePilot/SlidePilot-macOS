//
//  CompletionStatus.swift
//  SlidePilot
//
//  Created by Pascal Braband on 27.05.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Cocoa

enum CompletionStatus {
    case success, failed, aborted
    
    init(_ success: Bool) {
        if success {
            self = .success
        } else {
            self = .failed
        }
    }
    
    func isSuccess() -> Bool {
        switch self {
        case .success:
            return true
        default:
            return false
        }
    }
}
