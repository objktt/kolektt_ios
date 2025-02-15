import Foundation
import Vision
import VisionKit
import UIKit

protocol RecordRecognitionService {
    func recognizeAlbum(from image: UIImage) async throws -> RecordRecognitionResult
}

struct RecordRecognitionResult {
    let title: String
    let artist: String
    let releaseYear: Int?
    let genre: String?
    let confidence: Float
}

class DefaultRecordRecognitionService: RecordRecognitionService {
    func recognizeAlbum(from image: UIImage) async throws -> RecordRecognitionResult {
        guard let cgImage = image.cgImage else {
            throw RecognitionError.invalidImage
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let textRequest = VNRecognizeTextRequest()
        
        // Vision 요청을 비동기적으로 실행
        return try await withCheckedThrowingContinuation { continuation in
            do {
                try requestHandler.perform([textRequest])
                
                guard let observations = textRequest.results else {
                    continuation.resume(throwing: RecognitionError.noResultsFound)
                    return
                }
                
                let recognizedText = observations.compactMap { $0.topCandidates(1).first?.string }
                
                let result = RecordRecognitionResult(
                    title: recognizedText.first ?? "Unknown Album",
                    artist: recognizedText.count > 1 ? recognizedText[1] : "Unknown Artist",
                    releaseYear: nil,
                    genre: nil,
                    confidence: 0.8
                )
                
                continuation.resume(returning: result)
            } catch {
                continuation.resume(throwing: RecognitionError.processingError)
            }
        }
    }
}

enum RecognitionError: Error {
    case invalidImage
    case noResultsFound
    case processingError
} 