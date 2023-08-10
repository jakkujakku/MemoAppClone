//
//  UtilieView.swift
//  MemoAppClone
//
//  Created by (^ㅗ^)7 iMac on 2023/08/09.
//

import UIKit

class Utilie {
    //MARK: - 공통부분
    static let utilie = Utilie()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var folders = [Folder]()
    var memos = [Memo]()
    
    // 날짜 형식 변환 ✅
    func dateFormatter()  -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy. M. d a hh:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: Date())
    }
}

