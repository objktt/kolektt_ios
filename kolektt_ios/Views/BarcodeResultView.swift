import SwiftUI

struct BarcodeResultView: View {
    let barcode: String
    @Environment(\.presentationMode) var presentationMode
    @State private var albumTitle = "더미 앨범 제목"
    @State private var artistName = "더미 아티스트"
    @State private var releaseYear = "2024"
    @State private var showingAlbumInput = false
    
    // 더미 이미지 추가
    private let dummyCoverImage = UIImage(systemName: "music.note")!
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("바코드 검색 결과")
                    .font(.title)
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("바코드: \(barcode)")
                    Text("앨범: \(albumTitle)")
                    Text("아티스트: \(artistName)")
                    Text("발매년도: \(releaseYear)")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                Button(action: {
                    showingAlbumInput = true
                }) {
                    Text("앨범 정보 수정")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("취소")
                        .foregroundColor(.red)
                }
                .padding()
                
                Spacer()
            }
            .padding()
            .navigationBarTitle("바코드 스캔 결과", displayMode: .inline)
            .navigationBarItems(leading: Button("닫기") {
                presentationMode.wrappedValue.dismiss()
            })
            .fullScreenCover(isPresented: $showingAlbumInput) {
                AlbumInputView(coverImage: dummyCoverImage)
            }
        }
    }
} 