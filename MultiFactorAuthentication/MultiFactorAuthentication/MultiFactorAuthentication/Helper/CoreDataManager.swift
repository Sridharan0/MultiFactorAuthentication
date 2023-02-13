//
//  CoreDataManager.swift
//  
//
//  Created by sridharan R on 23/08/22.
//

import UIKit
import CoreData
import CoreLocation

public class CoreDataManager {
    
    public static let shared = CoreDataManager()
    
    private init() { }
    
    let model = "LocationCoreData"  //Model name

    lazy var persistentContainer: NSPersistentContainer = {
       
      
        
        let modelURL = bundle.url(forResource: self.model, withExtension: ".momd")!
        let model = NSManagedObjectModel(contentsOf: modelURL)!
        let container = NSPersistentCloudKitContainer(name: self.model, managedObjectModel: model)
        container.loadPersistentStores { (storeDescription, error) in
            if let err = error{
                fatalError("❌ Loading of store failed:\(err)")
            }
        }
        return container
    }()
    
    public lazy var context = persistentContainer.viewContext
    
    /// Cretae new table entity in core data
    /// - Returns: entity
    func add<T: NSManagedObject>(_ type: T.Type) -> T? {
        guard let entityName = T.entity().name else { return nil }
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else { return nil }
        let object = T(entity: entity, insertInto: context)
        return object
    }
    
    /// Fetch core data values
    /// - Parameter type: Entity tpe
    /// - Parameter predicate: Predicate querry
    /// - Returns: List of data entity
    func fetch<T : NSManagedObject>(_ type : T.Type,_ predicate : NSPredicate? = nil) -> [T] {
        let request = T.fetchRequest()
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            return try context.fetch(request) as! [T]
        } catch {
            print("❌ Failed to fetch \(T.Type.self): \(error.localizedDescription)")
            return []
        }
    }
    
    /// Fetch core data values
    /// - Parameter request: fetch request
    /// - Parameter predicate: Predicate querry
    /// - Returns: List of data entity
    func fetch<T : NSManagedObject>(_ request : NSFetchRequest<T> ,_ predicate : NSPredicate? = nil) -> [T] {
        let request = request
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Failed to fetch \(T.Type.self): \(error.localizedDescription)")
            return []
        }
    }
    
    /// save all core data values
    func save() {
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Saves location data to core data
    /// - Parameters:
    ///   - location: CLLocation from delegate
    ///   - version: location service version
    public func saveLocationData(_ location: MFALocationModel, _ version : String = "1"){
        guard let mfaLocation = CoreDataManager.shared.add(MFALocation.self) else { return }
        mfaLocation.lat = location.lat ?? 0
        mfaLocation.long = location.long ?? 0
        mfaLocation.version = location.version
        mfaLocation.accuracy = location.accuracy ?? 0 //positional error in meters related to the latitude, longitude coordinate.
        mfaLocation.dateTime = location.dateTime
        save()
    }
    
    /// Fetch valied MFALocation list from core data
    /// - Returns: List of MFALocation
    public func fetchLocationData() -> [MFALocation] {
        return fetch(MFALocation.fetchRequest(), NSPredicate(format: "lat != %@ AND long != %@", NSNumber(value: 0.0), NSNumber(value: 0.0)))
    }
    
    /// Delete all uploaded location data
    public func deleteLocationData() {
        let fetch =  NSFetchRequest<NSFetchRequestResult>(entityName: "MFALocation")
        fetch.predicate = NSPredicate(format: "uploadStatus == %@", NSNumber(value: true))
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        
        do {
            let _ = try context.execute(request)
        } catch {
            print("❌ Failed to delete location: \(error.localizedDescription)")
        }
    }
    
    /// Delete all location data from core data.
    func deleteAllLocationData() {
        let fetch =  NSFetchRequest<NSFetchRequestResult>(entityName: "MFALocation")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            let _ = try context.execute(request)
        } catch {
            print("❌ Failed to delete all location: \(error.localizedDescription)")
        }
       
    }
    
}

public extension CodingUserInfoKey {
    // Helper property to retrieve the context
    static let managedObjectContext = CodingUserInfoKey(rawValue: CoreDataManager.shared.model)
}
