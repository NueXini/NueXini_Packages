'use strict';
'require baseclass';
'require form';
'require fs';
'require view';
'require ui';
'require uci';
'require poll';
'require dom';
'require tools.widgets as widgets';

/*
	Copyright 2021-2025 Rafał Wabik - IceG - From eko.one.pl forum
	
	Licensed to the GNU General Public License v3.0.
	
	Thanks to https://github.com/koshev-msk for the initial progress bar calculation for rssi/rsrp/rsrq/sinnr.
*/

function csq_bar(v, m) {
var pg = document.querySelector('#csq')
var vn = parseInt(v) || 0;
var mn = parseInt(m) || 100;
var pc = Math.floor((100 / mn) * vn);
		if (vn >= 20 && vn <= 31 ) 
			{
			pg.firstElementChild.style.background = 'lime';
			var tip = _('Very good');
			};
		if (vn >= 14 && vn <= 19) 
			{
			pg.firstElementChild.style.background = 'yellow';
			var tip = _('Good');
			};
		if (vn >= 10 && vn <= 13) 
			{
			pg.firstElementChild.style.background = 'darkorange';
			var tip = _('Weak');
			};
		if (vn <= 9 && vn >= 1) 
			{
			pg.firstElementChild.style.background = 'red';
			var tip = _('Very weak');
			};
pg.firstElementChild.style.width = pc + '%';
pg.style.width = '33%';
pg.setAttribute('title', '%s'.format(v) + ' | ' + tip + ' ');
}

function rssi_bar(v, m) {
var pg = document.querySelector('#rssi')
var vn = parseInt(v) || 0;
var mn = parseInt(m) || 100;
if (vn > -50) { vn = -50 };
if (vn < -110) { vn = -110 };
var pc =  Math.floor(100*(1-(-50 - vn)/(-50 - mn)));
		if (vn > -70) 
			{
			pg.firstElementChild.style.background = 'lime';
			var tip = _('Very good');
			};
		if (vn >= -85 && vn <= -70) 
			{
			pg.firstElementChild.style.background = 'yellow';
			var tip = _('Good');
			};
		if (vn >= -100 && vn <= -86) 
			{
			pg.firstElementChild.style.background = 'darkorange';
			var tip = _('Weak');
			};
		if (vn < -100) 
			{
			pg.firstElementChild.style.background = 'red';
			var tip = _('Very weak');
			};
pg.firstElementChild.style.width = pc + '%';
pg.style.width = '33%';
pg.firstElementChild.style.animationDirection = "reverse";
pg.setAttribute('title', '%s'.format(v) + ' | ' + tip + ' ');
}

function rsrp_bar(v, m) {
var pg = document.querySelector('#rsrp')
var vn = parseInt(v) || 0;
var mn = parseInt(m) || 100;
if (vn > -50) { vn = -50 };
if (vn < -140) { vn = -140 };
var pc =  Math.floor(120*(1-(-50 - vn)/(-70 - mn)));
		if (vn >= -80 ) 
			{
			pg.firstElementChild.style.background = 'lime';
			var tip = _('Very good');
			};
		if (vn >= -90 && vn <= -79) 
			{
			pg.firstElementChild.style.background = 'yellow';
			var tip = _('Good');
			};
		if (vn >= -100 && vn <= -89) 
			{
			pg.firstElementChild.style.background = 'darkorange';
			var tip = _('Weak');
			};
		if (vn < -100) 
			{
			pg.firstElementChild.style.background = 'red';
			var tip = _('Very weak');
			};
pg.firstElementChild.style.width = pc + '%';
pg.style.width = '33%';
pg.firstElementChild.style.animationDirection = "reverse";
pg.setAttribute('title', '%s'.format(v) + ' | ' + tip + ' ');
}

function sinr_bar(v, m) {
var pg = document.querySelector('#sinr')
var vn = parseInt(v) || 0;
var mn = parseInt(m) || 100;
var pc = Math.floor(100-(100*(1-((mn - vn)/(mn - 40)))));
		if (vn > 20 ) 
			{
			pg.firstElementChild.style.background = 'lime';
			var tip = _('Excellent');
			};
		if (vn >= 13 && vn <= 20)
			{
			pg.firstElementChild.style.background = 'yellow';
			var tip = _('Good');
			};
		if (vn > 0 && vn <= 12) 
			{
			pg.firstElementChild.style.background = 'darkorange';
			var tip = _('Mid cell');
			};
		if (vn <= 0) 
			{
			pg.firstElementChild.style.background = 'red';
			var tip = _('Cell edge');
			};
pg.firstElementChild.style.width = pc + '%';
pg.style.width = '33%';
pg.firstElementChild.style.animationDirection = "reverse";
pg.setAttribute('title', '%s'.format(v) + ' | ' + tip + ' ');
}

function rsrq_bar(v, m) {
var pg = document.querySelector('#rsrq')
var vn = parseInt(v) || 0;
var mn = parseInt(m) || 100;
var pc = Math.floor(115-(100/mn)*vn);
if (vn > 0) { vn = 0; };
		if (vn >= -10 ) 
			{
			pg.firstElementChild.style.background = 'lime';
			var tip = _('Excellent');
			};
		if (vn >= -15 && vn <= -9) 
			{
			pg.firstElementChild.style.background = 'yellow';
			var tip = _('Good');
			};
		if (vn >= -20 && vn <= -14) 
			{
			pg.firstElementChild.style.background = 'darkorange';
			var tip = _('Mid cell');
			};
		if (vn < -20) 
			{
			pg.firstElementChild.style.background = 'red';
			var tip = _('Cell edge');
			};
pg.firstElementChild.style.width = pc + '%';
pg.style.width = '33%';
pg.firstElementChild.style.animationDirection = "reverse";
pg.setAttribute('title', '%s'.format(v) + ' | ' + tip + ' ');
}

function SIMdata(data) {
	var sdata = JSON.parse(data);

	if (sdata.simslot.length > 0) {
		return ui.itemlist(E('span'), [
		_('SIM Slot'), sdata.simslot,
		_('SIM IMSI'), sdata.imsi,
		_('SIM ICCID'), sdata.iccid,
		_('Modem IMEI'), sdata.imei,
		_('Hint'), _('CLICK ME TO SEE NEW MENU')
		]);
	}
	else {
		return ui.itemlist(E('span'), [
		_('SIM IMSI'), sdata.imsi,
		_('SIM ICCID'), sdata.iccid,
		_('Modem IMEI'), sdata.imei,
		_('Hint'), _('CLICK ME TO SEE NEW MENU')
		]);
	}
}

function active_select() {
	uci.load('modemdefine').then(function() {
		var modemz = (uci.get('modemdefine', '@modemdefine[1]', 'comm_port'));
		if (!modemz) {
			document.getElementById("modc").disabled = true;
		}
		else {
			document.getElementById("modc").disabled = false;
		}
	});
}

function formatDuration(sec) {
    if (sec === '-') { return '-'; }
    if (sec === '') { return '-'; }
    var d = Math.floor(sec / 86400),
        h = Math.floor(sec / 3600) % 24,
        m = Math.floor(sec / 60) % 60,
        s = sec % 60;
    var time = d > 0 ? d + 'd ' : '';
    if (time !== '') { time += h + 'h '; } else { time = h > 0 ? h + 'h ' : ''; }
    if (time !== '') { time += m + 'm '; } else { time = m > 0 ? m + 'm ' : ''; }
    time += s + 's';
    return time;
}

function formatDateTime(s) {
	if (s.length == 14) {
		return s.replace(/(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/, "$1-$2-$3 $4:$5:$6");
	} else if (s.length == 12) {
		return s.replace(/(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})/, "$1-$2-$3 $4:$5");
	} else if (s.length == 8) {
		return s.replace(/(\d{4})(\d{2})(\d{2})/, "$1-$2-$3");
	} else if (s.length == 6) {
		return s.replace(/(\d{4})(\d{2})/, "$1-$2");
	}
	return s;
}

function checkOperatorName(t) {
    var w = t.split(" ");
    var f = {};

    for (var i = 0; i < w.length; i++) {
        var wo = w[i].toLowerCase(); 
        if (!f.hasOwnProperty(wo)) {
            f[wo] = i;
        }
    }

    var u = Object.keys(f).map(function(wo) {
        return w[f[wo]];
    });

    var r = u.join(" ");
    return r;
}

return view.extend({


modemDialog: baseclass.extend({
		__init__: function(title, description, callback) {
			this.title       = title;
			this.description = description;
			this.callback    = callback;
		},

		load: function() {
			return uci.load('modemdefine');
		},

		render: function(content) {

			var sections = uci.sections('modemdefine');
			var portM = sections.length;

    			var result = "";
    			for (var i = 1; i < portM; i++) {
       			       	result += sections[i].comm_port + '_' + sections[i].network + '#' + sections[i].comm_port + ' - ' + sections[i].modem + ' (' + sections[i].user_desc + ');';
    			}
			var result = result.slice(0, -1);
			var result = result.replace("(undefined)", "");

			ui.showModal(this.title, [
				E('div', { 'class': 'cbi-section' }, [
					E('div', { 'class': 'cbi-section-descr' }, this.description),
					E('div', { 'class': 'cbi-section' },
						E('p', {},
							E('div', { 'class': 'cbi-value' }, [
							E('p'),
							E('label', { 'class': 'cbi-value-title' }, [ _('Modem') ]),
							E('div', { 'class': 'cbi-value-field' }, [
								E('select', { 'class': 'cbi-input-select',
										'id': 'mselect',
										'style': 'margin:0px 0; width:100%;',
										},
									(result || "").trim().split(/;/).map(function(cmd) {
										var fields = cmd.split(/#/);
										var name = fields[1];
										var code = fields[0];
									return E('option', { 'value': code }, name ) })

								)
							]) 
						]),
						)
					),
				]),
				E('div', { 'class': 'right' }, [
					E('button', {
						'class': 'btn',
						'click': ui.createHandlerFn(this, this.handleDissmis),
					}, _('Cancel')),

					' ',
					E('button', {
						'id': 'btn_save',
						'class': 'btn cbi-button-positive important',
						'click': ui.createHandlerFn(this, this.handleSave),
					}, _('Save')),

				]),
			]);
		},

		handleSave: function(ev) {

			return uci.load('modemdefine').then(function() {

				var vx = document.getElementById('mselect').value;
				var marr = vx.split('_');

				uci.set('modemdefine', '@general[0]', 'main_modem', marr[0].toString());
				uci.set('modemdefine', '@general[0]', 'main_network', marr[1].toString());


				uci.save();
				uci.apply();

				window.setTimeout(function() {
					if (!poll.active()) poll.start();
					location.reload();
					//ev.target.blur();
				}, 2000).finally();
			});

		},

		handleDissmis: function(ev) {
				ui.hideModal();
				if (!poll.active()) poll.start();
		},

		show: function() {
			ui.showModal(null,
				E('p', { 'class': 'spinning' }, _('Loading'))
			);
			poll.stop();
			this.load().then(content => {
				ui.hideModal();
				return this.render(content);
			}).catch(e => {
				ui.hideModal();
				return this.error(e);
			})
		},
	}),

simDialog: baseclass.extend({
		__init__: function(title, description, callback) {
			this.title       = title;
			this.description = description;
			this.callback    = callback;
		},

		load: function() {
			return L.resolveDefault(fs.exec_direct('/usr/share/3ginfo-lite/3ginfo.sh', [ 'json' ]));
		},

		render: function(content) {

			var json = JSON.parse(content);

			if (json) {
				if (!json.imei.length > 2) {
					return false,
					       poll.start()
				}
			}


			ui.showModal(this.title, [
				E('div', { 'class': 'cbi-section' }, [
					E('div', { 'class': 'cbi-section-descr' }, this.description),
					E('div', { 'class': 'cbi-section' },
						E('p', {},
							E('div', { 'class': 'cbi-value' }, [
							E('p'),
							E('label', { 'class': 'cbi-value-title' }, [ _('SIM IMSI') ]),
							E('div', { 'class': 'cbi-value-field' }, [
								E('input', {
									'class': 'cbi-input-text',
									'readonly': 'readonly',
									'value': json.imsi
								}, null),
							]),
							E('label', { 'class': 'cbi-value-title' }, [ _('SIM ICCID') ]),
							E('div', { 'class': 'cbi-value-field' }, [
								E('input', {
									'class': 'cbi-input-text',
									'readonly': 'readonly',
									'value': json.iccid
								}, null),
							]),
							E('label', { 'class': 'cbi-value-title' }, [ _('Modem IMEI') ]),
							E('div', { 'class': 'cbi-value-field' }, [
								E('input', {
									'class': 'cbi-input-text',
									'readonly': 'readonly',
									'value': json.imei
								}, null),
							])

						]),
						)
					),
				]),
				E('div', { 'class': 'right' }, [
					E('button', {
						'class': 'btn',
						'click': ui.createHandlerFn(this, this.handleDissmis),
					}, _('Close')),
				]),
			]);
		},

		handleDissmis: function(ev) {
				ui.hideModal();
				if (!poll.active()) poll.start();
		},

		show: function() {
			ui.showModal(null,
				E('p', { 'class': 'spinning' }, _('Loading'))
			);
			poll.stop();
			this.load().then(content => {
				ui.hideModal();
				return this.render(content);
			}).catch(e => {
				ui.hideModal();
				return this.error(e);
			})
		},
	}),


	formdata: { threeginfo: {} },
	
	load: function() {
		return L.resolveDefault(fs.exec_direct('/usr/share/3ginfo-lite/3ginfo.sh', [ 'json' ]));
	},

	render: function(data) {
		var m, s, o;

		active_select();

		var upModemDialog = new this.modemDialog(
			_('Defined modems'),
			_('Interface for selecting user defined modems.'),
		);

		var upSIMDialog = new this.simDialog(
			_('SIM card menu'),
			_('Information read from the SIM card and device.'),
		);


		if (data != null){
		try {

		var json = JSON.parse(data);

			if(!json.hasOwnProperty('error')){
				
				if (json.registration == 'SIM not inserted' || json.registration == '-') { 
					ui.addNotification(null, E('p', _('Problem with registering to the network, check the SIM card.')), 'info');
				}
				if (json.registration == 'SIM PIN required') { 
					ui.addNotification(null, E('p', _('SIM PIN required')), 'info');
				}
				if (json.registration == 'SIM PUK required') { 
					ui.addNotification(null, E('p', _('SIM PUK required')), 'info');
				}
				if (json.registration == 'SIM failure') { 
					ui.addNotification(null, E('p', _('SIM failure')), 'info');
				}
				if (json.registration == 'SIM busy') { 
					ui.addNotification(null, E('p', _('SIM busy')), 'info');
				}
				if (json.registration == 'SIM wrong') { 
					ui.addNotification(null, E('p', _('SIM wrong')), 'info');
				}
				if (json.registration == 'SIM PIN2 required') { 
					ui.addNotification(null, E('p', _('SIM PIN2 required')), 'info');
				}
				if (json.registration == 'SIM PUK2 required') { 
					ui.addNotification(null, E('p', _('SIM PUK2 required')), 'info');
				}
				if (json.signal == '0' || json.signal == '' || json.signal == '-') {
					ui.addNotification(null, E('p', _('There is a problem reading data from the modem. \
										<br /><br /><b>Please check:</b> \
										<ul><li>1. Modem availability in the system.</li><li>2. The correct installation of the SIM card in the modem.</li><li> \
										3. Port for communication with the modem.</li><li><ul>')), 'info');
				}
				else {
					if (json.connt == '' || json.connt == '-') {
						ui.addNotification(null, E('p', _('There is a problem reading connection data. \
											<br /><br /><b>Please check:</b> \
											<ul><li>1. Connection of the modem to the internet, the correctness of the entered APN. Some modems need to force the APN on the modem using at commands to connect to internet.</li><li> \
											2. Check that the correct interface assigned to the modem is selected. The default name of the interface in the package is wan.</li><li><ul>')), 'info');
					}


			pollData: poll.add(function() {
				return L.resolveDefault(fs.exec_direct('/usr/share/3ginfo-lite/3ginfo.sh', 'json'))
					.then(function(res) {
					var json = JSON.parse(res);

				if (!json.cport.includes('192.')) {
					if (json.signal == '0' || json.signal == '') {
						fs.exec('sleep 3');
							if (json.signal == '0' || json.signal == '' || json.signal == '-') {
							L.ui.showModal(_('3ginfo-lite'), [
							E('p', { 'class': 'spinning' }, _('Waiting to read data from the modem...'))
							]);

							window.setTimeout(function() {
							location.reload();
							}, 5000).finally();
							}
					}
					else {
					L.hideModal();
					}
				}
					
					var icon, wicon, ticon, t;
					var wicon = L.resource('icons/loading.gif');
					var ticon = L.resource('icons/ctime.png');

					var p = (json.signal);
					if (p < 0)
						icon = L.resource('icons/3ginfo-0.png');
					else if (p == 0)
						icon = L.resource('icons/3ginfo-0.png');
					else if (p < 20)
						icon = L.resource('icons/3ginfo-0-20.png');
					else if (p < 40)
						icon = L.resource('icons/3ginfo-20-40.png');
					else if (p < 60)
						icon = L.resource('icons/3ginfo-40-60.png');
					else if (p < 80)
						icon = L.resource('icons/3ginfo-60-80.png');
					else
						icon = L.resource('icons/3ginfo-80-100.png');


					if (document.getElementById('signal')) {
						var view = document.getElementById("signal");
						view.innerHTML = String.format('<medium>%d%%</medium><br/>' + '<img style="padding-left: 10px;" src="%s"/>', p, icon);
					}

					if (document.getElementById('connst')) {
						var view = document.getElementById("connst");
						if (json.conn_time == '' || json.conn_time == '-') {
						view.innerHTML = String.format('<img style="width: 16px; height: 16px; vertical-align: middle;" src="%s"/>' + ' ' +_('Waiting for connection data...'), wicon, p);
						}
						else {
						view.innerHTML = String.format('<img style="width: 16px; height: 16px; vertical-align: middle;" src="%s"/>' + ' ' + formatDuration(json.conn_time_sec) + ' ' + ' | \u25bc\u202f' + json.rx + ' \u25b2\u202f' + json.tx, ticon, t);
						}
					}

					if (document.getElementById('operator')) {
						var view = document.getElementById("operator");
						if (!json.operator_name.length > 1) { 
						view.textContent = '-';
						}
						else {
						view.textContent = checkOperatorName(json.operator_name);
						}
					}

					if (document.getElementById('location')) {
						var viewloc = document.getElementById("location");
						if (!json.location.length > 2) { 
						viewloc.style.display = 'none';
						}
						else {
						viewloc.innerHTML = json.location;
						}

					}

					if (document.getElementById('sim')) {
						var view = document.getElementById("sim");
						var sv = document.getElementById("simv");
						if (json.registration == '') { 
						view.textContent = '-';
						}
						else {
						sv.style.visibility = "visible";
						view.textContent = json.registration;
						if (json.registration == '0') { 
							view.textContent = _('Not registered');
						}
						if (json.registration == '1') { 
							view.textContent = _('Registered');
						}
						if (json.registration == '2') { 
							view.textContent = _('Searching..');
						}
						if (json.registration == '3') { 
							view.textContent = _('Registering denied');
						}
						if (json.registration == '5') { 
							view.textContent = _('Registered (roaming)');
						}
						if (json.registration == '6') { 
							view.textContent = _('Registered, only SMS');
						}
						if (json.registration == '7') { 
							view.textContent = _('Registered (roaming), only SMS');
						}
					}
					}

					if (document.getElementById('mode')) {
						var view = document.getElementById("mode");
						if (!json.mode.length > 1) { 
						view.textContent = '-';
						}
						else {
						view.textContent = json.mode;
						}
					}

					if (document.getElementById('modem')) {
						var view = document.getElementById("modem");
						if (!json.modem.length > 1) { 
						view.textContent = '-';
						}
						else {
						view.textContent = json.modem;
						}
					}

					if (document.getElementById('fw')) {
						var view = document.getElementById("fw");
						if (!json.firmware.length > 1) { 
						view.textContent = '-';
						}
						else {
						view.textContent = json.firmware;
						}
					}

					if (document.getElementById('cport')) {
						var view = document.getElementById("cport");
						if (!json.cport.length > 1) { 
						view.textContent = '-';
						}
						else {
						view.textContent = json.cport;
						}
					}

					if (document.getElementById('protocol')) {
						var view = document.getElementById("protocol");
						if (!json.protocol.length > 1) { 
						view.textContent = '-';
						}
						else {
						view.textContent = json.protocol;
						}
					}

					if (document.getElementById('temp')) {
						var view = document.getElementById("temp");
						var viewn = document.getElementById("tempn");
						var t = json.mtemp;
						if (!t.length > 1 && t.includes(' ') || t == '' || t == '-') { 
						viewn.style.display = 'none';
						}
						else {
						view.textContent = t.replace('&deg;', '°');
						}
					}

					if (document.getElementById('csq')) {
						var view = document.getElementById("csq");
						if (json.signal == 0 || json.signal == '-') {
						view.style.visibility = 'hidden';
						}
						else {
						if (json.csq == '') { 
						view.textContent = '-';
						}
						else {
						csq_bar(json.csq, 31);
						}
						}
					}

					if (document.getElementById('rssi')) {
						var view = document.getElementById("rssi");
						if (json.rssi == '-') { 
						view.style.visibility = 'hidden';
						}
						else {
							view.style.visibility = 'visible';
							var z = json.rssi;
							if (z.includes('dBm')) { 
							var rssi_min = -110;
							rssi_bar(json.rssi, rssi_min);	
							}
							else {
							var rssi_min = -110;
							rssi_bar(json.rssi + " dBm", rssi_min);
							}
						}
					}

					if (document.getElementById('rsrp')) {
						var view = document.getElementById('rsrp');
						if (json.rsrp == '-') { 
						view.style.visibility = 'hidden';
						}
						else {
							view.style.visibility = 'visible';
							var z = json.rsrp;
							if (z.includes('dBm')) { 
							var rsrp_min = -140;
							rsrp_bar(json.rsrp, rsrp_min);

							}
							else {
							var rsrp_min = -140;
							rsrp_bar(json.rsrp + " dBm", rsrp_min);
							}
						}
					}

					if (document.getElementById('sinr')) {
						var view = document.getElementById("sinr");
						if (json.sinr == '-') { 
						view.style.visibility = 'hidden';
						}
						else {
							view.style.visibility = 'visible';
							var z = json.sinr;
							if (z.includes('dB')) { 
							view.textContent = json.sinr;
							}
							else {
							var sinr_min = -21;
							sinr_bar(json.sinr + " dB", sinr_min);
							}
						}
					}

					if (document.getElementById('rsrq')) {
						var view = document.getElementById("rsrq");
						if (json.rsrq == '-') { 
						view.style.visibility = 'hidden';
						}
						else {
							view.style.visibility = 'visible';
							var z = json.rsrq;
							if (z.includes('dB')) { 
							view.textContent = json.rsrq;
							}
							else {
							var rsrq_min = -20;
							rsrq_bar(json.rsrq + " dB", rsrq_min);
							}
						}
					}

					if (document.getElementById('mccmnc')) {
						var view = document.getElementById("mccmnc");
						if (json.operator_mcc == '-' & json.operator_mnc == '-') { 
						view.textContent = '-';
						}
						else {
						view.textContent = json.operator_mcc + " " + json.operator_mnc;
						}
					}

					if (document.getElementById('lac')) {
						var view = document.getElementById("lac");
						var viewn = document.getElementById("lacn");
						if (json.lac_dec.length < 2 || json.lac_hex.length < 2) { 
						viewn.style.display = "none";
						}
						else {
							if (json.lac_dec == '' || json.lac_hex == '') { 
							var lc = json.lac_dec   + ' ' + json.lac_hex;
							var ld = lc.split(' ').join('');
							view.textContent = ld;
							}
							else {
							view.innerHTML = json.lac_dec + ' (' + json.lac_hex + ')';
							}
						}
					}

					if (document.getElementById('tac')) {
						var view = document.getElementById("tac");
						var tac_dh, tac_dec_hex, lac_dec_hex;
							if (json.tac_d.length > 1 || json.tac_h.length > 1) {
							var tac_dh =  json.tac_d + ' (' + json.tac_h + ')';
									view.textContent = tac_dh;
							}
							else {
								if (json.tac_dec.length > 1 || json.tac_hex.length > 1) {
									var tac_dh =  json.tac_dec + ' (' + json.tac_hex + ')';
									view.textContent = tac_dh;
								}
								else {
									view.textContent = '-';
								}
							}
					}

					if (document.getElementById('cid')) {
						var view = document.getElementById("cid");
						if (json.cid_dec == '' || json.cid_hex == '') { 
						var cc = json.cid_hex   + ' ' + json.cid_dec;
						var cd = cc.split(' ').join('');
						view.textContent = cd;
						}
						else {
						view.innerHTML = json.cid_dec + ' (' + '' + json.cid_hex + ')';
						}
					}

					if (document.getElementById('pband')) {
						var view = document.getElementById("pband");
						if (json.pband == '-') { 
						view.textContent = '-';
						}
						else {
							if (json.pci.length > 0 && json.earfcn.length > 0) { 
								view.textContent = json.pband + ' | ' + json.pci + ' ' + json.earfcn;
							}
							else {
								view.textContent = json.pband;
							}
						}
					}

					if (document.getElementById('s1band')) {
						var view = document.getElementById("s1band");
						if (json.s1band == '-') { 
						view.textContent = '-';
						}
						else {
							if (json.s1pci.length > 0 && json.s1earfcn.length > 0) { 
								view.textContent = json.s1band + ' | ' + json.s1pci + ' ' + json.s1earfcn;
							}
							else {
								view.textContent = json.s1band;
							}
						}
					}
					
					if (document.getElementById('s2band')) {
						var view = document.getElementById("s2band");
						if (json.s2band == '-') { 
						view.textContent = '-';
						}
						else {
							if (json.s2pci.length > 0 && json.s2earfcn.length > 0) { 
								view.textContent = json.s2band + ' | ' + json.s2pci + ' ' + json.s2earfcn;
							}
							else {
								view.textContent = json.s2band;
							}
						}
					}
					
					if (document.getElementById('s3band')) {
						var view = document.getElementById("s3band");
						if (json.s3band == '-') { 
						view.textContent = '-';
						}
						else {
							if (json.s3pci.length > 0 && json.s3earfcn.length > 0) { 
								view.textContent = json.s3band + ' | ' + json.s3pci + ' ' + json.s3earfcn;
							}
							else {
								view.textContent = json.s3band;
							}
						}
					}
					
					if (document.getElementById('s4band')) {
						var view = document.getElementById("s4band");
						if (json.s4band == '-') {  
						view.textContent = '-';
						}
						else {
							if (json.s4pci.length > 0 && json.s4earfcn.length > 0) { 
								view.textContent = json.s4band + ' | ' + json.s4pci + ' ' + json.s4earfcn;
							}
							else {
								view.textContent = json.s4band;
							}
						}
					}
					});
				});	

				}
			}	

		} catch (err) {
				ui.addNotification(null, E('p', _('Error: ') + err.message), 'error');
				}
		}		

		var info = _('More information about the 3ginfo on the %seko.one.pl forum%s.').format('<a href="https://eko.one.pl/?p=openwrt-3ginfo" target="_blank">', '</a>');
		m = new form.JSONMap(this.formdata, _('3ginfo-lite'), info);

		s = m.section(form.TypedSection, '3ginfo', '', null);
		s.anonymous = true;

		s.render = L.bind(function(view, section_id) {

			return E('div', { 'class': 'cbi-section' }, [

			E('div', { 'class': 'right' }, [
				E('button', {
					'id': 'modc',
					'style': 'position:relative; display:block; margin:0 !important; margin-top:-3% !important; left:95%; top:',
 					'disabled': 'true',
					'data-tooltip': _('Modem selection menu'),
					'class': 'btn cbi-button',
					'click': ui.createHandlerFn(this, function() {
							return upModemDialog.show();
					}),
				}, _('☰')),
			]),

			E('h4', {}, [ _('General Information') ]),
			E('table', { 'class': 'table' }, [
				E('tr', { 'class': 'tr' }, [
					E('td', { 'class': 'td left', 'width': '33%' }, [ _('Signal strength')]),
					E('td', { 'class': 'td left', 'id': 'signal' }, [ '-' ]),
					]),
				E('tr', { 'class': 'tr' }, [
					E('td', { 'class': 'td left', 'width': '33%' }, [ _('Operator')]),
					E('td', { 'class': 'td left' }, [
						E('div', { 'class': 'right' }, [
							E('div', { 'style': 'text-align:left;font-size:100%', 'id': 'operator' }, [ '-' ]),
							E('div', { 'style': 'text-align:left;font-size:66%', 'id': 'location' }, [ '-' ]),
						]),
					]),
				]),
				E('tr', { 'class': 'tr' }, [
					E('td', { 'class': 'td left', 'width': '33%' }, [ _('SIM status')]),
					E('td', { 'class': 'td left'}, [
						E('span', {
							'class': 'ifacebadge',
							'title': null,
							'id': 'simv',
							'style': 'visibility: hidden; margin:0 auto; padding: 4px;',
							'click': ui.createHandlerFn(this, function() {
									return upSIMDialog.show();
							}),
							
						}, [
							E('div', { 'class': 'ifacebox-body' }, [
							E('div', { 'class': 'cbi-tooltip-container' }, [
							E('img', {
								'src': L.resource('icons/sim1m.png'),
								'style': 'width:24px; height:auto; padding: 1%; margin:0 auto;',
								'title': _(''),
								'class': 'middle',
							}),
							E('span', { 'class': 'cbi-tooltip', 'style': 'text-align:left;font-size:80%' }, SIMdata(data)),
								]),
							]),
						]),
						E('normal', { 'id': 'sim', 'style': 'margin-left: 0.5em;'}, [ '-' ]),
						]),
					]),
				E('tr', { 'class': 'tr' }, [
					E('td', { 'class': 'td left', 'width': '33%' }, [ _('Connection statistics')]),
					E('td', { 'class': 'td left', 'id': 'connst' }, [ '-' ]),
					]),
				E('tr', { 'class': 'tr' }, [
					E('td', { 'class': 'td left', 'width': '33%' }, [ _('Technology')]),
					E('td', { 'class': 'td left', 'id': 'mode' }, [ '-' ]),
					]),
			]),
			E('h4', {}, [ _('Modem Information') ]),
			E('table', { 'class': 'table' }, [
				E('tr', { 'class': 'tr' }, [
					E('td', { 'class': 'td left', 'width': '33%' }, [ _('Modem type')]),
					E('td', { 'class': 'td left', 'id': 'modem' }, [ '-' ]),
					]),
				E('tr', { 'class': 'tr' }, [
					E('td', { 'class': 'td left', 'width': '33%' }, [ _('Revision / Firmware')]),
					E('td', { 'class': 'td left', 'id': 'fw' }, [ '-' ]),
					]),
				E('tr', { 'class': 'tr' }, [
					E('td', { 'class': 'td left', 'width': '33%' }, [ _('IP adress / Communication Port')]),
					E('td', { 'class': 'td left', 'id': 'cport' }, [ '-' ]),
					]),
				E('tr', { 'class': 'tr' }, [
					E('td', { 'class': 'td left', 'width': '33%' }, [ _('Protocol')]),
					E('td', { 'class': 'td left', 'id': 'protocol' }, [ '-' ]),
					]),
				E('tr', { 'id': 'tempn', 'class': 'tr' }, [
					E('td', { 'class': 'td left', 'width': '33%' }, [ _('Chip Temperature')]),
					E('td', { 'class': 'td left', 'id': 'temp' }, [ '-' ]),
					]),
			]),
			E('h4', {}, [ _('Cell / Signal Information') ]),
			E('table', { 'class': 'table' }, [
				E('tr', { 'class': 'tr' }, [
					E('td', { 'class': 'td left', 'width': '33%' }, [ _('MCC MNC')]),
					E('td', { 'class': 'td left', 'id': 'mccmnc' }, [ '-' ]),
					]),
				E('tr', { 'class': 'tr' }, [
					E('td', { 'class': 'td left', 'width': '33%' }, [ _('Cell ID')]),
					E('td', { 'class': 'td left', 'id': 'cid' }, [ '-' ]),
					]),
				E('tr', { 'class': 'tr' }, [
					E('td', { 'class': 'td left', 'width': '33%' }, [ _('TAC')]),
					E('td', { 'class': 'td left', 'id': 'tac' }, [ '-' ]),
					]),
				E('tr', { 'id': 'lacn', 'class': 'tr' }, [
					E('td', { 'class': 'td left', 'width': '33%' }, [ _('LAC')]),
					E('td', { 'class': 'td left', 'id': 'lac' }, [ '-' ]),
					]),

				E('tr', { 'id': 'csqn', 'class': 'tr' }, [
					E('td', { 'class': 'td left', 'width': '33%' }, [
					_('CSQ'),
					E('div', { 'style': 'text-align:left;font-size:66%' }, [ _('(Signal Strength)') ]),
					]),
					E('td', { 'class': 'td' }, E('div', {
							'id': 'csq',
							'class': 'cbi-progressbar',
							'title': '-'
							}, E('div')
						))
					]),
				E('tr', { 'id': 'rssin', 'class': 'tr' }, [
					E('td', { 'class': 'td left', 'width': '33%' }, [
					_('RSSI'),
					E('div', { 'style': 'text-align:left;font-size:66%' }, [ _('(Received Signal Strength Indicator)') ]),
					]),
					E('td', { 'class': 'td' }, E('div', {
							'id': 'rssi',
							'class': 'cbi-progressbar',
							'title': '-'
							}, E('div')
						))
					]),
				E('tr', { 'id': 'rsrpn', 'class': 'tr' }, [
					E('td', { 'class': 'td left', 'width': '33%' }, [
					_('RSRP'),
					E('div', { 'style': 'text-align:left;font-size:66%' }, [ _('(Reference Signal Receive Power)') ]),
					]),
					E('td', { 'class': 'td' }, E('div', {
							'id': 'rsrp',
							'class': 'cbi-progressbar',
							'title': '-'
							}, E('div')
						))
					]),
				E('tr', { 'id': 'sinrn', 'class': 'tr' }, [
					E('td', { 'class': 'td left', 'width': '33%' }, [
					_('SINR'),
					E('div', { 'style': 'text-align:left;font-size:66%' }, [ _('(Signal to Interference plus Noise Ratio)') ]),
					]),
					E('td', { 'class': 'td' }, E('div', {
							'id': 'sinr',
							'class': 'cbi-progressbar',
							'title': '-'
							}, E('div')
						))
					]),
				E('tr', { 'id': 'rsrqn', 'class': 'tr' }, [
					E('td', { 'class': 'td left', 'width': '33%' }, [
					_('RSRQ'),
					E('div', { 'style': 'text-align:left;font-size:66%' }, [ _('(Reference Signal Received Quality)') ]),
					]),
					E('td', { 'class': 'td' }, E('div', {
							'id': 'rsrq',
							'class': 'cbi-progressbar',
							'title': '-'
							}, E('div')
						))
					]),
				E('tr', { 'class': 'tr' }, [
					E('td', { 'class': 'td left', 'width': '33%' }, [ _('Primary band (PCC) | PCI & EARFCN')]),
					E('td', { 'class': 'td left', 'id': 'pband' }, [ '-' ]),
					]),
				E('tr', { 'class': 'tr' }, [
					E('td', { 'class': 'td left', 'width': '33%' }, [ _('CA band (SCC1)')]),
					E('td', { 'class': 'td left', 'id': 's1band' }, [ '-' ]),
					]),
				E('tr', { 'class': 'tr' }, [
					E('td', { 'class': 'td left', 'width': '33%' }, [ _('CA band (SCC2)')]),
					E('td', { 'class': 'td left', 'id': 's2band' }, [ '-' ]),
					]),
				E('tr', { 'class': 'tr' }, [
					E('td', { 'class': 'td left', 'width': '33%' }, [ _('CA band (SCC3)')]),
					E('td', { 'class': 'td left', 'id': 's3band' }, [ '-' ]),
					]),
				E('tr', { 'class': 'tr' }, [
					E('td', { 'class': 'td left', 'width': '33%' }, [ _('CA band (SCC4)')]),
					E('td', { 'class': 'td left', 'id': 's4band' }, [ '-' ]),
					]),

				])
			]);
		}, o, this);

		s = m.section(form.TypedSection, 'threeginfo', null);
		s.anonymous = true;
		s.addremove = false;

		s.tab('opt1', _('BTS Search'));
		s.anonymous = true;

		o = s.taboption('opt1', form.Button, '_search');
		o.title      = _('Search BTS using Cell ID');
		o.inputtitle = _('Search');
		o.onclick = function() {

		return uci.load('3ginfo').then(function() {
		var searchsite = (uci.get('3ginfo', '@3ginfo[0]', 'website'));

			if (searchsite.includes('btsearch')) {
			//http://www.btsearch.pl/szukaj.php?mode=std&search=CellID
			
				var id_dec = json.cid_dec;
				var id_hex = json.cid_hex;
				var id_dec_conv = parseInt(id_hex, 16);

				if ( id_dec.length > 2 ) {
					window.open(searchsite + id_dec);
				}
				else {
					window.open(searchsite + id_dec_conv);
				}
			}

			if (searchsite.includes('lteitaly')) {
			//https://lteitaly.it/internal/map.php#bts=MCCMNC.CellIDdiv256

			var zzmnc = json.operator_mnc;
			var first = zzmnc.slice(0, 1);
			var second = zzmnc.slice(1, 2);
			var zzcid = Math.round(json.cid_dec/256);
				if ( zzmnc.length == 3 ) {
					if (first.includes('0')) {
					var cutmnc = zzmnc.slice(1, 3);
					}
					if (first.includes('0') && second.includes('0')) {
					var cutmnc = zzmnc.slice(2, 3);
					}
				}
				if ( zzmnc.length == 2 ) {
					var first = zzmnc.slice(0, 1);
					if (first.includes('0')) {
						var cutmnc = zzmnc.slice(1, 2);
						}
					else {
					var cutmnc = zzmnc;
						}
					}
				if ( zzmnc.length < 2 || !first.includes('0') && !second.includes('0')) {
				var cutmnc = zzmnc;
				}

			window.open(searchsite + json.operator_mcc + cutmnc + '.' + zzcid);
			}
    		});
		};

		return m.render();
	},

	handleSaveApply: null,
	handleSave: null,
	handleReset: null
});
