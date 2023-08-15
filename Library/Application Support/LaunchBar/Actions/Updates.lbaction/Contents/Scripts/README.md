

# Action Updates Action

Custom actions are great, but difficult to keep up to date. Rather than all of us individually build updating mechanisms, and clutter our actions with update related UI and pinging.

[Action Updates User Information and Download](https://renaghan.com/launchbar/action-updates/)

This action checks each custom action a user has installed and figures out if a newer version exists. It reports on results and provides options for user
* visit `/LBDescription/LBWebsiteURL`
* see `/LBDescription/LBChangelog`
* download `/LBDescription/LBDownloadURL` (trigger browser open URL)

The trick is for all custom actions to include the `/LBDescription/LBUpdateURL` key in their `Info.plist` as a string URL reference to a remote server of the `Info.plist` of most recent version

Also make sure the `CFBundleVersion` key is specified and uses standard version numbering convention `major[.minor][.patch]` where all 3 are integers.

*Optional* keys to enable changelog and download link features:
* `/LBDescription/LBChangelog` - string changelog text to display to user
* `/LBDescription/LBDownloadURL` - string URL reference to remote server where most recent action package can be downloaded

## Preferences
You may override/specify the Update URL for any action you have installed by setting a preference in this action's local preferences file 
`~/Library/Application Support/LaunchBar/Action Support/com.renaghan.launchbar.Updates/Preferences.plist`

You may also tell this action that a custom action should be skipped by setting the LBUpdate URL to `SKIP` in this action's local preferences file.

The action will search for custom actions in `~/Application Support/LaunchBar/Actions`. You may override this by setting a local `ActionsDir` preference.

## Preferences Example
```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>ActionsDir</key>
	<string>/Users/jsmith/Library/Application Support/LaunchBar/Actions</string>
	<key>LBUpdateURL</key>
	<dict>
		<key>com.example.action1</key>
		<string>https://example.com/action1.lbaction</string>
		<key>com.example.action2</key>
		<string>SKIP</key>
	</dict>
</dict>
</plist>
```

## Action Info.plist Example
```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  ...
	<key>LBDescription</key>
	<dict>
	  ...
	  <key>LBUpdateURL</key>
	  <string>https://raw.githubusercontent.com/jsmith/launchbar/master/Checker.lbaction/Contents/Info.plist</string>
	  <key>LBDownloadURL</key>
	  <string>https://download.com/lbdist/Checker.lbaction</string>
	  <key>LBChangelog</key>
	  <string>
	    1.2: Fixed bug when user option clicked on 2nd item.
	  </string>
	</dict>
</dict>
</plist>
```
