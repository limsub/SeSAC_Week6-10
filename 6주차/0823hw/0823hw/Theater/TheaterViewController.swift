//
//  TheaterViewController.swift
//  0823hw
//
//  Created by 임승섭 on 2023/08/23.
//

import UIKit
import CoreLocation
import MapKit
import SnapKit



// 8/23 hw


class TheaterViewController: UIViewController {
    
    
    // location 버튼
    // filter 버튼 (actionsheet)
    // mapView
    
    
    let locationManager = CLLocationManager()
    
    let mapView = MKMapView()
    let locationButton = {
        let button = UIButton()
        
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        
        return button
    }()
    let filterButton = {
        let button = UIButton()
        
        button.setTitle("Filter", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        
        
        
        return button
    }()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 화면 디자인
        view.backgroundColor = .white
        [mapView, locationButton, filterButton].forEach { item in
            view.addSubview(item)
        }
        setLayout()
        
        // 프로토콜 연결
        mapView.delegate = self
        locationManager.delegate = self

        
        // 시작
        checkDeviceLocationAuthorization()
    }
    
    
    func setLayout() {
        mapView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.bottom.equalTo(view)
        }
        locationButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.size.equalTo(40)
        }
        filterButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.height.equalTo(40)
        }
    }
}


// 커스텀 함수 선언
extension TheaterViewController {
    
    // 권한 설정 여부
    func checkDeviceLocationAuthorization() {
        
        DispatchQueue.global().async {
            
            // 기기의 권한 설정 여부
            if (CLLocationManager.locationServicesEnabled()) {
                
                let authorization: CLAuthorizationStatus
                
                // 사용자의 권한 설정 여부
                if #available(iOS 14.0, *) {
                    authorization = self.locationManager.authorizationStatus
                } else {
                    authorization = CLLocationManager.authorizationStatus()
                }
                
                
                
                DispatchQueue.main.async {
                    self.checkCurrentLocationAuthorization(status: authorization)
                }
                
                
            }
            else {
                print("기기의 위치 서비스가 꺼져 있습니다. 권한 요청이 불가합니다")
            }
        }
    }
    
        
    // 사용자의 권한에 따라 동작
    func checkCurrentLocationAuthorization(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("권한 상태 : notdetermined")
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("restriced")
        case .denied:
            print("권한 상태 : denied")
            showLocationSettingAlert()
        case .authorizedAlways:
            print("authorizedAlways")
        case .authorizedWhenInUse:
            print("권한 상태 : authorizedWhenInUse")
            locationManager.startUpdatingLocation()
        case .authorized:
            print("authorized")
        @unknown default:
            print("default")
        }
    }
    
    
    // 화면 전환 및 어노테이션 찍기 (아마 과제에서는 어노테이션은 필요 없다)
    func setRegionAndAnnotation(center: CLLocationCoordinate2D) {
        
        let region = MKCoordinateRegion(
            center: center,
            latitudinalMeters: 100,
            longitudinalMeters: 100
        )
        mapView.setRegion(region, animated: true)
    
        let annotation = MKPointAnnotation()
        annotation.title = "현재 위치입니다"
        annotation.coordinate = center
        
        mapView.addAnnotation(annotation)
    }
    
    
    
    // 권한이 거부되었을 때, 설정 창으로 유도하는 alert
    func showLocationSettingAlert() {
        
        let requestLocationServiceAlert = UIAlertController(
            title: "위치 정보 이용",
            message: "위치 서비스를 사용할 수 없습니다. 기기의 '설정>개인정보 보호'에서 위치 서비스를 켜주세요",
            preferredStyle: .alert
        )
        
        let goSetting = UIAlertAction(title: "설정으로 이동", style: .destructive) { _ in
            // 설정 창으로 이동
            if let appSetting = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSetting)
            }
        }
        
        let cancel = UIAlertAction(title: "취소", style: .default)
        
        requestLocationServiceAlert.addAction(cancel)
        requestLocationServiceAlert.addAction(goSetting)
        
        present(requestLocationServiceAlert, animated: true, completion: nil)
    }
}


// location 함수 선언
extension TheaterViewController: CLLocationManagerDelegate {
    
    // 사용자 위치를 성공적으로 받아옴
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let coordinate = locations.last?.coordinate {    // 실질적으로 사용자의 위치가 저장되는 곳?
            print("현재 위도경도 : ", coordinate)
            
            setRegionAndAnnotation(center: coordinate)
        }
        
        locationManager.stopUpdatingLocation()
    }
    
    
    // 사용자 위치를 가져오는 데 실패함
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("사용자 위치를 불러오는 것을 실패하였습니다")
    }
    
    
    // 사용자의 권한 상태가 바뀔 때를 알려줌
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print(#function)
        
        // 권한을 다시 체크
        checkDeviceLocationAuthorization()
    }
    
}


// map 함수 선언
extension TheaterViewController: MKMapViewDelegate {
    
    // 지도 움직이다 멈춘다
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("화면이 움직였습니다")
    }
}
