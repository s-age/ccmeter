import SwiftUI

struct UsagePopoverView: View {
    @Bindable var viewModel: UsageViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Claude Code Usage")
                .font(.system(size: 14, weight: .semibold))

            if let error = viewModel.errorMessage {
                errorView(error)
            }

            if let usage = viewModel.usage {
                usageContent(usage)
            }

            Divider()
            intervalPicker
            labelColorPicker
            launchAtLoginToggle
            Divider()
            footerView
        }
        .padding(16)
        .frame(width: 300)
    }

    @ViewBuilder
    private func usageContent(
        _ usage: FetchUsageResponse
    ) -> some View {
        if let fiveHour = usage.fiveHour {
            UsageRowView(title: "5-Hour Session", info: fiveHour)
        }

        if let sevenDay = usage.sevenDay {
            UsageRowView(title: "7-Day Weekly", info: sevenDay)
        }

        if let model = usage.sevenDayModel {
            UsageRowView(
                title: "7-Day \(model.modelName)",
                info: FetchUsageResponse.RateLimitInfo(
                    utilization: model.utilization,
                    resetsAt: model.resetsAt
                )
            )
        }

        if let extra = usage.extraUsage, extra.isEnabled {
            Divider()
            extraUsageView(extra)
        }
    }

    private func extraUsageView(
        _ extra: FetchUsageResponse.ExtraUsageInfoResponse
    ) -> some View {
        HStack {
            Text("Extra Usage")
                .font(.system(size: 11))
            Spacer()
            if let usedCredits = extra.usedCredits,
               let monthlyLimit = extra.monthlyLimit,
               let utilization = extra.utilization
            {
                Text(String(
                    format: "$%.2f / $%d (%.1f%%)",
                    usedCredits,
                    monthlyLimit,
                    utilization
                ))
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            }
        }
    }

    private var intervalPicker: some View {
        HStack {
            Text("Refresh")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            Spacer()
            Picker("", selection: $viewModel.pollingInterval) {
                ForEach(PollingInterval.allCases, id: \.self) { interval in
                    Text(interval.displayLabel).tag(interval)
                }
            }
            .labelsHidden()
            .fixedSize()
        }
    }

    private var labelColorPicker: some View {
        HStack {
            Text("Menu Bar Color")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            Spacer()
            Picker("", selection: $viewModel.labelColor) {
                ForEach(MenuBarLabelColor.allCases, id: \.self) { color in
                    Text(color.displayLabel).tag(color)
                }
            }
            .labelsHidden()
            .fixedSize()
        }
    }

    private var launchAtLoginToggle: some View {
        HStack {
            Text("Launch at Login")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            Spacer()
            Toggle(
                "",
                isOn: Binding(
                    get: { viewModel.launchAtLogin },
                    set: { _ in viewModel.toggleLaunchAtLogin() }
                )
            )
            .labelsHidden()
            .toggleStyle(.switch)
            .controlSize(.mini)
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                Text("API request failed")
                    .font(.system(size: 12, weight: .medium))
            }
            Text(message)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            if let lastUpdated = viewModel.lastUpdated {
                Text(
                    "Last successful update: \(lastUpdated.formatted(date: .omitted, time: .shortened))"
                )
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)
            }
        }
        .padding(8)
        .background(Color.orange.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private var footerView: some View {
        HStack {
            if viewModel.errorMessage == nil, let lastUpdated = viewModel.lastUpdated {
                Text(
                    "Updated \(lastUpdated.formatted(date: .omitted, time: .shortened))"
                )
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)
            }

            Spacer()

            Button {
                Task { await viewModel.refresh() }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .buttonStyle(.borderless)

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.secondary)
        }
    }
}
