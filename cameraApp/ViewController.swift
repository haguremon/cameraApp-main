//
//  ViewController.swift
//  cameraApp
//
//  Created by IwasakIYuta on 2021/06/29.
//

import UIKit //UIKitのフレームワークでその中のクラスを使用
import FirebaseStorage

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    private let storage = Storage.storage()
    
    private func  storageReferenceCreate() -> StorageReference {
        let storageRef = storage.reference(forURL: "gs://imagepicker-11d14.appspot.com/image.jpg")
        return storageRef
        
    }
    
    @IBAction func cameraBarButton(_ sender: UIBarButtonItem) {
        let camera = UIImagePickerController.SourceType.camera //画像の取得方法 //UIImagePickerControllerカメラ類を表現するクラス
        if UIImagePickerController.isSourceTypeAvailable(camera) { //カメラが無いデバイスでは実行できないように設定
            let picker = UIImagePickerController()
            picker.sourceType = camera
            picker.delegate = self //selfはViewController自身
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        guard let imagejpg = image.pngData() else {
            print("errrorr")
            return
            
        }
        image.accessibilityIdentifier = UUID().uuidString
        print(image.accessibilityIdentifier!)
        let imageRef = storageReferenceCreate().child(image.accessibilityIdentifier!)
        //        guard let jpeg = image.jpegData(compressionQuality: 1.0) else {
        //            print("その画像は保存できません")
        //            return
        //        }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        imageRef.putData(imagejpg, metadata: metadata) { _, error in
            if (error != nil) {
                print("upload error!")
                return
            } else {
                print("upload successful!")
                imageRef.downloadURL { url, error in
                    
                    if (error != nil) {
                        print("upload error!")
                        return
                    }
                    guard let downloadURL = url?.absoluteString else { return }
                    print(downloadURL)
                    let url = URL(string: downloadURL)
                    URLSession.shared.dataTask(with: url!) { [ weak  self ] data , response, error in
                        guard let data = data ,
                             error == nil else {
                          print("Uh-oh, an error occurred!")
                            return
                        }
                        DispatchQueue.main.async {
                            print("aaaa")
                            self?.imageView.image = UIImage(data: data)
                        
                        }
                        
                    
                    }.resume()
                    
                    
                    
                    
                }
                
            }
        }
        
        
        // imageView.imageの方がUIImge型なのでダウンキャストしないといけない
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImageViewButton(_ sender: UIBarButtonItem) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
        //self.present(picker, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imageView.contentMode = .scaleAspectFit
    }
    
    
}
extension ViewController : UIImagePickerControllerDelegate {
    
}
extension ViewController : UINavigationControllerDelegate {
    
}
