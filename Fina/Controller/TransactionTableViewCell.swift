//
//  TransactionTableViewCell.swift
//  Fina
//
//  Created by Mikhael Adiputra on 28/04/22.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {

    @IBOutlet weak var nominalLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func setupCell(_ transaksi : Transaksi) {
        self.nominalLabel.text = transaksi.jumlahPengeluaranStr
        self.dateLabel.text = transaksi.tanggalPengeluaran
    }
}
