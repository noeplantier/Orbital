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
                            .accessibilityLabel(place.title)
                    }
                }

                if viewModel.routeCoordinates.count > 1 {
                    // Simple polyline overlay connecting the user to a nearby place — stand-in for
                    // turn-by-turn directions from a real routing API.
                    MapPolyline(coordinates: viewModel.routeCoordinates)
                        .stroke(Color.metacityPrimary, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
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
                VStack(spacing: Spacing.md) {
                    IconButton(systemImage: "location.fill", accessibilityLabel: "Center on my location") {
                        viewModel.recenterOnUser()
                    }
                    IconButton(
                        systemImage: viewModel.is3DEnabled ? "view.2d" : "view.3d",
                        accessibilityLabel: viewModel.is3DEnabled ? "Switch to 2D view" : "Switch to 3D view"
                    ) {
                        viewModel.toggle3DPerspective()
                    }
                }
                .padding(Spacing.xl)
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
        Image(systemName: category.systemImage)
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(.white)
            .padding(Spacing.sm)
            .background(category.tintColor, in: Circle())
            .elevation(.soft)
    }
}

#Preview {
    MapScreenView(viewModel: MapViewModel(mapRepository: MockMapRepository(), locationProvider: CoreLocationProvider()))
}
