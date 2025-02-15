import SwiftUI
import SwiftData
import PhotosUI
import Charts

private let primaryColor = Color(hex: "0036FF")

struct CollectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var records: [Record]
    @StateObject private var viewModel = CollectionViewModel()
    
    // View States
    @State private var showingCamera = false
    @State private var showingBarcodeScanner = false
    @State private var showingCatNoInput = false
    @State private var showingManualInput = false
    @State private var showingAddRecord = false
    @State private var isGridView = true
    @State private var searchText = ""
    @State private var selectedGenre: String = "전체"
    @State private var sortOption: SortOption = .dateAdded
    @State private var showingSearchFilter = false
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    enum SortOption: String, CaseIterable {
        case dateAdded = "추가된 날짜"
        case title = "제목"
        case artist = "아티스트"
        case year = "발매년도"
    }
    
    var filteredRecords: [Record] {
        var result = records
        
        // 검색어 필터링
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.artist.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // 장르 필터링
        if selectedGenre != "전체" {
            result = result.filter { $0.genre == selectedGenre }
        }
        
        // 정렬
        switch sortOption {
        case .dateAdded:
            result.sort { $0.createdAt > $1.createdAt }
        case .title:
            result.sort { $0.title < $1.title }
        case .artist:
            result.sort { $0.artist < $1.artist }
        case .year:
            result.sort { ($0.releaseYear ?? 0) > ($1.releaseYear ?? 0) }
        }
        
        return result
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 4) {
                    // 분석 섹션
                    AnalyticsSection(analytics: viewModel.analytics)
                    
                    // 컨트롤 섹션
                    HStack(spacing: 16) {
                        Button(action: {
                            withAnimation {
                                showingSearchFilter.toggle()
                            }
                        }) {
                            Image(systemName: showingSearchFilter ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
                        
                        Button(action: { isGridView.toggle() }) {
                            Image(systemName: isGridView ? "square.grid.2x2" : "list.bullet")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // 검색 및 필터 바
                    if showingSearchFilter {
                        SearchFilterBar(
                            searchText: $searchText,
                            selectedGenre: $selectedGenre,
                            sortOption: $sortOption,
                            isGridView: $isGridView,
                            genres: ["전체"] + Array(Set(records.compactMap { $0.genre })).sorted()
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.vertical, 4)
                    }
                    
                    // 레코드 목록 섹션
                    if isGridView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(filteredRecords) { record in
                                NavigationLink(destination: CollectionRecordDetailView(record: record)) {
                                    RecordCardView(record: record)
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredRecords) { record in
                                RecordListItemView(record: record)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("컬렉션")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingCamera = true }) {
                            Label("앨범 커버 인식", systemImage: "camera.viewfinder")
                        }
                        
                        Button(action: { showingBarcodeScanner = true }) {
                            Label("바코드 스캔", systemImage: "barcode.viewfinder")
                        }
                        
                        Button(action: { showingCatNoInput = true }) {
                            Label("CatNo 입력", systemImage: "number")
                        }
                        
                        Button(action: { showingManualInput = true }) {
                            Label("수동 입력", systemImage: "square.and.pencil")
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.black)
                            .clipShape(Circle())
                    }
                }
            }
            .sheet(isPresented: $showingCamera) {
                CameraView(mode: .albumCover)
            }
            .sheet(isPresented: $showingBarcodeScanner) {
                CameraView(mode: .barcode)
            }
            .sheet(isPresented: $showingCatNoInput) {
                CatNoInputView { catNo in
                    Task {
                        await searchByCatNo(catNo)
                    }
                }
            }
            .sheet(isPresented: $showingManualInput) {
                AddRecordView(
                    initialTitle: "",
                    initialArtist: "",
                    onSave: { title, artist, year, genre, notes in
                        addRecord(title: title,
                                artist: artist,
                                releaseYear: year,
                                genre: genre,
                                notes: notes)
                    }
                )
            }
            .onChange(of: viewModel.selectedImage) { oldValue, newValue in
                if let image = newValue {
                    Task {
                        await processImage(image)
                    }
                }
            }
            .onChange(of: records) { oldValue, newValue in
                viewModel.updateAnalytics(records: newValue)
            }
            .onAppear {
                if records.isEmpty {
                    addSampleData()
                }
                viewModel.updateAnalytics(records: records)
            }
        }
    }
    
    private func addSampleData() {
        for record in Record.sampleData {
            modelContext.insert(record)
        }
    }
    
    private func handleCapturedImage(_ image: UIImage?) {
        guard let image = image else { return }
        Task {
            await processImage(image)
        }
    }
    
    private func processImage(_ image: UIImage) async {
        do {
            let result = try await viewModel.recognizeAlbum(from: image)
            await MainActor.run {
                viewModel.recognitionResult = result
                showingAddRecord = true
            }
        } catch {
            print("Error processing image: \(error)")
        }
    }
    
    private func addRecord(title: String, artist: String, releaseYear: Int?, genre: String?, notes: String?) {
        Task { @MainActor in
            let record = Record(
                title: title,
                artist: artist,
                releaseYear: releaseYear,
                genre: genre,
                notes: notes
            )
            modelContext.insert(record)
            viewModel.updateAnalytics(records: records)
        }
    }
    
    private func handleBarcodeScan(_ image: UIImage?) {
        guard let image = image else { return }
        Task {
            await viewModel.processBarcode(image)
            await MainActor.run {
                showingAddRecord = true
            }
        }
    }
    
    private func searchByBarcode(_ barcode: String) async {
        await viewModel.searchBarcode(barcode)
        await MainActor.run {
            showingAddRecord = true
        }
    }
    
    private func searchByCatNo(_ catNo: String) async {
        await MainActor.run {
            showingAddRecord = false  // 기존 시트를 닫음
        }
        await viewModel.searchCatNo(catNo)
        await MainActor.run {
            showingAddRecord = true
        }
    }
}

// MARK: - Search and Filter Components
struct SearchFilterBar: View {
    @Binding var searchText: String
    @Binding var selectedGenre: String
    @Binding var sortOption: CollectionView.SortOption
    @Binding var isGridView: Bool
    let genres: [String]
    
    var body: some View {
        VStack(spacing: 12) {
            // 검색 바
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("앨범 또는 아티스트 검색", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
            
            HStack {
                // 장르 필터
                Menu {
                    ForEach(genres, id: \.self) { genre in
                        Button(action: { selectedGenre = genre }) {
                            HStack {
                                Text(genre)
                                if selectedGenre == genre {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedGenre)
                        Image(systemName: "chevron.down")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // 정렬 옵션
                Menu {
                    ForEach(CollectionView.SortOption.allCases, id: \.self) { option in
                        Button(action: { sortOption = option }) {
                            HStack {
                                Text(option.rawValue)
                                if sortOption == option {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(sortOption.rawValue)
                        Image(systemName: "chevron.down")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
}

// MARK: - List View Component
struct RecordListItemView: View {
    let record: Record
    @State private var showingEditSheet = false
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        HStack(spacing: 16) {
            // 앨범 커버
            AsyncImageView(
                url: record.coverImageURL,
                size: CGSize(width: 60, height: 60),
                cornerRadius: 8
            )
            
            // 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(record.title)
                    .font(.headline)
                Text(record.artist)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if let genre = record.genre {
                    KolekttTag(genre, color: Color(hex: "0036FF"))
                }
            }
            
            Spacer()
            
            // 수정 버튼
            Button(action: {
                showingEditSheet = true
            }) {
                Image(systemName: "pencil.circle.fill")
                    .font(.title2)
                    .foregroundColor(Color(hex: "0036FF"))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .sheet(isPresented: $showingEditSheet) {
            EditRecordView(record: record)
        }
    }
}

struct EditRecordView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let record: Record
    
    @State private var title: String
    @State private var artist: String
    @State private var releaseYear: String
    @State private var genre: String
    @State private var notes: String
    @State private var catalogNumber: String
    @State private var label: String
    @State private var format: String
    @State private var country: String
    @State private var style: String
    @State private var condition: String
    @State private var conditionNotes: String
    
    let conditions = [
        "M": "Mint (완벽한 상태)",
        "NM": "Near Mint (거의 새것)",
        "VG+": "Very Good Plus (매우 좋음)",
        "VG": "Very Good (좋음)",
        "G+": "Good Plus (양호)",
        "G": "Good (보통)",
        "F": "Fair (나쁨)"
    ]
    
    init(record: Record) {
        self.record = record
        _title = State(initialValue: record.title)
        _artist = State(initialValue: record.artist)
        _releaseYear = State(initialValue: record.releaseYear?.description ?? "")
        _genre = State(initialValue: record.genre ?? "")
        _notes = State(initialValue: record.notes ?? "")
        _catalogNumber = State(initialValue: record.catalogNumber ?? "")
        _label = State(initialValue: record.label ?? "")
        _format = State(initialValue: record.format ?? "")
        _country = State(initialValue: record.country ?? "")
        _style = State(initialValue: record.style ?? "")
        _condition = State(initialValue: record.condition ?? "NM")
        _conditionNotes = State(initialValue: record.conditionNotes ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("기본 정보")) {
                    TextField("앨범명", text: $title)
                    TextField("아티스트", text: $artist)
                    TextField("발매년도", text: $releaseYear)
                        .keyboardType(.numberPad)
                    TextField("장르", text: $genre)
                }
                
                Section(header: Text("Discogs 메타데이터")) {
                    TextField("카탈로그 번호", text: $catalogNumber)
                    TextField("레이블", text: $label)
                    TextField("포맷", text: $format)
                    TextField("국가", text: $country)
                    TextField("스타일", text: $style)
                }
                
                Section(header: Text("레코드 상태")) {
                    Picker("상태", selection: $condition) {
                        ForEach(Array(conditions.keys.sorted()), id: \.self) { key in
                            Text("\(key) - \(conditions[key] ?? "")")
                                .tag(key)
                        }
                    }
                    
                    TextField("상태 설명", text: $conditionNotes)
                        .frame(height: 100)
                }
                
                Section(header: Text("노트")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("레코드 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        saveRecord()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveRecord() {
        record.title = title
        record.artist = artist
        record.releaseYear = Int(releaseYear)
        record.genre = genre
        record.notes = notes
        record.catalogNumber = catalogNumber
        record.label = label
        record.format = format
        record.country = country
        record.style = style
        record.condition = condition
        record.conditionNotes = conditionNotes
        record.updatedAt = Date()
        
        try? modelContext.save()
    }
}

// MARK: - Analytics Components
struct AnalyticsSection: View {
    let analytics: CollectionAnalytics?
    @State private var currentPage = 0
    
    private let cardWidth: CGFloat = UIScreen.main.bounds.width - 32
    private let cardHeight: CGFloat = 340
    
    var body: some View {
        VStack(spacing: 8) {
            if let analytics = analytics {
                TabView(selection: $currentPage) {
                    // 현황 카드
                    AnalyticCard(title: "컬렉션 현황", width: cardWidth, height: cardHeight) {
                        CollectionSummaryView(analytics: analytics)
                    }
                    .tag(0)
                    
                    // 장르 분포 카드
                    AnalyticCard(title: "장르별 분포", width: cardWidth, height: cardHeight) {
                        GenreDistributionView(genres: analytics.genres)
                    }
                    .tag(1)
                    
                    // 연도별 분포 카드
                    AnalyticCard(title: "연도별 분포", width: cardWidth, height: cardHeight) {
                        DecadeDistributionView(decades: analytics.decades)
                    }
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: cardHeight)
                
                // 페이지 인디케이터
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(currentPage == index ? primaryColor : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut, value: currentPage)
                    }
                }
            } else {
                // 빈 상태 표시
                AnalyticCard(title: "컬렉션 분석", width: cardWidth, height: cardHeight) {
                    VStack(spacing: 16) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)
                        
                        Text("컬렉션을 추가하여\n분석을 시작해보세요")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxHeight: .infinity)
                }
            }
        }
        .padding(.top, 4)
    }
}

struct AnalyticCard<Content: View>: View {
    let title: String
    let width: CGFloat
    let height: CGFloat
    let content: Content
    
    init(title: String, width: CGFloat, height: CGFloat, @ViewBuilder content: () -> Content) {
        self.title = title
        self.width = width
        self.height = height
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            
            content
                .padding(.horizontal, 20)
        }
        .frame(width: width, height: height)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

struct CollectionSummaryView: View {
    let analytics: CollectionAnalytics
    private let primaryColor = Color(hex: "0036FF")
    
    var body: some View {
        if analytics.totalRecords == 0 {
            Text("아직 레코드가 없습니다")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .frame(maxHeight: .infinity)
        } else {
            VStack(spacing: 16) {
                // 상단 통계
                HStack(spacing: 16) {
                    StatisticCard(
                        title: "총 레코드",
                        value: "\(analytics.totalRecords)장",
                        icon: "record.circle",
                        color: primaryColor
                    )
                    
                    StatisticCard(
                        title: "인기 장르",
                        value: analytics.mostCollectedGenre.isEmpty ? "없음" : analytics.mostCollectedGenre,
                        icon: "music.note",
                        color: primaryColor
                    )
                }
                
                // 하단 통계
                HStack(spacing: 16) {
                    StatisticCard(
                        title: "가장 많은 아티스트",
                        value: analytics.mostCollectedArtist.isEmpty ? "없음" : analytics.mostCollectedArtist,
                        icon: "person.2",
                        color: primaryColor
                    )
                    
                    StatisticCard(
                        title: "수집 기간",
                        value: analytics.oldestRecord == 0 ? "없음" : "\(analytics.oldestRecord) - \(analytics.newestRecord)",
                        icon: "calendar",
                        color: primaryColor
                    )
                }
            }
            .padding(.top, 8)
        }
    }
}

struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemBackground).opacity(0.5))
        .cornerRadius(12)
    }
}

struct GenreDistributionView: View {
    let genres: [GenreAnalytics]
    private let primaryColor = Color(hex: "0036FF")
    
    var body: some View {
        VStack(spacing: 16) {
            if genres.isEmpty {
                Text("아직 장르 데이터가 없습니다")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .frame(maxHeight: .infinity)
            } else {
                Chart {
                    ForEach(genres.sorted(by: { $0.count > $1.count }).prefix(6), id: \.name) { genre in
                        BarMark(
                            x: .value("Count", genre.count),
                            y: .value("Genre", genre.name == "기타" ? "미분류" : genre.name)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [primaryColor.opacity(0.8), primaryColor.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .annotation(position: .trailing, alignment: .leading) {
                            Text("\(genre.count)장")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                                .padding(.leading, 4)
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(position: .bottom) { value in
                        if let count = value.as(Int.self) {
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel {
                                Text("\(count)")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let name = value.as(String.self) {
                                Text(name)
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                .frame(height: 200)
            }
        }
        .padding(.horizontal)
    }
}

struct DecadeDistributionView: View {
    let decades: [DecadeAnalytics]
    private let primaryColor = Color(hex: "0036FF")
    
    var body: some View {
        VStack(spacing: 20) {
            Chart {
                ForEach(decades.sorted(by: { $0.decade < $1.decade }), id: \.decade) { decade in
                    BarMark(
                        x: .value("Decade", decade.decade),
                        y: .value("Count", decade.count)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [primaryColor.opacity(0.8), primaryColor.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(4)
                    .annotation(position: .top) {
                        Text("\(decade.count)장")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let decade = value.as(String.self) {
                            Text(decade)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let count = value.as(Int.self) {
                            Text("\(count)")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .frame(height: 200)
        }
        .padding(.horizontal)
    }
}

struct RecordCardView: View {
    let record: Record
    
    private let cardWidth = (UIScreen.main.bounds.width - 48) / 2
    private let imageHeight: CGFloat = 160
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 앨범 커버
            AsyncImageView(
                url: record.coverImageURL,
                size: CGSize(width: cardWidth, height: imageHeight),
                cornerRadius: 8
            )
            
            VStack(alignment: .leading, spacing: 6) {
                Text(record.title)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)
                
                Text(record.artist)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    if let year = record.releaseYear {
                        Text("\(year)")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    
                    if let genre = record.genre {
                        if record.releaseYear != nil {
                            Text("•")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        Text(genre)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
                .lineLimit(1)
            }
            .padding(.horizontal, 2)
            .padding(.vertical, 8)
        }
        .frame(width: cardWidth)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Add Record Views
struct CatNoInputView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var catNo = ""
    let onSubmit: (String) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("CatNo 입력", text: $catNo)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                } header: {
                    Text("앨범의 CatNo를 입력해주세요")
                } footer: {
                    Text("예시: 88985456371, SRCS-9198")
                }
            }
            .navigationTitle("CatNo로 검색")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("검색") {
                        onSubmit(catNo)
                        dismiss()
                    }
                    .disabled(catNo.isEmpty)
                }
            }
        }
    }
}

struct RecognitionResult {
    let title: String
    let artist: String
    let releaseYear: Int?
    let genre: String?
}

#Preview {
    CollectionView()
} 