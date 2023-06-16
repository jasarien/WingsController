//
//  WingsController.swift
//  WingsController
//
//  Created by James Addyman on 14/06/2023.
//

import Foundation
import ComposableArchitecture

struct WingsController: ReducerProtocol {
	struct State: Equatable {
		enum Mode: Equatable {
			case auto
			case manual(Int)
			case steady

			var url: URL? {
				switch self {
				case .auto:
					return URL(string: "http://192.168.4.1/wings/auto")
				case .steady:
					return URL(string: "http://192.168.4.1/wings/steady")
				case let .manual(position):
					return URL(string: "http://192.168.4.1/wings/manual?\(position)")
				}
			}

			var title: String {
				switch self {
				case .auto:
					return "Auto"
				case .manual:
					return "Manual"
				case .steady:
					return "Steady"
				}
			}
		}

		var mode: Mode

		@BindingState var position: Double = 100 {
			didSet {
				mode = .manual(Int(position))
			}
		}
		var previousPosition: Double = 100

		var sliderDisabled: Bool {
			switch mode {
			case .manual:
				return false
			default:
				return true
			}
		}

		init(mode: Mode) {
			self.mode = mode
		}
	}

	enum Action: BindableAction {
		case switchMode(State.Mode)
		case updatePosition
		case response(TaskResult<(Data, URLResponse)>)
		case binding(BindingAction<State>)
	}

	init() {}

	var body: some ReducerProtocolOf<Self> {
		BindingReducer()
		Reduce<State, Action> { state, action in
			switch action {
			case let .switchMode(mode):
				guard let url = mode.url else {
					return .none
				}
				state.mode = mode

				return .task {
					await .response(
						TaskResult {
							try await URLSession.shared.data(for: .init(url: url))
						}
					)
				}

			case .response(.success):
				return .none

			case let .response(.failure(error)):
				print(error)
				return .none

			case .updatePosition:
				return .send(.switchMode(.manual(Int(state.position))))

			case .binding:
				return .none
			}
		}
	}
}
