'use strict';
'require form';
'require fs';
'require view';
'require uci';
'require ui';
'require tools.widgets as widgets'

/*
	Copyright 2021-2024 Rafał Wabik - IceG - From eko.one.pl forum
	
	Licensed to the GNU General Public License v3.0.
*/

return view.extend({
	load: function() {
		return fs.list('/dev').then(function(devs) {
			return devs.filter(function(dev) {
				return dev.name.match(/^ttyUSB/) || dev.name.match(/^cdc-wdm/) || dev.name.match(/^ttyACM/) || dev.name.match(/^mhi_/) || dev.name.match(/^wwan/);
			});
		});
	},

	render: function(devs) {
		var m, s, o;
		m = new form.Map('3ginfo', _('Configuration 3ginfo-lite'), _('Configuration panel for the 3ginfo-lite application.'));

		s = m.section(form.TypedSection, '3ginfo', '', null);
		s.anonymous = true;

/*		Old config
		o = s.option(widgets.DeviceSelect, 'network', _('Interface'),
		_('Network interface for Internet access.')
		);
		o.noaliases  = false;
		o.default = 'wan';
		o.rmempty = false;
*/
		
		o = s.option(widgets.NetworkSelect, 'network', _('Interface'),
		_('Network interface for Internet access.')
		);
		o.exclude = s.section;
		o.nocreate = true;
		o.rmempty = false;
		o.default = 'wan';

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

		s = m.section(form.TypedSection, '3ginfo', null);
		s.anonymous = true;
		s.addremove = false;

		s.tab('bts1', _('BTS search settings'));
		s.anonymous = true;

		o = s.taboption('bts1', form.DummyValue, '_dummy');
			o.rawhtml = true;
			o.default = '<div class="cbi-section-descr">' +
				_('Hint: To set up a BTS search engine, all you have to do is select the dedicated website for your location.') +
				'</div>';

		o = s.taboption('bts1',form.ListValue, 'website', _('Website to search for BTS'),
		_('Select a website for searching.')
		);
		o.value('http://www.btsearch.pl/szukaj.php?mode=std&search=', _('btsearch.pl'));
		o.value('https://lteitaly.it/internal/map.php#bts=', _('lteitaly.it'));
		o.default = 'http://www.btsearch.pl/szukaj.php?mode=std&search=';
		o.modalonly = true;

		return m.render();
	}
});
