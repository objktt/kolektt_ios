import Foundation

struct LeaderboardUser: Identifiable {
    let id: UUID
    let name: String
    let amount: Int
    let profileImageURL: URL?
    let rank: Int
    
    init(id: UUID = UUID(), name: String, amount: Int, profileImageURL: URL? = nil, rank: Int) {
        self.id = id
        self.name = name
        self.amount = amount
        self.profileImageURL = profileImageURL
        self.rank = rank
    }
}

struct LeaderboardData {
    var sellers: [LeaderboardUser]
    var buyers: [LeaderboardUser]
    
    static var sampleData: LeaderboardData {
        LeaderboardData(
            sellers: [
                LeaderboardUser(name: "김판매", amount: 1250000, rank: 1),
                LeaderboardUser(name: "이레코드", amount: 980000, rank: 2),
                LeaderboardUser(name: "박중고", amount: 750000, rank: 3),
                LeaderboardUser(name: "최음반", amount: 580000, rank: 4),
                LeaderboardUser(name: "정바이닐", amount: 420000, rank: 5)
            ],
            buyers: [
                LeaderboardUser(name: "홍구매", amount: 2100000, rank: 1),
                LeaderboardUser(name: "강컬렉터", amount: 1850000, rank: 2),
                LeaderboardUser(name: "조음악", amount: 1620000, rank: 3),
                LeaderboardUser(name: "윤앨범", amount: 1450000, rank: 4),
                LeaderboardUser(name: "한바이닐", amount: 1280000, rank: 5)
            ]
        )
    }
} 