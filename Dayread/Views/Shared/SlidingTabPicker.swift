import SwiftUI

struct SlidingTabPicker<T: Hashable & RawRepresentable>: View where T.RawValue == String {
    let selection: Binding<T>
    let items: [T]

    @Namespace private var animation

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.self) { item in
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selection.wrappedValue = item
                    }
                } label: {
                    Text(item.rawValue)
                        .font(.subheadline)
                        .fontWeight(selection.wrappedValue == item ? .semibold : .regular)
                        .foregroundStyle(selection.wrappedValue == item ? .primary : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .background {
                    if selection.wrappedValue == item {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            .matchedGeometryEffect(id: "TAB", in: animation)
                    }
                }
            }
        }
        .padding(4)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
