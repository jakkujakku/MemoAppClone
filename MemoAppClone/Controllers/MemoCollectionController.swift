////
////  MemoCollectionController.swift
////  MemoAppClone
////
////  Created by (^ㅗ^)7 iMac on 2023/08/03.
////
//
//import UIKit
//import CoreData
//
//class MemoCollectionController: UIViewController {
//
//    @IBOutlet weak var collectionView: UICollectionView!
//
//    // context 생성
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//
//    var memoModel = [Memo]()
//
//    var homeNavigationTitle: String = ""
//    var navigationTitle : String = ""
//    var toggle: Bool = false
//    var isSelected: Bool = false
//    var groupHeight : NSCollectionLayoutDimension =  .estimated(120)
//    var groupWidth: NSCollectionLayoutDimension = .estimated(750)
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        collectionView.dataSource = self
//        collectionView.delegate = self
//
//        collectionView.reloadData()
//        addBackButton()
//        settingUI()
//        addPanGesture()
//        addRightButton()
//        setUpToolBar()
//
//        if let flowlayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            flowlayout.estimatedItemSize = .zero
//        }
//    }
//
//    func dateFormatter() -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy. MM. dd hh:mm"
//        formatter.locale = Locale(identifier: "ko_KR")
//        return formatter.string(from: Date())
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        getAllItems()
//        collectionView.reloadData()
//    }
//
//    // 폴더 -> 메모 쓰는 페이지
//    @objc func goToWriteMemo(_ sender: UIBarButtonItem) {
//        let vc = MemoWriteViewController()
//        navigationController?.pushViewController(vc, animated: true)
//        print("이동")
//    }
//
//    // PanGesture Action
//    @objc func panGestureAction (_ sender : UIPanGestureRecognizer){
//        let velocity = sender.velocity(in: collectionView)
//
//        if velocity.y < 0 {
//            //            print("up")
//        } else {
//            //            print("down")
//            addSearchBar()
//        }
//    }
//
//    @objc func returnHome(_ sender: UIBarButtonItem) {
//        guard let vc = storyboard?.instantiateViewController(withIdentifier: "FolderViewController") as? FolderViewController else { return }
//        print("눌렀음.")
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//
//    // 백 버튼 구현
//    func addBackButton() {
//        let backBarButtonItem = UIBarButtonItem(title: homeNavigationTitle, style: .plain, target: self, action: #selector(returnHome(_:)))
//            backBarButtonItem.tintColor = .systemOrange  // 색상 변경
//            self.navigationItem.backBarButtonItem = backBarButtonItem
//    }
//
//    // PanGesture 추가
//    func addPanGesture() {
//        let panGestureRecongnizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_ :)))
//        panGestureRecongnizer.delegate = self
//        self.view.addGestureRecognizer(panGestureRecongnizer)
//    }
//
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool{
//        return true
//    }
//
//    // UI 띄우기
//    func settingUI() {
//        // 배경색상 변경
//        view.backgroundColor = .systemGray6
//
//        // tableView 색상 변경
//        collectionView.backgroundColor = .clear
//
//        // 네비게이션 타이틀
//        navigationItem.title = navigationTitle
//
//        // 네비게이션 타이틀 크게 보기
//        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationController?.navigationBar.tintColor = .systemOrange
//    }
//
//    // 툴바 올리기
//    func setUpToolBar() {
//        let writeButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(goToWriteMemo))
//        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//
//        writeButton.isEnabled = true
//
//        toolbarItems = [spaceButton , writeButton]
//
//        navigationController?.toolbar.tintColor = UIColor.systemOrange
//        navigationController?.isToolbarHidden = false
//    }
//
//    // 서치바 추가
//    func addSearchBar() {
//        let searchController = UISearchController(searchResultsController: nil)
//        //        검색컨트롤러는 검색하는 동안 네비게이션바에 가려지지않도록한다
//        searchController.hidesNavigationBarDuringPresentation = false
//        searchController.searchBar.placeholder = "Search"
//        searchController.navigationItem.hidesSearchBarWhenScrolling = true
//
//        self.navigationItem.searchController = searchController
//    }
//
//    func addRightButton() {
//        // 갤러리보기 - 목록 보기(기본값)
//        let firstMenu = UIMenu(title: "", options: .displayInline, children: [
//            UIDeferredMenuElement.uncached { [weak self] completion in
//                let actions = [
//                    UIAction(
//                        title: self?.toggle == true ? "목록으로 보기" : "갤러리로 보기" ,
//                        image: UIImage(systemName: "square.grid.2x2") ,
//                        state: self?.toggle == true ? .on : .off,
//                        handler: { value in [self]
//                            print("선택")
//                            self?.toggle.toggle()
//                            print(self?.toggle)
//                            guard let vc = self?.storyboard?.instantiateViewController(withIdentifier: "MemoTableViewController") as? MemoTableViewController else { return }
//                            vc.navigationTitle = self?.navigationItem.title ?? "n/a"
//                            self?.navigationController?.pushViewController(vc, animated: false)
//                        }),
//                ]
//                completion(actions)
//            }
//        ])
//
//        // 메모 선택, 첨부 파일 보기, 삭제
//        let secondMenu = UIMenu(title: "", options: .displayInline, children: [
//            UIDeferredMenuElement.uncached { [weak self] completion in
//                let actions = [
//                    UIAction(
//                        title: "메모 선택" ,
//                        image: UIImage(systemName: "checkmark.circle") ,
//                        state: .off,
//                        handler: { value in [self]
//                            print("메모 선택")
//                            // 기능 추가 해야 할 것.
//                            self?.isSelected.toggle()
//                            if self?.isSelected == true {
//                                print("성공")
//                                guard let vc = self?.storyboard?.instantiateViewController(withIdentifier: "FolderViewController") as? FolderViewController else { return }
//                                self?.navigationController?.pushViewController(vc, animated: false)
//                            } else {
//                                print("실패")
//                            }
//
//                        }),
//                    UIAction(
//                        title: "첨부 파일 보기" ,
//                        image: UIImage(systemName: "paperclip") ,
//                        state: .off,
//                        handler: { value in [self]
//                            print("첨부 파일 보기")
//                        }),
//                ]
//                completion(actions)
//            }
//        ])
//
//        let menu = UIMenu(title: "", options: .displayInline, children: [firstMenu, secondMenu]) // 갤러리보기 , [메모 선택, 파일 보기]
//
//        navigationItem.rightBarButtonItem?.changesSelectionAsPrimaryAction = false
//
//        navigationItem.rightBarButtonItem =  UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), primaryAction: nil, menu: menu)
//        navigationItem.rightBarButtonItem?.tintColor = .systemOrange
//    }
//
//    // Core Data
//    // 리스트 가져오기
//    func getAllItems() {
//        do {
//            memoModel = try context.fetch(Memo.fetchRequest())
//
//            DispatchQueue.main.async {
//                self.collectionView.reloadData()
//            }
//        } catch {
//            // error
//        }
//    }
//
//    // Create Item
//    func createItem(name: String) {
//        let newItem = Memo(context: context)
//        newItem.title = name
//        newItem.memoDate = dateFormatter()
//        do {
//            try context.save()
//            getAllItems()
//        }
//        catch {
//
//        }
//    }
//
//    // Update Item
//    func updateItem(item: Memo, newName: String) {
//        item.title = newName
//        do {
//            try context.save()
//            getAllItems()
//        }
//        catch {
//
//        }
//    }
//
//    // Delete Item
//    func deleteItem(item: Memo) {
//        context.delete(item)
//
//        do {
//            try context.save()
//            getAllItems()
//        }
//        catch {
//
//        }
//    }
//
//}
//
////MARK: - UICollectionViewDataSource
//
//extension MemoCollectionController: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemoCollectionViewCell", for: indexPath) as? MemoCollectionViewCell else { return UICollectionViewCell() }
//        let list = memoModel[indexPath.item]
//        print("203 \(memoModel)")
//        cell.configure(list)
//        cell.backgroundColor = .white
//        cell.layer.cornerRadius = toggle ? 10 : 0
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        print(memoModel.count)
//        return memoModel.count
//    }
//}
//
////MARK: - UICollectionViewDelegateFlowLayout
//
//extension MemoCollectionController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let interItemSpacing: CGFloat = 10
//        let padding: CGFloat = 16
//        let width = (collectionView.bounds.width - interItemSpacing * 3 - padding * 2) / 3
//        //        print(width)
//        let height = width * 1.2
//        return CGSize(width: width, height: height)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return toggle ? 10 : 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return toggle ? 10 : 0
//    }
//}
//
////MARK: - UICollectionViewDelegate
//
//extension MemoCollectionController: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let item = memoModel[indexPath.item]
//        let vc = MemoWriteViewController()
//        vc.inputTextValue = item.title ?? "n/a"
//        navigationController?.pushViewController(vc, animated: true)
//    }
//}
//
//extension MemoCollectionController: UIGestureRecognizerDelegate {
//
//}
//
//
//
