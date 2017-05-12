//
//  ViewController.swift
//  FingerPassword
//
//  Created by 鲁志刚 on 2017/5/11.
//  Copyright © 2017年 FEBA. All rights reserved.
//

import UIKit
import QuartzCore

class FingerPasswordController: UIViewController {
    
    lazy var _circleView:UIView = UIView()
    lazy var _touchView:FingerPasswordTouchView = FingerPasswordTouchView(frame: CGRect.zero)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.addSubview(_touchView);
        _touchView.backgroundColor = UIColor.clear
        self.view.backgroundColor = UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.00)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var frame:CGRect = view.bounds
        frame.origin.x = 15
        frame.origin.y = frame.size.height * 0.4
        frame.size.height = frame.size.height - frame.origin.y
        frame.size.width = frame.size.width - frame.origin.x*2
        _touchView.frame = frame
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class FingerPasswordTouchView: UIView {
    
    lazy var circleViews:NSMutableArray = NSMutableArray()
    lazy var _lineLayer:CAShapeLayer = CAShapeLayer()
    lazy var _password:NSMutableArray = NSMutableArray()
    var _lastPoint = CGPoint.zero
    var _lastItem:FingerPasswordCircleView?

    let maxCol = 3
    let maxRow = 3
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        _lastItem = nil
        
        self.setupLineLayer()
        self.layer.addSublayer(_lineLayer)
        
        for index in 0 ..< (maxRow*maxCol) {
            let circleItem = self.defaultCircleView()
            circleItem.tag = index
            self.addSubview(circleItem)
            self.circleViews.add(circleItem)
        }
        
        let panGes = UIPanGestureRecognizer(target: self, action: #selector(panGesAction(ges:)))
        self.addGestureRecognizer(panGes)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var curCol = 0
        var curRow = 0
        let circleViewW = self.bounds.size.width / CGFloat(maxCol)
        let circleViewH = self.bounds.size.height / CGFloat(maxRow)
        let ratio = CGFloat(0.8)
        for item in self.circleViews {
            let view = item as! FingerPasswordCircleView
            curCol = view.tag % 3
            curRow = view.tag / 3
            
            var frame = CGRect.zero
            frame.size.width = circleViewW * ratio
            frame.size.height = circleViewH * ratio
            frame.origin.x = CGFloat(circleViewW * CGFloat(curRow)) + circleViewW * CGFloat((1.0-ratio)/2.0)
            frame.origin.y = CGFloat(circleViewH * CGFloat(curCol)) + circleViewH * CGFloat((1.0-ratio)/2.0)
            view.frame = frame
        }
        _lineLayer.frame = self.bounds
    }
    
    func setupLineLayer() {
        _lineLayer.fillColor = UIColor(red: 221.0/255.0, green: 221.0/255.0, blue: 221.0/255.0, alpha: 1.000).cgColor
        _lineLayer.lineWidth = 1
        _lineLayer.strokeColor = _lineLayer.fillColor
        _lineLayer.path = UIBezierPath().cgPath
    }
    
    func panGesAction(ges:UIPanGestureRecognizer) {
        let point = ges.location(in: self)
        switch ges.state {
            case UIGestureRecognizerState.began:
                
                for item in self.circleViews {
                    let subItem = item as! FingerPasswordCircleView
                    if subItem.frame.contains(point) {
                        subItem.highlighted = true
                        _lastPoint = subItem.center
                        _lastItem = subItem
                        _password.add("\(subItem.tag)")
                        break;
                    }
                }
                
            break
            case UIGestureRecognizerState.changed:
                var startPoint:CGPoint = CGPoint.zero
                var founded = false
                for item in self.circleViews {
                    let subItem = item as! FingerPasswordCircleView
                    if subItem.frame.contains(point) {
                        startPoint = subItem.center
                        if _lastItem != subItem && subItem.highlighted == false {
                            founded = true
                            _lastItem = subItem
                            _password.add("\(subItem.tag)")
                        }
                        subItem.highlighted = true
                        
                        if _lastPoint.equalTo(CGPoint.zero) {
                            _lastPoint = startPoint
                        }
                        
                        break;
                    }
                }
                
                if founded && _lastPoint.equalTo(startPoint) == false {
                    //// Bezier Drawing
                    let bezierPath = UIBezierPath(cgPath: _lineLayer.path!)
                    bezierPath.move(to: _lastPoint)
                    bezierPath.addLine(to: startPoint)
                    UIColor.black.setStroke()
                    bezierPath.lineWidth = 1
                    bezierPath.stroke()
                    _lastPoint = startPoint
                    _lineLayer.path = bezierPath.cgPath
                }
            break
            case UIGestureRecognizerState.ended:
                self.isUserInteractionEnabled = false
                for item in self.circleViews {
                    let subItem = item as! FingerPasswordCircleView
                    if subItem.highlighted! {
                        subItem .setRed(red: true)
                    }
                }
                
                self._lineLayer.strokeColor = UIColor.red.cgColor
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self._password.removeAllObjects()
                    self._lastItem = nil
                    self._lastPoint = CGPoint.zero
                    self._lineLayer.path = UIBezierPath().cgPath
                    for item in self.circleViews {
                        let subItem = item as! FingerPasswordCircleView
                        subItem.highlighted = false
                        self.isUserInteractionEnabled = true
                    }
                    self.setupLineLayer()
                }
                
                print("hello \(_password)")    //  方式2: \( ) :括号中为定义好的变量或常量
            break
            default:
                
            break
        }
    }
    
    func defaultCircleView() -> FingerPasswordCircleView {
        let circleView:FingerPasswordCircleView = FingerPasswordCircleView(frame: CGRect.zero)
        return circleView;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class FingerPasswordCircleView: UIView {
    
    var _highlighted:Bool?
        var highlighted:Bool?{
        get{
            return _highlighted;
        }
        set{
            _highlighted = newValue
            _dotView.isHidden = !newValue!
            
            if newValue! {
                let _ffffff = UIColor(red: 221.0/255.0, green: 221.0/255.0, blue: 221.0/255.0, alpha: 1.000)
                _circleShapeLayer.strokeColor = _ffffff.cgColor
            }else{
                let _808080 = UIColor(red: 0.502, green: 0.502, blue: 0.502, alpha: 1.000)
                _circleShapeLayer.strokeColor = _808080.cgColor
                _dotView.backgroundColor = UIColor(red:0.33, green:0.33, blue:0.33, alpha:1.00)
            }
        }
    }
    
    lazy var _circleShapeLayer:CAShapeLayer = CAShapeLayer()
    lazy var _dotView:UIView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.backgroundColor = UIColor.clear
        self.layer.addSublayer(_circleShapeLayer)
        _circleShapeLayer.fillColor = UIColor.clear.cgColor
        
        _dotView.layer.masksToBounds = true
        _dotView.isHidden = true
        self.addSubview(_dotView)
        
        highlighted = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //// Color Declarations
        _circleShapeLayer.frame = self.bounds;
        
        _dotView.frame = CGRect(origin: CGPoint(x: self.frame.size.width*0.5-_dotView.frame.size.width*0.5, y: self.frame.size.height*0.5-_dotView.frame.size.height*0.5), size: CGSize(width: self.bounds.size.width*0.3, height: self.bounds.size.width*0.3))
        _dotView.layer.cornerRadius = _dotView.frame.size.width*0.5
        
        let WH = CGFloat(min(self.bounds.size.width, self.bounds.size.height, 100))
        
        if _highlighted! {
            
            //// Oval Drawing
            let ovalPath = UIBezierPath(ovalIn: CGRect(x: self.bounds.size.width*0.5-WH*0.5, y: self.bounds.size.height*0.5-WH*0.5, width:WH , height: WH))
            ovalPath.lineWidth = 1
            ovalPath.stroke()
            _circleShapeLayer.path = ovalPath.cgPath
        }else{
            
            //// Oval Drawing
            let ovalPath = UIBezierPath(ovalIn: CGRect(x: self.bounds.size.width*0.5-WH*0.5, y: self.bounds.size.height*0.5-WH*0.5, width:WH , height: WH))
            ovalPath.lineWidth = 1
            ovalPath.stroke()
            _circleShapeLayer.path = ovalPath.cgPath
        }
    }
    
    func setRed(red:Bool) {
        if red {
            self._circleShapeLayer.strokeColor = UIColor.red.cgColor
            self._dotView.backgroundColor = UIColor.red
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
