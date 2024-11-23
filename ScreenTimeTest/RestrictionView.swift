import Foundation
import SwiftUI

struct RestrictionView: View
{
	@StateObject var model = Model()
	@State private var familyPickerPresented = false

	@State var allDay: Bool
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
						Toggle("All Day", isOn: $allDay)
						NavigationLink("Selected Apps & Websites", destination: {
							Text("Select Apps & Website to Restrict")
							.font(.title)
							.familyActivityPicker(
								isPresented: $familyPickerPresented,
								selection: $model.selection
							)
							.onAppear {
								familyPickerPresented = true
							}
						})
						Picker("Apps & Websites", selection: $state) {
							if model.isEmpty {
								Text("Select")
							}
							else {
								Text("\(model.blocked)")
							}
						}
						.pickerStyle(.navigationLink)
						DatePicker("Starts", selection: $model.schedule.starts, displayedComponents: .hourAndMinute)
						DatePicker("Ends", selection: $model.schedule.ends, displayedComponents: .hourAndMinute)
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
							print("Pressed")
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
		RestrictionView(allDay: false)
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
