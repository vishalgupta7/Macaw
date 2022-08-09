//
//  ExampleViewController.swift
//  Example-macOS
//
//  Created by Daniil Manin on 9/28/18.
//

import Cocoa
import Macaw

class ExampleViewController: NSViewController {
    override func awakeFromNib() {
        super.awakeFromNib()
        view.wantsLayer = true
        view.layer?.backgroundColor = .white
    }
    
    func getFileContent(resource: String, ofType type: String = "svg", inDirectory directory: String? = nil, fromBundle bundle: Bundle = Bundle.main) -> String? {
        guard let fullpath = bundle.path(forResource: resource, ofType: type, inDirectory: directory),
         let text = try? String(contentsOfFile: fullpath, encoding: .utf8) else {
            print("Error parsing file")
            return nil
        }
        return text
    }
    
    @IBOutlet var svgView: SVGView!
    
    @IBAction func buttonTapped(_ sender: NSButton) {
        guard var xml = getFileContent(resource: "CSS") else { return }
        
        let styles = SVGHelper.getAllVarColors(xmlText: xml)
        SVGHelper.replaceColorVars(xml: &xml, colorNames: styles)
        svgView.node = (try? SVGParser.parse(text: xml)) ?? Group()
    }
}

