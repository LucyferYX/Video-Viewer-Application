//
//  VideoDetailsView.swift
//  Video Viewer Application
//
//  Created by liene.krista.neimane on 09/09/2023.
//

import SwiftUI
import AVKit

struct VideoDetailsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var video: Video

    var body: some View {
        VStack(alignment: .center) {
            VideoPlayer(player: AVPlayer(url: video.video_url))
                .frame(height: 200)
                .cornerRadius(10)
                .padding()
            Text(video.name)
                .font(.title)
                .multilineTextAlignment(.center)
                .padding()
            Text(video.description)
                .padding()
        }
        // Download button
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Downloading thing
                }) {
                    HStack {
                        Text("Download video")
                        Image(systemName: "square.and.arrow.down")
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
}
