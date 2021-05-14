//
//  ViewController.swift
//  TestLarge
//
//  Created by 黄坤鹏 on 2021/5/13.
//

import UIKit

class ViewController: UIViewController {

    private var scrollView:EHLargeImageScrollView?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        self.navigationController?.navigationBar.isTranslucent = false
        self.automaticallyAdjustsScrollViewInsets = false
        /*
         *长图2：
         "http://pic1.win4000.com/wallpaper/2018-12-17/5c1731baae242.jpg"
         */
        
        self.scrollView = EHLargeImageScrollView()
        self.scrollView?.frame = self.view.bounds
        self.view.addSubview(self.scrollView!)
        
        DispatchQueue.global().async {
            self.loadNetImage()
        }
        
//        self.loadLocalImage()
        
    }
    
    
    func loadNetImage(){
        do{
            let data = try Data(contentsOf: URL(string: "http://pic1.win4000.com/wallpaper/2018-12-17/5c1731baae242.jpg")!)
            let image = UIImage(data: data)
            print("finish loading")
            DispatchQueue.main.async {
                self.scrollView?.load(image:image)
            }
        }catch let e {
            print(e)
        }
        
    }
    
    func loadLocalImage(){
        if let path = Bundle.main.path(forResource: "1.jpg", ofType: nil) {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                self.scrollView?.load(image:UIImage(data: data))
            }catch let e {
                print(e)
            }
            
        }
        
    }


}
/// gcd延时
func delay(_ i: CGFloat, _ closure: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + TimeInterval(i), execute: closure)
}
