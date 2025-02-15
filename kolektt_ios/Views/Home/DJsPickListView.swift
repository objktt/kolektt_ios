import SwiftUI

struct DJsPickListView: View {
    // 샘플 데이터 - 실제로는 ViewModel에서 가져와야 함
    let djs = [
        DJ(
            id: "1",
            name: "Sickmode",
            title: "DJ",
            imageURL: URL(string: "https://example.com/dj1.jpg")!,
            yearsActive: 5,
            recordCount: 1000,
            interviewContents: []
        ),
        DJ(
            id: "2",
            name: "Zedd",
            title: "DJ",
            imageURL: URL(string: "https://example.com/dj2.jpg")!,
            yearsActive: 8,
            recordCount: 1500,
            interviewContents: []
        ),
        DJ(
            id: "3",
            name: "Skrillex",
            title: "DJ",
            imageURL: URL(string: "https://example.com/dj3.jpg")!,
            yearsActive: 10,
            recordCount: 2000,
            interviewContents: []
        ),
        DJ(
            id: "4",
            name: "Diplo",
            title: "DJ",
            imageURL: URL(string: "https://example.com/dj4.jpg")!,
            yearsActive: 12,
            recordCount: 2500,
            interviewContents: []
        ),
        DJ(
            id: "5",
            name: "Calvin Harris",
            title: "DJ",
            imageURL: URL(string: "https://example.com/dj5.jpg")!,
            yearsActive: 15,
            recordCount: 3000,
            interviewContents: []
        )
    ]
    
    // 그리드 레이아웃 설정
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(djs, id: \.id) { dj in
                    NavigationLink(destination: DJsPickDetailView(dj: dj)) {
                        VStack(alignment: .leading, spacing: 0) {
                            // DJ 이미지
                            KolekttAsyncImage(
                                url: dj.imageURL,
                                width: 160,
                                height: 200,
                                cornerRadius: 12
                            )
                            
                            // DJ 정보
                            VStack(alignment: .leading, spacing: 8) {
                                Text(dj.name)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                // 장르 태그
                                HStack(spacing: 8) {
                                    Text("House")
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                    
                                    Text("Techno")
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                }
                            }
                            .padding(12)
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
        .navigationTitle("DJs Pick")
        .navigationBarTitleDisplayMode(.large)
    }
} 