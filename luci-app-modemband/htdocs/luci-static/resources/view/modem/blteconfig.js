'use strict';
'require form';
'require fs';
'require view';
'require uci';
'require ui';
'require tools.widgets as widgets'

/*
	Copyright 2022 Rafał Wabik - IceG - From eko.one.pl forum
*/

return view.extend({
	load: function() {
		return fs.list('/dev').then(function(devs) {
			return devs.filter(function(dev) {
				return dev.name.match(/^ttyUSB/) || dev.name.match(/^cdc-wdm/) || dev.name.match(/^ttyACM/);
			});
		});
	},

	render: function(devs) {
		var m, s, o;
		m = new form.Map('modemband', _('Configuration luci-app-modemband'), _('Configuration panel for modemband and gui application.'));

		s = m.section(form.TypedSection, 'modemband', '', _(''));
		s.anonymous = true;

		o = s.option(widgets.DeviceSelect, 'iface', _('Interface'),
		_('Network interface for Internet access.')
		);
		o.noaliases  = true;
		o.default = 'wan';

		o = s.option(form.Value, 'set_port', _('Port for communication with the modem'), 
			_("Select one of the available ttyUSBX ports."));
		devs.forEach(function(dev) {
			o.value('/dev/' + dev.name);
		});
		o.placeholder = _('Please select a port');
		o.rmempty = false;

		o = s.option(form.Flag, 'wanrestart',	_('Restart WAN'),
		_('WAN restart after making changes to bands.')
		);
		o.rmempty = false;

		o = s.option(form.Flag, 'modemrestart', _('Modem restart'),
		_('Modem restart after making changes to bands.')
		);
		o.rmempty = false;

		o = s.option(form.Value, 'restartcmd', _('Restart with AT command'),
		_('AT command to restart the modem.')
		);
		o.default = 'AT+CFUN=1,1';
		o.depends("modemrestart", "1");
		o.rmempty = false;

		return m.render();
	}
});
