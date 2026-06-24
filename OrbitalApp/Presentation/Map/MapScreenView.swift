import MapKit
import SwiftUI

struct MapScreenView: View {
    @ObservedObject var viewModel: MapViewModel

    var body: some View {
        NavigationStack {
            Map(position: $viewModel.cameraPosition) {
                UserAnnotation()

                ForEach(viewModel.places) { place in
                    Annotation(place.title, coordinate: place.coordinate.clLocationCoordinate) {
                        PlaceMarkerView(category: place.category)
                    }
                }

                if viewModel.routeCoordinates.count > 1 {
                    // Simple polyline overlay connecting the user to a nearby place — stand-in for
                    // turn-by-turn directions from a real routing API.
                    MapPolyline(coordinates: viewModel.routeCoordinates)
                        .stroke(Color.orbitalPrimary, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                }
            }
            // Pairing realistic elevation with a pitched MapCamera (see MapViewModel) is what
            // gives the "3D map" effect requested in the brief.
            .mapStyle(.standard(elevation: viewModel.is3DEnabled ? .realistic : .flat))
            .mapControls {
                MapCompass()
                MapScaleView()
            }
            .overlay(alignment: .bottomTrailing) {
                VStack(spacing: 12) {
                    MapControlButton(systemImage: "location.fill") {
                        viewModel.recenterOnUser()
                    }
                    MapControlButton(systemImage: viewModel.is3DEnabled ? "view.2d" : "view.3d") {
                        viewModel.toggle3DPerspective()
                    }
                }
                .padding(20)
            }
            .navigationTitle("Map")
            .task { viewModel.onAppear() }
            .errorAlert($viewModel.presentedError)
        }
    }
}

private struct PlaceMarkerView: View {
    let category: PlaceCategory

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(.white)
            .padding(8)
            .background(Circle().fill(color))
            .shadow(radius: 2)
    }

    private var systemImage: String {
        switch category {
        case .office: return "building.2.fill"
        case .partner: return "person.2.fill"
        case .pointOfInterest: return "star.fill"
        }
    }

    private var color: Color {
        switch category {
        case .office: return .orbitalPrimary
        case .partner: return .orbitalSecondary
        case .pointOfInterest: return .orbitalWarning
        }
    }
}

private struct MapControlButton: View {
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.orbitalTextPrimary)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.orbitalSurface))
                .shadow(radius: 3)
        }
    }
}

#Preview {
    MapScreenView(viewModel: MapViewModel(mapRepository: MockMapRepository(), locationProvider: CoreLocationProvider()))
}
