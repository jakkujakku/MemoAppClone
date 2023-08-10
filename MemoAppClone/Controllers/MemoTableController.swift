//
//  MemoTableController.swift
//  MemoAppClone
//
//  Created by (^ㅗ^)7 Macbook pro  on 2023/08/06.
//

import UIKit
import CoreData
import SnapKit

class MemoTableController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var memoCountLabel: UILabel!
    
    // context 생성
    let context = Utilie.utilie.context
    var memos = Utilie.utilie.memos
    var currentTitle: String?
    
    var selectedFolder: Folder? {
        didSet {
            getAllMemos()
        }
    }
    
    var homeNavigationTitle: String = ""
    var navigationTitle : String = ""
    var toggle: Bool = false
    var isToggle: Bool = false
    var isSelected: Bool = false
    var groupHeight : NSCollectionLayoutDimension =  .estimated(120)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        currentTitle = selectedFolder?.folderName
        settingUI()
        addRightButton()
        setUpToolBar()
        topViewUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getAllMemos()
        tableView.reloadData()
    }
    
    
    
    // 스크롤시 서치바 보이게 하는 함수
    func topViewUp() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            // 상단에 서치바 올리기
            self.view.transform = CGAffineTransform(translationX: 0, y: 0)
            self.addSearchBar()
            self.view.layoutIfNeeded()
        })
    }
    
    // 날짜 형식 변환
    func dateFormatter()  -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy. M. d a hh:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: Date())
    }
    
    // UI 띄우기
    func settingUI() {
        // 배경색상 변경
        view.backgroundColor = .systemGray6
        // tableView 색상 변경
        tableView.backgroundColor = .clear
        // 메모 개수 표시
        memoCountLabel.text = "\(memos.count ?? 0)개의 메모"
        // 네비게이션 타이틀
        navigationItem.title = currentTitle
        // 네비게이션 타이틀 크게 보기
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .systemOrange
    }
    
    // 툴바 올리기
    func setUpToolBar() {
        let writeButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(goToWriteMemo))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        writeButton.isEnabled = true
        toolbarItems = [spaceButton , writeButton]
        navigationController?.toolbar.tintColor = UIColor.systemOrange
        navigationController?.isToolbarHidden = false
    }
    
    // 서치바 추가
    func addSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        //        검색컨트롤러는 검색하는 동안 네비게이션바에 가려지지않도록한다
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.navigationItem.hidesSearchBarWhenScrolling = true
        searchController.searchBar.delegate = self
        self.navigationItem.searchController = searchController
    }
    
    func addRightButton() {
        // 갤러리보기 - 목록 보기(기본값)
        let firstMenu = UIMenu(title: "", options: .displayInline, children: [
            UIDeferredMenuElement.uncached { [weak self] completion in
                let actions = [
                    UIAction(
                        title: self?.toggle == true ? "목록으로 보기" : "갤러리로 보기" ,
                        image: UIImage(systemName: "square.grid.2x2") ,
                        state: self?.toggle == true ? .on : .off,
                        handler: { value in [self]
                            print("선택")
                            self?.toggle.toggle()
                            print(self?.toggle)
                            //                            guard let vc = self?.storyboard?.instantiateViewController(withIdentifier: "MemoCollectionViewController") as? MemoCollectionViewController else { return }
                            //                            vc.navigationTitle = self?.navigationItem.title ?? "n/a"
                            //                            self?.navigationController?.pushViewController(vc, animated: false)
                        }),
                ]
                completion(actions)
            }
        ])
        
        // 메모 선택, 첨부 파일 보기, 삭제
        let secondMenu = UIMenu(title: "", options: .displayInline, children: [
            UIDeferredMenuElement.uncached { [weak self] completion in
                let actions = [
                    UIAction(
                        title: self?.isToggle ?? false ? "메모 편집 취소" : "메모 편집" ,
                        image: UIImage(systemName: "checkmark.circle") ,
                        state: self?.isToggle ?? false ? .on : .off,
                        handler: { [self] value in
                            print("메모 편집")
                            // 기능 추가 해야 할 것.
                            self?.isToggle = !(self?.isToggle ?? false)
                            
                            self?.isToggle ?? false ? self?.tableView.setEditing(true, animated: true) : self?.tableView.setEditing(false, animated: true)
                            
                        }),
                    UIAction(
                        title: "첨부 파일 보기" ,
                        image: UIImage(systemName: "paperclip") ,
                        state: .off,
                        handler: { value in [self]
                            print("첨부 파일 보기")
                        }),
                ]
                completion(actions)
            }
        ])
        
        let menu = UIMenu(title: "", options: .displayInline, children: [firstMenu, secondMenu]) // 갤러리보기 , [메모 선택, 파일 보기]
        
        navigationItem.rightBarButtonItem?.changesSelectionAsPrimaryAction = false
        
        navigationItem.rightBarButtonItem =  UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), primaryAction: nil, menu: menu)
        navigationItem.rightBarButtonItem?.tintColor = .systemOrange
    }
    
}


//MARK: - UICollectionViewDataSource

extension MemoTableController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = memos[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoTCell", for: indexPath) as? MemoTCell else { return UITableViewCell() }
        cell.configure(item)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "오늘의 메모"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    // Cell 위치 이동
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var memos = self.memos
        let memo = memos[sourceIndexPath.row]
        memos.remove(at: sourceIndexPath.row)
        memos.insert(memo, at: destinationIndexPath.row)
        self.memos = memos
    }
    
    // Cell 삭제
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 셀 삭제
        self.deleteMemo(at: indexPath)
        tableView.reloadData()
    }
}

extension MemoTableController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("눌렀다")
        performSegue(withIdentifier: "goToWriteViewT", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! MemoWriteController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedFolder = self.selectedFolder
            destinationVC.currentNavigationTitle = currentTitle
            destinationVC.currentTextViewTitle = memos[indexPath.row].memoName
            destinationVC.currentIndex = indexPath
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
}

//MARK: - Search bar methods

extension MemoTableController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        let request : NSFetchRequest<Memo> = Memo.fetchRequest()
    
        let predicate = NSPredicate(format: "memoName CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "memoName", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.getAllMemos()
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
          
        }
    }
}

//MARK: - Core Data

extension MemoTableController {

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
            tableView?.reloadData()
        } catch {
            // error
            print("패치 에러 : \(error)")
        }
    }
    
    // Create Memo
    func createMemo(memoName: String) {
        let newMemo = Memo(context: context)
        newMemo.memoName = memoName
        newMemo.memoDate = self.dateFormatter()
        newMemo.parentFolder = self.selectedFolder
        self.memos.append(newMemo)
        
        do {
            try context.save()
            getAllMemos()
        }
        catch {
            print("삽입 에러 : \(error)")
        }
    }
    
    // Update Memo
    func updateMemo(memo: Memo, newName: String) {
        memo.memoName = newName
        
        do {
            try context.save()
            getAllMemos()
        }
        catch {
            print("업데이트 에러 : \(error)")
        }
    }
    
    // Delete Memo(부분 삭제)
    func deleteMemo(at indexPath: IndexPath) {
        let memoIndexPath = memos[indexPath.row]
        context.delete(memoIndexPath)
        
        do {
            try context.save()
            getAllMemos()
            tableView.reloadData()
        }
        catch {
            print("부분 삭제 에러 : \(error)")
        }
    }
    
    // 전체 삭제
    //    func deleteAllFolder(folder: Folder) {
    //        context.delete()
    //
    //        do {
    //            try context.save()
    //            tableView.reloadData()
    //        } catch {
    //            print("전체 삭제 에러 : \(error)")
    //        }
    //    }
    
    func loadItems(with request: NSFetchRequest<Memo> = Memo.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentFolder.folderName MATCHES %@", selectedFolder!.folderName!)
        
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        
        do {
            memos = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
        
    }
}

//MARK: - Objective-C MemoTable Page

extension MemoTableController {
    // 폴더 -> 메모 쓰는 페이지
    @objc func goToWriteMemo(_ sender: UIBarButtonItem) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "MemoWriteController") as! MemoWriteController
        vc.currentNavigationTitle = selectedFolder?.folderName
        vc.selectedFolder = selectedFolder
        self.navigationController?.pushViewController(vc, animated: true)
        print("이동")
    }
}

