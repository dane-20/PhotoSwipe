//
//  ContentView.swift
//  PhotoSwipe
//
//  Created by Dane Young on 9/23/26.
//

import SwiftUI
import Photos

struct ContentView: View {
    
    @State private var imagesAmount = 0
    @State private var displayImage:UIImage?
    @State private var currentIndex = 0
    @State private var images = PHFetchResult<PHAsset>()
    @State private var dragOffset:CGSize = CGSize.zero // Core Graphics framework, bundles height and width
    @State private var discardArray: [PHAsset] = [] // array of photos swiped left (discard)
    
    var body: some View {
        VStack {
            if let displayImage {
                Image(uiImage: displayImage)
                    .offset(dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged {
                                value in dragOffset = value.translation
                                // print(value.translation)
                            }
                            .onEnded {
                                value in // naming the closure's incoming parameter
                                if value.translation.width >= 150 {
                                    nextImage()
                                    dragOffset = CGSize.zero
                                } else if value.translation.width <= -150 {
                                    discardArray.append(images[currentIndex])
                                    nextImage()
                                    dragOffset = CGSize.zero
                                } else {
                                    dragOffset = CGSize.zero }
                            }
                    )
            } else {
                Image(systemName: "photo")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
            }
            Text("Hello! You have \(imagesAmount) photos on your device.")
                .padding()
            
            Text("You are going to delete \(discardArray.count) photos.")
                .padding()
            
            Button("Next", action: nextImage)
        }
        .onAppear {
            requestPhotoAccessAndCount()
        }
    }
    
    // function that requests photo access and gathers the amount of photos
    private func requestPhotoAccessAndCount() {
        // request user for photo access
        PHPhotoLibrary.requestAuthorization(for:.readWrite) { status in
            guard status == .authorized || status == .limited else { return }
            
            // images fetched from the user's phone (PHFetchResult<PHAsset> Object)
            images = PHAsset.fetchAssets(with: .image, options: nil)
            print(images.count)
            
            // Schedules the state update to run on the main thread,
            // since @State must only be mutated from main
            DispatchQueue.main.async {
                imagesAmount = images.count
            }
            
            loadImage(from: images[currentIndex])
            //            for i in 0...images.count {
            //                loadImage(from: images[i])
            //            }
        }
    }
    
    private func loadImage(from asset: PHAsset) {
        // TODO: grab a single image and display it on the screen!
        PHImageManager.default().requestImage(for:asset, targetSize: CGSize(width: 500, height: 500), contentMode: .aspectFit, options: nil, resultHandler: { image, info in
            if let unwrappedImage = image {
                DispatchQueue.main.async {
                    displayImage = unwrappedImage
                }
            }})
    }
    
    private func nextImage() {
        if currentIndex >= imagesAmount - 1 {
            return
        }
        currentIndex += 1
        loadImage(from: images[currentIndex])
    }
}

#Preview {
    ContentView()
}
