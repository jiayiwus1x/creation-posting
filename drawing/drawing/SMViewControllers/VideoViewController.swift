//
//  VideoViewController.swift
//  drawing
//
//  Created by Jiayi Wu on 9/25/20.
//  Copyright © 2020 Jiayi Wu. All rights reserved.
//

import UIKit

class VideoViewController: UIViewController {
    var obj : [String: Any]!
    var ind = 0

    @IBOutlet weak var NextButton: UIBarButtonItem!
    @IBOutlet weak var canvasView: CanvasView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if obj == nil {
           return
        }

      
        let lines = self.iter(n: ind)
        self.canvasView.lines = lines
        //self.canvasView.draw(self.canvasView.bounds)
        self.canvasView.setNeedsDisplay()
        setupNavigationController()
            
       
        
    }
    private func setupNavigationController(){
        
        navigationItem.rightBarButtonItems = [NextButton]
    }
   
    @IBAction func next(_ sender: Any) {
        ind += 1
        
        let lines = self.iter(n: ind)
        self.canvasView.lines = lines
        //self.canvasView.draw(self.canvasView.bounds)
        self.canvasView.setNeedsDisplay()
        
    }
    
    func iter(n: Int) -> [TouchPointsAndColor]{
        var lines = [TouchPointsAndColor]()
        var firstind = Int(0)
        var secondind = Int(0)
        let linewidth = obj["linewidth"] as! [Float]
        let ind = obj["ind"] as! [Int]
        let pos = obj["pos"] as! [String]
        let linecolor = obj["linecolor"] as! [String]
        let lineop = obj["lineop"] as! [Float]
        
        for (i) in (0...n%linewidth.count) {
            
            var points = Array<CGPoint>()
            if i > 0{
                firstind += ind[i-1]
            }
            secondind = firstind + ind[i]
            for j in Range(uncheckedBounds: (firstind , secondind)){
                points.append(NSCoder.cgPoint(for: pos[j]))
            }
            
            var line = TouchPointsAndColor(color: UIColor.color(withCodedString: (linecolor[i]))!, points: points)
            
            line.width = CGFloat(linewidth[i])
            line.opacity = CGFloat(lineop[i])
            lines.append(line)
            
            
        }
        return lines
    }
    //MARK: Delay func
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    
}
