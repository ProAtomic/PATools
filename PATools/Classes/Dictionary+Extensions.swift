//
//  Dictionary+Extensions.swift
//  PATools
//
//  Created by Guillermo Sáenz on 3/13/21.
//

import Foundation

public extension Dictionary {
    func asJSONString(with options: JSONSerialization.WritingOptions = [.prettyPrinted]) throws -> String? {
        let theJSONData = try JSONSerialization.data(
            withJSONObject: self,
            options: options
        )
        
        let theJSONText = String(
            data: theJSONData,
            encoding: .utf8
        )
        
        return theJSONText
    }
}
