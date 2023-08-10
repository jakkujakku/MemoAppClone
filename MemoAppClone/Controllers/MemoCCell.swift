//
//  MemoCCell.swift
//  MemoAppClone
//
//  Created by (^ㅗ^)7 iMac on 2023/08/03.
//

import UIKit

class MemoCCell: UICollectionViewCell {
    @IBOutlet weak var memoTitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    
//    func configure(_ data: Memo) {
//        memoTitleLabel.text = data.title
//        dateLabel.text = dateFormatter()
//        iconImage.image = UIImage(systemName: data.image ?? "folder")
//    }
//    
//    func dateFormatter() -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yy. M. d a hh:MM"
//        formatter.locale = Locale(identifier: "ko_KR")
//        return formatter.string(from: Date())
//    }
}
