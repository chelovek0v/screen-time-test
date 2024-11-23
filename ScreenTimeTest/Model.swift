import Combine
import Foundation

import FamilyControls
import DeviceActivity
import ManagedSettings


final class Model: ObservableObject
{
	@Published
	var selection = FamilyActivitySelection() {
		didSet {
			saved = false
		}
	}

	var isEmpty: Bool {
		selection.applicationTokens.isEmpty &&
		selection.webDomainTokens.isEmpty
	}
	var blocked: Int {
		selection.applicationTokens.count + selection.webDomainTokens.count
	}

	var active: Bool {
		// TODO: create something more concrete, e.g Weekdays.
		(1...7)
			.map({ String(describing: $0) })
			.compactMap({ center.schedule(for: .init($0)) })
					.isEmpty == false
	}

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
			saved = false
		}
	}

	@Published
	var saved = true

	lazy var sharedUserDefaults = UserDefaults(suiteName: "group.6M9LRL268Y.me.vanka")!

	lazy var center = DeviceActivityCenter()

    private static let encoder = PropertyListEncoder()
	func startMonitoring()
	{
        sharedUserDefaults.set(try? Self.encoder.encode(selection), forKey: "Selection")

		center.stopMonitoring()

		for (weekday, weekdaySchedule) in schedule.deviceActivitySchedules
		{
			logger.debug("Weekday: \(weekday), starts: \(weekdaySchedule.intervalStart.hour!, privacy: .public)-\(weekdaySchedule.intervalStart.minute!, privacy: .public) ends: \(weekdaySchedule.intervalEnd.hour!, privacy: .public)-\(weekdaySchedule.intervalEnd.minute!, privacy: .public)")

			do {
				logger.info("Starting monitor for \(weekday).")

				try center.startMonitoring(DeviceActivityName(String(describing: weekday)), during: weekdaySchedule)

				logger.info("Monitoring installed successfuly for \(weekday).")
			}
			catch let error {
				logger.error("Monitoring failed for \(weekday), error: \(error.localizedDescription, privacy: .public)")
			}
		}

		saved = true
	}

	func stopMonitoring()
	{
		let settings = AllSettings(named: .default)
		
		settings.clearAllSettings()
		center.stopMonitoring()
		saved = true
	}
}
