//
//  ContentView.swift
//  WingsController
//
//  Created by James Addyman on 14/06/2023.
//

import SwiftUI
import ComposableArchitecture

struct WingsControllerView: View {
	let store: StoreOf<WingsController>

	init(store: StoreOf<WingsController>) {
		self.store = store
	}

    var body: some View {
		WithViewStore(store) { viewStore in
			VStack(spacing: 20) {
				Text("Mode: \(viewStore.mode.title)")
					.font(.headline)

				Button("Auto") {
					viewStore.send(.switchMode(.auto))
				}
				.buttonStyle(.borderedProminent)

				Button("Steady") {
					viewStore.send(.switchMode(.steady))
				}
				.buttonStyle(.borderedProminent)

				Button("Manual") {
					viewStore.send(.switchMode(.manual(100)))
				}
				.buttonStyle(.borderedProminent)

				HStack {
					Text("Open")

					Slider(
						value: viewStore.binding(\.$position),
						in: 0...100,
						step: 1
					) { editing in
						if !editing {
							viewStore.send(.updatePosition)
						}
					}
					.disabled(viewStore.sliderDisabled)

					Text("Closed")
				}
			}
			.padding()
		}
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
		WingsControllerView(
			store: Store(
				initialState: WingsController.State(mode: .manual(100)),
				reducer: WingsController()
			)
		)
    }
}
