//
//  String+Capitalize.swift
//  Chess
//
//  Created by Brian Ouzomgi on 12/2/20.
//

import Foundation

extension String {
    func capitalizeFirstLetter() -> String {
        self.prefix(1).capitalized + self.suffix(self.count - 1)
    }
}
