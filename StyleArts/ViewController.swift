//
//  ViewController.swift
//  StyleArts
//
//  Created by iosdevlog on 2018/9/22.
//  Copyright © 2018年 iosdevlog. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {
    //MARK:- IBOutlets
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var tipsLabel: UILabel!
    
    //MARK:- Properties
    var originalImage:UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkPermission()
        tipsLabel.isHidden = true
        
        imageView.isUserInteractionEnabled = true
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.shareAction(_:)))
        imageView.addGestureRecognizer(longTap)
        self.toggleLoading(show: false)
    }
    
    private func toggleLoading(show: Bool) {
        if show {
            self.loadingView.alpha = 0.75
        } else {
            self.loadingView.alpha = 0
        }
        self.navigationItem.leftBarButtonItem?.isEnabled = !show
        self.navigationItem.rightBarButtonItem?.isEnabled = !show
    }
    
    @objc func shareAction(_ sender: Any) {
        let image = imageView.image
        
        let activityVC = UIActivityViewController.init(activityItems: [image as Any], applicationActivities: nil)
        
        self.present(activityVC, animated: true) {
            
        }
    }
    
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted:
            // same same
            print("User do not have access to photo album.")
        case .denied:
            // same same
            print("User has denied the permission.")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.originalImage = self.imageView.image
        CollectionView.delegate = self
        CollectionView.dataSource = self
    }
    
    @IBAction func camera(_ sender: Any) {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        cameraPicker.allowsEditing = true
        
        present(cameraPicker, animated: true)
    }
    
    @IBAction func openLibrary(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
}

extension ViewController: UIImagePickerControllerDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        originalImage = image
        imageView.image = image
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension ViewController: UINavigationControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:FilterCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "filter", for: indexPath) as! FilterCollectionViewCell
        switch indexPath.item {
        case 0:
            cell.lbl.text = "Mosaic"
            cell.imageView.image = #imageLiteral(resourceName: "mosaicImg")
        case 1:
            cell.lbl.text = "Scream"
            cell.imageView.image = #imageLiteral(resourceName: "screamImg")
        case 2:
            cell.lbl.text = "Muse"
            cell.imageView.image = #imageLiteral(resourceName: "museImg")
        case 3:
            cell.lbl.text = "Udnie"
            cell.imageView.image = #imageLiteral(resourceName: "Udanie")
        case 4:
            cell.lbl.text = "Candy"
            cell.imageView.image = #imageLiteral(resourceName: "candy")
        case 5:
            cell.lbl.text = "Feathers"
            cell.imageView.image = #imageLiteral(resourceName: "Feathers")
            
        default:
            cell.lbl.text = ""
        }
        
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.imageView.image != nil {
            toggleLoading(show: true)
            StyleArt.shared.imageSize = self.imageView.image?.size ?? CGSize(width: 1000, height: 1000)
            
            DispatchQueue.global().async { [weak self] in
                StyleArt.shared.process(image: self!.originalImage!, style: ArtStyle(rawValue: indexPath.row)!, compeletion: { (result) in
                    DispatchQueue.main.async {
                        self?.toggleLoading(show: false)
                        
                        if let image = result{
                            self?.imageView.image = image
                            UIView.animate(withDuration: 1000, animations: {
                                self?.tipsLabel.isHidden = false
                            })
                        }
                    }
                })
            }
        }
        
    }
}
