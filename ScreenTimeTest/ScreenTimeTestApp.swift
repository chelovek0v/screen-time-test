import SwiftUI
import FamilyControls

import OSLog

let logger = Logger(subsystem: "me.vanka.ScreenTimeTest", category: "Application")

@main
struct ScreenTimeTestApp: App {
    var body: some Scene {
        WindowGroup {
            RestrictionView()
				.task {
					do{
						logger.info("Requesting Authorisation.")
						try await AuthorizationCenter.shared.requestAuthorization(for: FamilyControlsMember.individual)
						logger.info("Authorisation Successful.")
					}
					catch let error {
						logger.error("Authorisation Failed: \(error.localizedDescription, privacy: .public)")
					}
				}
        }
    }
}


// MARK - Additions
import DeviceActivity
import ManagedSettings


extension AllSettings.Name
{
	static let `default` = AllSettings.Name("DefaultSettings")
}

typealias AllSettings = ManagedSettingsStore
typealias AuthorisationReqeust = AuthorizationCenter
typealias DeviceActivityExtension = DeviceActivityCenter


