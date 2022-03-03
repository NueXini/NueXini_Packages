'use strict';
'require form';
'require fs';
'require view';

/*
	Copyright 2021 Rafał Wabik - IceG - From eko.one.pl forum
*/

return view.extend({
	load: function() {
		return fs.list('/dev').then(function(devs) {
			return devs.filter(function(dev) {
				return dev.name.match(/^ttyUSB/);
			});
		});
	},

	render: function(devs) {
		var m, s, o;
		m = new form.Map('3ginfo', _('Configuration 3ginfo-lite'), _('Configuration panel for the 3ginfo-lite application.'));

		s = m.section(form.TypedSection, '3ginfo', '', _(''));
		s.anonymous = true;

		o = s.option(form.Value, 'network', _('Network'));
		o.default = 'wan';
		o.rmempty = false;

		o = s.option(form.Value, 'device', 
			_('IP adress / Port for communication with the modem'), 
			_("Select the appropriate settings. <br /> \
				<br />Traditional modem. <br /> \
				Select one of the available ttyUSBX ports.<br /> \
				<br />HiLink modem. <br /> \
				Enter the IP address 192.168.X.X under which the modem is available."));
		devs.forEach(function(dev) {
			o.value('/dev/' + dev.name);
		});

		return m.render();
	}
});
