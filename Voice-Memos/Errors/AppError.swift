//
//  AppErrorProtocol.swift
//  Voice-Memos
//
//  Created by Isaque da Silva on 1/10/26.
//

import Foundation

protocol AppErrorProtocol: Error, LocalizedError {
    var title: String { get }
    var description: String? { get }
}

struct DefaultUnknownError: AppErrorProtocol {
    private(set) var title: String = "Unknown Error"
    private(set) var description: String? = "An unknown error occurred. Please try to reload the app and again later."
    
    init(title: String, description: String?) {
        self.title = title
        self.description = description
    }
    
    init() { }
}
