'use strict';
'require view';
'require fs';
'require ui';

/*
	Copyright 2021-2022 Rafał Wabik - IceG - From eko.one.pl forum
*/

return view.extend({
	load: function() {
		return fs.read_direct('/sys/kernel/debug/usb/devices', [ '-r' ]).catch(function(err) {
			ui.addNotification(null, E('p', {}, _('Unable to load log data: ' + err.message)));
			return '';
		});
	},

	render: function(data) {
		var dlines = data.trim().split(/\n/).map(function(line) {
		return line.replace(/^<\d+>/, '');
		});

		return E([], [
			E('h2', {}, [ _('3ginfo-lite') ]),
			E('div', { class: 'cbi-section-descr' }, _('More information about the 3ginfo on the')+ ' <a href="https://eko.one.pl/?p=openwrt-3ginfo" target="_blank">' + _('eko.one.pl forum') + '</a>.'),
			E('h4', {}, [ _('cat /sys/kernel/debug/usb/devices') ]),
			E('div', { 'id': 'content_syslog' }, [
				E('pre', {
					'id': 'syslog',
					'style': 'font-size:12px',
					'readonly': 'readonly',
					'wrap': 'off',
					'rows': dlines.length + 1
				}, [ dlines.join('\n') ])
			]),

		]);
	},

	handleSaveApply: null,
	handleSave: null,
	handleReset: null
});
