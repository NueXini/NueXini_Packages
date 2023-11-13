const TargetHost="127.0.0.1"
const TargetPort=5555
let TargetHubName="homelede"
//let TargetHubName=""
const TargetPass="homelede"
const DEBUG=false

var vpnClient = require('./vpnrpc')

var homeConnect=new vpnClient.VpnServerRpc(TargetHost,TargetPort,TargetHubName,TargetPass,false);
vpnClient.VpnServerRpc.SetDebugMode(DEBUG);

let handleAction = function(ActionPromise)
{
	ActionPromise.then(
	  (res) => {
		  let result = {succ:true,data:res}
		  console.log(JSON.stringify(result));
	  },
	  (err) => {
		  let result = {succ:false,msg:handleError(err)}
		  console.log(JSON.stringify(result));
	  }
	).catch((err) => {
		console.log(err);
	});
}

let handleError = function(Error) {
	let errorMsgStr=Error.message;
	//console.log(errorMsgStr);
	var symbol="Message=";
	var i=errorMsgStr.indexOf(symbol);
	if(i!=-1)
	{
		return errorMsgStr.substring(i+symbol.length);
	}
	else
	{
		return errorMsgStr;
	}
}

let arguments = process.argv.splice(2);
let user = arguments[0];
let pass = arguments[1];

let resloveUserPass = function() {
	return {user:user,pass:pass};
}

module.exports.TargetHubName = TargetHubName;
module.exports.c = homeConnect;
module.exports.handleAction = handleAction;
module.exports.resloveUserPass = resloveUserPass;