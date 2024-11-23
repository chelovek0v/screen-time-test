import Combine
import Foundation

import FamilyControls
import DeviceActivity


final class Model: ObservableObject
{
	@Published
	var selection = FamilyActivitySelection()

	lazy var center = DeviceActivityCenter()

	func startMonitoring()
	{
		let settings = AllSettings(named: .default)
		settings.shield.applications = selection.applicationTokens

		let schedule = DeviceActivitySchedule(
			intervalStart: DateComponents(hour: 10, minute: 0),
			intervalEnd: DateComponents(hour: 20, minute: 0),
			repeats: false)

		do {
			logger.info("Starting monitor.")

			try center.startMonitoring(.default, during: schedule)

			logger.info("Monitoring installed successfuly.")
		}
		catch let error {
			logger.error("Monitoring failed: \(error.localizedDescription, privacy: .public)")
		}
	}

	func stopMonitoring()
	{
		center.stopMonitoring()
	}
}
