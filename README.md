# itunes_notifier
This program listens to iTunes notifications and emits JSON formatted data of what is produced. It is intended to run "all the time", so it can emit json files as songs play. 

This was done because it seems like a good way forward in Catalina. iTunes isn't in Catalina, nor does it support the iTunes Music Library.xml file read by [web generator](https://github.com/bolsinga/web_generator). This program is as agnostic as possible about the keys that iTunes emits. I filter out UI related keys, since they caused the json to be different depending upon if the user started or stopped iTunes from playing.

On my system, I created the .plist file at the end of this document. The following commands will get this running:

    cd ~/Library/LaunchAgents
    ln -s ~/<path-to>/com.bolsinga.itunes_notifier.plist
    launchctl load com.bolsinga.itunes_notifier.plist
    
To verify it is running:

    ps wwwaux | grep itunes_notifier

Here's the plist file.

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>com.bolsinga.itunes_notifier</string>
      <key>ProgramArguments</key>
      <array>
        <string>/Users/bolsinga/Applications/itunes_notifier</string>
        <string>/Users/bolsinga/Sites/</string>
      </array>
      <key>LowPriorityIO</key>
      <true/>
      <key>LowPriorityBackgroundIO</key>
      <true/>
      <key>KeepAlive</key>
      <true/>
    </dict>
    </plist>
