import SwiftUI

struct AddRecordView: View {
    @Environment(\.dismiss) private var dismiss
    
    let initialTitle: String
    let initialArtist: String
    let onSave: (String, String, Int?, String?, String?) -> Void
    
    @State private var title: String
    @State private var artist: String
    @State private var releaseYear: String = ""
    @State private var genre: String = ""
    @State private var notes: String = ""
    
    init(initialTitle: String, initialArtist: String,
         onSave: @escaping (String, String, Int?, String?, String?) -> Void) {
        self.initialTitle = initialTitle
        self.initialArtist = initialArtist
        self.onSave = onSave
        _title = State(initialValue: initialTitle)
        _artist = State(initialValue: initialArtist)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("기본 정보")) {
                    TextField("앨범 제목", text: $title)
                    TextField("아티스트", text: $artist)
                    TextField("발매년도", text: $releaseYear)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("추가 정보")) {
                    TextField("장르", text: $genre)
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("레코드 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        let year = Int(releaseYear)
                        onSave(title, artist, year,
                              genre.isEmpty ? nil : genre,
                              notes.isEmpty ? nil : notes)
                        dismiss()
                    }
                }
            }
        }
    }
} 