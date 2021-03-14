//
//  Data+Logger.swift
//  PATools
//
//  Created by Guillermo Sáenz on 3/13/21.
//

import Foundation
import CocoaLumberjack

public extension HTTPURLResponse {
    
    func log(
        with data: Data?
    ) {
        
        let urlString = self.url?.absoluteString ?? "None"
        let statusCode = self.statusCode
        let headersString = (try? self.allHeaderFields.asJSONString()) ?? "None"
        let prettyPrintedData = (try? data?.prettyPrinted()) ?? "None"
        
        let responseAsString = """

********* API RESPONSE START *********
URL: \(urlString)
STATUS CODE: \(statusCode)
HEADERS: \(headersString)
DATA: \(prettyPrintedData)
********* API RESPONSE END *********
"""
        
        DDLogDebug(responseAsString)
    }
}

fileprivate extension Data {
    func prettyPrinted() throws -> String? {
        
        let object = try JSONSerialization.jsonObject(with: self, options: [])
        let data = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted])
        let prettyPrintedString = String(data: data, encoding: .utf8)
        
        return prettyPrintedString
    }
}
