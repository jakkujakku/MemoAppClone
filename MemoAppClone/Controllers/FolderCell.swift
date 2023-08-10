//
//  FolderCell.swift
//  MemoAppClone
//
//  Created by (^ㅗ^)7 iMac on 2023/08/02.
//

import UIKit

class FolderCell: UITableViewCell {

    @IBOutlet weak var folderIcon: UIImageView!
    @IBOutlet weak var folderTitleLabel: UILabel!
    @IBOutlet weak var memoCountIntheFolder: UILabel!
    
    func configure(_ data: Folder) {
        folderTitleLabel.text = data.folderName
        guard let count = data.memos?.count else { return }
        memoCountIntheFolder.text = String(count)
        folderIcon.image = UIImage(systemName: "folder")
        folderIcon.tintColor = .systemOrange
    }
}
