//
//  TransaksiViewController.swift
//  Fina
//
//  Created by Mikhael Adiputra on 28/04/22.
//

import UIKit
import CoreData

protocol dismissTransaksi {
    func dismissNilTransaksi()
}

class TransaksiViewController: UIViewController {

    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var transactionArray = [Transaksi]()
    private var selectedIndex    = 0
    private var selectedItem     = false
    
    @IBOutlet weak var transactionCard: UIView!
    @IBOutlet weak var totalNominalLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        loadItem()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        transactionCard.layer.cornerRadius = 8
        
        tableView.register(UINib(nibName: "TransactionTableViewCell", bundle: nil), forCellReuseIdentifier: "transactionCell")
        
    }
    
    private func loadItem() {
        let request: NSFetchRequest<Transaksi> = Transaksi.fetchRequest()
       do {
           transactionArray = try context.fetch(request)
       } catch {
           print("Fetching data Failed")
       }
        calculateTotal()
        tableView.reloadData()
    }
    
    private func calculateTotal() {
        var finaleTotal : Int64 = 0
        for trans in self.transactionArray {
            var result = trans.jumlahPengeluaranStr!.filter("0123456789".contains)
            var subRes = 0
            if result.count  > 2 {
                result.removeLast()
                result.removeLast()
                subRes = Int(result) ?? 0
            }else {
                subRes = 0
            }
            finaleTotal += Int64(subRes)
        }
        if finaleTotal == 0 {
            self.totalNominalLabel.text = "Rp.0"
        }else {
            self.totalNominalLabel.text = changeNumericToCurrency(strInt: finaleTotal)
        }
    }
    
    @IBAction func addAction(_ sender: Any) {
        performSegue(withIdentifier: "goToTransaksi", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTransaksi" {
            if let nextViewController = segue.destination as? AddTransaksiViewController {
                if self.selectedItem == true {
                    nextViewController.delegate  = self
                    nextViewController.transaksi = self.transactionArray[self.selectedIndex]
                }
            }
        }
    }
    
    private func changeNumericToCurrency(strInt : Int64) -> String {
        let finaleString = "\(strInt)00".currencyInputFormatting()
        return finaleString
    }
}

extension TransaksiViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath) as! TransactionTableViewCell
        
        cell.setupCell(self.transactionArray[indexPath.row])
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        selectedItem  = true
        performSegue(withIdentifier: "goToTransaksi", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TransaksiViewController : dismissTransaksi {
    func dismissNilTransaksi() {
        self.selectedItem  = false
        self.selectedIndex = 0
    }
}
