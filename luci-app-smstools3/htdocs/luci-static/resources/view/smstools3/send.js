'use strict';
'require dom';
'require form';
'require fs';
'require ui';
'require uci';
'require view';

/*
	Copyright 2022-2023 Rafał Wabik - IceG - From eko.one.pl forum
	Modified for smstools3 by Konstantine Shevlakov <shevlakov@132lan.ru> 2024
	Licensed to the GNU General Public License v3.0.
*/

return view.extend({
	handleCommand: function(exec, args) {
		var buttons = document.querySelectorAll('.cbi-button');

		for (var i = 0; i < buttons.length; i++)
			buttons[i].setAttribute('disabled', 'true');

		return fs.exec(exec, args).then(function(res) {

			res.stdout = res.stdout?.replace(/(?=\n)$|\s*|\s*$|\n\n+/gm, "") || '';
			res.stderr = res.stderr?.replace(/(?=\n)$|\s*|\s*$|\n\n+/gm, "") || '';
			
		}).catch(function(err) {
			ui.addNotification(null, E('p', [ err ]))
		}).finally(function() {
			for (var i = 0; i < buttons.length; i++)
			buttons[i].removeAttribute('disabled');

		});
	},

	handleGo: function(ev) {

		var smstext = document.getElementById('textvalue').value;
		var phone = document.getElementById('phonevalue').value;

		if ( phone.length < 2 ) {
			ui.addNotification(null, E('p', _('Please specify the phone number to send')), 'info');
			return false;
		} else if ( phone.length < 6 && Number(phone) )  {
			// send short numbers
			ui.addNotification(null, E('p', _('Message sent')), 'info');
			return this.handleCommand('/usr/bin/sendsms', [ 's'+phone, smstext ]);
		} else {
			ui.addNotification(null, E('p', _('Message sent')), 'info');
			return this.handleCommand('/usr/bin/sendsms', [ phone, smstext ]);
		}

	},

	handleClear: function(ev) {
		var ov = document.getElementById('phonevalue');
		ov.value = '';
		var ov = document.getElementById('textvalue');
		ov.value = '';
		document.getElementById('textvalue').focus();
	},

	handleCopy: function(ev) {
		var ov = document.getElementById('phonevalue');
		ov.value = '';
		var x = document.getElementById('tk').value;
		ov.value = x;
	},

	load: function() {
		return Promise.all([
			L.resolveDefault(fs.read_direct('/etc/smstools3.pb'), null),
			uci.load('smstools3')
		]);
	},

	render: function (loadResults) {
	
	var info = _('User interface for sending SMS via smsd.');
	var execBtn = document.getElementById('execute');

		return E('div', { 'class': 'cbi-map', 'id': 'map' }, [
				E('h2', {}, [ _('Smstools3: send message') ]),
				E('div', { 'class': 'cbi-map-descr'}, info),
				E('hr'),
				E('div', { 'class': 'cbi-section' }, [
					E('div', { 'class': 'cbi-section-node' }, [
						E('div', { 'class': 'cbi-value' }, [
							E('label', { 'class': 'cbi-value-title' }, [ _('Phonebook') ]),
							E('div', { 'class': 'cbi-value-field' }, [
								E('select', { 'class':  'cbi-input-select',
											'id': 'tk',
											'style': 'margin:5px 0; width:70%;',
											'change': ui.createHandlerFn(this, 'handleCopy')
										},
									(loadResults[0] || "").trim().split("\n").map(function(cmd) {
										var fields = cmd.split(/;/);
										var name = fields[0];
										var code = fields[1];
									return E('option', { 'value': code }, name ) })
								)
							]) 
						]),
						E('div', { 'class': 'cbi-value' }, [
							E('label', { 'class': 'cbi-value-title' }, [ _('Phone Number') ]),
							E('div', { 'class': 'cbi-value-field' }, [
							E('input', {
								'style': 'margin:5px 0; ; width:70%;',
								'type': 'text',
								'id': 'phonevalue',
								}),
							])
						]),
						E('div', { 'class': 'cbi-value' }, [
							E('label', { 'class': 'cbi-value-title' }, [ _('Text Message') ]),
							E('div', { 'class': 'cbi-value-field' }, [
							E('textarea', {
								'class': 'cbi-section',
								'style': 'margin:600px 20; ; width:70%;',
                                                                'type': 'text',
                                                                'rows': '6',
                                                                'id': 'textvalue'
                                                                }),
                                                        ])
                                                ]),

					])
				]),
				E('hr'),
				E('div', { 'class': 'right' }, [
					E('button', {
						'class': 'cbi-button cbi-button-remove',
						'id': 'clr',
						'click': ui.createHandlerFn(this, 'handleClear')
					}, [ _('Clear text') ]),
					'\xa0\xa0\xa0',
					E('button', {
						'class': 'cbi-button cbi-button-action important',
						'id': 'execute',
						'click': ui.createHandlerFn(this, 'handleGo')
					}, [ _('Send message') ]),
				]),

			]);
	},

	handleSaveApply: null,
	handleSave: null,
	handleReset: null
})
