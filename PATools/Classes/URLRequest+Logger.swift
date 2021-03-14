//
//  URLRequest+Logger.swift
//  PATools
//
//  Created by Guillermo Sáenz on 3/13/21.
//

import Foundation
import CocoaLumberjack

public extension URLRequest {
    func log() {
        
        let urlString = self.url?.absoluteString ?? "None"
        let httpMethodString = self.httpMethod ?? "None"
        let headersString = (try? self.allHTTPHeaderFields?.asJSONString()) ?? "None"
        let httpBodyString = (try? self.prettyPrintedHttpBody()) ?? "None"
        
        let requestAsString = """

********* API REQUEST START *********
URL: \(urlString)
METHOD: \(httpMethodString)
HEADERS: \(headersString)
PAYLOAD: \(httpBodyString)
********* API REQUEST END *********
"""
        
        DDLogDebug(requestAsString)
    }
    
    fileprivate func prettyPrintedHttpBody() throws -> String? {
        guard
            let httpBody = self.httpBody
        else {
            return nil
        }
        
        let object = try JSONSerialization.jsonObject(with: httpBody, options: [])
        let data = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted])
        let prettyPrintedString = String(data: data, encoding: .utf8)
        
        return prettyPrintedString
    }
}

