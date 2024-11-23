import Combine
import Foundation

import FamilyControls
import DeviceActivity
import ManagedSettings


final class Restrictions: ObservableObject
{
	@Published
	var hasChanges = false

	@Published
	var selection = FamilyActivitySelection() {
		didSet {
			hasChanges = true
			sharedUserDefaults.set(try? Self.encoder.encode(selection), forKey: "Selection")
		}
	}

	var isSelectionEmpty: Bool {
		selection.applicationTokens.isEmpty &&
		selection.webDomainTokens.isEmpty
	}

	var numberOfSelectedItems: Int {
		selection.applicationTokens.count + selection.webDomainTokens.count
	}

	var isActive: Bool {
		// TODO: create something more concrete, e.g Weekdays.
		(1...7)
			.map({ String(describing: $0) })
			.compactMap({ center.schedule(for: .init($0)) })
					.isEmpty == false
	}

	// MARK: - Schedule
	struct Schedule {
		// TODO: there're better options, maybe an enum. But it's good enough, no optimisation beforehand.
		// See EKEvent for example.
		var allDay: Bool

		var starts: Date
		var ends: Date
		var weekdays: Set<Int>

		var deviceActivitySchedules: [(weekday: Int, schedule: DeviceActivitySchedule)] {
			weekdays.map {
				// TODO: extension would be nice here, just to hush the noise.
				let startsComponents = allDay ? DateComponents(hour: 0, minute: 0) : Calendar.current.dateComponents([.hour, .minute], from: starts)
				let endsComponents = allDay ? DateComponents(hour: 23, minute: 59) : Calendar.current.dateComponents([.hour, .minute], from: ends)

				let schedule = DeviceActivitySchedule(
					intervalStart: DateComponents(hour: startsComponents.hour!, minute: startsComponents.minute!, weekday: $0),
					intervalEnd: DateComponents(hour: endsComponents.hour!, minute: endsComponents.minute!, weekday: $0),
					repeats: false)

				return ($0, schedule)
			}
		}
	}

	@Published
	var schedule: Schedule = .init(allDay: false, starts: .now, ends: .init(timeIntervalSinceNow: 60 * 60), weekdays: []) {
		didSet {
			hasChanges = true
		}
	}

	// MARK: -
	lazy var sharedUserDefaults = UserDefaults(suiteName: "group.6M9LRL268Y.me.vanka")!

	func activate()
	{
		defer { hasChanges = false }

		let center = DeviceActivityCenter()
		center.stopMonitoring()

		for (weekdayCalendarIndex, weekdaySchedule) in schedule.deviceActivitySchedules
		{
			logger.debug("Weekday: \(weekdayCalendarIndex), starts: \(weekdaySchedule.intervalStart.hour!, privacy: .public)-\(weekdaySchedule.intervalStart.minute!, privacy: .public) ends: \(weekdaySchedule.intervalEnd.hour!, privacy: .public)-\(weekdaySchedule.intervalEnd.minute!, privacy: .public)")

			do {
				logger.info("Starting monitor for \(weekdayCalendarIndex).")

				try center.startMonitoring(DeviceActivityName(String(describing: weekdayCalendarIndex)), during: weekdaySchedule)

				logger.info("Monitoring installed successfuly for \(weekdayCalendarIndex).")
			}
			catch let error {
				logger.error("Monitoring failed for \(weekdayCalendarIndex), error: \(error.localizedDescription, privacy: .public)")
			}
		}
	}

	func deactivate()
	{
		let center = DeviceActivityCenter()
		let settings = AllSettings(named: .default)
		
		settings.clearAllSettings()
		center.stopMonitoring()
		hasChanges = false
	}

    private static let encoder = PropertyListEncoder()
}
