import SwiftUI

struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // 임시 알림 데이터
    private let notifications = [
        Notification(
            id: UUID(),
            type: .like,
            message: "DJ Huey님이 회원님의 컬렉션을 좋아합니다",
            date: Date().addingTimeInterval(-3600),
            isRead: false
        ),
        Notification(
            id: UUID(),
            type: .follow,
            message: "DJ Smith님이 회원님을 팔로우하기 시작했습니다",
            date: Date().addingTimeInterval(-7200),
            isRead: false
        ),
        Notification(
            id: UUID(),
            type: .comment,
            message: "DJ Jane님이 회원님의 레코드에 댓글을 남겼습니다",
            date: Date().addingTimeInterval(-86400),
            isRead: true
        ),
        Notification(
            id: UUID(),
            type: .sale,
            message: "관심 레코드의 새로운 매물이 등록되었습니다",
            date: Date().addingTimeInterval(-172800),
            isRead: true
        )
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(notifications) { notification in
                    NotificationRow(notification: notification)
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("알림")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// 알림 모델
struct Notification: Identifiable {
    let id: UUID
    let type: NotificationType
    let message: String
    let date: Date
    let isRead: Bool
    
    enum NotificationType {
        case like
        case follow
        case comment
        case sale
        
        var icon: String {
            switch self {
            case .like: return "heart.fill"
            case .follow: return "person.fill.badge.plus"
            case .comment: return "bubble.right.fill"
            case .sale: return "tag.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .like: return .red
            case .follow: return .blue
            case .comment: return .green
            case .sale: return .orange
            }
        }
    }
}

// 알림 행 컴포넌트
struct NotificationRow: View {
    let notification: Notification
    
    var body: some View {
        HStack(spacing: 16) {
            // 알림 아이콘
            Image(systemName: notification.type.icon)
                .font(.title2)
                .foregroundColor(notification.type.color)
                .frame(width: 40, height: 40)
                .background(notification.type.color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.message)
                    .font(.subheadline)
                    .foregroundColor(notification.isRead ? .secondary : .primary)
                
                Text(formatDate(notification.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !notification.isRead {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
} 