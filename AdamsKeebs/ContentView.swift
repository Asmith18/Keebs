//
//  ContentView.swift
//  AdamsKeebs
//
//  Created by Adam Smith on 15/12/1401 AP.
//

import SwiftUI
import URLImage

func extractImageURLs(from text: String) -> [String]? {
    let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
    return matches.compactMap { match in
        guard let range = Range(match.range, in: text) else { return nil }
        let urlString = text[range]
        let url = URL(string: String(urlString))
        if let host = url?.host, host.contains("imgur.com") {
            return url?.absoluteString
        } else {
            return nil
        }
    }
}


struct NewPostView: View {
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.post, id: \.self) { post in
                NavigationLink(destination: PostDetailView(post: post)) {
                    VStack {
                        Text(post.title)
                            .font(.headline)
                        if let imageURLs = extractImageURLs(from: post.selftext) {
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(imageURLs, id: \.self) { url in
                                        let _ = print(imageURLs)
                                        AsyncImage(url: URL(string: url)) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .frame(height: 200)
                                        
                                    }
                                    
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Mech Market")
            .onAppear() {
                viewModel.fetch()
            }
        }
    }
}

struct PostDetailView: View {
    let post: PostData
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                Text(post.title)
                    .font(.headline)
                if let imageURLs = extractImageURLs(from: post.selftext) {
                    ScrollView(.horizontal) {
                        HStack(spacing: 10) {
                            ForEach(imageURLs, id: \.self) { url in
                                AsyncImage(url: URL(string: url)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(height: 200)
                            }
                        }
                    }
                }
                Text(post.selftext)
                    .font(.headline)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NewPostView()
    }
}
