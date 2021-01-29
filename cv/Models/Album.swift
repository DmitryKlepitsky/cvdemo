//
//  Album.swift
//  cv
//
//  Created by Dmitry on 1/27/21.
//

import UIKit
import CoreData

class Album: NSManagedObject, Codable { //
    @NSManaged var id: Int
    @NSManaged var title: String
    @NSManaged var url: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case url
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(url, forKey: .url)
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.context,
            let managedObjectContext = decoder.userInfo[codingUserInfoKeyManagedObjectContext] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Album", in: managedObjectContext) else {
            fatalError("Failed to decode Album")
        }

        self.init(entity: entity, insertInto: managedObjectContext)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        url = try container.decode(String.self, forKey: .url)
    }
}
