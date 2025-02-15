import Foundation

struct Seller: Identifiable {
    let id: UUID
    let name: String
    let location: String
    let rating: Double
    let profileImageURL: String?
    let description: String?
    let contactInfo: String
    
    init(id: UUID = UUID(), 
         name: String, 
         location: String, 
         rating: Double, 
         profileImageURL: String? = nil, 
         description: String? = nil, 
         contactInfo: String) {
        self.id = id
        self.name = name
        self.location = location
        self.rating = rating
        self.profileImageURL = profileImageURL
        self.description = description
        self.contactInfo = contactInfo
    }
}
