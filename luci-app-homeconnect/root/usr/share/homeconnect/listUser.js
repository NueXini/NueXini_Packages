var homeConnect = require('./homeconnect.js');

let action = homeConnect.c.EnumUser({'HubName_str':homeConnect.TargetHubName});
homeConnect.handleAction(action);