//
//  MapController.swift
//  UltraCore
//
//  Created by Slam on 7/26/23.
//

import UIKit
import MapKit

class MapController: BaseViewController<String>, MKMapViewDelegate {
    
    var locationMessage: LocationMessage?
    
    var locationCallback:((LocationMessage) -> Void)?
    
    fileprivate let mapView: MKMapView = .init()
    fileprivate let locationManager = CLLocationManager()

    fileprivate lazy var closeButton: UIButton = .init({[weak self] button in
        
        button.cornerRadius = 24
        button.backgroundColor = .white
        button.setImage(UIImage.named("icon_close"), for: .normal)
        button.addAction {[weak self] in
            self?.dismiss(animated: true)
        }
    })
    
    fileprivate lazy var nextButton: ElevatedButton = .init({[weak self] button in
        button.setTitle("Отправить", for: .normal)
        button.backgroundColor = .green500
        button.addAction {[weak self] in
            guard let `self` = self, let locationMessage = self.locationMessage else { return }
            self.dismiss(animated: true, completion: { self.locationCallback?(locationMessage) })
        }
    })
    
    override func setupViews() {
        super.setupViews()
        self.mapView.delegate = self
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.mapView.addGestureRecognizer(tapGesture)
        
        self.view.addSubview(mapView)
        self.mapView.addSubview(closeButton)
        self.mapView.addSubview(nextButton)
        
    }
    
    override func setupConstraints() {
        super.setupConstraints()

        self.mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.closeButton.snp.makeConstraints { make in
            make.height.width.equalTo(48)
            make.top.equalToSuperview().offset(kMediumPadding)
            make.right.equalToSuperview().offset(-kMediumPadding)
        }

        self.nextButton.snp.makeConstraints { make in
            make.height.equalTo(kMediumPadding * 3)
            make.left.equalToSuperview().offset(kMediumPadding)
            make.right.equalToSuperview().offset(-kMediumPadding)
            make.bottom.equalToSuperview().offset(-kHeadlinePadding)
        }
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let locationInView = gesture.location(in: mapView)
        let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
        self.update(by: locationOnMap)
        self.nextButton.isEnabled = true
    }
}

extension MapController: CLLocationManagerDelegate {
    
    func update(by coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = coordinate
        self.mapView.removeAnnotations(mapView.annotations)
        self.mapView.addAnnotation(annotation)
        
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        self.locationMessage = .with({
            $0.lat = coordinate.latitude
            $0.lon = coordinate.longitude
        })
        geocoder.reverseGeocodeLocation(location) { placemarks, error in

            guard let placemark = placemarks?.first else {
                print("Адрес не найден")
                return
            }

            let address = [placemark.thoroughfare, placemark.subThoroughfare, placemark.locality, placemark.administrativeArea, placemark.country].compactMap({$0}).joined(separator: " ")
            
            self.locationMessage = .with({
                $0.desc = address
                $0.lat = coordinate.latitude
                $0.lon = coordinate.longitude
            })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            manager.startUpdatingLocation()
        default: break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let userLocation = locations.last {
            let userCoordinate = userLocation.coordinate
            let region = MKCoordinateRegion(center: userCoordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            self.mapView.setRegion(region, animated: true)
            
            self.update(by: userCoordinate)
            self.nextButton.isEnabled = true
            self.locationManager.stopUpdatingLocation()
            
        }
    }
}
