//
//  PersistenceManager.swift
//  T Krobot
//
//  Created by Jia Chen Yee on 19/3/23.
//

import Foundation

class PersistenceManager {
    
    var classes: [String: ClassInfo] = [:] {
        didSet {
            Task.detached {
                self.writeData()
            }
        }
    }
    
    func getFolderURL() -> URL? {
        let folder = FileManager.default.urls(for: .desktopDirectory, in: .allDomainsMask).first
        return folder
    }
    
    func getPersistenceURL() -> URL {
        getFolderURL()!.appending(component: "classes.json")
    }
    
    init() {
        loadData()
    }
    
    func loadData() {
        do {
            let data = try Data(contentsOf: getPersistenceURL())
            classes = try JSONDecoder().decode([String: ClassInfo].self, from: data)
        } catch {
            classes = [:]
        }
    }
    
    func writeData() {
        print("WRITE")
        
        print(getPersistenceURL().path(percentEncoded: false))
        
        do {
            let encodedClasses = try JSONEncoder().encode(classes)
            let didSucceed = FileManager.default.createFile(atPath: getPersistenceURL().path(), contents: encodedClasses)
            if didSucceed {
                print("YAY")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
