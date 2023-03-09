//
//  ContentView.swift
//  AdamsKeebs
//
//  Created by Adam Smith on 15/12/1401 AP.
//

import SwiftUI
import URLImage

func extractImageURLs(from text: String) -> Set<String> {
    let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
    var urls = Set<String>()
    for match in matches {
        guard let range = Range(match.range, in: text),
              let url = URL(string: String(text[range])),
              url.host?.contains("imgur.com") == true else {
            continue
        }
        let urlString = url.absoluteString
        if !urls.contains(urlString) {
            urls.insert(urlString)
        }
    }
    return urls
}

//: MARK - Original
struct NewPostView: View {
    @StateObject var viewModel = ViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.post, id: \.self) { post in
                NavigationLink(destination: PostDetailView(post: post)) {
                    VStack {
                        Text(post.title)
                            .font(.headline)
                        if let imageURLs = extractImageURLs(from: post.selftext), !imageURLs.isEmpty {
                            ScrollView(.horizontal) {
                                HStack {
                                    let uniqueImageURLs = Set(imageURLs).filter { !viewModel.loadedImageURLs.contains($0)}
                                    ForEach(Array(uniqueImageURLs), id: \.self) { url in
                                        let _ = print("Loading image from URL: \(url)")
                                        AsyncImage(url: URL(string: url)) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .onAppear() {
                                                    viewModel.loadedImageURLs.insert(url)
                                                }
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .frame(height: 100)
                                        .id(url)
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
    let imageURLs: Set<String>
    
    init(post: PostData) {
        self.post = post
        self.imageURLs = extractImageURLs(from: post.selftext)
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                Text(post.title)
                    .font(.headline)
                if !imageURLs.isEmpty {
                    ScrollView(.horizontal) {
                        HStack(spacing: 10) {
                            ForEach(Array(imageURLs), id: \.self) { url in
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
