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
    static var cellHeight: CGFloat = 0.0
    static var imageHeights: Dictionary<TimeInterval, CGFloat> = Dictionary() // date int - img height
    let catService = CatService()
    @Published var catsData = [CatData]()
    @Published var offsetY = 0.0
    var pageCount = Calendar.current.component(.weekOfYear, from: Date())
    var selectedIndex = -1
    var tapLock = false
    
    
    override init() {
        super.init()
        Task {
            await self.wrangleCats()
        }
    }
    func wrangleCats(_ attempt: Int = 0) async {
        do {
            catsData = try await catService.getCats(search: "", pageCount, 7)
        } catch let error {
            print("CatError: \(error)")
            if attempt < 4, let e = error as? NetworkError, case NetworkError.dataConversionFailure = e {
                print("Try Again")
                await wrangleCats(attempt + 1)
            }
        }
    }
    func gotoNextPage() {
        catsData = []
        selectedIndex = -1
        goToPage(pageCount + 1)
    }
    func gotoPrevPage() {
        catsData = []
        selectedIndex = -1
        goToPage(pageCount - 1)
    }
    
    func goToPage(_ page: Int) {
        pageCount = page
        if page > 51 {
            pageCount = 51
        } else if page < 0 {
            pageCount = 0
        }
        Task {
            await self.wrangleCats()
        }
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
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        tapLock = false
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        offsetY = scrollView.contentOffset.y
    }
}

