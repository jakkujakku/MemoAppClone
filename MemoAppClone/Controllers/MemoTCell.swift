//
//  MemoTCell.swift
//  MemoAppClone
//
//  Created by (^ㅗ^)7 Macbook pro  on 2023/08/06.
//

import UIKit

class MemoTCell: UITableViewCell {
    @IBOutlet weak var memoTitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!

    func configure(_ data: Memo) {
        memoTitleLabel.text = data.memoName
        dateLabel.text = data.memoDate
        iconImage.image = UIImage(systemName: "folder")
    }
}
