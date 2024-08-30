//
//  CatCalendarCell.swift
//  Calendar Cats
//
//  Created by Eric Eddy on 2024-08-29.
//

import UIKit
import SDWebImage

class CatCalendarCell: UITableViewCell {
    let catBackground: UIImageView = {
        let img = UIImageView()
        img.contentMode =  .top
        img.clipsToBounds = true
        img.translatesAutoresizingMaskIntoConstraints = false
        img.backgroundColor = UIColor.background
        return img
    }()
    // Making 2 labels to layer them to both avoid and make use of the attributed string issue with rendering strokes
    let monthLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-CondensedBlack", size: 24.0)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        return label
    }()
    let monthLabel2: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-CondensedBlack", size: 24.0)
        label.textColor = .white.withAlphaComponent(0.6)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        return label
    }()
    // Making 2 labels to layer them to both avoid and make use of the attributed string issue with rendering strokes
    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-CondensedBlack", size: 140.0)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        return label
    }()
    let dateLabel2: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue-CondensedBlack", size: 140.0)
        label.textColor = .white.withAlphaComponent(0.6)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        return label
    }()
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.background
        return view
    }()
    var img_topAnchor: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
     required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
         setupUI()
    }
    
    func setupUI() {
        selectionStyle = .none
        backgroundColor = .background
        contentView.clipsToBounds = true
        contentView.backgroundColor = UIColor.background
        containerView.clipsToBounds = true
        containerView.backgroundColor = UIColor.background
        
        containerView.addSubview(catBackground)
        containerView.addSubview(dateLabel2)
        containerView.addSubview(dateLabel)
        containerView.addSubview(monthLabel2)
        containerView.addSubview(monthLabel)
        contentView.addSubview(containerView)
        
        img_topAnchor = catBackground.topAnchor.constraint(equalTo: containerView.topAnchor)
        img_topAnchor.isActive = true
        _ = catBackground.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        _ = catBackground.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        
        _ = dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        _ = dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4).isActive = true
        _ = dateLabel2.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        _ = dateLabel2.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4).isActive = true
        
        
        _ = monthLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        _ = monthLabel.trailingAnchor.constraint(equalTo: dateLabel2.trailingAnchor, constant: -8).isActive = true
        _ = monthLabel2.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        _ = monthLabel2.trailingAnchor.constraint(equalTo: dateLabel2.trailingAnchor, constant: -8).isActive = true
        
        _ = containerView.topAnchor.constraint(equalTo:      contentView.topAnchor).isActive = true
        _ = containerView.bottomAnchor.constraint(equalTo:   contentView.bottomAnchor).isActive = true
        _ = containerView.leadingAnchor.constraint(equalTo:  contentView.leadingAnchor).isActive = true
        _ = containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }
    func setData(_ catData: CatData, _ offsetY: CGFloat) {
        let isToday = catData.date == Calendar.current.startOfDay(for: Date())
        if catBackground.sd_currentImageURL?.absoluteString != catData.cat.url {
            catBackground.sd_setImage(with: URL(string: catData.cat.url)) { [weak self] image, error, _, _ in
                guard let strongSelf = self else { return }
                let img = image?.resizeTopAlignedToFill(newWidth: strongSelf.contentView.frame.width, minHeight: strongSelf.frame.height)
                strongSelf.catBackground.image = img
                strongSelf.updateImagePosition(offsetY)
            }
        }
        
        let date = catData.getDate()
        let month = catData.getMonth()
        monthLabel.attributedText = month
        dateLabel.attributedText = date
        monthLabel2.text = month.string
        dateLabel2.text = date.string
        
        let color: UIColor = isToday ? .white.withAlphaComponent(0.6) : .white.withAlphaComponent(0.4)
        monthLabel2.textColor = color
        dateLabel2.textColor = color
    }
    func updateImagePosition(_ offsetY: CGFloat) {
        let imgH = self.catBackground.image?.size.height ?? 0
        let cellH = self.bounds.height
        let windowH = (window?.windowScene?.screen.bounds.height ?? 800) + cellH
        let diff = max((cellH - imgH), -50)
        
        let positionOnScreen = frame.origin.y - offsetY + cellH
        let factor = max(min((1 - (positionOnScreen / windowH)), 1.0), 0.0)
        let easing = -(cos(.pi * factor) - 1) / 2;
        
        img_topAnchor.constant = imgH == 0 ? 0 : diff * easing
//        if positionOnScreen > windowH {
//            img_topAnchor.constant = 0
//        } else if positionOnScreen < 0 {
//            img_topAnchor.constant = diff
//        } else {
//            
//        }
        
//            let x = cell.catBackground.frame.origin.x
//            let w = cell.catBackground.bounds.width
//
//            let y = ((offsetY - cell.frame.origin.y) / h) * 25
//            cell.img.frame = CGRectMake(x, y, w, h)
    }
}
