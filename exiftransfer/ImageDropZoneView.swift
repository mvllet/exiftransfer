// ImageDropZoneView.swift

import AppKit
import SwiftUI
import UniformTypeIdentifiers

// Square drop zone with preview and visual drop feedback.
struct ImageDropZoneView: View {
    let title: String
    let role: DropRole
    @Binding var slot: ImageSlotState
    let onDropItems: ([NSItemProvider], DropRole) -> Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(backgroundColor)
                .overlay(border)
                .shadow(color: slot.flash ? .green.opacity(0.45) : .clear, radius: 14)
                .animation(.easeInOut(duration: 0.18), value: slot.flash)

            VStack(spacing: 14) {
                if let image = slot.image {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(18)
                } else {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 44, weight: .medium))
                        .foregroundStyle(.secondary)

                    Text(title)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if let url = slot.url {
                    Text(url.lastPathComponent)
                        .font(.caption)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .padding(.horizontal, 12)
                }
            }
            .padding(20)
        }
        .aspectRatio(1, contentMode: .fit)
        .onDrop(of: [UTType.fileURL.identifier], isTargeted: $slot.isTargeted) { providers in
            onDropItems(providers, role)
        }
    }

    private var backgroundColor: Color {
        if slot.flash {
            return Color.green.opacity(0.16)
        }

        if slot.isTargeted {
            return Color.accentColor.opacity(0.16)
        }

        return Color(nsColor: .windowBackgroundColor)
    }

    private var border: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .strokeBorder(
                slot.isTargeted ? Color.accentColor : Color.secondary.opacity(0.25),
                lineWidth: slot.isTargeted ? 3 : 1
            )
    }
}
