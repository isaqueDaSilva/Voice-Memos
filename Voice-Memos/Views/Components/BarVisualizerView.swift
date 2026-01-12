//
//  BarVisualizerView.swift
//  Voice-Noise-Reductor
//
//  Created by Isaque da Silva on 1/5/26.
//

import SwiftUI

struct BarVisualizerView: View {
    let values: [Float]
    let barCount: Int
    
    var body: some View {
        GeometryReader { geo in
            let rawWidth = geo.size.width
            let rawHeight = geo.size.height
            let width = rawWidth.isFinite ? max(0, rawWidth) : 0
            let height = rawHeight.isFinite ? max(0, rawHeight) : 0
            
            let safeBarCount = max(1, barCount)
            let barSpacing: CGFloat = 1
            let totalSpacing = CGFloat(safeBarCount - 1) * barSpacing
            let availableWidth = max(0, width - totalSpacing)
            let barWidth = availableWidth / CGFloat(safeBarCount)
            
            let chunckSize = max(1, values.count / safeBarCount)
            
            let barValues: [Float] = (0..<safeBarCount).map { i in
                let start = i * chunckSize
                let end = min(start + chunckSize, values.count)
                if start >= end { return 0 }
                let slice = values[start..<end]
                return slice.reduce(0, +) / Float(slice.count)
            }
            
            HStack(spacing: barSpacing) {
                ForEach(0..<safeBarCount, id: \.self) { i in
                    let base = CFloat(barValues[i])
                    let v = base.isFinite ? base : 0
                    let capped = max(0.07, min(v, 1))
                    let barHeight = max(0, min(height, CGFloat(capped) * height))
                    let safeBarwidth = max(0, barWidth)
                    let yoffset = (height - barHeight) / 2
                    
                    Rectangle()
                        .fill(.primary.opacity(0.85))
                        .frame(width: safeBarwidth, height: barHeight)
                        .cornerRadius(safeBarwidth / 2)
                        .offset(y: yoffset)
                }
            }
        }
    }
}

//#Preview {
//    BarVisualizerView()
//}
