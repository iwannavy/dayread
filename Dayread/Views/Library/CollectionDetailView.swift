import SwiftUI

struct CollectionDetailView: View {
    let collection: CollectionMeta
    let sessionMap: [String: StudySessionListItem]
    let membershipTier: MembershipTier
    let onSessionTap: (StudySessionListItem) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack(spacing: 12) {
                    Text(collection.icon)
                        .font(.largeTitle)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(collection.title)
                            .font(.title3.weight(.bold))
                        Text(collection.titleKo)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Text(collection.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Divider()

                // Sessions
                let sessions = CollectionContent.getCollectionSessions(collection.id)
                ForEach(Array(sessions.enumerated()), id: \.element.id) { index, item in
                    if let sessionId = item.sessionId, let session = sessionMap[sessionId] {
                        SessionListItemView(
                            session: session,
                            membershipTier: membershipTier,
                            onTap: { onSessionTap(session) }
                        )
                    }
                }
            }
            .padding()
        }
        .navigationTitle(collection.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
