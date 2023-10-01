//
//  NewMapView.swift
//  Zipadoo
//
//  Created by 김상규 on 10/1/23.
//

import SwiftUI
import MapKit

// MARK: - 검색 기능을 통해 장소 설정할 수 있는 옵션의 맵뷰
/// 현재 MapView와 NewMapView 간의 버전이 서로 다르기 때문에 우선 두가지 옵션을 선택할 수 있도록 구현
/// 두가지 기능을 합칠 수 있는 방법을 찾을 경우 도입 시도해볼 예정
struct NewMapView: View {
    @Namespace var mapScope

    @ObservedObject var searchOfKakaoLocal: SearchOfKakaoLocal = SearchOfKakaoLocal.sharedInstance
    @State var userPosition: MapCameraPosition = .automatic
    @State var camerBounds: MapCameraBounds = MapCameraBounds()
    @State var selectedPlacePosition: CLLocationCoordinate2D?
    @State var placeName: String = ""
    @State var searching: Bool = true
    @Binding var isClickedPlace: Bool
    @Binding var addLocationButton: Bool
    @Binding var promiseLocation: PromiseLocation

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Map(position: $userPosition, bounds: camerBounds, scope: mapScope) {
                    if isClickedPlace == true {
                        Annotation(placeName, coordinate: selectedPlacePosition ?? CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)) {
                            AnnotationCell()
                        }
                        UserAnnotation()
                        
                    } else {
                        UserAnnotation()
                    }
                }
                if isClickedPlace == true {
                    AddPlaceButtonCell(isClickedPlace: $isClickedPlace, addLocationButton: $addLocationButton, promiseLocation: promiseLocation)
                        .padding(.bottom, 40)
                } else {
                    
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()
                    SearchBarCell(isClickedPlace: $isClickedPlace, placeName: $placeName, selectedPlacePosition: $selectedPlacePosition, promiseLocation: $promiseLocation)
                    Spacer()
                }
                .background(.ultraThinMaterial)
            }
            .mapControls {
                MapUserLocationButton(scope: mapScope)
                    .mapControlVisibility(.visible)
                MapPitchToggle(scope: mapScope)
                    .mapControlVisibility(.visible)
                MapCompass(scope: mapScope)
                    .mapControlVisibility(.visible)
            }
            .onChange(of: userPosition) { newValue in
                userPosition = newValue
            }
        }
        .onMapCameraChange(frequency: .continuous) {
            userPosition = .userLocation(followsHeading: true, fallback: .automatic)
            
            // transform() 함수 호출을 제거하고 selectedPlacePosition을 직접 갱신
            if isClickedPlace == true {
                selectedPlacePosition = CLLocationCoordinate2D(latitude: promiseLocation.latitude, longitude: promiseLocation.longitude)
                userPosition = .region(.init(center: selectedPlacePosition ??  CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780), latitudinalMeters: 1000, longitudinalMeters: 1000))
                camerBounds = .init(centerCoordinateBounds: MKCoordinateRegion(center: selectedPlacePosition ??  CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780), latitudinalMeters: .infinity, longitudinalMeters: .infinity))
                print("이동된 카메라 위도: \(promiseLocation.latitude)")
                print("이동된 카메라 경도: \(promiseLocation.longitude)")
                print("이동 성공")
            } else {
                userPosition = .region(.init(center: selectedPlacePosition ??  CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780), latitudinalMeters: 1000, longitudinalMeters: 1000))
            }
        }
    }
}

#Preview {
    NewMapView(isClickedPlace: .constant(false), addLocationButton: .constant(false), promiseLocation: .constant(PromiseLocation(latitude: 37.5665, longitude: 126.9780, address: "서울시청")))
}
