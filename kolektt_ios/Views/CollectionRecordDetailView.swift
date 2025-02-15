import SwiftUI
import WebKit

struct CollectionRecordDetailView: View {
    let record: Record
    @State private var showingPreviewSheet = false
    @State private var showingAddPreviewSheet = false
    @State private var showingEditSheet = false
    @State private var previewUrl: String = ""
    @State private var selectedCondition: String
    @State private var currentPage = 0
    
    private let conditions = [
        "M": "Mint (완벽한 상태)",
        "NM": "Near Mint (거의 새것)",
        "VG+": "Very Good Plus (매우 좋음)",
        "VG": "Very Good (좋음)",
        "G+": "Good Plus (양호)",
        "G": "Good (보통)",
        "F": "Fair (나쁨)"
    ]
    
    // 앨범 이미지 배열
    private var albumImages: [(String, AnyView)] {
        [
            ("앞면", AnyView(
                AlbumImageView(url: record.coverImageURL)
            )),
            ("뒷면", AnyView(
                AlbumImageView(url: record.coverImageURL)
            )),
            ("미리듣기", AnyView(
                PreviewSlideView(url: record.previewUrl) {
                    showingAddPreviewSheet = true
                }
            ))
        ]
    }
    
    init(record: Record) {
        self.record = record
        _selectedCondition = State(initialValue: record.condition ?? "NM")
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 앨범 커버 이미지 슬라이더
                TabView(selection: $currentPage) {
                    ForEach(0..<albumImages.count, id: \.self) { index in
                        VStack {
                            albumImages[index].1
                                .frame(height: 300)
                            Text(albumImages[index].0)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .frame(height: 350)
                
                VStack(alignment: .leading, spacing: 16) {
                    // 앨범 정보
                    VStack(alignment: .leading, spacing: 8) {
                        Text(record.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(record.artist)
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    
                    // Discogs 메타데이터
                    VStack(alignment: .leading, spacing: 16) {
                        Text("레코드 정보")
                            .font(.headline)
                            .padding(.top, 8)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            MetadataRow(title: "카탈로그 번호", value: record.catalogNumber ?? "미등록")
                            MetadataRow(title: "레이블", value: record.label ?? "미등록")
                            MetadataRow(title: "포맷", value: record.format ?? "미등록")
                            MetadataRow(title: "국가", value: record.country ?? "미등록")
                            MetadataRow(title: "발매년도", value: record.releaseYear?.description ?? "미등록")
                            MetadataRow(title: "장르", value: record.genre ?? "미등록")
                            MetadataRow(title: "스타일", value: record.style ?? "미등록")
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // 레코드 상태
                    VStack(alignment: .leading, spacing: 16) {
                        Text("레코드 상태")
                            .font(.headline)
                            .padding(.top, 8)
                        
                        Menu {
                            ForEach(Array(conditions.keys.sorted()), id: \.self) { key in
                                Button(action: {
                                    selectedCondition = key
                                }) {
                                    HStack {
                                        Text("\(key) - \(conditions[key] ?? "")")
                                        if selectedCondition == key {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text("\(selectedCondition) - \(conditions[selectedCondition] ?? "")")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        if let notes = record.notes {
                            Text("노트")
                                .font(.headline)
                                .padding(.top, 8)
                            
                            Text(notes)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingEditSheet = true
                }) {
                    Image(systemName: "pencil")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditRecordView(record: record)
        }
    }
}

struct MetadataRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
        }
    }
}

// 앨범 이미지 뷰
struct AlbumImageView: View {
    let url: URL?
    
    var body: some View {
        if let url = url {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        Image(systemName: "music.note")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    )
            }
        } else {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .overlay(
                    Image(systemName: "music.note")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                )
        }
    }
}

// 미리듣기 슬라이드 뷰
struct PreviewSlideView: View {
    let url: String?
    let onAddPreview: () -> Void
    @State private var showingPreviewPlayer = false
    
    var body: some View {
        VStack(spacing: 20) {
            if let url = url {
                // 미리듣기가 있는 경우
                Button(action: { showingPreviewPlayer = true }) {
                    VStack(spacing: 16) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        Text("미리듣기 재생")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                .sheet(isPresented: $showingPreviewPlayer) {
                    NavigationView {
                        PreviewPlayerView(url: url)
                            .navigationTitle("미리듣기")
                            .navigationBarItems(
                                trailing: Button("편집") {
                                    showingPreviewPlayer = false
                                    onAddPreview()
                                }
                            )
                    }
                }
            } else {
                // 미리듣기가 없는 경우
                Button(action: onAddPreview) {
                    VStack(spacing: 16) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("미리듣기 추가")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal)
    }
}

struct PreviewCard: View {
    let previewUrl: String?
    
    var body: some View {
        VStack(spacing: 12) {
            if previewUrl == nil {
                // 미리듣기가 없는 경우
                VStack(spacing: 8) {
                    Image(systemName: "music.note")
                        .font(.system(size: 30))
                        .foregroundColor(.gray)
                    Text("미리듣기 추가")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            } else {
                // 미리듣기가 있는 경우
                HStack {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.blue)
                    Text("미리듣기 재생")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct PreviewPlayerView: View {
    let url: String?
    
    var body: some View {
        VStack {
            if let url = url {
                // TODO: 실제 플레이어 구현
                WebView(urlString: url)
            } else {
                Text("등록된 미리듣기가 없습니다")
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct AddPreviewView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var previewUrl: String
    @State private var urlInput = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("YouTube URL 입력")) {
                    TextField("https://youtube.com/...", text: $urlInput)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                Section(header: Text("또는")) {
                    Button(action: {
                        // TODO: 오디오 파일 선택 구현
                    }) {
                        Label("오디오 파일 선택", systemImage: "music.note")
                    }
                }
            }
            .navigationTitle("미리듣기 추가")
            .navigationBarItems(
                leading: Button("취소") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("저장") {
                    savePreview()
                }
                .disabled(urlInput.isEmpty)
            )
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("오류"),
                    message: Text("올바른 URL을 입력해주세요"),
                    dismissButton: .default(Text("확인"))
                )
            }
        }
    }
    
    private func savePreview() {
        guard urlInput.contains("youtube.com") || urlInput.contains("youtu.be") else {
            showingAlert = true
            return
        }
        previewUrl = urlInput
        presentationMode.wrappedValue.dismiss()
    }
}

struct WebView: UIViewRepresentable {
    let urlString: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

#Preview {
    NavigationView {
        CollectionRecordDetailView(record: Record.sampleData[0])
    }
} 