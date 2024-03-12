'use strict';
'require dom';
'require form';
'require fs';
'require ui';
'require uci';
'require view';

/*
        Copyright 2024 Konstantine Shevlakov <shevlakov@132lan.ru> 
        Licensed to the GNU General Public License v3.0.
*/

return view.extend({

	load: function() {
		return L.resolveDefault(fs.exec_direct('/usr/bin/msg_control', [ 'sent' ]));
	},

	handleClear: function(ev) {
		return L.resolveDefault(fs.exec_direct('/usr/bin/msg_control', [ 'rmsent' ]));
	},

	handleRefresh: function(ev) {
		location.reload()
	},
	
	render: function (data) {
		var obj = JSON.parse(data);
		let tableHeaders = [
			_('Send Date'),
			_('Time(sec)'),
			_('To'),
			_('Message')
		];

		let tableSMS = E('table', { 'class': 'table' },
			E('tr', { 'class': 'tr cbi-section-table-titles' }, [
				E('th', { 'class': 'th left', 'width': '15%' }, tableHeaders[0]),
				E('th', { 'class': 'th left', 'width': '15%' }, tableHeaders[1]),
				E('th', { 'class': 'th left', 'width': '20%' }, tableHeaders[2]),
				E('th', { 'class': 'th left', 'width': '50%' }, tableHeaders[3]),
			]),
		);
		
		var s = 1;
		for (let i = 0; i < obj.sent.length; i++) {
			if (obj.sent[i].to.length > 6 && Number(obj.sent[i].to)) {
				var to = '+' + obj.sent[i].to;
			} else {
				var to = obj.sent[i].to;
			}
			tableSMS.append(
				E('tr', { 'class': 'cbi-rowstyle-'+s }, [
					E('td', { 'class': 'td left', 'data-title': tableHeaders[0], 'width': '15%' }, obj.sent[i].sent),
					E('td', { 'class': 'td left', 'data-title': tableHeaders[1], 'width': '15%' }, obj.sent[i].time),
					E('td', { 'class': 'td left', 'data-title': tableHeaders[2], 'width': '20%' }, to),
					E('td', { 'class': 'td left', 'data-title': tableHeaders[3], 'width': '50%' }, obj.sent[i].content),
				]),
			);
			s = (s % 2) + 1;
		};

		var button = ( 
			E('hr'),
				E('div', { 'class': 'right'  }, [
				E('button', { 
					'class': 'cbi-button cbi-button-remove', 'id': 'clr', 'click': ui.createHandlerFn(this, 'handleClear')
				}, [ _('Remove SMS') ]),
				'\xa0\xa0\xa0',
                                E('button', {
                                        'class': 'cbi-button cbi-button-save', 'id': 'clr', 'click': ui.createHandlerFn(this, 'handleRefresh')
                                }, [ _('Refresh') ])
			])
		);

		var result = E('fieldset', { 'class': 'cbi-section' }, [E('h2', {}, _('Smstools3: Outgoing messages')), tableSMS, button]);
		return result;
	},
	handleSaveApply: null,	
	handleSave: null,
	handleReset: null
});
