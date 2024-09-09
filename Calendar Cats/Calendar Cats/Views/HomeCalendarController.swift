//
//  ViewController.swift
//  Calendar Cats
//
//  Created by Eric Eddy on 2024-08-28.
//

import UIKit
import Combine

class HomeCalendarController: UIViewController, HomeControllerProtocol {
    let picker: UIDatePicker = UIDatePicker()
    let catCalVM = CatCalendarViewModel()
    let calendarView = CatCalendarView()
    let headerView = CalendarHeaderView()
    let loader = UIActivityIndicatorView(style: .large)
    var tableRowAnimationOut: UITableView.RowAnimation = .left
    var tableRowAnimationIn: UITableView.RowAnimation = .left
    var swipeLock = true
    var pckr_topAnchor: NSLayoutConstraint!
    var pckr_heightAnchor: NSLayoutConstraint!
    
    var cancellables = Set<AnyCancellable>()
    override func viewDidLoad() {
        super.viewDidLoad()
        CatCalendarViewModel.cellHeight = floor((view.window?.screen.bounds.height ?? 800 ) / 3.5)
        loader.layer.cornerRadius = 8
        loader.backgroundColor = .white.withAlphaComponent(0.5)
        loader.hidesWhenStopped = true
        loader.startAnimating()
        
        // Do any additional setup after loading the
        calendarView.backgroundColor = UIColor.background
        calendarView.delegate = catCalVM
        calendarView.dataSource = catCalVM
        calendarView.allowsSelection = true
        calendarView.allowsMultipleSelection = false
        calendarView.register(CatCalendarCell.self, forCellReuseIdentifier: "CatCalendarCell")
        
        headerView.delegate = self
        
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.tintColor = .gray
        picker.layer.backgroundColor = UIColor.white.cgColor
        picker.layer.cornerRadius = 8
        picker.clipsToBounds = true
        picker.date = catCalVM.beginningOfWeekDate
        picker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)

        view.addSubview(calendarView)
        view.addSubview(loader)
        view.addSubview(picker)
        
        let leftGesture = UISwipeGestureRecognizer(target: self, action: #selector(leftSwiped))
        leftGesture.direction = .left
        calendarView.addGestureRecognizer(leftGesture)

        let rightGesture = UISwipeGestureRecognizer(target: self, action: #selector(rightSwiped))
        rightGesture.direction = .right
        calendarView.addGestureRecognizer(rightGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(checkCellTapped))
        tapGesture.numberOfTapsRequired = 1
        calendarView.addGestureRecognizer(tapGesture)
        
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        loader.translatesAutoresizingMaskIntoConstraints = false
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        _ = calendarView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        _ = calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        _ = calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        _ = calendarView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        _ = loader.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        _ = loader.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        _ = loader.heightAnchor.constraint(equalToConstant: 72).isActive = true
        _ = loader.widthAnchor.constraint(equalToConstant: 72).isActive = true
        
        pckr_topAnchor = picker.topAnchor.constraint(equalTo: view.topAnchor, constant: 100)
        pckr_topAnchor.isActive = true
        _ = picker.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pckr_heightAnchor = picker.heightAnchor.constraint(equalToConstant: 330)
        pckr_heightAnchor.isActive = true
        _ = picker.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
        
        catCalVM.$catsData.sink { cats in
            DispatchQueue.main.async {
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
                self.calendarView.contentOffset = .init(x: 0, y: -CatCalendarViewModel.safeTop)
                self.calendarView.endUpdates()
                
                if cats.count > 0 {
                    self.loader.stopAnimating()
                    self.swipeLock = false
                } else {
                    self.loader.startAnimating()
                }
            }
        }.store(in: &cancellables)
        
        catCalVM.$offsetY.sink { offsetY in
            DispatchQueue.main.async {
                for cell in self.calendarView.visibleCells as! [CatCalendarCell] {
                    cell.updateImagePosition(offsetY)
                }
                self.pckr_topAnchor.constant = -offsetY
                self.view.layoutIfNeeded()
            }
        }.store(in: &cancellables)
        
        catCalVM.$datesTitle.sink { title in
            DispatchQueue.main.async {
                self.headerView.updateTitle(title)
//                for cell in self.calendarView.visibleCells as! [CatCalendarCell] {
//                    cell.updateImagePosition(offsetY)
//                }
            }
        }.store(in: &cancellables)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        CatCalendarViewModel.safeTop = view.window?.safeAreaInsets.top ?? 0.0
        CatCalendarViewModel.safeBot = view.window?.safeAreaInsets.bottom ?? 0.0
        calendarView.setTableHeaderView(headerView: headerView)
        headerView.updateTop()
        pckr_heightAnchor.constant = 0 //this lets the calendar draw once at 330 before hiding it so that first display renders better
        calendarView.contentOffset = .init(x: 0, y: -CatCalendarViewModel.safeTop)
        catCalVM.scrollViewDidScroll(calendarView)
    }
    // go to next
    @objc func leftSwiped() {
        if swipeLock { return }
        tableRowAnimationOut = .left
        tableRowAnimationIn = .right
        swipeLock = catCalVM.gotoNextPage()
    }
    // go to previous
    @objc func rightSwiped() {
        if swipeLock { return }
        tableRowAnimationOut = .right
        tableRowAnimationIn = .left
        swipeLock = catCalVM.gotoPrevPage()
    }
    @objc func todayTapped() {
        if swipeLock { return }
        compareDate(catCalVM.currentDatesRange[0], Date())
        swipeLock = catCalVM.gotoToday()
        
    }
    func compareDate(_ d1: Date, _ d2: Date){
        let compare = d1.compare(d2)
        switch compare {
        case .orderedAscending:
            tableRowAnimationOut = .left
            tableRowAnimationIn = .right
            break
        case .orderedDescending:
            tableRowAnimationOut = .right
            tableRowAnimationIn = .left

            break
        default:
            tableRowAnimationOut = .right
            tableRowAnimationIn = .left
            break
        }
    }
    @objc func gotoDate(_ date: Date) {
        if swipeLock { return }
        compareDate(catCalVM.currentDatesRange[0], date)
        swipeLock = catCalVM.gotoDate(date)
        
    }
    func getDates() -> [Date] {
        catCalVM.getDates()
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        DispatchQueue.main.async {
            self.gotoDate(sender.date)
        }
    }
    func showDatePicker() {
        DispatchQueue.main.async {
            self.picker.setDate(self.catCalVM.beginningOfWeekDate, animated: false)
            self.pckr_heightAnchor.constant = 330
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
            
        }
    }
    func hideDatePicker() {
        DispatchQueue.main.async {
            self.pckr_heightAnchor.constant = 0
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func checkCellTapped(sender: UITapGestureRecognizer? = nil ) {
        if pckr_heightAnchor.constant > 0 {
            hideDatePicker()
            return
        }
        if let touchPoint = sender?.location(ofTouch: 0, in: calendarView), let headerTouchPoint = sender?.location(ofTouch: 0, in: headerView)  {
            if headerView.container.frame.contains(headerTouchPoint) {
                if let containerTouchPoint = sender?.location(ofTouch: 0, in: headerView.container) {
                    let next = headerView.nextWeekButton.frame.contains(containerTouchPoint)
                    let prev = headerView.lastWeekButton.frame.contains(containerTouchPoint)
                    let today = headerView.todayButton.frame.contains(containerTouchPoint)
                    let title = headerView.title.frame.contains(containerTouchPoint)
//                    print("\(next) \(prev) \(today) \(title)")
                    DispatchQueue.main.async {
                        if next {
                            self.headerView.nextWeekButton.sendActions(for: .touchUpInside)
                        } else if prev {
                            self.headerView.lastWeekButton.sendActions(for: .touchUpInside)
                        } else if today {
                            self.headerView.todayButton.sendActions(for: .touchUpInside)
                        } else if title {
                            self.showDatePicker()
                        }
                    }
                }
                
            } else if let indexPath = calendarView.indexPathForRow(at: touchPoint) {
                DispatchQueue.main.async {
                    self.calendarView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                    self.calendarView.delegate?.tableView!(self.calendarView, didSelectRowAt: indexPath)
                }
            }
            
//                print("header: \(headerView.frame) \(headerView.container.frame) \(catCalVM.offsetY) \(touchPoint)")
//            {
//                print("inside header")
//                if headerView.nextWeekButton.frame.contains(touchPoint) {
//                    print("inside next")
//                }
//                
//            }
        }
    }
}
@objc protocol HomeControllerProtocol {
    @objc func leftSwiped()
    @objc func rightSwiped()
    @objc func todayTapped()
    @objc func gotoDate(_ date: Date)
    func getDates() -> [Date]
}
