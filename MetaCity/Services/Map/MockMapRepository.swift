import Foundation

/// Generates plausible-looking nearby places and a route polyline around any coordinate, so the
/// Map screen has real-looking data to render without a backend. Swap for a real places/directions
/// API later behind the same `MapRepository` protocol — see the architecture notes for swap points.
final class MockMapRepository: MapRepository {
    func fetchNearbyPlaces(around coordinate: Coordinate, radiusMeters: Double) async throws -> [PlaceAnnotationItem] {
        try await Task.sleep(nanoseconds: 300_000_000)
        let offsets: [(latOffset: Double, lonOffset: Double, title: String, subtitle: String, category: PlaceCategory)] = [
            (0.004, 0.003, "MetaCity HQ", "Where the team works", .office),
            (-0.003, 0.005, "Partner Studio", "Design partner", .partner),
            (0.002, -0.004, "Coffee Lab", "Great espresso", .pointOfInterest),
            (-0.005, -0.002, "Launch Park", "Demo day venue", .pointOfInterest)
        ]
        return offsets.map { offset in
            PlaceAnnotationItem(
                id: UUID().uuidString,
                title: offset.title,
                subtitle: offset.subtitle,
                coordinate: Coordinate(
                    latitude: coordinate.latitude + offset.latOffset,
                    longitude: coordinate.longitude + offset.lonOffset
                ),
                category: offset.category
            )
        }
    }

    func fetchRoute(from start: Coordinate, to end: Coordinate) async throws -> [Coordinate] {
        try await Task.sleep(nanoseconds: 200_000_000)
        let steps = 12
        return (0...steps).map { step in
            let fraction = Double(step) / Double(steps)
            // A gentle sine curve rather than a straight line, just to demonstrate a non-trivial polyline overlay.
            let curveOffset = sin(fraction * .pi) * 0.0015
            return Coordinate(
                latitude: start.latitude + (end.latitude - start.latitude) * fraction + curveOffset,
                longitude: start.longitude + (end.longitude - start.longitude) * fraction
            )
        }
    }
}
