//  Created by David Shaw on 2/3/16.

import UIKit


@objc public protocol ManagedAppConfigSettingsDelegate
{
    func settingsDidChange(_ changes:[String : Any]);
}

open class ManagedAppConfigSettings: NSObject {

    private static var __once: () = {
            manager = ManagedAppConfigSettings()
        }()

    fileprivate static var token:Int = 0
    fileprivate static var manager:ManagedAppConfigSettings?
    @objc
    open var delegate:ManagedAppConfigSettingsDelegate?

    // MARK: Public Methods

    /**
     Return a singleton instance of ManagedAppConfigSettings

     - returns: ManagedAppConfigSettings instance
     */
    @objc
    public static func clientInstance() -> ManagedAppConfigSettings
    {
        _ = ManagedAppConfigSettings.__once
        return manager!
    }

    /**
     Start the ManagedAppConfigSettings, including adding observers
     It is recommended to set the delegate before calling start()
     */
    @objc
    open func start()
    {
        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: OperationQueue.main) { (notification:Notification) -> Void in
            let changes = self.checkAppConfigChanges()
            if ( changes.count > 0 )
            {
                if let d = self.delegate
                {
                    print("notify others of changes: \(changes)")
                    d.settingsDidChange(changes)
                }
            }
        }
        _ = self.checkAppConfigChanges()
    }

    @objc
    open func end()
    {
        NotificationCenter.default.removeObserver(self, name: UserDefaults.didChangeNotification, object: nil);
    }

    /**
     Retrieve the dictionary of keys stored by the MDM server

     - returns: dictionary of key/value pairs
     */
    @objc
    open func appConfig ()  -> [String : Any]? {
        if let serverConfig = UserDefaults.standard.dictionary(forKey: kMDM_CONFIGURATION_KEY)
        {
            return serverConfig
        }
        return nil
    }

    // MARK: Private Methods

    /**
     retrieve the stored, cached set of keys

     - returns: dictionary of key/value pairs
     */
    fileprivate func persistedAppConfig () -> [String : Any]?
    {
        if let serverConfig = UserDefaults.standard.dictionary(forKey: kMDM_CACHED_CONFIGURATION_KEY)
        {
            return serverConfig
        }
        return nil
    }

    /**
     Compares the AppCofig stored values for equality

     - parameter a: AnyObject value 1
     - parameter b: AnyObject value 2

     - returns: true if equivalent, false otherwise
     */
    fileprivate func isEqual(_ a: Any, b: Any) -> Bool
    {
        if let va = a as? String, let vb = b as? String
        {
            return va == vb
        }
        else if let va = a as? Int, let vb = b as? Int
        {
            return va == vb
        }
        else if let va = a as? Bool, let vb = b as? Bool
        {
            return va == vb
        }
        else if let va = a as? Date, let vb = b as? Date
        {
            return (va == vb)
        }
        return false
    }

    /**
     Find any keys that changed as a result of the server pushing down
     New keys.  Persist the new keys, and return those keys that changed

     - returns: dictionary of key/value pairs that changed or were added
     */
    fileprivate func checkAppConfigChanges() -> [String : Any]
    {
        var result:[String:Any] = [:]

        // copy the keys into the result
        if let newConfig = appConfig()
        {
            for (k,v) in newConfig
            {
                result[k] = v
            }
        }

        // reove any values that were already in the set
        if let persistedConfig = persistedAppConfig()
        {
            for (key, oldValue) in persistedConfig
            {
                if let newValue = result[key]
                {
                    if isEqual(oldValue, b: newValue)
                    {
                        result.removeValue(forKey: key)
                    }
                }
            }
        }

        if let newConfig = appConfig()
        {
            if ( result.count > 0 )
            {
                // only write out the changes if there were new values
                persistConfig(newConfig)
            }
        }
        else
        {
            persistConfig(nil)
        }
        return result
    }

    /**
     Write the passed Dictionary to the persisted key

     - parameter toPersist: Dictionary to persist
     */
    fileprivate func persistConfig(_ toPersist:[String : Any]?)
    {
        let defaults =  UserDefaults.standard
        if let persist = toPersist
        {
            defaults.set(persist, forKey: kMDM_CACHED_CONFIGURATION_KEY)
        }
        else
        {
            if (defaults.object(forKey: kMDM_CACHED_CONFIGURATION_KEY) != nil)
            {
                defaults.removeObject(forKey: kMDM_CACHED_CONFIGURATION_KEY)
            }
        }
        defaults.synchronize()
    }
}
