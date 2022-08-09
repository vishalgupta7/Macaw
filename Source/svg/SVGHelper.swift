//
//  SVGParser.swift
//  Example-macOS
//
//  Created by Rohit Vishwakarma on 21/07/22.
//

import Foundation

open class SVGHelper {
    open class func getAllVarColors(xmlText: String) -> [String: MColor] {
        var result: [String: MColor] = [:]
        
        do {
            var styles: [String] = []
            let range = NSRange(location: 0, length: xmlText.utf16.count)
            let captureRegex = try NSRegularExpression(pattern: ":root \\{(.*?)\\}", options: [.dotMatchesLineSeparators])
            let matches = captureRegex.matches(in: xmlText, options: [], range: range)
            matches.forEach { match in
                if let _range = Range(match.range(at: 1), in: xmlText) {
                    styles.append(String(xmlText[_range]))
                }
            }
            
            for style in styles {
                let cssStyles = getVarColors(content: style)
                for (key, value) in cssStyles {
                    result[key] = SVGParser.createColor(value)?.toNativeColor()
                }
            }
        } catch {}
        return result
    }
    
    open class func replaceColorVars(xml: inout String, colorNames: [String: MColor]) {
        for (key, value) in colorNames {
            xml = xml.replacingOccurrences(of: "var(\(key))", with: value.toHexString())
        }
    }
    
    open class func getVarColors(content: String) -> [String: String] {
        var styles: [String: String] = [:]
        var currentStyles = [String: String]()
        let style = content.components(separatedBy: .whitespacesAndNewlines).joined().components(separatedBy: ";")
        
        style.forEach { styleAttribute in
            if !styleAttribute.isEmpty {
                let currentStyle = styleAttribute.components(separatedBy: ":")
                if currentStyle.count == 2 {
                    currentStyles[currentStyle[0]] = currentStyle[1]
                }
            }
        }
        for (key, value) in currentStyles {
            if key.prefix(2) == "--" {
                styles[key] = value
            }
        }
        return styles
    }
}

// MARK: Color Extension
public extension  Color {
    func toNativeColor() -> MColor{
        let red = CGFloat(Double(r()) / 255.0)
        let green = CGFloat(Double(g()) / 255.0)
        let blue = CGFloat(Double(b()) / 255.0)
        let alpha = CGFloat(Double(a()) / 255.0)
        return MColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

public extension MColor {
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgba:Int = (Int)(r*255)<<24 | (Int)(g*255)<<16 | (Int)(b*255)<<8 | (Int)(a*255)<<0
        
        return NSString(format:"#%08x", rgba) as String
    }
}
