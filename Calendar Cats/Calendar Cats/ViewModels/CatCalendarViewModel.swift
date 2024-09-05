//
//  CatCalendarViewModel.swift
//  Calendar Cats
//
//  Created by Eric Eddy on 2024-08-29.
//

import Foundation
import Combine
import UIKit

class CatCalendarViewModel: NSObject, ObservableObject, UITableViewDelegate, UITableViewDataSource {
    static var safeTop: CGFloat = 0.0
    static var safeBot: CGFloat = 0.0
    static var cellHeight: CGFloat = 0.0
    static var imageHeights: Dictionary<TimeInterval, CGFloat> = Dictionary() // date int - img height
    let catService = CatService()
    @Published var catsData = [CatData]()
    @Published var offsetY = 0.0
    @Published var datesTitle = ""
    var currentDatesRange: [Date] = []
    var beginningOfWeekDate: Date! = Calendar.current.date(byAdding: .day, value: -(Calendar.current.component(.weekday, from: Date()) - 1), to: Calendar.current.startOfDay(for:Date()))
    var selectedIndex = -1
    var tapLock = false
    
    
    override init() {
        super.init()
        Task {
            await self.wrangleCats()
        }
    }
    func wrangleCats(_ attempt: Int = 0) async {
        updateDateTitle()
        do {
            catsData = try await catService.getCats(beginningOfWeekDate)
            currentDatesRange = getDates()
        } catch let error {
            print("CatError: \(error)")
            if attempt < 4, let e = error as? NetworkError, case NetworkError.dataConversionFailure = e {
                print("Try Again")
                await wrangleCats(attempt + 1)
            }
        }
    }
    func updateDateTitle() {
        let df = DateFormatter()
        df.dateFormat = "MMM dd"
        let dates = getDates()
        guard let firstDate = dates.first,
                let lastDate = dates.last else { return }
        datesTitle = "\( df.string(from: firstDate) ) - \( df.string(from: lastDate) )"
    }
    func gotoNextPage() -> Bool {
        guard let d = Calendar.current.date(byAdding: .day, value: 7, to: beginningOfWeekDate) else { return false }
        catsData = []
        selectedIndex = -1
        goToPage(d)
        return true
    }
    func gotoPrevPage() -> Bool {
        guard let d = Calendar.current.date(byAdding: .day, value: -7, to: beginningOfWeekDate) else { return false }
        catsData = []
        selectedIndex = -1
        goToPage(d)
        return true
    }
    func gotoToday() -> Bool {
        let d = Calendar.current.date(byAdding: .day, value: -(Calendar.current.component(.weekday, from: Date()) - 1), to: Calendar.current.startOfDay(for:Date()))
        if let d = d, d.compare(beginningOfWeekDate) != .orderedSame {
            catsData = []
            selectedIndex = -1
            goToPage(d)
            return true
        }
        return false
    }
    func gotoDate(_ date: Date) -> Bool {
        let d = Calendar.current.date(byAdding: .day, value: -(Calendar.current.component(.weekday, from: date) - 1), to: Calendar.current.startOfDay(for:date))
        if let d = d, d.compare(beginningOfWeekDate) != .orderedSame {
            catsData = []
            selectedIndex = -1
            goToPage(d)
            return true
        }
        return false
    }
    func goToPage(_ date: Date) {
        beginningOfWeekDate = date
        Task {
            await self.wrangleCats()
        }
    }
    func getDates() -> [Date] {
        catService.getDates(beginningOfWeekDate)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CatCalendarCell", for: indexPath) as? CatCalendarCell else {
            return tableView.dequeueReusableCell(withIdentifier: "CatCalendarCell") ?? CatCalendarCell()
        }
        let catData = catsData[indexPath.row]
        cell.setData(catData, offsetY)
        cell.isUserInteractionEnabled = false
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tapLock {
            tableView.deselectRow(at: indexPath, animated: false)
            return
        }
        selectedIndex = indexPath.row == selectedIndex ? -1 : indexPath.row
        offsetY = tableView.contentOffset.y
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let date = catsData[indexPath.row].date.timeIntervalSince1970
        return indexPath.row == selectedIndex ? Self.imageHeights[date] ?? Self.cellHeight : Self.cellHeight
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        tapLock = true
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            tapLock = false
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        tapLock = false
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        offsetY = scrollView.contentOffset.y
    }
}

