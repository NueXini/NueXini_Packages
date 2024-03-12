'use strict';
'require form';
'require rpc';
'require fs';
'require view';
'require uci';
'require ui';
'require tools.widgets as widgets'

var callSerialPort = rpc.declare({
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

var callLEDs = rpc.declare({
	object: 'luci',
	method: 'getLEDs',
	expect: { '': {} }
});


return view.extend({

	load: function() {
		return Promise.all([
			callLEDs(),
			L.resolveDefault(fs.list('/www' + L.resource('view/system/led-trigger')), []),
		]).then(function(data) {
			var plugins = data[1];
			var tasks = [];

			for (var i = 0; i < plugins.length; i++) {
				var m = plugins[i].name.match(/^(.+)\.js$/);

				if (plugins[i].type != 'file' || m == null)
					continue;

				tasks.push(L.require('view.system.led-trigger.' + m[1]).then(L.bind(function(name){
					return L.resolveDefault(L.require('view.system.led-trigger.' + name)).then(function(form) {
						return {
							name: name,
							form: form,
						};
					});
				}, this, m[1])));
			}

			return Promise.all(tasks).then(function(plugins) {
				var value = {};
				value[0] = data[0];
				value[1] = plugins;
				
				return value;
			});
		});
	},

	render: function(data) {
		var m, s, o, triggers = [];
		var leds = data[0];
		var plugins = data[1];

		for (var k in leds)
			for (var i = 0; i < leds[k].triggers.length; i++)
				triggers[i] = leds[k].triggers[i];
		
		m = new form.Map('smstools3', _('Smstools3: Setup'), _('Configure smstools3 daemon.'));
		s = m.section(form.TypedSection, 'sms', null);
		s.tab('general', _('General'));
		s.tab('advanced', _('Advanced'));
		s.anonymous = true;

		o = s.taboption('general', form.Flag, 'decode_utf', _('Decode SMS'), _('Decode Incoming messages to UTF-8 codepage.'));
		o.rmempty = true;

		o = s.taboption('advanced', form.Flag, 'ui', _('Unexepted Input'), _('Enable Unexpected input from COM port.'));
		o.rmempty = true;

		o = s.taboption('general', form.ListValue, 'storage', _('SMS Storage'), _('Select storage to save SMS.'));
		o.value('temporary', _('Temporary'));
		o.value('persistent', _('Persistent'));
		o.default = 'temporary';

		o = s.taboption('general', form.ListValue, 'device', _('Select COM port'));
		o.load = function(section_id) {
			return callSerialPort('/dev/').then(L.bind(function(devices) {
				for (var i = 0; i < devices.length; i++)
					this.value(devices[i]);
				return form.Value.prototype.load.apply(this, [section_id]);
			}, this));
		};

		o = s.taboption('general', form.ListValue, 'init', _('Init string'), _('Initialise modem for more vendors'));
		o.value('huawei', _('Huawei'));
		o.value('intel', _('Intel XMM'));
		o.value('asr', _('ASR or more'));
		o.value('', _('Qualcomm or more'));
		o.default = '';
		o.rmempty = true;

		o = s.taboption('advanced', form.Value, 'pin', _('PIN Code'), _('Default value: not in use.<br />Specifies the PIN number of the SIM card inside the modem.'));
		o.datatype = 'and(rangelength,(4,8),uinteger)';
		o.rmempty = true;

		o = s.taboption('advanced', form.ListValue, 'loglevel', _('Loglevel'), _('Logging output.'));
		o.value('1', _('Emergency'));
		o.value('2', _('Alert'));
		o.value('3', _('Critical'));
		o.value('4', _('Error'));
		o.value('5', _('Warning'));
		o.value('6', _('Notice'));
		o.value('7', _('Info'));
		o.value('8', _('Debug'));
		o.default = '5';

		o = s.taboption('advanced', form.ListValue, 'net_check', _('Check network'), _('Setup network checking. Some modems incorrect test network.'));
		o.value('0', _('Ignore'));
		o.value('1', _('Always'));
		o.value('2', _('Before messages'));

		o = s.taboption('advanced', form.Flag, 'sig_check', _('Ignore signal level'), _('Some devices do not support Bit Error Rate'));
		o.rmempty = true;

		o = s.taboption('general', form.Flag, 'led_enable', _('LED'), _('LED indicate to Incoming messages.'));
		o.rmempty = true;

		o = s.taboption('general', form.ListValue, 'led', _('Select LED'));
				Object.keys(leds).sort().forEach(function(name) {
			o.value(name);
		});
		o.rmempty = true;
		o.depends('led_enable', '1');

		return m.render();
	}
});
