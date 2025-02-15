'use strict';
'require rpc';
'require form';
'require network';

var callFileList = rpc.declare({
	object: 'file',
	method: 'list',
	params: [ 'path' ],
	expect: { entries: [] },
	filter: function(list, params) {
		var rv = [];
		for (var i = 0; i < list.length; i++)
			if (list[i].name.match(/^ttyACM/) || list[i].name.match(/^ttyUSB/))
				rv.push(params.path + list[i].name);
		return rv.sort();
	}
});

network.registerPatternVirtual(/^xmm-.+$/);

return network.registerProtocol('xmm', {
	getI18n: function() {
		return _('Intel XMM Cellular');
	},

	getIfname: function() {
		return this._ubus('l3_device') || 'xmm-%s'.format(this.sid);
	},

	getOpkgPackage: function() {
		return 'xmm-modem';
	},

	isFloating: function() {
		return true;
	},

	isVirtual: function() {
		return true;
	},

	getDevices: function() {
		return null;
	},

	containsDevice: function(ifname) {
		return (network.getIfnameOf(ifname) == this.getIfname());
	},

	renderFormOptions: function(s) {
		var dev = this.getL3Device() || this.getDevice(), o;

		o = s.taboption('general', form.Value, 'device', _('Modem port'));
		o.ucioption = 'device';
		o.rmempty = false;
		o.load = function(section_id) {
			return callFileList('/dev/').then(L.bind(function(devices) {
				for (var i = 0; i < devices.length; i++)
					this.value(devices[i]);
				return form.Value.prototype.load.apply(this, [section_id]);
			}, this));
		};

		o = s.taboption('general', form.Value, 'apn', _('APN'));
		o.validate = function(section_id, value) {
			if (value == null || value == '')
				return true;

			if (!/^[a-zA-Z0-9\-.]*[a-zA-Z0-9]$/.test(value))
				return _('Invalid APN provided');

			return true;
		};

		s.taboption('general', form.Value, 'username', _('PAP/CHAP username'));

		o = s.taboption('general', form.Value, 'password', _('PAP/CHAP password'));

		o = s.taboption('general', form.ListValue, 'auth', _('Auth Type'));
		o.value('auto', 'Auto');
		o.value('pap', 'PAP');
		o.value('chap', 'CHAP');
		o.default = 'auto';

		o = s.taboption('advanced', form.Value, 'delay', _('Modem init timeout'), _('Maximum amount of seconds to wait for the modem to become ready'));
		o.placeholder = '10';
		o.datatype    = 'min(1)';

		o = s.taboption('advanced', form.Value, 'mtu', _('Override MTU'));
		o.placeholder = dev ? (dev.getMTU() || '1500') : '1500';
		o.datatype    = 'max(9200)';

		o = s.taboption('general', form.ListValue, 'pdp', _('PDP Type'));
		o.value('ipv4v6', 'IPv4/IPv6');
		o.value('ip', 'IPv4');
		o.value('ipv6', 'IPv6');
		o.default = 'ipv4v6';

		o = s.taboption('advanced', form.Flag, 'defaultroute',
			_('Use default gateway'),
			_('If unchecked, no default route is configured'));
		o.default = o.enabled;

		o = s.taboption('advanced', form.Value, 'metric',
			_('Use gateway metric'));
			o.placeholder = '0';
		o.datatype = 'uinteger';
		o.depends('defaultroute', '1');

		o = s.taboption('advanced', form.Flag, 'peerdns',
			_('Use DNS servers advertised by peer'),
			_('If unchecked, the advertised DNS server addresses are ignored'));
		o.default = o.enabled;

	}
});

