var homelede = require('./vpnclientAjax.js');

var c = new homelede.HomeConnect.createNew();

c.sendRequest("GetIPsecServices",{});