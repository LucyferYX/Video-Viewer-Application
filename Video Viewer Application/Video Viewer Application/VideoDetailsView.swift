//
//  VideoDetailsView.swift
//  Video Viewer Application
//
//  Created by liene.krista.neimane on 09/09/2023.
//

import SwiftUI

struct VideoDetailsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var video: Video

    var body: some View {
        VStack(alignment: .center) {
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
    }
}

