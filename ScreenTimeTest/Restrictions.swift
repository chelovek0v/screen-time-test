import Combine
import Foundation

import FamilyControls
import DeviceActivity
import ManagedSettings


final class Restrictions: ObservableObject
{
	// MARK: - Initialisation
	init()
	{
		sharedUserDefaults =  UserDefaults(suiteName: "group.6M9LRL268Y.me.vanka")!
		selection = FamilyActivitySelection.from(data: sharedUserDefaults.data(forKey: "Selection")) ?? FamilyActivitySelection()
		schedule = Schedule.from(data: sharedUserDefaults.data(forKey: "Schedule")) ?? .default
	}


	// MARK: -
	let sharedUserDefaults: UserDefaults

	@Published
	var selection: FamilyActivitySelection {
		didSet {
			hasChanges = true
			sharedUserDefaults.set(try? Self.encoder.encode(selection), forKey: "Selection")
		}
	}


	// MARK: - Schedule
	@Published
	var schedule: Schedule  {
		didSet {
			hasChanges = true
			// TODO: better to use inner encoder.
			sharedUserDefaults.set(try? Self.encoder.encode(schedule), forKey: "Schedule")
		}
	}

	struct Schedule: Codable {
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

		static var `default`: Self = .init(allDay: false, starts: .now, ends: .init(timeIntervalSinceNow: 60 * 60), weekdays: [])

		static let decoder = PropertyListDecoder()

		static func from(data: Data?) -> Self?
		{
			if let data {
				return try? decoder.decode(Schedule.self, from: data)
			}
			else {
				return nil
			}
		}
	}


	// MARK: -
	var isSelectionEmpty: Bool {
		selection.applicationTokens.isEmpty &&
		selection.webDomainTokens.isEmpty &&
		selection.categoryTokens.isEmpty
	}

	var numberOfSelectedItems: Int {
		selection.applicationTokens.count + selection.webDomainTokens.count + selection.categoryTokens.count
	}

	var isActive: Bool {
		// TODO: create something more concrete, e.g Weekdays.
		(1...7)
			.map({ String(describing: $0) })
			.compactMap({ center.schedule(for: .init($0)) })
					.isEmpty == false
	}

	@Published
	var hasChanges = false


	// MARK: -
	let center = DeviceActivityCenter()

	func activate()
	{
		defer { hasChanges = false }

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
		let settings = AllSettings(named: .default)
		
		settings.clearAllSettings()
		center.stopMonitoring()
		hasChanges = false
	}

    private static let encoder = PropertyListEncoder()
}


extension FamilyActivitySelection
{
	static let decoder = PropertyListDecoder()

	static func from(data: Data?) -> Self?
	{
		if let data {
			return try? decoder.decode(FamilyActivitySelection.self, from: data)
		}
		else {
			return nil
		}
	}
}
