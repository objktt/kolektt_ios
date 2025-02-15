import SwiftUI

struct UserProfileView: View {
    let user: LeaderboardUser
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 프로필 헤더
                VStack(spacing: 16) {
                    // 프로필 이미지
                    if let imageURL = user.profileImageURL {
                        AsyncImage(url: imageURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } placeholder: {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 40))
                                )
                        }
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 40))
                            )
                    }
                    
                    // 사용자 정보
                    VStack(spacing: 8) {
                        Text(user.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("거래액: \(formatAmount(user.amount))원")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 32)
                
                // 통계 카드
                HStack(spacing: 0) {
                    StatCard(title: "순위", value: "\(user.rank)위")
                    Divider()
                    StatCard(title: "평점", value: "4.8")
                    Divider()
                    StatCard(title: "거래 수", value: "32회")
                }
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 10)
                .padding(.horizontal)
                
                // 최근 거래 내역
                VStack(alignment: .leading, spacing: 16) {
                    Text("최근 거래 내역")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(1...5, id: \.self) { index in
                        TransactionRow(
                            title: "Led Zeppelin IV",
                            date: "2024.03.\(10-index)",
                            amount: 150000 + (index * 10000)
                        )
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // 메시지 보내기 기능
                }) {
                    Image(systemName: "message")
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    private func formatAmount(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: amount)) ?? "0"
    }
}

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
}

struct TransactionRow: View {
    let title: String
    let date: String
    let amount: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                Text(date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(formatAmount(amount))원")
                .font(.subheadline)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
    }
    
    private func formatAmount(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: amount)) ?? "0"
    }
}

#Preview {
    NavigationView {
        UserProfileView(user: LeaderboardData.sampleData.sellers[0])
    }
} 