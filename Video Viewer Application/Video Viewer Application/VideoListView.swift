//
//  VideoListView.swift
//  Video Viewer Application
//
//  Created by liene.krista.neimane on 07/09/2023.
//

import SwiftUI
import Alamofire

struct VideoListView: View {
    @State var videos: [Video] = []
    @State var showError = false
    let videoURL = "https://iphonephotographyschool.com/test-api/lessons"
    
    var body: some View {
        NavigationView {
            List(videos) { video in
                NavigationLink(destination: VideoDetailsView(video: video)) {
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
            }
            .navigationTitle("Videos")
            // Pull to refresh
            .refreshable {
                await loadVideos()
            }
            // Videos loaded at launch
            .task {
                await loadVideos()
            }
        }
        .alert(isPresented: $showError) {
            Alert(
                title: Text("Error fetching data!"),
                message: Text("Please try again!"),
                dismissButton: .default(Text("Ok"))
            )
        }
    }

    func loadVideos() async {
        do {
            let url = URL(string: videoURL)!
            let (data, _) = try await URLSession.shared.data(from: url)
            let json = try JSONDecoder().decode([String: [Video]].self, from: data)
            videos = json["lessons"] ?? []
            
            // Added a small test video to see whether downloading can be finished
            if let testVideoURL = URL(string: "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4") {
                let testVideo = Video(id: videos.count + 1,
                                      name: "Test Video",
                                      description: "Video to test downloading.",
                                      thumbnail: testVideoURL,
                                      video_url: testVideoURL)
                videos.append(testVideo)
            }
        } catch {
            // Error in console
            print("Error:", error)
            // Error in app
            self.showError = true
        }
    }

}


struct Video: Identifiable, Decodable {
    let id: Int
    let name: String
    let description: String
    let thumbnail: URL
    let video_url: URL
}



// Showing preview
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        VideoListView()
//    }
//}
