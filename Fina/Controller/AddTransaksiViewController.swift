//
//  AddTransaksiViewController.swift
//  Fina
//
//  Created by Mikhael Adiputra on 28/04/22.
//

import UIKit
import CoreData

class AddTransaksiViewController: UIViewController {

    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var saveButtonItem: UIBarButtonItem!
    @IBOutlet weak var imageBarang: UIImageView!
    @IBOutlet weak var pengeluaranTextfield: UITextField!
    @IBOutlet weak var tanggalTextfield: UITextField!
    @IBOutlet weak var namaBarangTextfield: UITextField!
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var imageData : Data?
    private let date = Date()
    private var pengeluaranReal = 0
    
    var transaksi : Transaksi?
    var delegate : dismissTransaksi?
    
    override func viewWillAppear(_ animated: Bool) {
        if transaksi != nil {
            
            title = "Transaksi"
            
            namaBarangTextfield.isEnabled  = false
            tanggalTextfield.isEnabled     = false
            pengeluaranTextfield.isEnabled = false
            deleteButton.isEnabled         = true
            
            saveButtonItem.isEnabled = false
            imageBarang.isUserInteractionEnabled = false
            
            namaBarangTextfield.backgroundColor = .systemGray.withAlphaComponent(0.25)
            tanggalTextfield.backgroundColor = .systemGray.withAlphaComponent(0.25)
            pengeluaranTextfield.backgroundColor = .systemGray.withAlphaComponent(0.25)

            pengeluaranTextfield.text = self.transaksi!.jumlahPengeluaranStr
            tanggalTextfield.text     = self.transaksi!.tanggalPengeluaran
            namaBarangTextfield.text  = self.transaksi!.namaBarangJasa
            if transaksi!.imageBarang != nil {
                imageBarang.image = UIImage(data: self.transaksi!.imageBarang!)
                changeImageObject()
            }else {
                imageBarang.isHidden = true
            }
        }else {
            deleteButton.isEnabled = false
            imageBarang.isUserInteractionEnabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        namaBarangTextfield.delegate = self
        tanggalTextfield.delegate = self
        pengeluaranTextfield.delegate = self
        
        let dateF = DateFormatter()
        dateF.dateFormat = "EEEE, MMM d yyyy"
        let todayDate = dateF.string(from: self.date)
        tanggalTextfield.text = todayDate
        tanggalTextfield.isUserInteractionEnabled = false
        
        pengeluaranTextfield.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
        
        let tapped = UITapGestureRecognizer(target: self, action: #selector(dismissView(_:)))
        self.view.addGestureRecognizer(tapped)
        
        let imageTappedGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageBarang.addGestureRecognizer(imageTappedGesture)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.dismissNilTransaksi()
    }
    
    private func changeImageObject() {
        imageBarang.backgroundColor = UIColor.black
        imageBarang.layer.borderColor = UIColor.systemGray2.cgColor
        imageBarang.layer.borderWidth = 3
        imageBarang.layer.cornerRadius = 10
        imageBarang.clipsToBounds = true
    }
    
    @objc private func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        cameraOptionFunction()
    }
    
    @objc private func dismissView(_ gesture : UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func saveButtonAction(_ sender: UIBarButtonItem) {
        if pengeluaranTextfield.text?.count != 0 && tanggalTextfield.text?.count != 0 && namaBarangTextfield.text?.count != 0 {
            let entity = NSEntityDescription.entity(forEntityName: "Transaksi", in: self.context)
            let newEntry = NSManagedObject(entity: entity!, insertInto: self.context)
            self.saveData(entryDBObj: newEntry)
            self.navigationController!.popToRootViewController(animated: true)
        }else {
            if pengeluaranTextfield.text?.count == 0 {
                pengeluaranTextfield.backgroundColor = UIColor.systemRed.withAlphaComponent(0.25)
            }
            
            if tanggalTextfield.text?.count == 0 {
                tanggalTextfield.backgroundColor = UIColor.systemRed.withAlphaComponent(0.25)
            }
            
            if namaBarangTextfield.text?.count == 0 {
                namaBarangTextfield.backgroundColor = UIColor.systemRed.withAlphaComponent(0.25)
            }
        }
    }
    
    private func saveData(entryDBObj:NSManagedObject){
        if self.imageData == nil {
            entryDBObj.setValue(nil, forKey: "imageBarang")
        }else {
            entryDBObj.setValue(self.imageData, forKey: "imageBarang")
        }
        entryDBObj.setValue(self.tanggalTextfield.text!, forKey: "tanggalPengeluaran")
        entryDBObj.setValue(self.pengeluaranTextfield.text!, forKey: "jumlahPengeluaranStr")
        entryDBObj.setValue(self.namaBarangTextfield.text!, forKey: "namaBarangJasa")
        
        do {
            try context.save()
        } catch {
            print("Storing data Failed")
        }
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Are you sure want to delete this item?", message: nil, preferredStyle: .alert)
        let okay = UIAlertAction(title: "Delete", style: .destructive) { UIAlertAction in
            self.context.delete(self.transaksi!)
               do {
                   try self.context.save()
               } catch let error as NSError {
                   print("Error While Deleting Note: \(error.userInfo)")
               }
            self.navigationController?.popViewController(animated: true)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okay)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func changeNumericToCurrency(strInt : Int) -> String {
        let finaleString = "\(strInt)00".currencyInputFormatting()
        return finaleString
    }
    
}

extension AddTransaksiViewController : UITextFieldDelegate {
    @objc func myTextFieldDidChange(_ textField: UITextField) {
        if let amountString = textField.text?.currencyInputFormatting() {
            textField.text = amountString
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == pengeluaranTextfield {
            var result = pengeluaranTextfield.text?.filter("0123456789".contains)
            if result?.count ?? 0 > 2 {
                result?.removeLast()
                result?.removeLast()
                self.pengeluaranReal = Int(result ?? "0") ?? 0
            }else {
                self.pengeluaranReal = 0
            }
        }
    }
}

extension AddTransaksiViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.view.endEditing(true)
        if let imagePicked = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageBarang.image = imagePicked
            changeImageObject()
            imageData = imagePicked.jpegData(compressionQuality: 0.4)!
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imageData = nil
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func cameraOptionFunction() {
        view.endEditing(true)
        
        let alertController = UIAlertController(title: "Add an Image", message: "Choose From", preferredStyle: .alert)
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
         
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            pickerController.sourceType = .camera
            self.present(pickerController, animated: true, completion: nil)
        }
        
        let photosLibraryAction = UIAlertAction(title: "Photos Library", style: .default) { (action) in
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
        }
        
        let savedPhotosAction = UIAlertAction(title: "Saved Photos Album", style: .default) { (action) in
            pickerController.sourceType = .savedPhotosAlbum
            self.present(pickerController, animated: true, completion: nil)
       }
       
       let deleteProfilePhoto = UIAlertAction(title: "Delete Photo", style: .destructive) { (UIAlertAction) in
           self.imageData = nil
           self.imageBarang.image = UIImage(named: "KTP")!
           self.imageBarang.backgroundColor = UIColor.clear
           self.imageBarang.layer.borderColor = UIColor.systemGray2.cgColor
           self.imageBarang.layer.borderWidth = 0
           self.imageBarang.layer.cornerRadius = 0
           self.imageBarang.clipsToBounds = true
       }
      
       let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
       
        
        if imageData != nil {
            deleteProfilePhoto.isEnabled = true
        }else {
            deleteProfilePhoto.isEnabled = false
        }
        
        alertController.addAction(cameraAction)
        alertController.addAction(photosLibraryAction)
        alertController.addAction(savedPhotosAction)
        alertController.addAction(deleteProfilePhoto)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
}
