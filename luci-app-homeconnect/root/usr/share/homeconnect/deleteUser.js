var homeConnect = require('./homeconnect.js');

let {user,pass} = homeConnect.resloveUserPass();

let action = homeConnect.c.DeleteUser({'HubName_str':homeConnect.TargetHubName,'Name_str':user});
homeConnect.handleAction(action);