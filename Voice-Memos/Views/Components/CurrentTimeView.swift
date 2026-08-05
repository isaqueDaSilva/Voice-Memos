//
//  CurrentTimeView.swift
//  Voice-Memos
//
//  Created by Isaque da Silva on 1/9/26.
//

import SwiftUI

struct CurrentTimeView: View {
    let currentTime: TimeInterval
    
    var body: some View {
        Text(currentTime.toTimeLabel())
            .font(.headline.monospaced())
    }
}

#Preview {
    CurrentTimeView(currentTime: 3)
}
