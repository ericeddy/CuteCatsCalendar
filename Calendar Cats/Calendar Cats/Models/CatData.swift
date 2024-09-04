//
//  CatData.swift
//  Calendar Cats
//
//  Created by Eric Eddy on 2024-08-28.
//

import UIKit

struct CatResponseData: Codable {
    let id: String
    let url: String
    let width: Int
    let height: Int
}


struct CatData: Codable {
    var cat: CatResponseData
    var date: Date = Date()
    var isSelected = false
    func getMonth() -> NSMutableAttributedString {
        let df = DateFormatter()
        df.dateFormat = "EEEE MMM"
        let string = df.string(from: date).uppercased()
        let isToday = date == Calendar.current.startOfDay(for: Date())
        let attr:[NSAttributedString.Key: Any] = [.strokeColor: isToday ?  UIColor.black.withAlphaComponent(0.8) : UIColor.black.withAlphaComponent(0.2), .foregroundColor: UIColor.white, .strokeWidth: 5]
        return NSMutableAttributedString(string: string, attributes: attr)
        
    }
    func getDate() -> NSMutableAttributedString {
        let df = DateFormatter()
        df.dateFormat = "dd"
        let string = df.string(from: date)
        
        let isToday = date == Calendar.current.startOfDay(for: Date())
        let attr:[NSAttributedString.Key: Any] = [.strokeColor: isToday ? UIColor.black.withAlphaComponent(0.8) : UIColor.black.withAlphaComponent(0.15), .foregroundColor: UIColor.white, .strokeWidth: 2]
        return NSMutableAttributedString(string: string, attributes: attr)
    }
}
