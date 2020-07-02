import Foundation

if CommandLine.arguments.count < 2 {
    print("Must provide a destination directory")
    exit(1)
}

let destinationDirectoryPath = CommandLine.arguments[1]
let destinationDirectoryURL = URL(fileURLWithPath: destinationDirectoryPath, isDirectory: true)

func save(jsonData : Data) throws {
    let fm = FileManager.default;

    let filename = "lastSong.json"
    let temporaryURL = URL(fileURLWithPath: filename, relativeTo: fm.temporaryDirectory)
    let destinationURL = URL(fileURLWithPath: filename, relativeTo: destinationDirectoryURL)

    try jsonData.write(to: temporaryURL, options: .atomic)
    if (!fm.contentsEqual(atPath: destinationURL.path, andPath: temporaryURL.path)) {
        do {
            try fm.removeItem(at: destinationURL)
        } catch {}
        try fm.moveItem(at: temporaryURL, to: destinationURL)
    } else {
        try fm.removeItem(at: temporaryURL)
    }
}

DistributedNotificationCenter.default().addObserver(forName: NSNotification.Name("com.apple.iTunes.playerInfo"), object: nil, queue: nil) { (notification) in
    guard notification.object as? String == "com.apple.iTunes.player" else {
        print("Unknown Notification.object : \(notification)")
        return
    }

    guard let t = notification.userInfo else {
        print("Empty Notification.userInfo : \(notification)")
        return
    }

    // Make the dictionary a real [String : String] so the following filter is simpler.
    // This has the some UI state that is not desirable, so disallow those keys.
    // This UI state is toggling, and it is not of interest to code that is just interesting in what is playing.
    let info = Dictionary(uniqueKeysWithValues: t.map {
        key, value in (String(describing: key), String(describing: value))
    }).filter { (key, _) in key != "Player State" && key != "Back Button State" }

    guard JSONSerialization.isValidJSONObject(info) else {
        print("Unable to create JSON for \(notification)")
        return
    }

    guard info.keys.count > 0 else {
        print("No JSON to record")
        return;
    }

    do {
        try save(jsonData: JSONSerialization.data(withJSONObject: info, options: [.prettyPrinted, .sortedKeys]))
    } catch {
        print("Error Creating JSON: \(error) for: \(notification)")
    }
}

RunLoop.main.run()
