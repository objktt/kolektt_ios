import SwiftUI

struct AlbumInputView: View {
    let coverImage: UIImage
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title: String = ""
    @State private var artist: String = ""
    @State private var releaseYear: String = ""
    @State private var genre: String = ""
    @State private var condition: String = "NM"
    @State private var conditionNotes: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // 레코드 상태 옵션
    private let conditions = [
        "M": "Mint (완벽한 상태)",
        "NM": "Near Mint (거의 새것)",
        "VG+": "Very Good Plus (매우 좋음)",
        "VG": "Very Good (좋음)",
        "G+": "Good Plus (양호)",
        "G": "Good (보통)",
        "F": "Fair (나쁨)"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 앨범 커버 이미지
                    Image(uiImage: coverImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)
                        .cornerRadius(8)
                    
                    // 앨범 정보 입력 폼
                    VStack(alignment: .leading, spacing: 12) {
                        InfoRow(title: "제목", text: $title)
                        InfoRow(title: "아티스트", text: $artist)
                        InfoRow(title: "발매년도", text: $releaseYear)
                        InfoRow(title: "장르", text: $genre)
                        
                        // 레코드 상태 선택
                        VStack(alignment: .leading, spacing: 4) {
                            Text("상태")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Menu {
                                ForEach(Array(conditions.keys.sorted()), id: \.self) { key in
                                    Button(action: { condition = key }) {
                                        HStack {
                                            Text("\(key) - \(conditions[key] ?? "")")
                                            if condition == key {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text("\(condition) - \(conditions[condition] ?? "")")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                        
                        // 상태 설명
                        VStack(alignment: .leading, spacing: 4) {
                            Text("상태 설명")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            TextEditor(text: $conditionNotes)
                                .frame(height: 100)
                                .padding(4)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    
                    // 저장 버튼
                    Button(action: saveToCollection) {
                        Text("컬렉션에 추가")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle("앨범 정보 입력")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("취소") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("알림"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("확인")) {
                        if alertMessage.contains("추가되었습니다") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                )
            }
        }
    }
    
    private func saveToCollection() {
        // TODO: 실제 저장 로직 구현
        // 상태 정보도 함께 저장
        alertMessage = "컬렉션에 추가되었습니다."
        showingAlert = true
    }
}

struct InfoRow: View {
    let title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            TextField(title, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
} 