import SwiftUI

@main
struct CCMeterApp: App {
    @State private var viewModel: UsageViewModel

    init() {
        let container = Container()
        let vm = container.presentation.makeUsageViewModel()
        _viewModel = State(wrappedValue: vm)
    }

    var body: some Scene {
        MenuBarExtra {
            UsagePopoverView(viewModel: viewModel)
        } label: {
            MenuBarLabel(viewModel: viewModel)
                .task(id: viewModel.pollingInterval) {
                    await viewModel.poll()
                }
        }
        .menuBarExtraStyle(.window)
    }
}
