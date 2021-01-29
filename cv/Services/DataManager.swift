//
//  DataManager.swift
//  cv
//
//  Created by Dmitry on 1/27/21.
//

import UIKit
import CoreData

class DataManager: NSObject {
    private let sourcesURL = URL(string: "https://api.mocki.io/v1/b43fe08c")!
    var coreDataManager: CoreDataManager = CoreDataManager(modelName: "cv")
    
    // MARK: - Album Data handlers
    func getAlbumList(completion : @escaping ([Album], Error?) -> ()) {
        URLSession.shared.dataTask(with: sourcesURL) { (data, urlResponse, error) in
            if let error = error {
                completion([], error)
                return
            }
            if let data = data {
                let jsonDecoder = JSONDecoder()
                guard let codingKey = CodingUserInfoKey.context else {
                    fatalError("Failed to retrieve managed object context Key")
                }
                
                jsonDecoder.userInfo[codingKey] = self.coreDataManager.managedObjectContext
                self.clearAlbumsCache()
                let empData = try! jsonDecoder.decode([Album].self, from: data)
                self.coreDataManager.saveContext()
                completion(empData, nil)
            }
        }.resume()
     }
    
    func clearAlbumsCache() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Album")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try self.coreDataManager.managedObjectContext.execute(batchDeleteRequest)
        } catch {
            
        }
    }
    
    func getCachedAlbumList(completion : @escaping ([Album]) -> ()) {
        let fetchRequest = NSFetchRequest<Album>(entityName: "Album")
        fetchRequest.resultType = .managedObjectResultType
        fetchRequest.sortDescriptors =  [NSSortDescriptor(keyPath: \Album.id, ascending: true)]
        do {
            let albums : [Album] = try self.coreDataManager.managedObjectContext.fetch(fetchRequest)
            completion(albums)
        }
        catch {
            fatalError("Failed to retrieve album data from core data")
        }
    }
    
    // MARK: - Load resource files (Images)
    func getResourceInfo(urlString : String, completion: @escaping (_ status: Int?, _ lastModifiedDate: Date?) -> Void) {
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.httpMethod = "HEAD"
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse, error == nil {
                    let lastModifiedDate = httpResponse.allHeaderFields["Last-Modified"] as? String
                    if let lastModifiedDate = lastModifiedDate {
                        let dateFormatter = DateFormatter();
                        dateFormatter.dateFormat = "EEEE, dd LLL yyyy HH:mm:ss zzz";
                        let serverDate = dateFormatter.date(from: lastModifiedDate) as Date?;
                        completion(httpResponse.statusCode, serverDate)
                    }
                    else
                    {
                        completion(httpResponse.statusCode, nil)
                    }
                } else {
                    completion(nil, nil)
                }
            }.resume()
        }
    }
    
    func getResource(urlString : String, completion: @escaping (_ data: Data?) -> Void) {
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { (data, urlResponse, error) in
                completion(data)
            }.resume()
        }
    }
}
