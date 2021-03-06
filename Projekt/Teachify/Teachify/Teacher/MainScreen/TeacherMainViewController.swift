//
//  TeacherMainViewController.swift
//  Teachify
//
//  Created by Bastian Kusserow on 10.04.18.
//  Copyright © 2018 Christian Pfeiffer. All rights reserved.
//

import UIKit
import CloudKit
import ObjectiveC

class TeacherMainViewController: UIViewController, CVIndexChanged {

    @IBOutlet var   classesCollectionView: UICollectionView!
    let             dataSource = ClassesCollectionViewDataSource()
    @objc var       delegate : ClassesCollectionViewDelegate!
    var             titleView : UILabel!
    var             loadingIndicator = ProgressIndicatorView(msg: "Downloading")
    private var     currentSelectedSubject = 0
    private var     provider: ICloudUserIDProvider!
    
    
    private var selectedClassIndex : Int = 0
    
    
    @IBOutlet var subjectCollectionView: SubjectCollectionView!
    var subjectDelegate : SubjectCollectionViewDelegate!
    
    @IBOutlet var excerciseCollectionView: UICollectionView!
    let excerciseDataSource = ExerciseCollectionViewDataSource()
    let excerciseDelegate = ExcerciseCollectionViewDelegate()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
        
        setupNotifications()
        provider = ICloudUserIDProvider()
        provider.request()
        
        setupClassesCollectionView()
        setupSubjectCollectionView()
        setupExcerciseCollectionView()
        
        
        view.addSubview(loadingIndicator)
        
        loadData()
        
        if let headerView = classesCollectionView.visibleSupplementaryViews(ofKind: UICollectionElementKindSectionHeader).first as? SegmentedControlHeaderView, let filterSegmentedControl = headerView.filterSegmentedControl {
            //do Stuff
        }
    
        
    }
    
    fileprivate func setupNavBar() {
        titleView = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        titleView.text = "Excercises"
        titleView.textColor = UIColor.white
        titleView.textAlignment = .center
        navigationItem.titleView = titleView
        navigationController?.navigationBar.barTintColor = .barBlue
        //get Rid of Background Shaodw Image in iOS 10
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
    }
    
    fileprivate func setupClassesCollectionView() {
        classesCollectionView.dataSource = dataSource
        delegate = ClassesCollectionViewDelegate(delegate: self)
        classesCollectionView.delegate = delegate
        classesCollectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: [])
    }
    
    fileprivate func setupSubjectCollectionView() {
        subjectDelegate = SubjectCollectionViewDelegate(delegate: self)
        subjectCollectionView.delegate = subjectDelegate
    }
    
    fileprivate func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(setUsername), name: .userNameLoaded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: .excerciseLoaded, object: nil)
    }
    
    @objc private func setUsername(){
        DispatchQueue.main.async { [unowned self] in
            self.navigationItem.prompt = self.provider.username
        }
    }
    
    override func delete(_ sender: Any?){
        print("Delete registered")
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    
    @IBAction func reloadAllData(_ sender: Any) {
       
        loadData()
    }
    
    @objc func reloadTable(){
        print("Notified")
        DispatchQueue.main.async {[weak self] in
            
            self?.classesCollectionView.reloadData()
            self?.subjectCollectionView.collectionView.reloadData()
            self?.excerciseCollectionView.reloadData()
            UIApplication.shared.endIgnoringInteractionEvents()
            self?.loadingIndicator.hide()
        }
    }
    
    func didChangeClassIndex(to: Int) {
        print("changed Index")
        if to == TKModelSingleton.sharedInstance.downloadedClasses.count {
            openCustomAlertView(for: .tkClass)
            return
        }
        subjectCollectionView.dataSource.selectedClass = to
        excerciseDataSource.selectedClass              = to
        subjectCollectionView.collectionView.reloadData()
        subjectCollectionView.collectionView.collectionViewLayout.invalidateLayout()
        subjectCollectionView.collectionView.layoutIfNeeded()
        subjectCollectionView.didSelectItem(at: 0)
        selectedClassIndex = to
        excerciseCollectionView.reloadData()
        
    }
    
    private func openCustomAlertView(for caller : CustomAlertViewCallers){
        let customAlert = self.storyboard?.instantiateViewController(withIdentifier: "CustomAlertViewController") as! CustomAlertViewController
        customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customAlert.caller = caller
        customAlert.delegate = self
        self.present(customAlert, animated: true, completion: nil)
    }
    
    func didChangeSubjectIndex(to: Int) {
        print("Changed subject Index")
        excerciseDataSource.selectedSubject = to
        currentSelectedSubject = to
        excerciseCollectionView.reloadData()
        if to == TKModelSingleton.sharedInstance.downloadedClasses[selectedClassIndex].subjects.count + 1{
            openCustomAlertView(for: .tkSubject)
        }
    }
    
    func loadData(){
        loadingIndicator.show()
        UIApplication.shared.beginIgnoringInteractionEvents()
        let fetchCtrl = TKFetchController()
        fetchCtrl.fetchAll(notificationName: .excerciseLoaded, rank: .teacher)
    }
    
    func setupExcerciseCollectionView(){
        
        excerciseCollectionView.dataSource = excerciseDataSource
        excerciseCollectionView.delegate = excerciseDelegate
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = .barBlue
        //loadData()
    }
  
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //When device is rotated, the layout of te cv should be updated
        excerciseCollectionView.collectionViewLayout.invalidateLayout()
        classesCollectionView.collectionViewLayout.invalidateLayout()
        subjectCollectionView.collectionView.collectionViewLayout.invalidateLayout()
        subjectCollectionView.collectionView.layoutIfNeeded()
        subjectCollectionView.didSelectItem(at: currentSelectedSubject)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        subjectCollectionView.didSelectItem(at: currentSelectedSubject)
        UIView.animate(withDuration: 0.3) { [unowned self] in
            self.titleView.transform = CGAffineTransform(scaleX: 2, y: 2)
        }
    }
    
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Add2AddExercise"{
            let destVC = segue.destination as! AddExerciseFirstScreenViewController
            let selectedClass = TKModelSingleton.sharedInstance.downloadedClasses[selectedClassIndex]
            destVC.selectedClass = selectedClass
        }
    }


    @IBAction func unwindToMain(_ sender: UIStoryboardSegue) {
        let sourceViewController = sender.source
        // Use data from the view controller which initiated the unwind segue
    }

}

extension TeacherMainViewController : CustomAlertViewDelegate{
    
    func cancelButtonTapped() {
        print("Cancel tapped")
        didChangeClassIndex(to: 0)
    }
    
    func okButtonTapped(textFieldValue: String, subjectColor: TKColor, with caller: CustomAlertViewCallers) {
        switch caller {
        case .tkClass:
            uploadClass(with: textFieldValue)
            didChangeClassIndex(to: 0)
        case .tkSubject:
            uploadSubject(with: textFieldValue, color: subjectColor)
            didChangeSubjectIndex(to: 0)
            
        }
    }
    
    private func uploadClass(with className : String){
        let addCtrl = TKAddController()
        let newClass = TKClass(name: className)
        addCtrl.addClass(class: newClass, completion: DispatchQueue.main.async {
            let itemCount = self.classesCollectionView.numberOfItems(inSection: 0)
            let indexPath = IndexPath(item: itemCount-1, section: 0)
            self.classesCollectionView.insertItems(at: [indexPath])
            }
        )
        
    }
    
    private func uploadSubject(with subjectName : String, color: TKColor){
        let newSubject = TKSubject(name: subjectName, color: color)
        let model = TKModelSingleton.sharedInstance
        let addCtrl = TKAddController()
        addCtrl.addSubject(newSubject: newSubject, toClass: model.downloadedClasses[selectedClassIndex]){
            let itemCount = self.subjectCollectionView.collectionView.numberOfItems(inSection: 0)
            let indexPath = IndexPath(item: itemCount-1, section: 0)
            self.subjectCollectionView.collectionView.insertItems(at: [indexPath])
            self.subjectCollectionView.didSelectItem(at: 0)
        }
    }
    
}


protocol CVIndexChanged {
    func didChangeClassIndex(to: Int)
    func didChangeSubjectIndex(to: Int)
}


extension UICollectionView {
    open override var canBecomeFirstResponder: Bool { return true}
}

