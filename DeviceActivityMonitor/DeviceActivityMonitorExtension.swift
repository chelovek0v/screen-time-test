import DeviceActivity
import ManagedSettings
import FamilyControls

import OSLog

let logger = Logger(subsystem: "me.vanka.ScreenTimeTest", category: "Application")


// Optionally override any of the functions below.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
final class DeviceActivityMonitorExtension: DeviceActivityMonitor
{
	lazy var settings = ManagedSettingsStore(named: .default)

	lazy var sharedUserDefaults = UserDefaults(suiteName: "group.6M9LRL268Y.me.vanka")!

    private static let decoder = PropertyListDecoder()

    override func intervalDidStart(for activity: DeviceActivityName)
    {
        super.intervalDidStart(for: activity)

		logger.info("Interval did start for \(activity.rawValue, privacy: .public).")

		if let selectionData = sharedUserDefaults.data(forKey: "Selection") {
			logger.info("Data bytes count: \(selectionData.count).")

			let selection = try? Self.decoder.decode(FamilyActivitySelection.self, from: selectionData)
			logger.info("Selection has application tokens: \(selection?.applicationTokens.count ?? 0), web domain tokens: \(selection?.webDomainTokens.count ?? 0)")

			settings.shield.applications = selection?.applicationTokens
			settings.shield.applicationCategories = .specific(selection?.categoryTokens ?? [])
			settings.shield.webDomains = selection?.webDomainTokens
		}
		else {
			logger.error("Couldn't retrieve selection data from the user defaults.")
		}

    }
    
    override func intervalDidEnd(for activity: DeviceActivityName)
    {
        super.intervalDidEnd(for: activity)
        
        // Handle the end of the interval.
		logger.info("Interval did end for \(activity.rawValue, privacy: .public).")
		settings.clearAllSettings()
		logger.info("Settings cleared.")
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        // Handle the event reaching its threshold.
    }
    
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        
        // Handle the warning before the interval starts.
    }
    
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        
        // Handle the warning before the interval ends.
    }
    
    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
        
        // Handle the warning before the event reaches its threshold.
    }
}
