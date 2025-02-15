import SwiftUI
import AVKit

class AudioPlayer: ObservableObject {
    private var player: AVPlayer?
    
    func play(url: String) {
        guard let url = URL(string: url) else { return }
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func stop() {
        player?.pause()
        player = nil
    }
}

struct RecordDetailView: View {
    let record: Record
    @StateObject private var audioPlayer = AudioPlayer()
    @State private var isPlaying = false
    @State private var showingPurchaseSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 앨범 커버 이미지
                AsyncImage(url: record.coverImageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "music.note")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                .clipped()
                
                VStack(alignment: .leading, spacing: 16) {
                    // 앨범 정보
                    VStack(alignment: .leading, spacing: 8) {
                        Text(record.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(record.artist)
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        if let description = record.recordDescription {
                            Text(description)
                                .font(.body)
                                .padding(.top, 8)
                        }
                    }
                    
                    // 음악 프리뷰 플레이어
                    if let previewUrl = record.previewUrl {
                        HStack {
                            Button(action: {
                                if isPlaying {
                                    audioPlayer.pause()
                                } else {
                                    audioPlayer.play(url: previewUrl)
                                }
                                isPlaying.toggle()
                            }) {
                                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(.blue)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("미리듣기")
                                    .font(.headline)
                                Text("30초")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // 판매자 목록
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("판매자 목록")
                                .font(.headline)
                            Spacer()
                            Text("\(record.sellersCount)개의 매물")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 8)
                        
                        ForEach(0..<3) { index in
                            SellerRow(
                                sellerName: "DJ Name \(index + 1)",
                                price: 50000 + (index * 5000),
                                condition: "VG+",
                                onPurchase: {
                                    showingPurchaseSheet = true
                                }
                            )
                        }
                        
                        NavigationLink(destination: SellersListView(record: record)) {
                            Text("전체 판매자 보기")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingPurchaseSheet) {
            PurchaseView(record: record)
        }
        .onDisappear {
            audioPlayer.stop()
        }
    }
}

struct SellerRow: View {
    let sellerName: String
    let price: Int
    let condition: String
    let onPurchase: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // 판매자 프로필
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(sellerName)
                    .font(.headline)
                
                HStack(spacing: 8) {
                    Text("\(price)원")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(condition)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            
            Spacer()
            
            Button(action: onPurchase) {
                Text("구매")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct SellersListView: View {
    let record: Record
    
    var body: some View {
        List {
            ForEach(0..<10) { index in
                SellerRow(
                    sellerName: "DJ Name \(index + 1)",
                    price: 50000 + (index * 5000),
                    condition: "VG+",
                    onPurchase: {}
                )
                .listRowInsets(EdgeInsets())
                .padding(.vertical, 4)
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("판매자 목록")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PurchaseView: View {
    let record: Record
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 구매 정보 표시
                Text("구매 진행 중...")
                    .font(.headline)
            }
            .navigationTitle("구매하기")
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

#Preview {
    NavigationView {
        RecordDetailView(record: Record.sampleData[0])
    }
} 