//
//  View+OnChange.swift
//  Bike Buddy
//
//  SwiftUI onChange compatibility shim for iOS 16/17+.
//

import SwiftUI

extension View {
    /// Backward-compatible onChange that works on iOS 16 and iOS 17+.
    /// Uses the new two-parameter form on iOS 17+ (suppresses deprecation warning)
    /// and falls back to the single-parameter form on iOS 16.
    @ViewBuilder
    func onValueChange<T: Equatable>(of value: T, perform action: @escaping (T) -> Void) -> some View {
        if #available(iOS 17, *) {
            self.onChange(of: value) { _, newValue in action(newValue) }
        } else {
            self.onChange(of: value, perform: action)
        }
    }
}
