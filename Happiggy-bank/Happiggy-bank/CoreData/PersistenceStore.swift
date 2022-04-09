//
//  PersistenceStore.swift
//  Happiggy-bank
//
//  Created by sun on 2022/03/08.
//

import CoreData
import UIKit

import Then

/// 싱글턴 패턴을 사용해 앱 전체에서 하나의 Persistence Container 를 통해 엔티티 인스턴스를  저장, 삭제하도록 함
class PersistenceStore {
    
    // MARK: - Core Data Stack
    
    /// 앱 전체에서 공유되는 단일 PersistenceStore
    static var shared: PersistenceStore = {
        PersistenceStore(name: StringLiteral.sharedPersistenceStoreName)
    }()

    static private(set) var fatalErrorNeeded = false
    
    /// persistence container 의 viewContext 에 접근하기 위한 syntactic sugar
    private(set) lazy var context: NSManagedObjectContext = {
        self.persistentContainer.viewContext
    }()
    
    private let persistentContainer: NSPersistentContainer
    
    weak var windowScene: UIWindowScene?
    
    
    // MARK: - Init(s)
    private init(name: String) {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        self.persistentContainer = NSPersistentContainer(name: name).then {
            $0.loadPersistentStores { _, error in
                if let error = error as NSError? {
                    PersistenceStore.fatalErrorNeeded = true
                    print(error.localizedDescription)
                    print(error.userInfo)
                }
            }
        }
    }
    
    
    // MARK: - Core Data Fetching support
    
    /// 코어데이터를 불러오기 위한 syntactic sugar
    func fetch<T: NSManagedObject>(request: NSFetchRequest<T>) -> [T] {
        do {
            let items = try self.context.fetch(request)
            return items
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    
    // MARK: - Core Data Saving support
    
    /// 현재 context 를 저장, 에러가 발생하면 설정한 에러 메시지(기본은 에러 이름)를 출력함
    func save(errorMessage: String? = nil) {
        if self.context.hasChanges {
            do {
                try self.context.save()
            } catch {
                let nserror = error as NSError
                if let errorMessage = errorMessage {
                    print("\(errorMessage)+\(nserror.localizedDescription)+\(nserror.userInfo)")
                } else {
                    print("\(nserror.localizedDescription), \(nserror.userInfo)")
                }
                
                self.presentErrorAlert(
                    title: StringLiteral.saveErrorTitle,
                    message: StringLiteral.saveErrorMessage
                )
            }
        }
    }
    
    
    // MARK: - Core Data Deleting support
    /// TODO: 개발 단계 편의를 위한 메서드로 추후 삭제
    
    /// 엔티티 인스턴스 삭제
    func delete(_ object: NSManagedObject) {
        self.context.delete(object)
        self.save()
    }
    
    /// 엔티티의 모든 인스턴스 삭제
    func deleteAll<T: NSManagedObject>(_ type: T.Type) {
        let request = type.fetchRequest()
        let delete = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try self.context.execute(delete)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    // MARK: - Alert
    
    /// 작업 실패 시 알림
    private func presentErrorAlert(
        title: String?,
        message: String?,
        handler: ((UIAlertAction) -> Void)? = nil
    ) {
        let alert = self.makeErrorAlert(
            title: title,
            message: message,
            handler: handler
        )
        self.windowScene?.topMostViewController?.present(alert, animated: true)
    }
    
    /// 알림 생성
    private func makeErrorAlert(
        title: String?,
        message: String?,
        handler: ((UIAlertAction) -> Void)? = nil
    ) -> UIAlertController {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let confirmationAction = UIAlertAction(
            title: StringLiteral.okButtonTitle,
            style: .default
        ) { action in
            guard let handler = handler
            else { return }
            
            handler(action)
        }

        alert.addAction(confirmationAction)
        return alert
    }
}
