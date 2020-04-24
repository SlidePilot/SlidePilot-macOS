//
//  Notification-Name+Extension.swift
//  SlidePilot
//
//  Created by Pascal Braband on 24.04.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import Foundation
import PDFKit

class PageController {
    
    public private(set) static var currentPage = 0
    
    public static let pageKey = "pageKey"
    
    
    /** Sends a notification, that the next page was selected. */
    public static func nextPage(sender: Any?) {
        selectPage(at: currentPage+1, sender: sender)
    }
    
    
    /** Sends a notification, that the previous page was selected. */
    public static func previousPage(sender: Any?) {
        selectPage(at: currentPage-1, sender: sender)
    }
    
    
    /** Sends a notification, that the page was changed. With the corresponding page as user info. */
    public static func selectPage(at index: Int, sender: Any?) {
        if isValidIndex(index) {
            currentPage = index
            NotificationCenter.default.post(name: .didSelectPage, object: sender, userInfo: [pageKey: index])
        }
    }
    
    
    private static func isValidIndex(_ index: Int) -> Bool {
        return index >= 0 && index < DocumentController.pageCount
    }
    
    
    /** Returns the page index from a `.didChangePage` Notification. */
    public static func getPageIndex(_ notification: Notification) -> Int? {
        guard let userInfo = notification.userInfo as? [String: Int] else { return nil }
        return userInfo[pageKey]
    }
    
    
    /** Subscribes a target to all notifications sent by `PageController`. */
    public static func subscribe(target: Any, action: Selector) {
        NotificationCenter.default.addObserver(target, selector: action, name: .didSelectPage, object: nil)
    }
    
    
    /** Unsubscribes a target from all notifications sent by `PageController`. */
    public static func unsubscribe(target: Any) {
        NotificationCenter.default.removeObserver(target, name: .didSelectPage, object: nil)
    }
}




extension Notification.Name {
    static let didSelectPage = Notification.Name("didSelectPage")
}
