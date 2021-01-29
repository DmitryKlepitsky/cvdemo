//
//  FileService.swift
//  cv
//
//  Created by Dmitry on 1/29/21.
//

import UIKit

class FileService: NSObject {
    let apiService = DataManager()
    func getImageData(url: String, completion: @escaping (_ data: Data?) -> Void) {
        apiService.getResourceInfo(urlString: url) { [weak self] (res, lastModified) in
            guard let self = self else { return }
            if let _ = res, let lastModified = lastModified
            {
                guard let fileName =  URL(string: url)?.lastPathComponent else { return }
                if self.checkFileNeedsToWrite(fileName: fileName, serverDate: lastModified)
                {
                    self.apiService.getResource(urlString: url) { [weak self] (data) in
                        guard let self = self else { return }
                        if let data = data  {
                            self.saveTempData(data: data, fileName: fileName)
                            completion(data)
                        }
                    }
                } else {
                    let data = FileManager.default.contents(atPath: NSTemporaryDirectory() + fileName)
                    completion(data)
                }
            }
        }
    }
    
    func saveTempData(data: Data, fileName: String) {
        let tmpDir = NSURL(fileURLWithPath: NSTemporaryDirectory())
        if let fileURL = tmpDir.appendingPathComponent(fileName) {
            do {
                try data.write(to: fileURL)
            } catch {
                print("Failed to save file data: \(fileName)")
            }
        }
    }
    
    func checkFileNeedsToWrite(fileName: String, serverDate: Date) -> Bool  {
        let tmpDir = NSTemporaryDirectory()
        let fileURL = tmpDir + fileName
        if let date = (try? FileManager.default.attributesOfItem(atPath: fileURL))?[.creationDate] as? Date {
            return serverDate > date
        } else {
            return true
        }
    }
}
