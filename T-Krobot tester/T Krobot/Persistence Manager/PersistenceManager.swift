//
//  PersistenceManager.swift
//  T Krobot
//
//  Created by Jia Chen Yee on 19/3/23.
//

import Foundation
import DiscordBM

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
            print("Classes: \(classes)")
        } catch {
            classes = [:]
            print("classes error")
        }
    }

    func writeData() {

        print("WRITEDATA: \(getPersistenceURL().path(percentEncoded: false))")

        do {
            let encodedClasses = try JSONEncoder().encode(classes)
            print("Encoded Class: \(encodedClasses)")
            let didSucceed = FileManager.default.createFile(
                atPath: getPersistenceURL().path(), contents: encodedClasses)
            if didSucceed {
                print("YAY")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
