
var TIMEOUT = {timeout: 10.0};
var ACTION_INFO = 'https://raw.githubusercontent.com/prenagha/launchbar/main/Updates.lbaction/Contents/Info.plist';
var LB_INFO = 'http://sw-update.obdev.at/update-feeds/launchbar-6.plist';
var LB_DOWNLOAD = 'http://www.obdev.at/products/launchbar/download.html';
var ALERT_ICON = 'alertTemplate';
var CAUTION = 'cautionTemplate';
var CHECK = "checkTemplate";
var SKIP = "skipTemplate";

function setup() {
  if (Action.preferences.ActionsDir)
    return;
  // load up an initial preferences object with defaults if first time run
  Action.preferences.ActionsDir = LaunchBar.homeDirectory + "/Library/Application Support/LaunchBar/Actions";
  var urls = {"com.example.action1": "https://example.com/action1.lbaction"
    , "com.example.action2": "SKIP" };
  Action.preferences.LBUpdateURL = urls;
}

function run(arg) {
  setup();
  var actionsDir = Action.preferences.ActionsDir;
  
  var items = [];
  var good = [];
  var bad = [];
  var skip = [];
  var error = [];

  skip.push({'title': 'Edit Preferences', icon: "prefTemplate", action: "editPref"});

  loadResult(items, good, bad, skip, error, checkLaunchBar());
    
  if (File.exists(actionsDir)
   && File.isDirectory(actionsDir) 
   && File.isReadable(actionsDir)) {
    LaunchBar.debugLog('Actions dir ' + actionsDir);
    var actions = File.getDirectoryContents(actionsDir);
    actions.forEach(function(actionPackage) {
      loadResult(items, good, bad, skip, error, checkAction(actionsDir, actionPackage));
    });
  } else {
    error.push({'title': 'Actions dir not accessible'
      ,'subtitle':actionsDir
      ,'alwaysShowsSubtitle': true
      ,'icon':ALERT_ICON});
  }
  
  if (error.length > 0)
    items.push({'title': 'Error', badge: ""+error.length, icon:ALERT_ICON, children: error});
  
  items.push({'title': 'Newer versions available', badge: ""+bad.length, icon:CAUTION, children: bad});
  items.push({'title': 'Up to date', badge: ""+good.length, icon:CHECK, children: good});
  
  if (skip.length > 1)
    items.push({'title': 'Skipped', badge: ""+(skip.length-1), icon:SKIP, children: skip});
  
  return items;
}

function editPref() {
  LaunchBar.openURL('file://' + encodeURI(Action.supportPath + '/Preferences.plist'));
}

function loadResult(items, good, bad, skip, error, item) {
  if (!item || !item.title)
    return;
  if (item.icon && item.icon == CHECK) {
    good.push(item);
    return;
  }
  if (item.icon && item.icon == CAUTION) {
    bad.push(item);
    return;
  }
  if (item.icon && item.icon == ALERT_ICON) {
    error.push(item);
    return;
  }
  if (item.icon && item.icon == SKIP) {
    skip.push(item);
    return;
  }
  items.push(item);
}

function checkAction(actionsDir, actionPackage) {
  LaunchBar.debugLog("Checking action " + actionPackage);
  var actionFile = actionsDir + "/" + actionPackage;
  if (!actionPackage 
   || typeof(actionPackage) != "string"
   || actionPackage.indexOf(".lbaction") < 0)
    return;
  var plistFile = actionsDir + "/" + actionPackage + "/Contents/Info.plist";
  if (!File.exists(plistFile)) {
    return {'title': actionPackage + ': Error local Info.plist does not exist ' + plistFile
      ,children: getActionChildren(actionFile, null, null)
      ,'icon':ALERT_ICON};
  }
  if (!File.isReadable(plistFile)) {
    return {'title': actionPackage + ': Error local Info.plist not readable ' + plistFile
      ,children: getActionChildren(actionFile, null, null)
      ,'icon':ALERT_ICON};
  }
  
  var plist;  
  try {
    plist = File.readPlist(plistFile);
  } catch (exception) {
    LaunchBar.log('Error ' + actionPackage + ' reading plist -- ' + exception);
    return {'title': actionPackage + ': Error reading plist ' + plistFile
      ,children: getActionChildren(actionFile, null, null)
      ,'icon':ALERT_ICON};
  }
  
  var updateURL = getUpdateURL(actionPackage, plist);
  if (updateURL == "SKIP") {
    return {'title': plist.CFBundleName + ': skipped'
      ,'icon':SKIP
      ,subtitle: 'Skipped via user preferences'
      ,children: getActionChildren(actionFile, plist, null)};
  }
  if (!updateURL || updateURL.indexOf('http') != 0) {
    return {'title': plist.CFBundleName + ': updates not supported'
      ,subtitle: 'Missing LBUpdateURL key'
      ,'icon':SKIP
      ,children: getActionChildren(actionFile, plist, null)};
  }

  if (updateURL.indexOf(" ") > 0)
    updateURL = encodeURI(updateURL);
  LaunchBar.debugLog(actionPackage + ' URL ' + updateURL);

  var result = {};
  try {  
    result = HTTP.getPlist(updateURL, TIMEOUT);
  } catch (exception) {
    LaunchBar.log('Error ' + actionPackage + ' -- ' + exception);
    return {'title':plist.CFBundleName + ': HTTP Error remote plist ' + exception + ' -- ' + updateURL
      ,'icon':ALERT_ICON
      ,children: getActionChildren(actionFile, plist, null)};
  }

  if (!result) {
    return {'title': plist.CFBundleName + ': Error remote plist empty result -- ' + updateURL
      ,'icon':ALERT_ICON
      ,children: getActionChildren(actionFile, plist, null)};
  }
  if (result.error) {
    return {'title': plist.CFBundleName + ': Error result remote plist ' + result.error
        + (result.response && result.response.status ? " -- " + result.response.status : "")
        + (result.response && result.response.localizedStatus ? " --  " + result.response.localizedStatus : "")
      ,'icon':ALERT_ICON
      ,children: getActionChildren(actionFile, plist, null)};
  }
  if (!result.data || result.data.length < 1) {
    return {'title': plist.CFBundleName + ': Error remote plist empty data ' + updateURL
      ,'icon':ALERT_ICON
      ,children: getActionChildren(actionFile, plist, null)};
  }
    
  if (upToDate(plist.CFBundleVersion, result.data.CFBundleVersion)) {
    return {'title': plist.CFBundleName + ': up to date'
      ,'badge' : plist.CFBundleVersion
      ,'icon': CHECK
      ,children: getActionChildren(actionFile, plist, result.data)};
  } else {
    return {'title': plist.CFBundleName + ': Newer version available'
        +  '   ' + plist.CFBundleVersion + ' ➔ ' + result.data.CFBundleVersion
      ,'icon':CAUTION
      ,children: getActionChildren(actionFile, plist, result.data)};
  }
  
  return [];
}

function getActionChildren(actionFile, currPlist, plist) {
  var items = [];
  var w = getWebsite(currPlist);
  if (w) {
    items.push({'title': 'Open ' + currPlist.CFBundleName + ' web site'
      ,'subtitle': w
      ,'icon':'urlTemplate'
      ,'url': w});
  }
  if (plist && plist.LBDescription && plist.LBDescription.LBChangelog && plist.LBDescription.LBChangelog.indexOf('http') == 0) {
    items.push({'title': 'Open version ' + plist.CFBundleVersion + ' change log'
      ,'subtitle':plist.LBDescription.LBChangelog
      ,'icon':'logTemplate'
      ,'url': plist.LBDescription.LBChangelog});
  }
  if (plist && plist.LBDescription && plist.LBDescription.LBChangelog && plist.LBDescription.LBChangelog.indexOf('http') != 0) {
    var changes = [{title: plist.LBDescription.LBChangelog, icon:'Text.icns'}];
    items.push({'title': 'Version ' + plist.CFBundleVersion + ' change log'
      ,'icon':'logTemplate'
      ,'children': changes});
  }
  if (plist && plist.LBDescription && plist.LBDescription.LBDownloadURL) {
    items.push({'title': 'Download version ' + plist.CFBundleVersion
      ,'subtitle':plist.LBDescription.LBDownloadURL
      ,'icon':'downloadTemplate'
      ,'url': plist.LBDescription.LBDownloadURL});
  }
  if (plist && plist.LBDescription && plist.LBDescription.LBDownload) {
    items.push({'title': 'Download version ' + plist.CFBundleVersion
      ,'subtitle':plist.LBDescription.LBDownload
      ,'icon':'downloadTemplate'
      ,'url': plist.LBDescription.LBDownload});
  }
  if (currPlist && currPlist.LBDescription && currPlist.LBDescription.LBUpdateURL) {
    items.push({'title': 'Open remote Info.plist'
      ,'subtitle':currPlist.LBDescription.LBUpdateURL
      ,'icon':'urlTemplate'
      ,'url': currPlist.LBDescription.LBUpdateURL});
  }
  if (currPlist && currPlist.LBDescription && currPlist.LBDescription.LBUpdate) {
    items.push({'title': 'Open remote Info.plist'
      ,'subtitle':currPlist.LBDescription.LBUpdate
      ,'icon':'urlTemplate'
      ,'url': currPlist.LBDescription.LBUpdate});
  }
  items.push({'title': 'Installed action version ' + (currPlist ? currPlist.CFBundleVersion : "")
    ,'subtitle':actionFile
    ,'icon': 'actionTemplate'
    ,'path': actionFile});

  if (currPlist) {
    if (Action.preferences
     && Action.preferences.LBUpdateURL
     && Action.preferences.LBUpdateURL[currPlist.CFBundleIdentifier] 
     && Action.preferences.LBUpdateURL[currPlist.CFBundleIdentifier] == "SKIP") {   
      items.push({'title': 'Resume checking this action for updates'
        ,'subtitle':currPlist.CFBundleIdentifier
        ,'icon':SKIP
        ,'action':'unskipper'
        ,'actionRunsInBackground':true
        ,'actionArgument': currPlist.CFBundleIdentifier});
    } else {
      items.push({'title': 'Skip checking this action for updates'
        ,'subtitle':currPlist.CFBundleIdentifier
        ,'icon':SKIP
        ,'action':'skipper'
        ,'actionRunsInBackground':true
        ,'actionArgument': currPlist.CFBundleIdentifier});
    }
  }
  return items;
}

function skipper(bundleId) {
  Action.preferences.LBUpdateURL[bundleId] = "SKIP";
}

function unskipper(bundleId) {
  Action.preferences.LBUpdateURL[bundleId] = "";
}

function getUpdateURL(actionPackage, plist) {
  if (Action.preferences
   && Action.preferences.LBUpdateURL
   && Action.preferences.LBUpdateURL[plist.CFBundleIdentifier] 
   && Action.preferences.LBUpdateURL[plist.CFBundleIdentifier] == "SKIP")
    return "SKIP";

  if (Action.preferences
   && Action.preferences.LBUpdateURL
   && Action.preferences.LBUpdateURL[plist.CFBundleIdentifier] 
   && Action.preferences.LBUpdateURL[plist.CFBundleIdentifier].indexOf('http') == 0)
    return Action.preferences.LBUpdateURL[plist.CFBundleIdentifier];

  if (plist.LBDescription
   && plist.LBDescription.LBUpdateURL
   && plist.LBDescription.LBUpdateURL.indexOf('http') == 0)
    return plist.LBDescription.LBUpdateURL;
    
  if (plist.LBDescription
   && plist.LBDescription.LBUpdate
   && plist.LBDescription.LBUpdate.indexOf('http') == 0)
    return plist.LBDescription.LBUpdate;
    
  return "";
}

function getWebsite(plist) {
  if (!plist || !plist.LBDescription)
    return null;
  if (plist.LBDescription.LBWebsiteURL)
    return plist.LBDescription.LBWebsiteURL;
  if (plist.LBDescription.LBWebsite)
    return plist.LBDescription.LBWebsite;
  return null;    
}

function checkLaunchBar() {
  try {
    var result = HTTP.getPlist(LB_INFO, TIMEOUT);
    if (!result) {
      return {'title':'Error checking LaunchBar version - empty result'
        ,'subtitle':'Empty Plist result from ' + LB_INFO
        ,'alwaysShowsSubtitle': true
        ,'icon':ALERT_ICON
        ,'url':LB_INFO};
    }
    if (result.error) {
      return {'title':'Error checking LaunchBar version - ' + result.error
        ,'subtitle':result.error
        ,'alwaysShowsSubtitle': true
        ,'icon':ALERT_ICON
        ,'url':LB_INFO};
    }
    if (!result.data || result.data.length < 1) {
      return {'title':'Error checking LaunchBar version - empty data'
        ,'subtitle':'Empty Plist result data from ' + LB_INFO
        ,'alwaysShowsSubtitle': true
        ,'icon':ALERT_ICON
        ,'url':LB_INFO};
    }
    if (upToDate(LaunchBar.version, result.data[0].BundleVersion)) {
      return {'title':'LaunchBar: up to date'
        ,'badge': LaunchBar.shortVersion
        ,'icon':CHECK
        ,'url':LB_DOWNLOAD};
    } else {
      return {'title':'LaunchBar: Newer version available   ' 
          + LaunchBar.shortVersion + ' ➔ ' + result.data[0].BundleShortVersionString
        ,'icon':CAUTION
        ,'url':LB_DOWNLOAD};
    }
  } catch (exception) {
    LaunchBar.log('Error checkLaunchBar ' + exception);
    return {'title':'HTTP Error checking LaunchBar version'
      ,'subtitle':exception
      ,'alwaysShowsSubtitle': true
      ,'icon':ALERT_ICON
      ,'url':LB_INFO};
  }
  return {};
}

// compare two versions, return true if local is up to date, false otherwise
// if both versions are in the form of major[.minor][.patch] then the comparison parses and compares as such
// otherwise the versions are treated as strings and normal string compare is done
var VPAT = /^\d+(\.\d+){0,2}$/;

function upToDate(local, remote) {
    if (!local || !remote || local.length === 0 || remote.length === 0)
        return false;
    if (local == remote)
        return true;
    if (VPAT.test(local) && VPAT.test(remote)) {
        var lparts = local.split('.');
        while(lparts.length < 3)
            lparts.push("0");
        var rparts = remote.split('.');
        while (rparts.length < 3)
            rparts.push("0");
        for (var i=0; i<3; i++) {
            var l = parseInt(lparts[i], 10);
            var r = parseInt(rparts[i], 10);
            if (l === r)
                continue;
            return l > r;
        }
        return true;
    } else {
        return local >= remote;
    }
}
