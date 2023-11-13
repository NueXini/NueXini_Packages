var http = require('https');  

var HomeConnect = {
	createNew : function()
	{
		var inst = {};
		inst.sendRequest = function(callMethod, callParams)
		{
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
	
			let post_data = {
			  "jsonrpc": "2.0",
			  "id": "rpc_call_id",
			  "method": callMethod,
			  "params": callParams
			}

			let content = JSON.stringify(post_data);
			  
			let options = {  
				hostname: '127.0.0.1',  
				port: 5555,  
				path: '/api',  
				method: 'POST',
				rejectUnauthorized: false,
				headers: {
					'Content-Type' : 'text/plain',
					'Authorization': 'Basic YWRtaW5pc3RyYXRvcjpob21lbGVkZQ==',
					'Content-Length':content.length
				}  
			};
		
			let responseBody="";
			let req = http.request(options, function (res) {  
				//console.log('STATUS: ' + res.statusCode);  
				//console.log('HEADERS: ' + JSON.stringify(res.headers));  
				res.setEncoding('utf8');  
				res.on('data', function (chunk) {  
					responseBody+=chunk;
				});
				
				res.on('end', function(){
					let result = {succ:true,data:JSON.parse(responseBody).result}
					console.log(JSON.stringify(result));
				});
			});  
			  
			req.on('error', function (e) {  
				let result = {succ:false,msg:handleError(err)}
				console.log(result);
			});  

			req.write(content);   
			req.end();
		}
		return inst;
	}
};

exports.HomeConnect = HomeConnect;