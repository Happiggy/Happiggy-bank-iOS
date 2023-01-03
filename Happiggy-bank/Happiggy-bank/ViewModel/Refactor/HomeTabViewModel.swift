//
//  HomeTabViewModel.swift
//  Happiggy-bank
//
//  Created by 권은빈 on 2022/12/26.
//

import CoreData
import Foundation

final class HomeTabViewModel: NSFetchedResultsController<Bottle> {
    
    // MARK: - Properties
    /// 현재 저금통
    var bottle: Bottle?
    
    /// 현재 진행중인 저금통이 있는지 없는지에 대한 불리언 값
    var hasBottle: Bool {
        self.bottle != nil
    }
    
    /// 오늘이 개봉날인지 아닌지에 대한 불리언 값
    var isTodayEndDate: Bool {
        let today = Calendar.current.startOfDay(for: Date()).customFormatted(type: .dot)
        let endDate = self.bottle?.endDate.customFormatted(type: .dot)
        
        return today == endDate
    }
    
    /// 개봉날이 지났는지 아닌지에 대한 불리언 값
    var isEndDatePassed: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        guard let endDate = self.bottle?.endDate
        else { return false }
        
        return today > endDate
    }
    
    /// 쪽지가 있는지 없는지에 대한 불리언 값
    var hasNotes: Bool {
        guard let note = self.bottle?.notes
        else { return false }
        
        return !note.isEmpty
    }
    
    
    override init() {
        super.init()

        let request = Bottle.fetchRequest()
        let result = PersistenceStore.shared.fetch(request: request)
        
        switch result {
        case .success(let bottles):
            guard let firstBottle = bottles.first
            else { return }
            
            self.bottle = firstBottle
        case .failure(let error):
            // TODO: Error Alert
            print(error.localizedDescription)
        }
    }
    
    func dDay() -> String? {
        var dDay: String = ""
        guard let endDate = bottle?.endDate
        else { return nil }
        let prefix = "D"
        let startDate = Date()
        let daysCount = Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: endDate),
            to: Calendar.current.startOfDay(for: startDate)
        )
        guard let days = daysCount.day
        else { return "" }
        
        if days == 0 {
            dDay = prefix + "-" + "\(days)"
        } else if days > 0 {
            dDay = prefix + "+" + "\(days)"
        } else {
            dDay = prefix + "\(days)"
        }
        
        return dDay
    }
    
}
