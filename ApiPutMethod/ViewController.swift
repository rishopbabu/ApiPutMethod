//
//  ViewController.swift
//  ApiPutMethod
//
//  Created by MAC-OBS-26 on 25/05/22.
//
// "/Users/mac-obs-26/Downloads/video.mp4"

import UIKit

typealias Parameters =  [String: String]

struct Media {
    let key: String
    let filename: String
    //let data: Data
    let mimeType: String
    
    init?(withImage image: UIImage, forKey key: String) {
        self.key = key
        self.mimeType = "image/jpeg"
        self.filename = "photo\(arc4random()).jpeg"
//        guard let data = Data(String: String.Encoding.utf8) else { return nil }
//        self.data = data
    }
}

struct MediaTwo {
    let key: String
    let filename: String
    let data: Data
    let mimeType: String

    init?(withData url: URL?, forKey key: String) {
        self.key = key
        self.mimeType = "video/mp4"
        self.filename = "video.mp4"

        guard let data = try? Data(contentsOf: url ?? URL(fileURLWithPath: "")) else { return nil }

        self.data = data
    }
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uploadImage()
    }
    
    func uploadImage() {
        
        let parameters = ["title": "sampletest",
                          "channelId": "61c2f3772e0cbd194220a30b",
                          "categoryId": "61cda3a28d78564104af13e8",
                          "subCategoryId": "61dc18a49264c843dc187dc3",
                          "tags": "Testtwotesttwo",
                          "isUploadedByFan": "false" ]
        
        //let image = UIImage(named: "photo")
        //guard let mediaImage = Media(withImage: image ?? UIImage(), forKey: "file") else { return }
       
        //let fileURL = URL(string: "/Users/mac-obs-26/Downloads/video.mp4")!
        //let fileData = try? Data(contentsOf: fileURL)
        //guard let fileData = MediaTwo(withData: fileData, forKey: "file") else { return }
        
        //let userID = "639aa2616cd74d004c0f929c"
        guard let url = URL(string: "https://api.fanatictv.com/api/v2/video/create_fan_video") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = generateBoundary()
        let tokenStr = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJmYW5hdGljVHYiLCJzdWIiOnsidXNlcklkIjoiNjM5YWEyNjE2Y2Q3NGQwMDRjMGY5MjljIn0sImlhdCI6MTY3MTcxMTA3MTE5NH0.CVExN2khE53t1Q64pt9YLhE5_pHtcZVA_Dxba6PuQe4"
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("jwt \(tokenStr)", forHTTPHeaderField: "Authorization")
        
        let videoURL = URL(fileURLWithPath: "/Users/mac-obs-26/Downloads/video.mp4")
        let videoURLData = MediaTwo(withData: data, forKey: "file")
        
        let dataBody = createDataBody(withParameters: parameters, media: videoURLData, boundary: boundary)
        request.httpBody = dataBody
        
        print(request.httpBody)
        print(dataBody)
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            
            if let data = data {
                do {
                    print(String(data: data, encoding: .utf8) as Any)
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
    
    func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
//    func createDataBody(withParameters params: Parameters?, media: Media?, boundary: String) -> Data {
//
//        let lineBreak = "\r\n"
//        var body = Data()
//
//        if let parameters = params {
//            for (key, value) in parameters {
//                body.append("--\(boundary + lineBreak)")
//                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
//                body.append("\(value + lineBreak)")
//            }
//        }
//        if let media = media {
//            for photo in media {
//                body.append("--\(boundary + lineBreak)")
//                body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename= \"\(photo.filename)\"\(lineBreak)")
//                body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
//                body.append(photo.data)
//                body.append(lineBreak)
//            }
//        }
//
//        body.append("--\(boundary)--\(lineBreak)")
//        return body
//    }
    
    func createDataBody(withParameters params: Parameters?, media: MediaTwo?, boundary: String) -> Data {

        let lineBreak = "\r\n"
        var body = Data()
        
        if let parameters = params {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value + lineBreak)")
            }
        }
        if let media = media {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(media.key)\"; filename= \"\(media.filename)\"\(lineBreak)")
            body.append("Content-Type: \(media.mimeType + lineBreak + lineBreak)")
            body.append(media.data)
            body.append(lineBreak)
        }

        body.append("--\(boundary)--\(lineBreak)")
        return body
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
