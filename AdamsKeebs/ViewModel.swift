//
//  ViewModel.swift
//  AdamsKeebs
//
//  Created by Adam Smith on 16/12/1401 AP.
//

import Foundation
import SwiftUI

struct MechMarket: Hashable, Codable {
    let kind: String?
    let data: MechData
}

struct MechData: Hashable, Codable {
    let children: [ChildData]
}

struct ChildData: Hashable, Codable {
    let kind: String?
    let data: PostData
}

struct PostData: Hashable, Codable {
    let selftext: String
    let title: String
}

class ViewModel: ObservableObject {
    @Published var post: [PostData] = []
    @Published var loadedImageURLs = Set<String>()
    
    func fetch() {
        guard let url = URL(string: "https://www.reddit.com/r/mechmarket/new.json") else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                return
            }
            do {
                let postData = try JSONDecoder().decode(MechMarket.self, from: data)
                let post = postData.data.children.map({ $0.data })
                DispatchQueue.main.sync {
                    self.post = post
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }
}
