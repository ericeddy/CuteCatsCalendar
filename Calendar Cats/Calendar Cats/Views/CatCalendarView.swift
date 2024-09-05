//
//  CatCalendarView.swift
//  Calendar Cats
//
//  Created by Eric Eddy on 2024-08-29.
//

import UIKit

class CatCalendarView: UITableView {
    // https://stackoverflow.com/a/44391970 -- using autolayout with headerviews
    func setTableHeaderView(headerView: UIView) {
        headerView.translatesAutoresizingMaskIntoConstraints = false

        self.tableHeaderView = headerView

        // ** Must setup AutoLayout after set tableHeaderView.
        headerView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        headerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        headerView.topAnchor.constraint(equalTo: self.topAnchor, constant: -CatCalendarViewModel.safeTop).isActive = true
    }

    func shouldUpdateHeaderViewFrame() -> Bool {
        guard let headerView = self.tableHeaderView else { return false }
        let oldSize = headerView.bounds.size
        // Update the size
        headerView.layoutIfNeeded()
        let newSize = headerView.bounds.size
        return oldSize != newSize
    }
}
