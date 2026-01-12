//
//  TimeInterval+Extensions.swift
//  Voice-Noise-Reductor
//
//  Created by Isaque da Silva on 1/10/26.
//

import Foundation

struct TimeLabel {
    private let minutes: String
    private let seconds: String
    
    func label() -> String {
        "\(minutes):\(seconds)"
    }
    
    init(minutes: Int, seconds: Int) {
        self.minutes = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        self.seconds = seconds > 9 ? "\(seconds)" : "0\(seconds)"
    }
}

extension TimeInterval {
    func toTimeLabel() -> String {
        let minutesInDouble = (Double(self) / 60)
        let minutes = Int(minutesInDouble)
        let secondsReminders = minutesInDouble - Double(minutes)
        let secondsInDouble = secondsReminders * 60
        let seconds = Int(secondsInDouble.rounded())
        
        let time = TimeLabel(minutes: minutes, seconds: seconds)
        
        return time.label()
    }
}
