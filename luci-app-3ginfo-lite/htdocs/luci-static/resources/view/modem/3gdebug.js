'use strict';
'require view';
'require dom';
'require fs';
'require ui';
'require uci';

/*
	Copyright 2021-2024 Rafał Wabik - IceG - From eko.one.pl forum
	
	Licensed to the GNU General Public License v3.0.
*/

return view.extend({
	handleCommand: function(exec, args) {
		var buttons = document.querySelectorAll('.diag-action > .cbi-button');

		for (var i = 0; i < buttons.length; i++)
			buttons[i].setAttribute('disabled', 'true');

		return fs.exec(exec, args).then(function(res) {
			var out = document.querySelector('textarea');
			out.style.display = '';

			dom.content(out, [ res.stdout || '', res.stderr || '' ]);
			fs.write('/tmp/debug_result.txt', [ res.stdout || '' ]);
		}).catch(function(err) {
			ui.addNotification(null, E('p', [ err ]))
		}).finally(function() {
			var viewbc = document.getElementById('clear');
			viewbc.style.display = '';
			var viewbd = document.getElementById('download');
			viewbd.style.display = '';

			for (var i = 0; i < buttons.length; i++)
				buttons[i].removeAttribute('disabled');
		});
	},

	handleUSB: function(ev, cmd) {
		return this.handleCommand('/bin/cat', ['/sys/kernel/debug/usb/devices']);
	},

	handleTTY: function(ev, cmd) {
		return this.handleCommand('/bin/ls', ['/dev']);
	},

	handleDBG: function(ev, cmd) {
		return this.handleCommand('/bin/sh', ['-x', '/usr/share/3ginfo-lite/3ginfo.sh']);
	},

	handleClear: function(ev) {
		var out = document.getElementById('pre');
		out.style.display = 'none';
		var viewbc = document.getElementById('clear');
		viewbc.style.display = 'none';
		var viewbd = document.getElementById('download');
		viewbd.style.display = 'none';
		fs.write('/tmp/debug_result.txt', '');
	},

	handleDownload: function(ev) {
		return L.resolveDefault(fs.read_direct('/tmp/debug_result.txt'), null).then(function (res) {
				if (res) {
					var link = E('a', {
						'download': 'debug_result.txt',
						'href': URL.createObjectURL(
							new Blob([ res ], { type: 'text/plain' })),
					});
					link.click();
					URL.revokeObjectURL(link.href);
				}
			}).catch(() => {
				ui.addNotification(null, E('p', {}, _('Download error') + ': ' + err.message));
		});

	},

	load: function() {
		return L.resolveDefault(uci.load('luci'));
	},

	render: function(res) {

		var table = E('table', { 'class': 'table' }, [
				E('tr', { 'class': 'tr' }, [
					E('td', { 'class': 'td left', 'style': 'overflow:initial' }, [
						E('label', { 'class': 'cbi-value-title' },
							_("USB debug information")						
						),
						E('p'),
						E('label', { 'class': 'cbi-value-title' },
							_("<code>cat /sys/kernel/debug/usb/devices</code>.")
						),
						E('p'),
						E('span', { 'class': 'diag-action' }, [
							E('button', {
								'class': 'cbi-button cbi-button-action',
								'click': ui.createHandlerFn(this, 'handleUSB')
							}, [ _('Show devices') ])
						])
					]),

					E('td', { 'class': 'td left', 'style': 'overflow:initial' }, [
						E('label', { 'class': 'cbi-value-title' },
							_("Check availability of ttyX ports.")						
						),
						E('p'),
						E('label', { 'class': 'cbi-value-title' },
							_("<code>ls /dev</code>.")
						),
						E('p'),
						E('span', { 'class': 'diag-action' }, [
							E('button', {
								'class': 'cbi-button cbi-button-action',
								'click': ui.createHandlerFn(this, 'handleTTY')
							}, [ _('Show devices') ])
						])
					]),

					E('td', { 'class': 'td left' }, [
						E('label', { 'class': 'cbi-value-title' },
							_("Check data read by the 3ginfo scripts.")						
						),
						E('p'),
						E('label', { 'class': 'cbi-value-title' },
							_("<code>sh -x /usr/share/3ginfo-lite/3ginfo.sh</code>.")
						),
						E('p'),
						E('span', { 'class': 'diag-action' }, [
							E('button', {
								'class': 'cbi-button cbi-button-action',
								'click': ui.createHandlerFn(this, 'handleDBG')
							}, [ _('Debug') ])
						])
					]),
				])
			]);


		var info = _('More information about the 3ginfo on the %seko.one.pl forum%s.').format('<a href="https://eko.one.pl/?p=openwrt-3ginfo" target="_blank">', '</a>');

		var view = E('div', { 'class': 'cbi-map'}, [
			E('h2', {}, [ _('Diagnostics') ]),
			E('div', { 'class': 'cbi-map-descr'}, _('Execution of various commands to check the availability of the modem and eliminate errors in the data collected by the scripts.') + '<br />' + info),
			table,
			E('hr'),
			E('div', {'class': 'cbi-section'}, [
				E('p'),
				E('textarea', {
					'id': 'pre',
					'style':'display:none; border: 1px solid var(--border-color-medium); border-radius: 5px; font-family: monospace; font-size:12px; white-space:pre; width: 100%; resize: none;',
					'readonly': true,
					'wrap': 'off',
					'rows': '25'
				}, []),
				E('p'),
				E('div', { 'class': 'right' }, [
					E('button', {
						'class': 'cbi-button cbi-button-remove',
						'id': 'clear',
						'style': 'display:none',
						'click': ui.createHandlerFn(this, 'handleClear')
					}, [ _('Clear') ]),
					'\xa0\xa0\xa0',
					E('button', {
						'class': 'cbi-button cbi-button-apply important',
						'id': 'download',
						'style': 'display:none',
						'click': ui.createHandlerFn(this, 'handleDownload')
					}, [ _('Download') ]),
				]),
			])
		]);

		return view;
	},

	handleSaveApply: null,
	handleSave: null,
	handleReset: null
});
