//
//  WingsControllerApp.swift
//  WingsController
//
//  Created by James Addyman on 14/06/2023.
//

import SwiftUI
import ComposableArchitecture

@main
struct WingsControllerApp: App {
    var body: some Scene {
        WindowGroup {
			WingsControllerView(
				store: Store(
					initialState: WingsController.State(mode: .manual(100)),
					reducer: WingsController()
				)
			)
        }
    }
}
