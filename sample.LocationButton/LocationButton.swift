//
//  LocationButton.swift
//
//  Created by 飯塚俊英 on 2019/11/02.
//  Copyright © 2019 bakapple.computer. All rights reserved.
//

//自動的に精度の高い位置情報を取得しつつ
//簡単実装で必要な情報が取得できるプログラム

import UIKit
import CoreLocation

class LocationButton: UIButton, CLLocationManagerDelegate {
    
    var delegate: LocationButtonDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //アニメーションボタンセットアップ
        buttonsetup()
    }
    
    func buttonsetup() {
        //角丸
        self.layer.cornerRadius = 20
        self.clipsToBounds = true
        
        //アクション追加
        self.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
    }
    
    @IBAction func buttonAction(_ button: UIButton) {
        
        //ボタンを押すまで位置情報オブジェクトに触れない
        
        //location
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse {
            locationManager.distanceFilter = 10
            locationManager.startUpdatingLocation()
            
            //ユーザ操作を無効化
            button.isUserInteractionEnabled = false
            button.alpha = 0.5
        }
    }

    //位置情報
    var locationManager: CLLocationManager!
    private var deferringUpdates = false//デバイスが位置情報の遅延更新に対応しているか
    
    private var updatecount = 0//メソッドが呼ばれたカウンター
    private var lcount = 0//位置情報取得リセットカウンター
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var accuracy: Double = 9999.0
    var address = ""
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        updatecount = updatecount + 1
        
        for location in locations {
            let _latitude = location.coordinate.latitude
            let _longitude = location.coordinate.longitude
            let _accuracy = location.horizontalAccuracy
            if ( Double(_accuracy) < Double(accuracy) || latitude + longitude == 0 ) {
                latitude = _latitude
                longitude = _longitude
                accuracy = _accuracy
                
                //Delegate呼び出し
                updateLocation(location: location)
            }
        }
        
        lcount = lcount + 1
        if ( lcount >= 3 ) {
            resetLocation()
        }
    }
    
    func updateLocation(location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil,
            let administrativeArea = placemark.administrativeArea, // 都道府県
            let locality = placemark.locality, // 市区町村
            let thoroughfare = placemark.thoroughfare, // 地名(丁目)
            let subThoroughfare = placemark.subThoroughfare, // 番地
            let postalCode = placemark.postalCode, // 郵便番号
            let location = placemark.location // 緯度経度情報
            else {
                return
            }
            
            self.address = """
            〒\(postalCode)
            \(administrativeArea)\(locality)\(thoroughfare)\(subThoroughfare)
            \(location.coordinate.latitude), \(location.coordinate.longitude)
            """
            
            self.isUserInteractionEnabled = true
            self.alpha = 1.0
            
            //ボタンに郵便番号を表示する
            self.setTitle(self.address, for: .normal)
            
            /*
            //Log
            print("--------------------")
            print(">>>update ")
            print(" latitude: " + String(_latitude) + " \n longitude: " + String(_longitude) )
            print("""
                〒\(postalCode)
                \(administrativeArea)\(locality)\(thoroughfare)\(subThoroughfare)
                \(location.coordinate.latitude), \(location.coordinate.longitude)
                """)
            print("--------------------")
            */
            
            //delegate
            self.delegate?.updateaddress(location:location, address: self.address)
        }
    }
    
    func resetLocation() {
        
        locationManager.stopUpdatingLocation()
        lcount = 0
        accuracy = 9999.0
        
    }
}

protocol LocationButtonDelegate {
    func updateaddress(location: CLLocation, address:String)
}

