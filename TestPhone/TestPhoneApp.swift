//
//  TestPhoneApp.swift
//  TestPhone
//
//  Created by User on 28.04.2021.
//

import SwiftUI

@main
struct TestPhoneApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
