//
//  SoundIntensityMeterView.swift
//  Voice-Noise-Reductor
//
//  Created by Isaque da Silva on 1/9/26.
//

import SwiftUI

struct SoundIntensityMeterView: View {
    let meterLevel: Float
    let currentTime: TimeInterval
    
    var body: some View {
        VStack {
            ProgressView(value: meterLevel)
                .progressViewStyle(.linear)
                .animation(.linear, value: meterLevel)
                .tint(.orange)
            
            Text(currentTime.toTimeLabel())
                .font(.headline.monospaced())
        }
    }
}

#Preview {
    SoundIntensityMeterView(meterLevel: 0, currentTime: 3)
}
