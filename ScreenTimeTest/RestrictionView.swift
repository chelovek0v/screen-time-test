import Foundation
import FamilyControls
import SwiftUI

struct RestrictionViewPreviews: PreviewProvider
{
	static var previews: some View {
		RestrictionView()
	}
}

struct RestrictionView: View
{
	@StateObject var restrictions = Restrictions()

	var body: some View {
		NavigationView {
			VStack {
				Form {
					Section {
							NavigationLink {
								FamilyActivityPicker(selection: $restrictions.selection)
							} label:  {
								HStack {
									Text("Apps & Website")
									Spacer()
									if restrictions.isSelectionEmpty {
										Button(action: {}) {
											Image(systemName: "info.circle.fill")
											Text("Select")
										}
										.buttonBorderShape(.roundedRectangle)
										.buttonStyle(.borderedProminent)
										.controlSize(.small)
										.tint(.yellow)
										.foregroundColor(.primary)
										.allowsHitTesting(false)
									}
									else {
										Text("Blocked \(restrictions.numberOfSelectedItems)")
									}
								}
							}

						Toggle("All Day", isOn: $restrictions.schedule.allDay)
						DatePicker("Starts", selection: $restrictions.schedule.starts, displayedComponents: .hourAndMinute)
						.disabled(restrictions.schedule.allDay)
						DatePicker("Ends", selection: $restrictions.schedule.ends, displayedComponents: .hourAndMinute)
						.disabled(restrictions.schedule.allDay)
					}
					footer: {
						DaysOfWeekView(selected: $restrictions.schedule.weekdays)
							.padding()
					}
				}
				.toolbar {
					ToolbarItemGroup(placement: .bottomBar) {
						Spacer()

						Button("Deactivate") {
							restrictions.deactivate()
						}
						.disabled(!restrictions.isActive)

						Spacer()

						Button("Activate") {
							restrictions.activate()
						}
						// TODO: add mode.active check
						.disabled(restrictions.isSelectionEmpty)
						.buttonStyle(.borderedProminent)
						.tint(restrictions.hasChanges ? .yellow : .blue)
					}
				}
			}
			.navigationTitle("Screen Time Test")
		}
	}
}


struct DaysOfWeekView: View
{
	@Binding var selected: Set<Int>

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

	var daysOfWeekActive: String {
		"\(selected.count) of 7"
	}

}
