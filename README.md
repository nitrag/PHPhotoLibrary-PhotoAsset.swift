# PHPhotoLibrary-PhotoAsset.swift
### Swift3, iOS 10

PHPhotoLibrary+PhotoAsset PHAsset+identifier kudos to ricardopereira / https://stackoverflow.com/users/3641812/ricardopereira

Created due to https://stackoverflow.com/questions/27008641/save-images-with-phimagemanager-to-custom-album

Save images and videos with phimagemanager to custom album 
A swift extention on top of PHPhotoLibrary usable in both swift and objective c

Check out the view controller file for the implementation and read the PHPhotoLibrary-PhotoAsset.swift file to see the class methods. 

Create Album
Find Album
Save Photo
Save Video 

You'll want to save the images as a temporary file first, so that upon save it preserves the images Metadata and most importantly the EXIF. 
```
import Photos

let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
do{
    let tmpURL = try URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        .appendingPathComponent("temp_image")
        .appendingPathExtension("jpg")
    try imageData?.write(to: tmpURL)
    PHPhotoLibrary.saveImage(imageUrl: tmpURL, albumName: "Your App Name", completion: { (asset) in
        print("Photo Saved", asset)
    })
}catch{
    
}
```
