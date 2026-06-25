import Foundation

enum PlaceCategory: String, Codable, CaseIterable {
    case office
    case partner
    case pointOfInterest
}

struct PlaceAnnotationItem: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let coordinate: Coordinate
    let category: PlaceCategory
}
