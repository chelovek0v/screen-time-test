import Foundation
import FamilyControls
import SwiftUI

struct RestrictionView: View
{
	@StateObject var model = Model()
	@State private var familyPickerPresented = false

	enum RestrictionState: CaseIterable {
		case notSelected
		case active
	}
	@State private var state: RestrictionState = .notSelected

	var body: some View {
		NavigationView {
			VStack {
				Form {
					Section {
							NavigationLink {
								FamilyActivityPicker(selection: $model.selection)
							} label:  {
								HStack {
									Text("Apps & Website")
									Spacer()
									if model.isEmpty {
										Button(action: {}) {
											Image(systemName: "info.circle.fill")
											Text("Select")
										}
										.buttonBorderShape(.roundedRectangle)
										.buttonStyle(.borderedProminent)
										.controlSize(.small)
										.tint(.yellow)
										.foregroundColor(.primary)
									}
									else {
										Text("Blocked \(model.blocked)")
									}
								}
							}

						Toggle("All Day", isOn: $model.schedule.allDay)
						DatePicker("Starts", selection: $model.schedule.starts, displayedComponents: .hourAndMinute)
						.disabled(model.schedule.allDay)
						DatePicker("Ends", selection: $model.schedule.ends, displayedComponents: .hourAndMinute)
						.disabled(model.schedule.allDay)
					}
					footer: {
						DaysOfWeekView(selected: $model.schedule.weekdays)
							.padding()
					}
				}
				.toolbar {
					ToolbarItemGroup(placement: .bottomBar) {
						Spacer()

						Button("Deactivate") {
							model.stopMonitoring()
						}
						.disabled(!model.active)

						Spacer()

						Button("Activate") {
							model.startMonitoring()
						}
						// TODO: add mode.active check
						.disabled(model.isEmpty)
						.buttonStyle(.borderedProminent)
						.tint(model.saved ? .blue : .yellow)
					}
				}
			}
			.navigationTitle("Screen Time Test")
		}
	}
}

struct RestrictionViewPreviews: PreviewProvider
{
	static var previews: some View {
		RestrictionView()
	}
}

struct DaysOfWeekView: View
{
	@Binding var selected: Set<Int>

	var daysOfWeekActive: String {
		"\(selected.count) of 7"
	}

	let weekdays =
		Calendar.current.veryShortStandaloneWeekdaySymbols
	var body: some View {
		VStack(alignment: .leading) {
		HStack {
			ForEach(weekdays.indices) { index in
				let weekdayCalendarIndex = index + 1

				Button(weekdays[index]) {
					if selected.contains(weekdayCalendarIndex) {
						selected.remove(weekdayCalendarIndex)
					}
					else {
						selected.insert(weekdayCalendarIndex)
					}
				}
				.fixedSize()
				.buttonStyle(.borderedProminent)
				.tint(selected.contains(weekdayCalendarIndex) ? .purple : .gray)
			}
		}
			Text("Days of week active \(daysOfWeekActive)")
			}
	}
}
