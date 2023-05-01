//
//  LanguageManager.swift
//  BigBrainFun
//
//  Created by Ed on 29/04/2023.
//

import Foundation

class LanguageManager {
    
    static let shared = LanguageManager()
    
    private init() {}
    
    func setLanguage(_ languageCode: String) {
        guard let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return
        }
        
        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        NotificationCenter.default.post(name: Notification.Name("LanguageChanged"), object: nil)
        Bundle.swizzleBundle(bundle)
    }
}

extension Bundle {
    
    static func swizzleBundle(_ bundle: Bundle) {
        object_setClass(Bundle.main, bundle.classForCoder)
    }
}
