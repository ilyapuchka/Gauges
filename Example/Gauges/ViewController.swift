//
//  ViewController.swift
//  Gauges
//
//  Created by Ilya Puchka on 19/12/2017.
//  Copyright © 2018 Ilya Puchka. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @objc @IBAction func valueChanged(_ slider: UISlider) {
        gaugeView.gauges[0].value = slider.value
        gaugeView.gauges[1].value = slider.value
        gaugeView.gauges[2].value = slider.value
    }

    @objc @IBAction func sizeChanged(_ slider: UISlider) {
        gaugeView.frame.size = CGSize(width: 120 + CGFloat(slider.value) * 240, height: 120 + CGFloat(slider.value) * 240)
        gaugeView.invalidateIntrinsicContentSize()
    }
    
    @objc @IBAction func radiusChanged(_ slider: UISlider) {
        gaugeView.gauges[0].radius = 60 + CGFloat(slider.value) * 60
        gaugeView.gauges[1].radius = 90 + CGFloat(slider.value) * 90
        gaugeView.gauges[1].radius = 120 + CGFloat(slider.value) * 120
        gaugeView.sizeToFit()
    }

    @objc @IBAction func shadowOffsetChanged(_ slider: UISlider) {
        gaugeView.shadow.offset = CGSize(width: CGFloat(slider.value) * 30, height: CGFloat(slider.value) * 30)
    }

    @objc @IBAction func shadowRadiusChanged(_ slider: UISlider) {
        gaugeView.shadow.opacity = 1 - CGFloat(slider.value)
    }

    @objc @IBAction func lineWidthChanged(_ slider: UISlider) {
        gaugeView.gauges[0].lineWidth = 15 + 20 * CGFloat(slider.value)
        gaugeView.gauges[1].lineWidth = 15 + 20 * CGFloat(slider.value)
        gaugeView.gauges[2].lineWidth = 15 + 20 * CGFloat(slider.value)
    }

    @IBOutlet weak var gaugeView: GaugeView! {
        didSet {
            gaugeView.gauges = [
                Gauge(value: 0, color: .gradient([(.yellow, 0), (.orange, 1)]), radius: 60, lineWidth: 15),
                Gauge(value: 0, color: .gradient([(.cyan, 0), (.green, 1)]), radius: 90, lineWidth: 15),
                Gauge(value: 0, color: .gradient([(.blue, 0), (.magenta, 1)]), radius: 120, lineWidth: 15)
            ]
            gaugeView.shadow = Shadow(color: .blur)
//            gaugeView.gauges = [
//                Gauge(value: 0, color: .solid(.orange), radius: 60, lineWidth: 15),
//                Gauge(value: 0, color: .solid(.green), radius: 90, lineWidth: 15),
//                Gauge(value: 0, color: .solid(.magenta), radius: 120, lineWidth: 15)
//            ]
//            gaugeView.shadow = Shadow(color: .colors([.orange, .green, .magenta]))
        }
    }

}
