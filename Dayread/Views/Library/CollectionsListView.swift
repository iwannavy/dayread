import SwiftUI

struct CollectionsListView: View {
    let sessionMap: [String: StudySessionListItem]
    let membershipTier: MembershipTier
    let onSessionTap: (StudySessionListItem) -> Void
    var onSessionAppear: ((String) -> Void)?

    @State private var selectedCollectionId: String?

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        if let selectedId = selectedCollectionId,
           let collection = CollectionContent.getCollectionMeta(selectedId) {
            collectionDetailView(collection)
        } else {
            collectionGrid
        }
    }

    // MARK: - Collection Grid

    private var collectionGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(CollectionContent.collections, id: \.id) { collection in
                CollectionCard(collection: collection)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCollectionId = collection.id
                        }
                    }
            }
        }
    }

    // MARK: - Collection Detail

    private func collectionDetailView(_ collection: CollectionMeta) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Back button
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedCollectionId = nil
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("테마 목록")
                }
                .font(.subheadline)
                .foregroundStyle(Color.dayreadGold)
            }

            // Collection header
            HStack(spacing: 12) {
                Text(collection.icon)
                    .font(.title)

                VStack(alignment: .leading, spacing: 2) {
                    Text(collection.title)
                        .font(.headline)
                    Text(collection.titleKo)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(CurriculumUtils.difficultyLabel(collection.difficulty))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(CurriculumUtils.difficultyColor(collection.difficulty))
            }

            Text(collection.description)
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            // Session list
            let collectionSessions = CollectionContent.getCollectionSessions(collection.id)
            ForEach(Array(collectionSessions.enumerated()), id: \.element.id) { index, item in
                if let sessionId = item.sessionId, let session = sessionMap[sessionId] {
                    HStack {
                        SessionListItemView(
                            session: session,
                            membershipTier: membershipTier,
                            onTap: { onSessionTap(session) },
                            onAppear: { onSessionAppear?(sessionId) }
                        )

                        if index == 0 && CollectionContent.isFreeCollectionSessionId(sessionId) {
                            Text("무료")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.green)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(.green.opacity(0.12)))
                        }
                    }
                } else {
                    // Session not in library — show static info
                    HStack(spacing: 12) {
                        Image(systemName: CurriculumUtils.genreIcon(item.genre))
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                            .frame(width: 28, height: 28)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(item.source)
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }

                        Spacer()

                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundStyle(Color.dayreadGold)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                }
            }
        }
    }
}

// MARK: - Collection Card

private struct CollectionCard: View {
    let collection: CollectionMeta

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(collection.icon)
                    .font(.title2)
                Spacer()
                Text("\(collection.sessions.count)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Text(collection.title)
                .font(.subheadline.weight(.semibold))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text(collection.titleKo)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer(minLength: 0)

            Text(CurriculumUtils.difficultyLabel(collection.difficulty))
                .font(.caption2.weight(.medium))
                .foregroundStyle(CurriculumUtils.difficultyColor(collection.difficulty))
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 120)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
}
