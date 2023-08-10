//
//  FolderController.swift
//  MemoAppClone
//
//  Created by (^ㅗ^)7 iMac on 2023/08/02.
//

import UIKit
import CoreData

// 폴더 작성 페이지
class FolderController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    // context 생성
    let context = Utilie.utilie.context
    var folders = Utilie.utilie.folders
    var isTappedEditButton: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Delegate
        tableView.dataSource = self
        tableView.delegate = self
        // FolderModel 불러오기
        getAllFolders()
        // UI 구성
        settingUI()
        // 우측 상단 버튼 구성
        showRightBarButton()
        // 툴바 추가
        setUpToolBar()
        // 스크롤시, 서치바 보이게 하는 함수
        topViewUp()
    }
    
    // 폴더 내 메모 개수 값 갱신
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    // 툴바 띄우기
    func setUpToolBar() {
        let addFolder = UIBarButtonItem(image: UIImage(systemName: "folder"), style: .plain, target: self, action: #selector(tapAddFolderButton))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [addFolder, spaceButton]
        navigationController?.toolbar.tintColor = UIColor.systemOrange
        navigationController?.isToolbarHidden = false
    }
    
    // UI 띄우기
    func settingUI() {
        // 배경색상 변경
        view.backgroundColor = .systemGray6
        
        // tableView 색상 변경
        tableView.backgroundColor = .clear
        
        // 네비게이션 타이틀
        navigationItem.title = "폴더"
        // 네비게이션 타이틀 크게 보기
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .systemOrange
    }
    
    // 우측 상단 편집 또는 완료 버튼
    func showRightBarButton() {
        let editButton = UIBarButtonItem(title: "편집", style: .plain, target: self, action: #selector(tapEditButton))
        let doneButton = UIBarButtonItem(title: "완료" , style: .plain, target: self, action: #selector(tapDoneButton))
        self.navigationItem.rightBarButtonItem = isTappedEditButton ? doneButton : editButton
        navigationItem.rightBarButtonItem?.tintColor = UIColor.systemOrange
    }
    
    // 폴더 추가 Alert 생성
    func showAddFolderAlert() {
        // Alert 생성
        let alert = UIAlertController(title: "새로운 폴더", message: nil, preferredStyle: .alert)
        
        // Alert TextField 생성
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "새로운 폴더"
            UITextField.appearance().clearButtonMode = .whileEditing
        })
        
        // 등록 버튼 생성
        let registerButton = UIAlertAction(title: "등록", style: .default, handler: { [weak self] _ in
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else {
                return
            }
            self?.createFolder(folderName: text)
        })
        
        // 취소 버튼 생성
        let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        // Alert 추가
        alert.addAction(cancelButton)
        alert.addAction(registerButton)
        self.present(alert, animated: true, completion: nil)
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
    
    // 서치바 추가
    func addSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        // 검색컨트롤러는 검색하는 동안 네비게이션바에 가려지지않도록한다
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.navigationItem.hidesSearchBarWhenScrolling = true
        searchController.searchBar.delegate = self
        self.navigationItem.searchController = searchController
    }
    
    
}

//MARK: - UITableViewDataSource

extension FolderController: UITableViewDataSource {
    
    // folderModel 개수 반환
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folders.count
    }
    
    // 재사용할 셀
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = folders[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell", for: indexPath) as? FolderCell else { return UITableViewCell() }
        cell.configure(item)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    // 섹션 제목
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "나의 메모"
    }
    
    // 섹션 개수
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Cell 이동 할 때
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Cell 위치 이동
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var folders = self.folders
        let folder = folders[sourceIndexPath.row]
        folders.remove(at: sourceIndexPath.row)
        folders.insert(folder, at: destinationIndexPath.row)
        self.folders = folders
    }
    
    // Cell 삭제
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 셀 삭제
        self.deleteFolder(at: indexPath)
    }
}

//MARK: - UITableViewDelegate

extension FolderController: UITableViewDelegate {
    
    // 셀 눌러 화면 이동
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToTableView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! MemoTableController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedFolder = folders[indexPath.row]
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // 섹션 높이
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}

//MARK: - Search bar methods

extension FolderController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        let request : NSFetchRequest<Folder> = Folder.fetchRequest()
    
        let predicate = NSPredicate(format: "folderName CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "folderName", ascending: true)]
        
        loadItems(with: request, predicate: predicate, folder: searchBar.text ?? "")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.getAllFolders()
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

extension FolderController {
    
    // 리스트 가져오기
    func getAllFolders() {
        do {
            folders = try context.fetch(Folder.fetchRequest())
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            // error
            print("패치 에러 : \(error)")
        }
    }
    
    // Create Item
    func createFolder(folderName: String) {
        let newFolder = Folder(context: context)
        newFolder.folderName = folderName
        
        do {
            try context.save()
            getAllFolders()
        }
        catch {
            print("삽입 에러 : \(error)")
        }
    }

    // Delete Item(부분 삭제)
    func deleteFolder(at indexPath: IndexPath) {
        let folderIndexPath = folders[indexPath.row]
        context.delete(folderIndexPath)
        
        do {
            try context.save()
            getAllFolders()
        }
        catch {
            print("부분 삭제 에러 : \(error)")
        }
    }
    
    //    // Update Item
    //    func updateFolder(folder: Folder, newName: String) {
    //        folder.folderName = newName
    //        do {
    //            try context.save()
    //            getAllFolders()
    //        }
    //        catch {
    //            print("업데이트 에러 : \(error)")
    //        }
    //    }
    
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
    
    // 검색 값 CoreData 비교
    func loadItems(with request: NSFetchRequest<Folder> = Folder.fetchRequest(), predicate: NSPredicate? = nil, folder: String = "") {

        let categoryPredicate = NSPredicate(format: "folderName CONTAINS[cd] %@", folder)

        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }

        do {
            folders = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
}

//MARK: - Objective-C Folder Page

extension FolderController {
    // 폴더 추가
    @objc func tapAddFolderButton(_ sender: UIBarButtonItem) {
        showAddFolderAlert()
    }
    
    // 완료 버튼
    @objc func tapDoneButton() {
        isTappedEditButton.toggle()
        self.tableView.setEditing(false, animated: true)
        showRightBarButton()
    }
    
    // 편집
    @objc func tapEditButton(_ sender: UIBarButtonItem) {
        isTappedEditButton.toggle()
        self.tableView.setEditing(true, animated: true)
        showRightBarButton()
    }
}
