//
//  String+html.swift
//  TinkoffNews
//
//  Created by user on 24.07.17.
//  Copyright © 2017 user. All rights reserved.
//

import UIKit

extension String {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: Data(utf8), options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return nil
        }
    }
    
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}
