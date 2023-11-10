//
//  VideoDetailsView.swift
//  Video Viewer Application
//
//  Created by liene.krista.neimane on 09/09/2023.
//

import SwiftUI
import AVKit

class DownloadManager: NSObject, ObservableObject, URLSessionDownloadDelegate {
    @Published var downloadProgress: Float = 0.0
    @Published var isDownloading = false
    var downloadTask: URLSessionDownloadTask?

    
    let semaphore = DispatchSemaphore(value: 5) // Maximum of 5 concurrent downloads

    func startDownload(_ url: URL) {
        DispatchQueue.global(qos: .background).async {
            self.semaphore.wait() // Decrement semaphore count and wait if count is 0
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            self.downloadTask = session.downloadTask(with: url)
            self.downloadTask?.resume()
            DispatchQueue.main.async {
                self.isDownloading = true
            }
            self.semaphore.signal() // Increment semaphore count when download is finished
        }
    }

    
//    func startDownload(_ url: URL) {
//        DispatchQueue.global(qos: .background).async {
//            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
//            self.downloadTask = session.downloadTask(with: url)
//            self.downloadTask?.resume()
//            DispatchQueue.main.async {
//                self.isDownloading = true
//            }
//        }
//    }

    func cancelDownload() {
        downloadTask?.cancel()
        downloadTask = nil
        isDownloading = false
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        DispatchQueue.main.async {
            self.downloadProgress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsPath.appendingPathComponent("video.mp4")
        
        do {
            try FileManager.default.moveItem(at: location, to: destinationURL)
            print("File downloaded to: \(destinationURL)") // Print the destination URL
        } catch let error as NSError {
            print("Couldn't move video to Documents folder. Error: \(error)")
        }
        
        DispatchQueue.main.async {
            self.isDownloading = false
        }
    }



    // Findings errors
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error as NSError? {
            DispatchQueue.main.async {
                self.isDownloading = false
                switch (error.domain, error.code) {
                case (NSURLErrorDomain, NSURLErrorNetworkConnectionLost):
                    print("Download failed due to network connection loss.")
                case (NSURLErrorDomain, NSURLErrorNotConnectedToInternet):
                    print("Download failed because the device is not connected to the internet.")
                case (NSURLErrorDomain, NSURLErrorTimedOut):
                    print("Download failed because the network connection timed out.")
                case (NSURLErrorDomain, NSURLErrorCannotFindHost):
                    print("Download failed because the host could not be found.")
                case (NSCocoaErrorDomain, NSFileWriteOutOfSpaceError):
                    print("Download failed because the device ran out of space.")
                default:
                    print("Download failed with error: \(error.localizedDescription)")
                }
            }
        }
    }
}


struct VideoDetailsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var downloadManager = DownloadManager()
    var video: Video

    @State private var orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation

    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                VideoPlayer(player: AVPlayer(url: video.video_url))
                    // Adjusts height based on orientation
                    .frame(height: orientation?.isLandscape == true ? UIScreen.main.bounds.height / 2 : UIScreen.main.bounds.width * 9 / 16)
                    .cornerRadius(10)
                    .padding()
                Text(video.name)
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()
                Text(video.description)
                    .padding()
            }
        }
        // Download button
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                VStack {
                    if downloadManager.isDownloading {
                        ProgressView(value: downloadManager.downloadProgress)
                        Text("\(Int(downloadManager.downloadProgress * 100))%")
                        Button("Cancel Download", action: downloadManager.cancelDownload)
                    } else {
                        HStack {
                            Button("Download Video", action: { downloadManager.startDownload(video.video_url) })
                            Image(systemName: "square.and.arrow.down")
                        }
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            self.orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
        }
    }
}
