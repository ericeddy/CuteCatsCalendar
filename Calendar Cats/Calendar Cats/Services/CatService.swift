//
//  CatService.swift
//  Calendar Cats
//
//  Created by Eric Eddy on 2024-08-28.
//

import Foundation
import Network

class CatService: APIService<CatWranglingRequest>, CatWranglingProtocol {
    
    func getCats(_ beginningOfWeekDate: Date) async throws -> [CatData] {
        let cats = try await request([CatResponseData].self, router: .getCats(beginningOfWeekDate))
        return wrapCats(cats, beginningOfWeekDate)
    }
                                     
//    func getCats(search: String, _ page: Int, _ year: Int, _ limit: Int) async throws -> [CatData] {
//        let cats = try await request([CatResponseData].self, router: .getCats(search: "", page, limit))
//        return wrapCats(cats, page, year)
//    }
                                     
    func getDates(_ date: Date) -> [Date] {
        var dates: [Date] = []
        let calendar = Calendar.current 
        
//        guard let todayYearBad = calendar.date(bySetting: .weekOfYear, value: page, of:  calendar.startOfDay(for:Date())),
//         let today = calendar.date(bySetting: .year, value: year, of: todayYearBad) else {
//            print("bad date via weekOfYear")
//            return [Date()]
//        }
        let dayOfWeek = calendar.component(.weekday, from: date)
        guard let range = calendar.range(of: .weekday, in: .weekOfYear, for: date) else {
            print("bad date ranges")
            return [Date()]
        }
        dates = range.compactMap { calendar.date(byAdding: .day, value: $0 - dayOfWeek, to: date) }
        print(dates)
        return dates
    }
    
    func wrapCats(_ cats:[CatResponseData], _ date: Date) -> [CatData] {
        var wrappedCats: [CatData] = []
        var i = 0
        let dates = getDates(date)
        for cat in cats {
            wrappedCats.append(CatData(cat: cat, date: dates[i]))
            i = i + 1
        }
        return wrappedCats
    }
}

protocol CatWranglingProtocol {
    func getCats(_ beginningOfWeekDate: Date) async throws -> [CatData]
//    func getCats(search: String, _ page: Int, _ year: Int, _ limit: Int) async throws -> [CatData]
}

enum CatWranglingRequest: APIServiceRequest {
    case getCats(_ beginningOfWeekDate: Date)
//    case getCats(search: String, _ page: Int, _ limit: Int)
    
    var config: any APIServiceConfig {
        CatConfig()
    }
    
    var endpoint: String {
        switch self {
        case .getCats:
            "/images/search"
        }
    }
    
    var method: String {
        "GET"
    }
    var composedURL: String {
        switch self {
        case .getCats(let date):
            let page = Calendar.current.component(.weekOfYear, from: date)
            return "\(config.baseURL)\(endpoint)?\(config.getParams(page, 7))"
        }
        
    }
}

struct CatConfig: APIServiceConfig {
    let baseURL = "https://api.thecatapi.com/v1"
    func getParams(_ page: Int, _ limit: Int) -> String {
        getParams(page, limit, "small", "jpg", "json", "true", "ASC")
    }
    func getParams(_ page: Int, _ limit: Int, _ size: String, _ mime_types: String, _ format: String, _ has_breeds: String, _ order: String) -> String {
        "size=\(size)&mime_types=\(mime_types)&format=\(format)&has_breeds=\(has_breeds)&order=\(order)&page=\(page)&limit=\(limit)"
    }
}
