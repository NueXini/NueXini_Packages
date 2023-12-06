var homelede = require('./vpnclientAjax.js');

var c = new homelede.HomeConnect.createNew();

let arguments = process.argv.splice(2);
let ipsecPreSharedKey = arguments[0];
if(ipsecPreSharedKey==null)
{
	ipsecPreSharedKey = "homelede"
}

c.sendRequest("SetIPsecServices",{
    "L2TP_Raw_bool": true,
    "L2TP_IPsec_bool": true,
    "EtherIP_IPsec_bool": true,
    "IPsec_Secret_str": ipsecPreSharedKey,
    "L2TP_DefaultHub_str": "homelede"
});