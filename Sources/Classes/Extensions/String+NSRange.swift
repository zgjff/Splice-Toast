//
//  String+NSRange.swift
//  Splice-Toast-Demo
//
//  Created by 郑桂杰 on 2022/1/7.
//

import Foundation

extension String {
    internal func nsRange(from range: Range<String.Index>) -> NSRange {
        if range.isEmpty {
            return NSRange(location: 0, length: 0)
        }
        guard let from = range.lowerBound.samePosition(in: utf16),
              let to = range.upperBound.samePosition(in: utf16) else {
                  return NSRange(location: 0, length: 0)
              }
        return NSRange(location: utf16.distance(from: utf16.startIndex, to: from),length: utf16.distance(from: from, to: to))
    }
}
