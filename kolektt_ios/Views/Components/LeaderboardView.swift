import SwiftUI

struct LeaderboardView: View {
    let data: LeaderboardData
    @State private var selectedTab = 0
    
    private let tabs = ["판매자 순위", "구매자 순위"]
    private let primaryColor = Color(hex: "0036FF")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("리더보드")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            // 탭 선택기
            HStack(spacing: 16) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    Button(action: {
                        withAnimation {
                            selectedTab = index
                        }
                    }) {
                        Text(tabs[index])
                            .font(.subheadline)
                            .fontWeight(selectedTab == index ? .semibold : .regular)
                            .foregroundColor(selectedTab == index ? .white : .primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedTab == index ? primaryColor : Color.clear)
                            )
                    }
                }
            }
            .padding(.horizontal)
            
            // 리더보드 리스트
            let users = selectedTab == 0 ? data.sellers : data.buyers
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(users) { user in
                        LeaderboardCard(user: user)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}

struct LeaderboardCard: View {
    let user: LeaderboardUser
    
    var body: some View {
        NavigationLink(destination: UserProfileView(user: user)) {
            VStack(spacing: 12) {
                // 순위 뱃지
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 24, height: 24)
                    
                    Text("\(user.rank)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                // 프로필 이미지
                if let imageURL = user.profileImageURL {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                    } placeholder: {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.gray)
                            )
                    }
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                        )
                }
                
                // 사용자 정보
                VStack(spacing: 4) {
                    Text(user.name)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text("\(formatAmount(user.amount))원")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 100)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatAmount(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: amount)) ?? "0"
    }
}

#Preview {
    LeaderboardView(data: LeaderboardData.sampleData)
        .previewLayout(.sizeThatFits)
} 