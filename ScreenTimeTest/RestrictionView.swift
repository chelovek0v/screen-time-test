import Foundation
import SwiftUI

struct RestrictionView: View
{
	@State var allDay: Bool
	enum RestrictionState: CaseIterable {
		case notSelected
		case active
	}
	@State private var state: RestrictionState = .notSelected

	@State var starts: Date = .now
	@State var ends: Date = .init(timeIntervalSinceNow: 60 * 60)
	@State var selected: Set<String> = []

	var body: some View {
		NavigationView {
			VStack {
				Form {
					Section {
						Button("Apps & Websites") {}
						Toggle("All Day", isOn: $allDay)
						NavigationLink("Link", destination: {
							Text("Some other destination")
						})
						Picker("Apps & Websites", selection: $state) {
							ForEach(RestrictionState.allCases, id: \.self) {
								Text(String(describing: $0))
							}
						}
						.pickerStyle(.navigationLink)
						DatePicker("Starts", selection: $starts, displayedComponents: .hourAndMinute)
						DatePicker("Ends", selection: $ends, displayedComponents: .hourAndMinute)
					}
					footer: {
						DaysOfWeekView(selected: $selected)
							.padding()
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
	@Binding var selected: Set<String>

	var daysOfWeekActive: String {
		"\(selected.count) of 7"
	}

	var body: some View {
		VStack(alignment: .leading) {
		HStack {
			ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { weekday in
				Button(weekday.prefix(1)) {
					if selected.contains(weekday) {
						selected.remove(weekday)
					}
					else {
						selected.insert(weekday)
					}
				}
				.fixedSize()
				.buttonStyle(.borderedProminent)
				.tint(selected.contains(weekday) ? .purple : .gray)
			}
		}
			Text("Days of week active \(daysOfWeekActive)")
			}
	}
}
