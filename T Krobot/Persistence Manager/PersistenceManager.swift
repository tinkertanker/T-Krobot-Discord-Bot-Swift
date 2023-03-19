//
//  PersistenceManager.swift
//  T Krobot
//
//  Created by Jia Chen Yee on 19/3/23.
//

import Foundation

class PersistenceManager {
    func getApplicationSupportURL() -> URL? {
        let applicationSupport = try? FileManager.default.url(for: .applicationSupportDirectory,
                                                              in: .localDomainMask,
                                                              appropriateFor: nil,
                                                              create: true)
        
        return applicationSupport?.appending(component: "sg.tk.tkrobot")
    }
}
