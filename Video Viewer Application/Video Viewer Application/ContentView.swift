//
//  ContentView.swift
//  Video Viewer Application
//
//  Created by liene.krista.neimane on 07/09/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var videos: [Video] = []
    
    var body: some View {
        NavigationView {
            List(videos) { video in
                HStack {
                    AsyncImage(url: video.thumbnail) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } placeholder: {
                        ProgressView()
                    }
                    
                    Text(video.name)
                        .font(.headline)
                }
            }
            .navigationTitle("Videos")
            .task {
                do {
                    let url = URL(string: "https://iphonephotographyschool.com/test-api/lessons")!
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
}


// Showing preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
