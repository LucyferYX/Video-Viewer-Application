//
//  VideoListView.swift
//  Video Viewer Application
//
//  Created by liene.krista.neimane on 07/09/2023.
//

import SwiftUI
import Alamofire

struct VideoListView: View {
    @State private var videos: [Video] = []
    let videoURL = "https://iphonephotographyschool.com/test-api/lessons"
    
    var body: some View {
        NavigationView {
            List(videos) { video in
                HStack {
                    // Video thumbnail
                    AsyncImage(url: video.thumbnail) { image in
                        image
                            .resizable()
                            // Square
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } placeholder: {
                        ProgressView()
                    }
                    // Video title
                    Text(video.name)
                        .font(.body)
                }
            }
            .navigationTitle("Videos")
            .refreshable {
                do {
                    let url = URL(string: videoURL)!
                    let (data, _) = try await URLSession.shared.data(from: url)
                    let json = try JSONDecoder().decode([String: [Video]].self, from: data)
                    videos = json["lessons"] ?? []
                } catch {
                    print("Error fetching videos:", error)
                }
            }
        }
    }
}


struct Video: Identifiable, Decodable {
    let id: Int
    let name: String
    let thumbnail: URL
    let description: String
}


// Showing preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        VideoListView()
    }
}
