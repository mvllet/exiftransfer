// ContentView.swift

import SwiftUI

// Main window with two equal-sized drop zones and transfer controls.
struct ContentView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        VStack(spacing: 18) {
            HStack(spacing: 18) {
                ImageDropZoneView(
                    title: "Source",
                    role: .source,
                    slot: $viewModel.sourceSlot,
                    onDropItems: viewModel.handleDrop
                )

                ImageDropZoneView(
                    title: "Target",
                    role: .target,
                    slot: $viewModel.targetSlot,
                    onDropItems: viewModel.handleDrop
                )
            }
            .frame(maxWidth: .infinity)
            .frame(maxHeight: 440)

            VStack(spacing: 12) {
                statusView
                
                Toggle("Direct Overwrite", isOn: $viewModel.directOverwrite)
                    .toggleStyle(.switch)
                    .controlSize(.mini)

                Button {
                    Task {
                        await viewModel.transferMetadata()
                    }
                } label: {
                    if viewModel.isTransferring {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text("Transfer Metadata")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canTransfer)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(16)
    }

    @ViewBuilder
    private var statusView: some View {
        switch viewModel.status {
        case .idle:
            Text("Drag a source on the left and a target on the right.")
                .foregroundStyle(.secondary)
        case .ready(let text):
            Text(text)
        case .success(let text):
            Text(text)
                .foregroundStyle(.green)
        case .failure(let text):
            Text(text)
                .foregroundStyle(.red)
        }
    }
}
