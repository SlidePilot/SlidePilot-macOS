//
//  Message.swift
//  SlidePilot
//
//  Created by Pascal Braband on 08.10.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

/**
 Protocol:
    - command: disconnect
      payload: nil if sender is Host (macOS App), MCPeerID if sender is client -> then macOS app should engage disconnect
 
    - command: code
      payload: String containing verification code
 
    - command: showNextSlide
      payload: nil
 
    - command: showPreviousSlide
      payload: nil
 
    - command: showBlackScreen
      payload: nil
 
    - command: showWhiteScreen
      payload: nil
 
    - command: currentSlide
      payload: Image of the related slide
 
    - command: nextSlide
      payload: Image of the related slide
 
    - command: noteSlide
      payload: Image of the related slide
 
 */

import Foundation

struct Message {
    
    var command: Command
    var payload: Data?
    
    enum Command: Int, Codable {
        case disconnect, code, connectionAccepted,
             showNextSlide, showPreviousSlide, showBlackScreen, showWhiteScreen,
             currentSlide, nextSlide, noteSlide
    }
    
    
    public var description: String {
        return "Message:\n    - Command: \(command.rawValue)\n    - Payload: \(payload?.count ?? 0)"
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        command = try container.decode(Command.self, forKey: .command)
        payload = try container.decode(Data?.self, forKey: .payload)
    }
    
    
    // MARK: - Encode/Decode convenience
    
    func data() -> Data? {
        guard let data = try? PropertyListEncoder().encode(self) else { return nil }
        return data
    }
    
    
    init?(data: Data) {
        guard let message = try? PropertyListDecoder().decode(Message.self, from: data) else { return nil }
        self = message
    }
}




extension Message: Codable {
    
    enum CodingKeys: String, CodingKey {
        case command, payload
    }
    
    
    init(command: Command, payload: Data?) {
        self.command = command
        self.payload = payload
    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(command, forKey: .command)
        try container.encode(payload, forKey: .payload)
    }
}
