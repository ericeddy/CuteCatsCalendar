//
//  ViewController.swift
//  Calendar Cats
//
//  Created by Eric Eddy on 2024-08-28.
//

import UIKit
import Combine

class HomeCalendarController: UIViewController {
    let catCalVM = CatCalendarViewModel()
    let calendarView = CatCalendarView()
    let cs = CatService()
    let loader = UIActivityIndicatorView(style: .large)
    var tableRowAnimationOut: UITableView.RowAnimation = .left
    var tableRowAnimationIn: UITableView.RowAnimation = .left
    
    
    var cancellables = Set<AnyCancellable>()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader.layer.cornerRadius = 8
        loader.backgroundColor = .white.withAlphaComponent(0.5)
        loader.hidesWhenStopped = true
        loader.startAnimating()
        
        // Do any additional setup after loading the
        calendarView.backgroundColor = UIColor.background
        calendarView.delegate = catCalVM
        calendarView.dataSource = catCalVM
        
        calendarView.register(CatCalendarCell.self, forCellReuseIdentifier: "CatCalendarCell")
        view.addSubview(calendarView)
        view.addSubview(loader)
        
        let leftGesture = UISwipeGestureRecognizer(target: self, action: #selector(leftSwiped))
        leftGesture.direction = .left
        calendarView.addGestureRecognizer(leftGesture)

        let rightGesture = UISwipeGestureRecognizer(target: self, action: #selector(rightSwiped))
        rightGesture.direction = .right
        calendarView.addGestureRecognizer(rightGesture)
        
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        loader.translatesAutoresizingMaskIntoConstraints = false
        _ = calendarView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        _ = calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        _ = calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        _ = calendarView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        _ = loader.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        _ = loader.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        _ = loader.heightAnchor.constraint(equalToConstant: 72).isActive = true
        _ = loader.widthAnchor.constraint(equalToConstant: 72).isActive = true
        
        catCalVM.$catsData.sink { cats in
            DispatchQueue.main.async {
                print("catsSet")
                let oldPaths: [IndexPath] = self.calendarView.indexPathsForVisibleRows ?? []
                let paths = [IndexPath(row: 0, section: 0),
                             IndexPath(row: 1, section: 0),
                             IndexPath(row: 2, section: 0),
                             IndexPath(row: 3, section: 0),
                             IndexPath(row: 4, section: 0),
                             IndexPath(row: 5, section: 0),
                             IndexPath(row: 6, section: 0)]
                self.calendarView.beginUpdates()
                if oldPaths.count > 0 {
                    self.calendarView.deleteRows(at: paths, with: self.tableRowAnimationOut)
                }
                if cats.count > 0 {
                    self.calendarView.insertRows(at: paths, with: self.tableRowAnimationIn)
                }
                self.calendarView.contentOffset = .init(x: 0, y: -59)
                self.calendarView.endUpdates()
                
                if cats.count > 0 {
                    self.loader.stopAnimating()
                } else {
                    self.loader.startAnimating()
                }
            }
        }.store(in: &cancellables)
        
        catCalVM.$offsetY.sink { offsetY in
            DispatchQueue.main.async {
                print("tablescrolled")
                for cell in self.calendarView.visibleCells as! [CatCalendarCell] {
                    cell.updateImagePosition(offsetY)
                }
            }
        }.store(in: &cancellables)
        
        

    }
    @objc func leftSwiped() {
        catCalVM.gotoNextPage()
        tableRowAnimationOut = .left
        tableRowAnimationIn = .right
        
    }

    @objc func rightSwiped() {
        catCalVM.gotoPrevPage()
        
        tableRowAnimationOut = .right
        tableRowAnimationIn = .left
    }
}

