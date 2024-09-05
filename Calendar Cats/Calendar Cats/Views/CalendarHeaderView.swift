//
//  CalendarHeaderView.swift
//  Calendar Cats
//
//  Created by Eric Eddy on 2024-09-04.
//

import UIKit

class CalendarHeaderView: UIView {
    let container = UIView()
    let title = UILabel()
    let nextWeekButton = UIButton()
    let lastWeekButton = UIButton()
    let todayButton = UIButton()
    let cornerSize = 8.0
    weak var delegate: HomeControllerProtocol?
    
    var title_topAnchor: NSLayoutConstraint!
    var ctnr_bottomAnchor: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    private func commonInit() {
        backgroundColor = .headerBackground
        layer.cornerRadius = cornerSize
        container.backgroundColor = .headerBackground
        container.layer.cornerRadius = cornerSize
        container.layer.shadowOpacity = 0.2
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height:4)
        
        container.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false
        nextWeekButton.translatesAutoresizingMaskIntoConstraints = false
        lastWeekButton.translatesAutoresizingMaskIntoConstraints = false
        todayButton.translatesAutoresizingMaskIntoConstraints = false
        
        title.font = UIFont(name: "HelveticaNeue-CondensedBlack", size: 18.0)
        title.textAlignment = .center
        
        nextWeekButton.tintColor = .black
        lastWeekButton.tintColor = .black
        todayButton.tintColor = .black
        
        nextWeekButton.setImage(UIImage(named: "arrow-square-right"), for: .normal)
        lastWeekButton.setImage(UIImage(named: "arrow-square-left"), for: .normal)
        todayButton.setImage(UIImage(named: "map-marker-home"), for: .normal)
        
        nextWeekButton.isEnabled = true
        nextWeekButton.isUserInteractionEnabled = true
        
        addSubview(container)
        container.addSubview(title)
        container.addSubview(nextWeekButton)
        container.addSubview(lastWeekButton)
        container.addSubview(todayButton)
        
        _ = trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        _ = leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        _ = topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        ctnr_bottomAnchor = bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ctnr_bottomAnchor.isActive = true
        
        _ = title.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        title_topAnchor = title.topAnchor.constraint(equalTo: container.topAnchor)
        title_topAnchor.isActive = true
        _ = container.bottomAnchor.constraint(equalTo: title.bottomAnchor, constant: 8.0).isActive = true
        _ = title.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        _ = nextWeekButton.lastBaselineAnchor.constraint(equalTo: title.lastBaselineAnchor).isActive = true
        _ = lastWeekButton.lastBaselineAnchor.constraint(equalTo: title.lastBaselineAnchor).isActive = true
        _ = container.trailingAnchor.constraint(equalTo: nextWeekButton.trailingAnchor, constant: 8).isActive = true
        _ = lastWeekButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8).isActive = true
        
        _ = todayButton.lastBaselineAnchor.constraint(equalTo: title.lastBaselineAnchor).isActive = true
        _ = nextWeekButton.leadingAnchor.constraint(equalTo: todayButton.trailingAnchor, constant: 8.0).isActive = true
        
        _ = nextWeekButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        _ = lastWeekButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        _ = todayButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        _ = nextWeekButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        _ = lastWeekButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        _ = todayButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        nextWeekButton.addTarget(self, action: #selector(nextWeek(_:)), for: .touchUpInside)
        lastWeekButton.addTarget(self, action: #selector(lastWeek(_:)), for: .touchUpInside)
        todayButton.addTarget(self, action: #selector(todayTapped(_:)), for: .touchUpInside)
    }
    
    @objc func nextWeek(_ button: UIButton) {
        delegate?.leftSwiped()
        button.simulateClick()
    }
    @objc func lastWeek(_ button: UIButton) {
        delegate?.rightSwiped()
        button.simulateClick()
    }
    @objc func todayTapped(_ button: UIButton) {
        delegate?.todayTapped()
        button.simulateClick()
    }
    
    func updateTitle(_ str: String) {
        title.text = str
    }
    func updateTop() {
        title_topAnchor.constant = CatCalendarViewModel.safeTop
        ctnr_bottomAnchor.constant = -(CatCalendarViewModel.safeTop + cornerSize)
        layoutIfNeeded()
    }
}
