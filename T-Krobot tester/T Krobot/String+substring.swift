//
//  String+substring.swift
//  T Krobot
//
//  copy/pasted from https://stackoverflow.com/questions/39677330/how-does-string-substring-work-in-swift
//  imported to make substrings easier to use (based on int)
//

import Foundation

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(to value: Int) -> String {
        let toIndex = index(from: value)
        return String(self[..<toIndex])
    }

    func substring(with range: Range<Int>) -> String {
        let startIndex = index(from: range.lowerBound)
        let endIndex = index(from: range.upperBound)
        return String(self[startIndex..<endIndex])
    }
}

// let str = "Hello, playground"
// print(str.substring(from: 7))         // playground
// print(str.substring(to: 5))           // Hello
// print(str.substring(with: 7..<11))    // play
