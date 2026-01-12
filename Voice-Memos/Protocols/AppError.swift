//
//  AppError.swift
//  Voice-Noise-Reductor
//
//  Created by Isaque da Silva on 1/10/26.
//

import Foundation

protocol AppError: Error, LocalizedError {
    var title: String { get }
    var description: String? { get }
}

struct DefaultUnknownError: AppError {
    let title: String = "Unknown Error"
    let description: String? = "An unknown error occurred. Please try to reload the app and again later."
}
