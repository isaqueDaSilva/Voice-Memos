//
//  ProgressBarView.swift
//  Voice-Memos
//
//  Created by Isaque da Silva on 1/10/26.
//

import SwiftUI

struct ProgressBarView: View {
    let currentTime: TimeInterval
    let progress: Double
    
    var body: some View {
        VStack {
            ProgressBar(progress: progress)
            
            CurrentTimeView(currentTime: currentTime)
        }
    }
}

struct ProgressBar: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(.secondary.opacity(0.1))
                
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: proxy.size.width * CGFloat(self.progress))
                    .foregroundStyle(.blue)
            }
        }
        .frame(height: 10)
    }
}

#Preview {
    ProgressBarView(currentTime: 24, progress: 0.4)
        .padding()
}
