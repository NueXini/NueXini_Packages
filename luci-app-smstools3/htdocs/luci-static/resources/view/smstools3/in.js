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


function wait(ms){
   var start = new Date().getTime();
   var end = start;
   while(end < start + ms) {
     end = new Date().getTime();
  }
}

return view.extend({

	load: function() {
		L.resolveDefault(fs.exec_direct('/usr/share/luci-app-smstools3/led.sh', [ 'off' ]));
		return L.resolveDefault(fs.exec_direct('/usr/bin/msg_control', [ 'recv' ]));
	},

	handleClear: function(ev) {
		return L.resolveDefault(fs.exec_direct('/usr/bin/msg_control', [ 'rmrecv' ]));
	},

	handleRefresh: function(ev) {
		location.reload ();
	},

	render: function (data) {
		var obj = JSON.parse(data);
		let tableHeaders = [
			_('Send Date'),
			_('Recv.Date'),
			_('From'),
			_('Message')
		];

		let tableSMS = E('table', { 'class': 'table' },
			 E('tr', { 'class': 'tr table-titles' }, [
				E('th', { 'class': 'th left', 'width': '15%' }, tableHeaders[0]),
				E('th', { 'class': 'th left', 'width': '15%' }, tableHeaders[1]),
				E('th', { 'class': 'th left', 'width': '20%' }, tableHeaders[2]),
				E('th', { 'class': 'th left', 'width': '50%' }, tableHeaders[3]),
			]),
		);
		
		var s = 1;
		for (let i = 0; i < obj.recv.length; i++) {
			if (obj.recv[i].from.length > 6 && Number(obj.recv[i].from)) {
				var from = '+' + obj.recv[i].from;
			} else {
				var from = obj.recv[i].from;
			}
			tableSMS.append(E('tr', { 'class': 'tr cbi-rowstyle-'+s }, [
				E('td', { 'class': 'td left', 'data-title': tableHeaders[0], 'width': '15%' }, obj.recv[i].srecv),
					E('td', { 'class': 'td left', 'data-title': tableHeaders[1], 'width': '15%' }, obj.recv[i].drecv),
					E('td', { 'class': 'td left', 'data-title': tableHeaders[2], 'width': '20%' }, from),
					E('td', { 'class': 'td left', 'data-title': tableHeaders[3], 'width': '50%' }, obj.recv[i].content),
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
		var result = E('fieldset', { 'class': 'cbi-section' }, [E('h2', {}, _('Smstools3: Incoming messages')), tableSMS, button]);
		return result;
	},
	handleSaveApply: null,	
	handleSave: null,
	handleReset:  null
});
