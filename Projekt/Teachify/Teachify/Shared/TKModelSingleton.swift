//
//  GameCardModel.swift
//  Teachify
//
//  Created by Christian Pfeiffer on 12.04.18.
//  Copyright © 2018 Christian Pfeiffer. All rights reserved.
//

import UIKit

//MARK: TKModelSingleton
class TKModelSingleton {
    //TODO Zugriffsschicht
    static let sharedInstance = TKModelSingleton()
    var downloadedClasses : [TKClass] = []
    
    private init (){}
}


//############################################
//MARK: TKFetchController
class TKFetchController: NSObject {
    fileprivate var model = TKModelSingleton.sharedInstance
    private var teacherCtrl : TKTeacherController = TKTeacherController()
    
    
    private override init() {
        super.init()
    }
    
    init(rank: TKRank){
        super.init()
        model.downloadedClasses = []
        
    }
    
    ///    Debug Print after Data is downloaded.
    private func debugPrintAfterFetch () {
        for myclass in model.downloadedClasses {
            print("Downloaded Class: \(myclass.name) DOwnload Subject: \(myclass.subjects.last?.name)" +
                "Download Documents: \(myclass.subjects.last?.documents.last?.name)" +
                "Downloaded Excercise: \(myclass.subjects.last?.documents.last?.exercises.last?.name)")
        }
        
        
    }
}


//#####################################################
//MARK: Zugriffsschicht
extension TKFetchController{
    
    /* For Queries in the already fetched Model */
    func getClassIndexForName(queryName : String) -> Int{
        
        let index = model.downloadedClasses.index { (myclass) -> Bool in
            if (myclass.name == queryName){
                return true
            }
                return false
        }
        
        if let returnIndex = index {
            return returnIndex
        }
        return -1
    }
    
    func getClasses() -> [TKClass] {
        return model.downloadedClasses
    }
    
    func getClassForIndex(myIndex: Int) -> TKClass{
        return model.downloadedClasses[myIndex]
    }
    
    //    func getSubjectsForClassRecord (queryRecord : CKRecord){
    //        var postition : Int
    //
    //
    //    }
    
    func fetchAll(notificationName : Notification.Name? = nil) {
        let classesOperation    = ClassOperation()
        let subjectOperation    = SubjectOperation()
        let documentOperation   = DocumentOperation()
        let exerciseOperation   = ExerciseOperation()
        var subjects            = [TKSubject]()
        
        classesOperation.completionBlock = {
            subjectOperation.classes = TKModelSingleton.sharedInstance.downloadedClasses
        }
        
        subjectOperation.completionBlock = {
            subjects = TKModelSingleton.sharedInstance.downloadedClasses.flatMap({$0.subjects})
            documentOperation.subjects = subjects
        }
        documentOperation.completionBlock = {
            exerciseOperation.documents = subjects.flatMap({$0.documents})
        }
        exerciseOperation.completionBlock = {
            if let notificationName = notificationName {
                print("Completion Block")
                DispatchQueue.main.async {
                    NotificationCenter.default.post(Notification(name: notificationName))
                }
            }
        }
        //Setting Dependencies
        subjectOperation.addDependency(classesOperation)
        documentOperation.addDependency(subjectOperation)
        exerciseOperation.addDependency(documentOperation)
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.addOperations([classesOperation,subjectOperation,documentOperation,exerciseOperation], waitUntilFinished: false)
        
    }
    
    func fetchClasses(){
        let classesOperation = ClassOperation()
        let queue = OperationQueue()
        queue.addOperation(classesOperation)
    }
    
    func fetchSubjects(for classes : [TKClass]){
        let subjectOperation = SubjectOperation()
        subjectOperation.classes = classes
        let queue = OperationQueue()
        queue.addOperation(subjectOperation)
        
    }
    
    func fetchDocuments(for subjects: [TKSubject]){
        let documentOperation = DocumentOperation()
        documentOperation.subjects = subjects
        let queue = OperationQueue()
        queue.addOperation(documentOperation)
    }
    
    func fetchExercise(for documents: [TKDocument], notificationName: Notification.Name){
        let exerciseOperation = ExerciseOperation()
        exerciseOperation.documents = documents
        let queue = OperationQueue()
        queue.addOperation(exerciseOperation)
    }
    
    
}
