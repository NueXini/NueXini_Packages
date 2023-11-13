var homeConnect = require('./homeconnect.js');

let {user,pass} = homeConnect.resloveUserPass();

let action = homeConnect.c.CreateUser({'HubName_str':homeConnect.TargetHubName,
									   'Name_str':user,"AuthType_u32": 1,"Auth_Password_str": pass
});
homeConnect.handleAction(action);