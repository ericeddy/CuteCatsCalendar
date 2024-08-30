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
    let catService = CatService()
    @Published var catsData = [CatData]()
    @Published var offsetY = 0.0
    var pageCount = Calendar.current.component(.weekOfYear, from: Date())
    
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
        goToPage(pageCount + 1)
    }
    func gotoPrevPage() {
        catsData = []
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        floor((tableView.window?.screen.bounds.height ?? 375 ) / 3.5)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        offsetY = scrollView.contentOffset.y
    }
}

