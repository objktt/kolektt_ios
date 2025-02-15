import Foundation

struct SaleRecord: Identifiable {
    let id: UUID
    let record: Record
    let price: Int
    let saleDate: Date
    
    init(id: UUID = UUID(), record: Record, price: Int, saleDate: Date) {
        self.id = id
        self.record = record
        self.price = price
        self.saleDate = saleDate
    }
}

extension SaleRecord {
    static var sampleData: [SaleRecord] {
        guard let record = Record.sampleData.first else { return [] }
        
        let calendar = Calendar.current
        let now = Date()
        
        return [
            SaleRecord(record: record, price: 35000, saleDate: now),
            SaleRecord(record: record, price: 42000, saleDate: calendar.date(byAdding: .day, value: -2, to: now) ?? now),
            SaleRecord(record: record, price: 28000, saleDate: calendar.date(byAdding: .day, value: -5, to: now) ?? now),
            SaleRecord(record: record, price: 50000, saleDate: calendar.date(byAdding: .day, value: -10, to: now) ?? now),
            SaleRecord(record: record, price: 45000, saleDate: calendar.date(byAdding: .month, value: -1, to: now) ?? now)
        ]
    }
} 