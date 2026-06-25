import CoreLocation
import MapKit
import SwiftUI

@MainActor
final class MapViewModel: ObservableObject {
    @Published var cameraPosition: MapCameraPosition
    @Published var places: [PlaceAnnotationItem] = []
    @Published var routeCoordinates: [CLLocationCoordinate2D] = []
    @Published var is3DEnabled = false
    @Published var presentedError: IdentifiableError?

    private let mapRepository: MapRepository
    private let locationProvider: UserLocationProvider
    private var hasCenteredOnUser = false

    /// Falls back to a fixed coordinate until real location arrives, so the map is never empty in
    /// a simulator without a simulated location set, or before permission is granted.
    private let fallbackCoordinate = Coordinate(latitude: 37.7749, longitude: -122.4194)

    init(mapRepository: MapRepository, locationProvider: UserLocationProvider) {
        self.mapRepository = mapRepository
        self.locationProvider = locationProvider
        let initialCoordinate = locationProvider.currentCoordinate ?? fallbackCoordinate
        self.cameraPosition = .camera(
            MapCamera(centerCoordinate: initialCoordinate.clLocationCoordinate, distance: 1200, heading: 0, pitch: 0)
        )
    }

    func onAppear() {
        locationProvider.requestWhenInUseAuthorization()
        locationProvider.startUpdatingLocation()
        Task { await observeLocationUpdates() }
        Task { await loadPlaces(around: locationProvider.currentCoordinate ?? fallbackCoordinate) }
    }

    private func observeLocationUpdates() async {
        for await coordinate in locationProvider.locationUpdates {
            if !hasCenteredOnUser {
                hasCenteredOnUser = true
                centerCamera(on: coordinate)
                await loadPlaces(around: coordinate)
            }
        }
    }

    private func loadPlaces(around coordinate: Coordinate) async {
        do {
            places = try await mapRepository.fetchNearbyPlaces(around: coordinate, radiusMeters: 1500)
            if let firstPlace = places.first {
                let route = try await mapRepository.fetchRoute(from: coordinate, to: firstPlace.coordinate)
                routeCoordinates = route.map(\.clLocationCoordinate)
            }
        } catch {
            presentedError = IdentifiableError(underlyingError: error)
        }
    }

    func recenterOnUser() {
        guard let coordinate = locationProvider.currentCoordinate else { return }
        centerCamera(on: coordinate)
    }

    /// Toggles between a flat top-down view and a pitched "3D" perspective by animating the
    /// camera's pitch/heading/distance together — this is what gives the illusion of a 3D map.
    func toggle3DPerspective() {
        is3DEnabled.toggle()
        let coordinate = locationProvider.currentCoordinate ?? fallbackCoordinate
        centerCamera(on: coordinate)
    }

    private func centerCamera(on coordinate: Coordinate) {
        withAnimation(.easeInOut(duration: 0.6)) {
            cameraPosition = .camera(
                MapCamera(
                    centerCoordinate: coordinate.clLocationCoordinate,
                    distance: is3DEnabled ? 600 : 1200,
                    heading: is3DEnabled ? 45 : 0,
                    pitch: is3DEnabled ? 60 : 0
                )
            )
        }
    }
}

extension Coordinate {
    var clLocationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
