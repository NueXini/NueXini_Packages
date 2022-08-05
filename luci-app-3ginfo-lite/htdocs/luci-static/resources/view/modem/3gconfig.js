'use strict';
'require form';
'require fs';
'require view';
'require uci';
'require ui';
'require tools.widgets as widgets'

/*
	Copyright 2021-2022 Rafał Wabik - IceG - From eko.one.pl forum
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
		m = new form.Map('3ginfo', _('Configuration 3ginfo-lite'), _('Configuration panel for the 3ginfo-lite application.'));

		s = m.section(form.TypedSection, '3ginfo', '', _(''));
		s.anonymous = true;
		
		o = s.option(widgets.DeviceSelect, 'network', _('Interface'),
		_('Network interface for Internet access.')
		);
		o.noaliases  = true;
		o.default = 'wan';
		o.rmempty = false;

		o = s.option(form.Value, 'device', 
			_('IP adress / Port for communication with the modem'), 
			_("Select the appropriate settings. <br /> \
				<br />Traditional modem. <br /> \
				Select one of the available ttyUSBX ports.<br /> \
				<br />HiLink modem. <br /> \
				Enter the IP address 192.168.X.X under which the modem is available."));
		devs.sort((a, b) => a.name > b.name);
		devs.forEach(dev => o.value('/dev/' + dev.name));
		o.placeholder = _('Please select a port');
		o.rmempty = false

		s = m.section(form.TypedSection, '3ginfo', _(''));
		s.anonymous = true;
		s.addremove = false;

		s.tab('bts1', _('BTS search settings'));
		s.anonymous = true;

		o = s.taboption('bts1', form.DummyValue, '_dummy');
			o.rawhtml = true;
			o.default = '<div class="cbi-section-descr">' +
				_('Hint: To set up the BTS search engine, simply fill in the required fields.') +
				'</div>';

		o = s.taboption('bts1',form.Value, 'bstart', _('Beginning of the web address'),
		_('Paste the entire site address into the Cell ID value.')
		);
		//o.default = 'http://www.btsearch.pl/szukaj.php?mode=std&search=';
		o.rmempty = true;

		o = s.taboption('bts1',form.Value, 'bend', _('End of search address'),
		_('Paste the string occurring after the Cell ID value.')
		);
		//o.default = '';
		o.rmempty = true;

		return m.render();
	}
});
