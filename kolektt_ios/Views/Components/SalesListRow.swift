import SwiftUI

struct SalesListRow: View {
    let sale: SaleRecord
    
    var body: some View {
        HStack(spacing: 16) {
            // 앨범 커버
            AsyncImage(url: sale.record.coverImageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay {
                        Image(systemName: "music.note")
                            .foregroundColor(.gray)
                    }
            }
            .frame(width: 60, height: 60)
            .cornerRadius(8)
            
            // 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(sale.record.title)
                    .font(.headline)
                Text(sale.record.artist)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("\(sale.price)원")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "0036FF"))
                        .fontWeight(.semibold)
                    
                    Text(formatDate(sale.saleDate))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
} 