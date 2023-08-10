//
//  MemoWriteController.swift
//  MemoAppClone
//
//  Created by (^ㅗ^)7 iMac on 2023/08/03.
//

import UIKit
import CoreData

class MemoWriteController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    // context 생성
    let context = Utilie.utilie.context
    var memos: [Memo]?
    var selectedFolder: Folder?
    
    var currentTextViewTitle: String?
    var currentNavigationTitle: String?
    var currentIndex: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        setUpToolBar()
        setUpUI()
        getAllMemos()
        textView?.text = currentTextViewTitle ?? ""
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("터치 했음")
        self.view.endEditing(true) /// 화면을 누르면 키보드 내려가게 하는 것
    }
    
    // Create right UIBarButtonItem.
    let rightShareButton: UIBarButtonItem = {
        let rightShareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareAction))
        rightShareButton.tag = 0
        return rightShareButton
    }()

    // Create right UIBarButtonItem.
    let rowAndGridButton: UIBarButtonItem = {
        let scan = UIAction(
            title: "스캔",
            image: UIImage(systemName: "doc.viewfinder"),
            handler: { _ in

            })

        let pinDlete = UIAction(
            title: "고정 해제",
            image: UIImage(systemName: "pin.slash.fill"),
            handler: { _ in

            })

        let lock = UIAction(
            title: "잠그기",
            image: UIImage(systemName: "lock.fill"),
            handler: { _ in

            })

        let menu1 = UIMenu(title: "", options: .displayInline, preferredElementSize: .medium, children: [scan, pinDlete, lock])

        // 메모에서 찾기, 메모 이동, 줄 및 격자, 삭제
        let actions = [
            UIAction(
                title: "메모에서 찾기" ,
                image: UIImage(systemName: "magnifyingglass") ,
                state: .off,
                handler: { value in [self]
                    print("메모에서 찾기")
                }),
            UIAction(
                title: "메모 이동" ,
                image: UIImage(systemName: "folder") ,
                state: .off,
                handler: { value in [self]
                    print("메모 이동")
                }),
            UIAction(
                title: "줄 및 격자" ,
                image: UIImage(systemName: "rectangle.split.3x3"),
                state: .off,
                handler: { value in [self]
                    print("줄 및 격자")
                }),
        ]

        let menu2 = UIMenu(title: "", options: .displayInline, children: actions)
        let menuList = UIMenu(title: "", options: .displayInline, children: [menu1, menu2])
        let rowAndGridButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), primaryAction: nil, menu: menuList)

        rowAndGridButton.tag = 1
        return rowAndGridButton
    }()

    // 완료 버튼
    let doneButton: UIBarButtonItem = {
        let doneButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(doneAction(_:)))
        doneButton.tag = 2
        doneButton.isHidden = true
        return doneButton
    }()

    func setUpUI() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItems = [doneButton, rowAndGridButton, rightShareButton]
        view.backgroundColor = .white
    }
    
    func setUpToolBar() {
        let checkList = UIBarButtonItem(image: UIImage(systemName: "checklist"), style: .plain, target: self, action: nil)
        let cameraButton = UIBarButtonItem(image: UIImage(systemName: "camera"), style: .plain, target: self, action: nil)
        let applePencil = UIBarButtonItem(image: UIImage(systemName: "pencil.tip.crop.circle"), style: .plain, target: self, action: nil)
        let updateButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(updateAction(_:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [checkList, spaceButton ,cameraButton, spaceButton  ,applePencil, spaceButton , updateButton]
        
        navigationController?.toolbar.tintColor = UIColor.systemOrange
        navigationController?.isToolbarHidden = false
    }
}

//MARK: - UITextViewDelegate

extension MemoWriteController: UITextViewDelegate {
    // 텍스트뷰를 수정하기 시작할 때
    func textViewDidBeginEditing(_ textView: UITextView) {
        doneButton.isHidden = false
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
        return true
    }
}

//MARK: - Core Data
extension MemoWriteController {

    // 리스트 가져오기
    func getAllMemos(with request: NSFetchRequest<Memo> = Memo.fetchRequest(), predicate: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "parentFolder.folderName MATCHES %@", selectedFolder!.folderName!)
        
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            memos = try context.fetch(request)
        } catch {
            // error
            print("패치 에러 : \(error)")
        }
    }
    
    // Create Memo
    func createMemo(memoName: String) {
        let newMemo = Memo(context: self.context)
        newMemo.memoName = memoName
        newMemo.memoDate = Utilie.utilie.dateFormatter()
        newMemo.parentFolder = self.selectedFolder
        self.memos?.append(newMemo)
        
        do {
            try context.save()
        }
        catch {
            print("삽입 에러 : \(error)")
        }
    }
    
    func updateMemo(at indexPath: IndexPath, newName: String) {
        let memoForUpdate = self.memos?[indexPath.row]
        memoForUpdate?.memoName = newName
        memoForUpdate?.memoDate = Utilie.utilie.dateFormatter()
        print(selectedFolder?.memos)
        
        do {
            try context.save()
            getAllMemos()
        } catch {
            print("업데이트 오류 : \(error)")
        }
    }
    
    // Delete Memo(부분 삭제)
//    func deleteMemo(at indexPath: IndexPath) {
//        let memoIndexPath = memos?[indexPath.row]
//        context.delete(memoIndexPath)
//
//        do {
//            try context.save()
//            getAllMemos()
//        }
//        catch {
//            print("부분 삭제 에러 : \(error)")
//        }
//    }
}

//MARK: - Object-C Functions Memo Wirte Page

extension MemoWriteController {
    @objc func doneAction(_ sender: UIBarButtonItem) {
        self.createMemo(memoName: textView.text ?? "n/a")
        self.view.endEditing(true)
        doneButton.isHidden = true
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func updateAction(_ sender: UIBarButtonItem) {
        print("업데이트 버튼 눌렀다..")
        guard let item = memos?[currentIndex!.row] else { return }
        self.updateMemo(at: currentIndex!, newName: textView.text)
        self.navigationController?.popViewController(animated: true)
    }

    @objc func shareAction(_ sender: UIBarButtonItem) {
        let shareText = "스위프트 메모"
        var shareObject = [Any]()

        shareObject.append(shareText)

        let activityViewController = UIActivityViewController(activityItems: shareObject, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view

        self.present(activityViewController, animated: true, completion: nil)
        print("공유")
    }
}
