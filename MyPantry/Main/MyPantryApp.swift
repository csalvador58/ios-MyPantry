//
//  My Pantry
//  Created by Chris Salvador on 2024
//  SWD Creative Labs
//

import CloudKit
import Models
import SwiftData
import SwiftUI

@main
struct MyPantryApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(\.privateItemManager, ItemManager(databaseType: .privateDB))
                .environment(\.sharedItemManager, ItemManager(databaseType: .sharedDB))
                .environment(\.pantryService, PantryService(containerIdentifier: Config.containerIdentifier))
        }
        .handlesExternalEvents(matching: [/*your URL schemes here*/])
    }

    init() {
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }
}

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    func windowScene(_ windowScene: UIWindowScene, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        guard cloudKitShareMetadata.containerIdentifier == Config.containerIdentifier else {
            print("Shared container identifier \(cloudKitShareMetadata.containerIdentifier) did not match known identifier.")
            return
        }
        
        let acceptSharesOperation = CKAcceptSharesOperation(shareMetadatas: [cloudKitShareMetadata])
        acceptSharesOperation.qualityOfService = .userInteractive
        acceptSharesOperation.perShareResultBlock = { _, result in
            switch result {
            case .success(let share):
                print("Accepted share for zone: \(share.recordID.zoneID.zoneName)")
                // You might want to refresh your UI or data here
            case .failure(let error):
                print("Error accepting share: \(error)")
            }
        }
        
        CKContainer(identifier: Config.containerIdentifier).add(acceptSharesOperation)
    }
}
