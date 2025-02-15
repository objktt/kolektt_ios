import SwiftUI
import SwiftData
import Charts

private let primaryColor = Color(hex: "0036FF")

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var records: [Record]
    @State private var selectedTab = 0
    @State private var showingSalesHistory = false
    
    private let tabs = ["컬렉션", "판매중", "구매", "활동"]
    
    var body: some View {
        NavigationView {
        ScrollView {
            VStack(spacing: 24) {
                // 프로필 헤더
        VStack(spacing: 16) {
                        // 프로필 정보 영역
                        HStack(alignment: .top, spacing: 20) {
            // 프로필 이미지
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 86, height: 86)
                                .overlay(
                Image(systemName: "person.circle.fill")
                                        .font(.system(size: 40))
                    .foregroundColor(.gray)
                                )
            .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color(.systemGray5), lineWidth: 1)
                                )
            
                            VStack(alignment: .leading, spacing: 12) {
            // 사용자 정보
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("DJ Huey")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                    
                                    Text("House / Techno")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                                }
                                
                                // 팔로워/팔로잉 정보
                                HStack(spacing: 24) {
                                    NavigationLink(destination: FollowersListView()) {
                    VStack(spacing: 4) {
                                            Text("1.2k")
                            .font(.headline)
                                                .foregroundColor(.primary)
                        Text("팔로워")
                                                .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                                    NavigationLink(destination: FollowingListView()) {
                    VStack(spacing: 4) {
                                            Text("824")
                            .font(.headline)
                                                .foregroundColor(.primary)
                        Text("팔로잉")
                                                .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                    .background(Color(.systemBackground))
                    
                    // 통계 카드
                    HStack(spacing: 16) {
            StatCard(
                            title: "총 레코드",
                            value: "\(records.count)장",
                icon: "record.circle.fill",
                            color: primaryColor
                        )
                        
                        SalesStatCard(
                            totalSales: "2,480,000원",
                            soldCount: "24장",
                            color: primaryColor
                        )
                    }
                    .padding(.horizontal)
                    
                    // 탭 메뉴
                    VStack(spacing: 0) {
                        // 탭 버튼
                        HStack(spacing: 0) {
                            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                                Button(action: {
                                    withAnimation {
                                        selectedTab = index
                                    }
                                }) {
                                    VStack(spacing: 8) {
                                        Text(tab)
                                            .font(.subheadline)
                                            .fontWeight(selectedTab == index ? .semibold : .regular)
                                            .foregroundColor(selectedTab == index ? .primary : .secondary)
                                        
                                        Rectangle()
                                            .fill(selectedTab == index ? primaryColor : Color.clear)
                                            .frame(height: 2)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal)
                        
                        // 탭 컨텐츠
                        switch selectedTab {
                        case 0:
                            // 컬렉션 탭
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 1) {
                                ForEach(records) { record in
                                    NavigationLink(destination: CollectionRecordDetailView(record: record)) {
                                        InstagramStyleRecordCard(record: record)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        
                        case 1:
                            // 판매중 탭
                            SaleListView()
                            
                        case 2:
                            // 구매 탭
                            PurchaseListView()
                            
                        case 3:
                            // 활동 탭
                            VStack(spacing: 16) {
                                ForEach(0..<3) { _ in
                                    ActivityCard(
                                        type: .activity,
                                        title: "새로운 레코드를 추가했습니다",
                                        subtitle: "Bicep - Isles",
                                        date: "2시간 전",
                                        status: nil,
                                        statusColor: nil
                                    )
                                }
                            }
                            .padding(.vertical)
                        default:
                            EmptyView()
                        }
                    }
                }
            }
            .navigationTitle("프로필")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SalesHistoryView()) {
                        Image(systemName: "list.bullet.clipboard.fill")
                            .foregroundColor(primaryColor)
                    }
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(color.opacity(0.05))
        .cornerRadius(12)
    }
}

struct SalesStatCard: View {
    let totalSales: String
    let soldCount: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "wonsign.circle.fill")
                .font(.title2)
                .foregroundColor(color)
            
                    VStack(spacing: 4) {
                Text(totalSales)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(soldCount)
                            .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text("판매 수익")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(color.opacity(0.05))
        .cornerRadius(12)
    }
}

struct ActivityCard: View {
    let type: ActivityType
    let title: String
    let subtitle: String
    let date: String
    let status: String?
    let statusColor: Color?
    
    enum ActivityType {
        case sale
        case purchase
        case activity
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // 앨범 커버
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "music.note")
                            .foregroundColor(.gray)
                    )
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(subtitle)
                        .font(.headline)
                    
                    if let status = status {
                        Text(status)
                            .font(.caption)
                            .foregroundColor(statusColor ?? primaryColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background((statusColor ?? primaryColor).opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                
                Spacer()
                
                Text(date)
                        .font(.caption)
                        .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct FollowersListView: View {
    var body: some View {
        List {
            ForEach(0..<20) { _ in
                NavigationLink(destination: OtherUserProfileView()) {
                    HStack(spacing: 12) {
                        Circle()
                .fill(Color.gray.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.gray)
                            )
                            .clipShape(Circle())
                        
            VStack(alignment: .leading, spacing: 4) {
                            Text("DJ Name")
                    .font(.headline)
                            Text("House / Techno")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("팔로워")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FollowingListView: View {
    var body: some View {
        List {
            ForEach(0..<20) { _ in
                NavigationLink(destination: OtherUserProfileView()) {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.gray)
                            )
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("DJ Name")
                                .font(.headline)
                            Text("House / Techno")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("팔로잉")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct OtherUserProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isFollowing = false
    @State private var selectedTab = 0
    
    private let tabs = ["컬렉션", "활동"]
    // 임시 데이터
    private let sampleRecords = Record.sampleData
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 프로필 헤더
                VStack(spacing: 16) {
                    // 프로필 정보 영역
                    HStack(alignment: .top, spacing: 20) {
            // 프로필 이미지
            Circle()
                .fill(Color.gray.opacity(0.2))
                            .frame(width: 86, height: 86)
                            .overlay(
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                            )
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color(.systemGray5), lineWidth: 1)
                            )
                        
                        VStack(alignment: .leading, spacing: 12) {
                            // 사용자 정보
            VStack(alignment: .leading, spacing: 4) {
                                Text("DJ Name")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                Text("House / Techno")
                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            // 팔로워/팔로잉 정보
                            HStack(spacing: 24) {
                                VStack(spacing: 4) {
                                    Text("1.2k")
                                        .font(.headline)
                                    Text("팔로워")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
                                VStack(spacing: 4) {
                                    Text("824")
                                        .font(.headline)
                                    Text("팔로잉")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            // 팔로우 버튼
                            Button(action: {
                                isFollowing.toggle()
                            }) {
                                Text(isFollowing ? "팔로잉" : "팔로우")
                                    .font(.headline)
                                    .foregroundColor(isFollowing ? .secondary : .white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 36)
                                    .background(isFollowing ? Color(.systemGray5) : Color(hex: "0036FF"))
                                    .cornerRadius(18)
                            }
                            .padding(.top, 8)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .background(Color(.systemBackground))
                
                // 통계 카드
                HStack(spacing: 16) {
                    StatCard(
                        title: "총 레코드",
                        value: "248장",
                        icon: "record.circle.fill",
                        color: primaryColor
                    )
                    
                    StatCard(
                        title: "판매 수익",
                        value: "1,240,000원",
                        icon: "wonsign.circle.fill",
                        color: primaryColor
                    )
                }
                .padding(.horizontal)
                
                // 탭 메뉴
                VStack(spacing: 0) {
                    // 탭 버튼
                    HStack(spacing: 0) {
                        ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                            Button(action: {
                                withAnimation {
                                    selectedTab = index
                                }
                            }) {
                                VStack(spacing: 8) {
                                    Text(tab)
                                        .font(.subheadline)
                                        .fontWeight(selectedTab == index ? .semibold : .regular)
                                        .foregroundColor(selectedTab == index ? .primary : .secondary)
                                    
                                    Rectangle()
                                        .fill(selectedTab == index ? primaryColor : Color.clear)
                                        .frame(height: 2)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal)
                    
                    // 탭 컨텐츠
                    switch selectedTab {
                    case 0:
                        // 컬렉션 탭
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 1) {
                            ForEach(sampleRecords) { record in
                                NavigationLink(destination: CollectionRecordDetailView(record: record)) {
                                    InstagramStyleRecordCard(record: record)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    
                    case 1:
                        // 활동 탭
                        VStack(spacing: 16) {
                            ForEach(0..<3) { _ in
                                ActivityCard(
                                    type: .activity,
                                    title: "새로운 레코드를 추가했습니다",
                                    subtitle: "Bicep - Isles",
                                    date: "2시간 전",
                                    status: nil,
                                    statusColor: nil
                                )
                            }
                        }
                        .padding(.vertical)
                    default:
                        EmptyView()
                    }
                }
            }
        }
        .navigationTitle("프로필")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SaleListView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(0..<5) { _ in
                    ActivityCard(
                        type: .sale,
                        title: "판매중인 레코드",
                        subtitle: "Bicep - Isles",
                        date: "3일 전",
                        status: "판매중",
                        statusColor: primaryColor
                    )
                }
            }
            .padding(.vertical)
        }
    }
}

struct PurchaseListView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(0..<5) { _ in
                    ActivityCard(
                        type: .purchase,
                        title: "구매한 레코드",
                        subtitle: "Bicep - Isles",
                        date: "1주일 전",
                        status: "구매완료",
                        statusColor: .secondary
                    )
                }
            }
            .padding(.vertical)
        }
    }
}

struct SalesHistoryView: View {
    // MARK: - Properties
    @State private var selectedPeriod: Period = .all
    @State private var salesData: [SaleRecord] = SaleRecord.sampleData
    
    // MARK: - Period Enum
    enum Period: String, CaseIterable {
        case week = "1주일"
        case month = "1개월"
        case threeMonths = "3개월"
        case sixMonths = "6개월"
        case year = "1년"
        case all = "전체"
    }
    
    // MARK: - Computed Properties
    private var filteredSales: [SaleRecord] {
        let calendar = Calendar.current
        let now = Date()
        
        return salesData.filter { sale in
            guard let components = calendar.dateComponents(
                [.day, .month, .year],
                from: sale.saleDate,
                to: now
            ) as DateComponents? else {
                return false
            }
            
            switch selectedPeriod {
            case .week:
                return components.day ?? 0 <= 7
            case .month:
                return components.month ?? 0 <= 1
            case .threeMonths:
                return components.month ?? 0 <= 3
            case .sixMonths:
                return components.month ?? 0 <= 6
            case .year:
                return components.year ?? 0 <= 1
            case .all:
                return true
            }
        }
    }
    
    private var totalRevenue: Int {
        filteredSales.reduce(0) { $0 + $1.price }
    }
    
    private var averagePrice: Int {
        filteredSales.isEmpty ? 0 : totalRevenue / filteredSales.count
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 기간 필터
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Period.allCases, id: \.self) { period in
                            Button(action: {
                                selectedPeriod = period
                            }) {
                                Text(period.rawValue)
                                    .font(.subheadline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedPeriod == period ? Color(hex: "0036FF") : Color.gray.opacity(0.1))
                                    .foregroundColor(selectedPeriod == period ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // 판매 분석 섹션
                VStack(spacing: 16) {
                    // 주요 지표
                    HStack(spacing: 20) {
                        SalesAnalysisCard(
                            title: "총 판매액",
                            value: "\(totalRevenue)원",
                            icon: "wonsign.circle.fill"
                        )
                        
                        SalesAnalysisCard(
                            title: "평균 판매가",
                            value: "\(averagePrice)원",
                            icon: "chart.bar.fill"
                        )
                    }
                    .padding(.horizontal)
                    
                    // 판매 내역 리스트
                    LazyVStack(spacing: 16) {
                        ForEach(filteredSales) { sale in
                            SalesListRow(sale: sale)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("판매 내역")
        .background(Color(.systemBackground))
    }
}

struct InstagramStyleRecordCard: View {
    let record: Record
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 앨범 커버 이미지
            GeometryReader { geometry in
                AsyncImageView(
                    url: record.coverImageURL,
                    size: CGSize(
                        width: geometry.size.width,
                        height: geometry.size.width
                    ),
                    cornerRadius: 0
                )
            }
            .aspectRatio(1, contentMode: .fit)
            
            // 앨범 정보
            VStack(alignment: .leading, spacing: 2) {
                Text(record.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(record.artist)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 6)
        }
    }
}

#Preview {
    ProfileView()
} 