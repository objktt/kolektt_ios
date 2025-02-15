import SwiftUI

@MainActor
class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private static let cache = NSCache<NSString, UIImage>()
    private let url: URL?
    
    init(url: URL?) {
        self.url = url
        loadImage()
    }
    
    private func loadImage() {
        guard let url = url else { return }
        
        let urlString = url.absoluteString as NSString
        
        // 캐시된 이미지가 있는지 확인
        if let cachedImage = Self.cache.object(forKey: urlString) {
            self.image = cachedImage
            return
        }
        
        // 비동기로 이미지 로드
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let loadedImage = UIImage(data: data) {
                    Self.cache.setObject(loadedImage, forKey: urlString)
                    self.image = loadedImage
                }
            } catch {
                print("Error loading image: \(error)")
            }
        }
    }
}

struct AsyncImageView: View {
    let url: URL?
    let size: CGSize
    let cornerRadius: CGFloat
    
    @StateObject private var loader: ImageLoader
    
    init(url: URL?, size: CGSize, cornerRadius: CGFloat = 10) {
        self.url = url
        self.size = size
        self.cornerRadius = cornerRadius
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
    }
    
    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "music.note")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    )
            }
        }
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
} 