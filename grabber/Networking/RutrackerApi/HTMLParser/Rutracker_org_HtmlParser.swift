//
//  TorrentListHtmlParser.swift
//  grabber
//
//  Created by Станислав К. on 13.10.2022.
//  Copyright © 2022 Станислав Калиберов. All rights reserved.
//

import Foundation
import Kanna

struct Rutracker_org_HtmlParserError: Error {}

class Rutracker_org_HtmlParser {
    let dateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yy"
        formatter.locale = .init(identifier: "ru_RU")
        return formatter
    }()
    
    func trackers(html: String) -> [TorrentPreviewModel] {
        var models: [TorrentPreviewModel] = []
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8) {
            for object in doc.xpath("//*[@id='tor-tbl']/tbody/tr") {
                let name = object.at_xpath("td[@class='row4 med tLeft t-title-col tt']/div/a")?.text
                let id = object.at_xpath("td[@class='row4 med tLeft t-title-col tt']/div/a")?["data-topic_id"]
                
                let seeds = object.at_xpath("td[@class='row4 nowrap']")?.text
                let downloads = object.at_xpath("td[@class='row4 small number-format']")?.text
                let peers = object.at_xpath("td[@class='row4 leechmed bold']")?.text
                
                let createdDate: Date? = {
                    let createdDateStr = object
                        .at_xpath("td[@class='row4 small nowrap']")?
                        .text?
                        .components(separatedBy: CharacterSet.newlines).joined()
                    if let createdDateStr = createdDateStr {
                        return dateFormatter.date(from: createdDateStr)
                    }
                    return nil
                }()
                
                
                let kByte: Double = {
                    let size = object.at_xpath("td[@class='row4 small nowrap tor-size\']")?.text
                    let number = Double(size?.filter{ "1234567890.".contains($0) } ?? "0") ?? 0
                    
                    if size?.contains("GB") == true {
                        return number * 1000 * 1000
                    } else if size?.contains("MB") == true {
                        return number * 1000
                    } else if size?.contains("KB") == true {
                        return number
                    } else {
                        return 0
                    }
                }()
                
                let model = TorrentPreviewModel(
                    id: id ?? "",
                    name: name ?? "None",
                    kByte: kByte,
                    tags: [],
                    createdDate: createdDate,
                    liveParams: .init(
                        seeds: cleanStringForInt(str: seeds),
                        downloads: cleanStringForInt(str: downloads),
                        peers: cleanStringForInt(str: peers)
                    )
                )
                models.append(model)
            }
        }
        return models
    }
    
    func trackerDetail(html: String) throws -> TorrentDetailModel {
        if let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8) {
            let body = doc.xpath("//*[@class='post_body']").first
            
            return TorrentDetailModel(
                id: "",
                name: body?.at_xpath("span")?.text ?? "None",
                body: body?.text ?? "None",
                image: {
                    if
                        let img = doc.xpath("//*[@class='postImg postImgAligned img-right']").first?.toXML,
                        let url = DetectUrlInString().perform(string: img).first
                    {
                        return url
                    } else {
                        return nil
                    }
                }()
            )
        }
        throw Rutracker_org_HtmlParserError()
    }
    
    private func cleanStringForInt(str: String?) -> Int {
        Int(str?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined() ?? "0") ?? 0
    }
}
