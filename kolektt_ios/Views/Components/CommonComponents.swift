import SwiftUI

// MARK: - 이미지 컴포넌트
struct KolekttAsyncImage: View {
    let url: URL?
    let width: CGFloat
    let height: CGFloat
    var cornerRadius: CGFloat = 0
    var contentMode: ContentMode = .fill
    
    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } placeholder: {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

// MARK: - 버튼 컴포넌트
struct KolekttButton: View {
    let title: String
    let style: ButtonStyle
    let action: () -> Void
    
    enum ButtonStyle {
        case primary
        case secondary
        case outline
        
        var backgroundColor: Color {
            switch self {
            case .primary: return .blue
            case .secondary: return .gray.opacity(0.1)
            case .outline: return .clear
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary: return .white
            case .secondary, .outline: return .primary
            }
        }
        
        var borderColor: Color {
            switch self {
            case .outline: return .gray.opacity(0.3)
            default: return .clear
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(style.foregroundColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(style.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(style.borderColor, lineWidth: 1)
                )
        }
    }
}

// MARK: - 섹션 헤더
struct SectionHeader: View {
    let title: String
    let showMore: Bool
    let moreAction: (() -> Void)?
    
    init(title: String, showMore: Bool = false, moreAction: (() -> Void)? = nil) {
        self.title = title
        self.showMore = showMore
        self.moreAction = moreAction
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            Spacer()
            if showMore {
                Button(action: { moreAction?() }) {
                    HStack(spacing: 4) {
                        Text("더보기")
                            .font(.subheadline)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - 태그
struct KolekttTag: View {
    let text: String
    let color: Color
    
    init(_ text: String, color: Color = .blue) {
        self.text = text
        self.color = color
    }
    
    var body: some View {
        Text(text)
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .cornerRadius(8)
    }
}

// MARK: - 가격 표시
struct PriceText: View {
    let price: Int
    let style: PriceStyle
    
    enum PriceStyle {
        case normal
        case large
        case accent
        
        var font: Font {
            switch self {
            case .normal: return .subheadline
            case .large: return .title3
            case .accent: return .headline
            }
        }
        
        var color: Color {
            switch self {
            case .normal: return .secondary
            case .large: return .primary
            case .accent: return .blue
            }
        }
    }
    
    init(_ price: Int, style: PriceStyle = .normal) {
        self.price = price
        self.style = style
    }
    
    var body: some View {
        Text("\(price)원")
            .font(style.font)
            .foregroundColor(style.color)
    }
}

// MARK: - 프로필 이미지
struct ProfileImage: View {
    let url: URL?
    let size: CGFloat
    
    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                )
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
} 