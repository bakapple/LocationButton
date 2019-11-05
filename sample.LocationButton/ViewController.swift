//
//  ViewController.swift
//  sample.LocationButton
//
//  Created by 飯塚俊英 on 2019/11/05.
//  Copyright © 2019 bakapple.computer. All rights reserved.
//

//LocationButton簡単実装サンプル
//1: UIViewControllerへLocationButtonDelegateのセット
//2: StoryBoardへLocationButtonを配置してlocationButtonへ接続
//3: delegateへself設定
//4: updateaddress(location: CLLocation, address:String)実装

import UIKit
import MapKit

class ViewController: UIViewController, LocationButtonDelegate//<--1: LocationButtonDelegate実装
{

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationButton: LocationButton!//<--2: LocationButtonDelegate実装
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationButton.delegate = self//<--3: LocationButtonDelegate実装
    }
    
    //ボタンから取得されたLocation情報、住所が送信されてくる<--4: LocationButtonDelegate実装
    func updateaddress(location: CLLocation, address:String) {
        // 現在地を拡大して表示する
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.region = region
        
        //ピンの生成
        let point = MKPointAnnotation()
        point.coordinate = location.coordinate
        point.title = "Now"
        point.subtitle = address
        mapView.addAnnotation(point)
        
         //Log
         print("--------------------")
         print(">>>update ")
         print(" latitude: " + String(location.coordinate.latitude) + " \n longitude: " + String(location.coordinate.longitude) )
         print(" address: " + address)
         print("--------------------")
    }
}

