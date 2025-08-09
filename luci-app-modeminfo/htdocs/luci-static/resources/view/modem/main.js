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
	Copyright Konstantine Shevlakov <shevlakov@132lan.ru> 2023
	
	Licensed to the GNU General Public License v3.0.
	
*/

return view.extend({

	load: function(data) {
		return L.resolveDefault(fs.exec_direct('/usr/bin/modeminfo'));
	},

	polldata: poll.add(function() {
		return L.resolveDefault(fs.exec_direct('/usr/bin/modeminfo')).then(function(res) {
			var json = JSON.parse(res);
			for (var i = 0; i < json.modem.length; i++) {
				// progressbar cellular metric
				const progressConfig = {
					rssi: {
						selector: '#rssi', min: -110, max: -50,
						calc: (vn, mn) => Math.floor(100 * (1 - (-50 - vn) / (-50 - mn)))
					},
					rsrp: {
						selector: '#rsrp', min: -140, max: -50,
						calc: (vn, mn) => Math.floor(120 * (1 - (-50 - vn) / (-70 - mn)))
					},
					sinr: {
						selector: '#sinr', min: -20, max: 30,
						calc: (vn, mn) => Math.floor(100 - (100 * (1 - ((mn - vn) / (mn - 30)))))
					},
					rsrq: {
						selector: '#rsrq', min: -20, max: 0,
						calc: (vn, mn) => Math.floor(115 - (100 / mn) * vn)
					},
					ecio: {
						selector: '#sinr', min: -24, max: 0,
						calc: (vn, mn) => Math.floor(100 - (100 / mn) * vn)
					}
				};


				function updateProgressBar(type, value, max, i) {
					const config = progressConfig[type];
					if (!config) return;

					const pg = document.querySelector(`${config.selector}${i}`);
					if (!pg) return;

					const vn = Math.max(config.min, Math.min(config.max, parseInt(value) || 0));
					const mn = parseInt(max) || 100;
					const pc = config.calc(vn, mn);

					pg.firstElementChild.style.width = `${pc}%`;
					pg.style.width = '%d%%';
					pg.firstElementChild.style.animationDirection = "reverse";
					pg.setAttribute('title', '%s'.format(value));
				}

				// icon signal strength
				var icn;

				var signalIcons = [
                                        { max: -1, icn: 'signal-000-000.svg' },
                                        { max: 0, icn: 'signal-000-000.svg' },
                                        { max: 10, icn: 'signal-000-000.svg' },
                                        { max: 25, icn: 'signal-000-025.svg' },
                                        { max: 50, icn: 'signal-025-050.svg' },
                                        { max: 75, icn: 'signal-050-075.svg' },
                                        { max: Infinity, icn: 'signal-075-100.svg' }
                                ];
				
				var p = json.modem[i].csq_per || 0;

				var { icn } = signalIcons.find(({ max }) => p <= max);
				var icon = L.resource(`view/modem/icons/${icn}`);

				// Registration Status
				var regStatuses = new Map([
					[0, _('No Registration')],
					[2, _('Searching')], [8, _('Searching')],
					[3, _('Denied')],
					[4, _('Unknown')],
					[5, _('Roaming')], [7, _('Roaming')], [10, _('Roaming')]
				]);

				var rg = json.modem[i].reg;
				var reg = regStatuses.get(rg) || _('No Data');
				
				// frequency band calculator
				var offset, band, bw, frdl, frul;
				var netmode = (json.modem[i].mode)
				var rfcn = (json.modem[i].arfcn)
				if (netmode === "LTE") {
				// list LTE-bans
					var lteBands = [
						{ min: 0, max: 599, frdl: 2110, frul: 1920, offset: 0, band: "1" },
						{ min: 600, max: 1199, frdl: 1930, frul: 1850, offset: 600, band: "2" },
						{ min: 1200, max: 1949, frdl: 1805, frul: 1710, offset: 1200, band: "3" },
						{ min: 1950, max: 2399, frdl: 2110, frul: 1710, offset: 1950, band: "4" },
						{ min: 2400, max: 2469, frdl: 869, frul: 824, offset: 2400, band: "5" },
						{ min: 2750, max: 3449, frdl: 2620, frul: 2500, offset: 2750, band: "7" },
						{ min: 3450, max: 3799, frdl: 925, frul: 880, offset: 3450, band: "8" },
						{ min: 6150, max: 6449, frdl: 791, frul: 832, offset: 6150, band: "20" },
						{ min: 9210, max: 9659, frdl: 758, frul: 703, offset: 9210, band: "28" },
						{ min: 9870, max: 9919, frdl: 452.5, frul: 462.5, offset: 9870, band: "31" },
						{ min: 37750, max: 38249, frdl: 2570, frul: 2570, offset: 37750, band: "38" },
						{ min: 38650, max: 39649, frdl: 2300, frul: 2300, offset: 38650, band: "40" }
					];

					var bandConfig = lteBands.find(b => rfcn >= b.min && rfcn <= b.max) || {
						frdl: 0, frul: 0, offset: 0, band: rfcn
					};
					({ frdl, frul, offset, band } = bandConfig);

					// Bandwidth channel (bw)
					var bandwidths = [1.4, 3, 5, 10, 15, 20];
					var bw = bandwidths[json.modem[i].bwdl] || "";

					// Calc frequency
					var dlfreq = frdl + (rfcn - offset) / 10;
					var ulfreq = frul + (rfcn - offset) / 10;
				} else {
					var nonLteBands = [
						{ 
							condition: (rfcn) => rfcn >= 10562 && rfcn <= 10838,
							calc: (rfcn) => ({ offset: 950, dlfreq: rfcn / 5, ulfreq: (rfcn - 950) / 5, band: "IMT2100" })
						},
						{ 
							condition: (rfcn) => rfcn >= 2937 && rfcn <= 3088,
							calc: (rfcn) => ({ frul: 925, offset: 340, ulfreq: 340 + (rfcn / 5), dlfreq: (340 + (rfcn / 5)) - 45, band: "UMTS900" })
						},
						{ 
							condition: (rfcn) => rfcn >= 955 && rfcn <= 1023,
							calc: (rfcn) => ({ frul: 890, ulfreq: 890 + ((rfcn - 1024) / 5), dlfreq: (890 + ((rfcn - 1024) / 5)) + 45, band: "DSC900" })
						},
						{ 
							condition: (rfcn) => rfcn >= 512 && rfcn <= 885,
							calc: (rfcn) => ({ frul: 1710, ulfreq: 1710 + ((rfcn - 512) / 5), dlfreq: (1710 + ((rfcn - 512) / 5)) + 95, band: "DCS1800" })
						},
						{ 
							condition: (rfcn) => rfcn >= 1 && rfcn <= 124,
							calc: (rfcn) => ({ frul: 890, ulfreq: 890 + (rfcn / 5), dlfreq: (890 + (rfcn / 5)) + 45,  band: "GSM900" })
						}
				];

					var bandConfig = nonLteBands.find(b => b.condition(rfcn))?.calc(rfcn) || { ulfreq: 0, dlfreq: 0, band: String(rfcn) };

					// CALC BANDS
					({ frul, offset, ulfreq, dlfreq, band } = bandConfig);

				}

					var carrier = "";
					var bcc, freq, distance, calte, namebnd;
					var dist = (json.modem[i].distance)

					var { enbid, cell, pci, lac, cid } = json.modem[i];

					const parts = [lac, cid];
					var namecid = "LAC/CID";

					if (enbid) {
					    parts.push(enbid);
					    namecid += "/eNB ID";

					    if (cell) {
					        parts.push(`/${cell}`);
					        namecid += "/Cell";

					        if (pci) {
					            parts.push(`/${pci}`);
					            namecid += "/PCI";
					        }
					    }
					}

					var lactac = parts.join(' / ').replace(' ', ' ').replace('/ /', '/ ').replace('/ /', '/ ')

					var UMTS_MODES = new Set([
						"3G", "UMTS", "HSPA", "HSUPA", "HSDPA", "HSPA+", 
						"WCDMA", "DC-HSPA+", "HSDPA+HSUPA", "HSDPA,HSUPA"
					]);

					var bcc, scc, cid;
					var bca = "";
					var arfcn = json.modem[i].arfcn + " (" + dlfreq + " / " + ulfreq + " MHz)";
					// name channels and signal/noise  
					if (netmode == "LTE") {
						var calte = (json.modem[i].lteca)
						var bwca = json.modem[i].bwca;
						distance = " ~"+ dist +" km";
						if (calte > 0) {
							carrier = "+";
							scc = json.modem[i].scc;
							bw = bwca;
							bca = " / " + bw + " MHz";
							bcc = " B" + band + "" + scc;
						} else {
							scc = "";
							bcc = " B" + band;
							if (bw) {
								bca = " / " + bw + " MHz";
							} else{
								bca = ""
							}
						}
						var namech = "EARFCN";
						var namesnr = "SINR";
					} else if (UMTS_MODES.has(netmode)) {
						var namech = "UARFCN";
						var namesnr = "ECIO";
						var namecid = "LAC/CID";
						var lactac = json.modem[i].lac + " / " + json.modem[i].cid;
						var bcc = " " + band;
					} else {
						var namech = "ARFCN";
						var namesnr = "SINR/ECIO";
						var namecid = "LAC/CID";
						var lactac = json.modem[i].lac + " / " + json.modem[i].cid;
						var bcc = " " + band;
					}
					if (bw) { 
						namebnd = _('Network/Band/Bandwidth');
					} else {
						namebnd = _('Network/Band');
				}

				// data by element	
				if (document.getElementById('status'+i)){
					var view = document.getElementById('status'+i);
					if (rg == 1 || rg == 6 || rg == 9) {
						if( dist== "--" || dist == "" || dist == "0.00"){
							view.innerHTML = String.format(json.modem[i].cops +'<img style="padding-left: 10px;" src="%s"/>'  + " " +  '<span class="ifacebadge"><p style="color:'+ json.modem[i].csq_col +'"><b>%d%%</b></p></span>', icon, p);
						} else {
							view.innerHTML = String.format(json.modem[i].cops +'<img style="padding-left: 10px;" src="%s"/>'  + " " +  '<span class="ifacebadge"><p style="color:'+ json.modem[i].csq_col +'"><b>%d%%</b></p></span>' + distance, icon, p);
						}
					} else if (rg == 3 || rg == 5 || rg == 7 || rg == 10) {
						if( dist== "--" || dist == "" || dist == "0.00"){
							view.innerHTML = String.format(json.modem[i].cops + " (" + reg + ')<img style="padding-left: 10px;" src="%s"/>'  + " " +  '<span class="ifacebadge"><p style="color:'+ json.modem[i].csq_col +'"><b>%d%%</b></p></span>', icon, p);
						} else {
							viev.innerHTML = String.format(json.modem[i].cops + " (" + reg + ')<img style="padding-left: 10px;" src="%s"/>'  + " " +  '<span class="ifacebadge"><p style="color:'+ json.modem[i].csq_col +'"><b>%d%%</b></p></span>' + distance, icon, p);
						}
					} else {
						view.innerHTML = String.format(reg);
					}
				}

				if (document.getElementById('mode'+i)){
					var view = document.getElementById('mode'+i);
					if (json.modem[i].signal = 0 || json.modem[i].signal == '') {
						view.textContent = '--';
					} else {
						if (json.modem[i].mode == '') { 
							view.textContent = '--';
						} else {
							view.innerHTML = String.format(json.modem[i].mode + "" + carrier + " /"+ bcc +""+ bca);
						}
					}
				}

				if (document.getElementById('namebnd'+i)){
					var view = document.getElementById('namebnd'+i);
					view.innerHTML = String.format(namebnd);
				}

				if (document.getElementById('chname'+i)){
					var view = document.getElementById('chname'+i);
					view.innerHTML = String.format(namech);
				}

				if (document.getElementById('namecid'+i)){
					var view = document.getElementById('namecid'+i);
					view.innerHTML = String.format(namecid);
				}

				if (document.getElementById('arfcn'+i)){
					var view = document.getElementById('arfcn'+i);
					view.innerHTML = String.format(arfcn);
				}

				if (document.getElementById('lac'+i)){
					var view = document.getElementById('lac'+i);
					view.innerHTML = String.format(lactac);
				}

				if (document.getElementById('snrname'+i)) {
					var view = document.getElementById('snrname'+i);
					view.innerHTML = String.format(namesnr);
				}

				if (document.getElementById('rssi'+i)) {
					var view = document.getElementById('rssi'+i);
					if (json.modem[i].rssi == '') {
						view = document.getElementById('--');
					} else {
						updateProgressBar('rssi', json.modem[i].rssi + ' dBm', -110, i);
					}
				}
				if (document.getElementById('sinr'+i)) {
					var view = document.getElementById('sinr'+i);
					if (json.modem[i].sinr == "--" || netmode == "--") {
						view = document.getElementById('--');
					} else {
						if (netmode == "LTE") {
							updateProgressBar('sinr', json.modem[i].sinr + ' dB', -20, i);
						} else {
							updateProgressBar('ecio', json.modem[i].sinr + ' dB', -24, i);
						}
					}
				}
				
				if (document.getElementById('rsrp'+i)) {
					var view = document.getElementById('rsrp'+i);
					if (json.modem[i].rsrp == "--") {
						view = document.getElementById('--');
					} else {
						updateProgressBar('rsrp', json.modem[i].rsrp + ' dBm', -140, i);
					}
				}

				if (document.getElementById('rsrq'+i)) {
					var view = document.getElementById('rsrq'+i);
					if (json.modem[i].rsrq == "--") {
						view = document.getElementById('--');
					} else {
						updateProgressBar('rsrq', json.modem[i].rsrq + ' dB', -20, i);
					}
				}
			};

		});
	}),

	render: function(data){
		var m, s, o;

		m = new form.Map('modeminfo', _('Modeminfo: Network'), _('Cellular network'));
		s = m.section(form.TypedSection, 'general', null);
		var json = JSON.parse(data);
	
		// for future use
		/*	
		var vendors = [];
		var duplicate_modem_index = 1;
		json.modem.forEach(obj => {
  			const device = obj.device;
  			if (!vendors.includes(device)) {
    			vendors.push(device);
  			} else {
    			vendors.push(device+" ("+duplicate_modem_index+")");
    			duplicate_modem_index++;
  			}
		});
		*/
		for (var i = 0; i < json.modem.length; i++) {
			let status = 'status'+i;
			let mode = 'mode'+i;
			let namebnd = 'namebnd'+i;
			let chname = 'chname'+i;
			let namecid = 'namecid'+i;
			let arfcn = 'arfcn'+i;
			let lac = 'lac'+i;
			let rssi = 'rssi'+i;
			let sinr = 'sinr'+i;
			let snrname = 'snrname'+i;
			let rsrp = 'rsrp'+i;
			let rsrq = 'rsrq'+i;
			let m = i+1;
			//s.tab("modem" + i, vendors[i]);
			//o = json.modem.length > 1 ? s.taboption('modem'+i, form.HiddenValue, 'generic') : s.option(form.HiddenValue, 'generic');

			if ( json.modem.length > 1 ) {
				s.tab("modem" + i, _('Modem')+' '+m);
				o = s.taboption('modem'+i, form.HiddenValue, 'generic');
			} else {
				o = s.option(form.HiddenValue, 'generic');
			}

			o.render = L.bind(function(data){
				return (
					E('div', {}, [
						E('h3', { 'class': 'data-tab' }),
							E('div', { 'class': 'cbi-section', 'data-title': 'modem'+i }, [
							E('table', { 'class': 'table' }, [
								E('tr', { 'class': 'tr cbi-rowstyle-2' }, [
									E('td', { 'class': 'td left', 'width': '50%' }, [ _('Operator')]),
									E('td', { 'class': 'td left', 'id': status }, [ '--' ]),
								]),
								E('tr', { 'class': 'tr cbi-rowstyle-1' }, [
									E('td', { 'class': 'td left', 'width': '50%', 'id': namebnd }, [ _('Network/band')]),
									E('td', { 'class': 'td left', 'id': mode }, [ '--' ]),
								]),
								E('tr', { 'class': 'tr cbi-rowstyle-2' }, [
									E('td', { 'class': 'td left', 'width': '50%', 'id': chname }, [ _('E/U/ARFCN')]),
									E('td', { 'class': 'td left', 'id': arfcn }, [ '--' ]),
								]),
								E('tr', { 'class': 'tr cbi-rowstyle-1' }, [
									E('td', { 'class': 'td left', 'width': '50%', 'id': namecid }, [ _('LAC/CID')]),
									E('td', { 'class': 'td left', 'id': lac }, [ '--' ]),
								]),
								E('tr', { 'class': 'tr cbi-rowstyle-2' }, [
									E('td', { 'class': 'td left', 'width': '50%' }, [ _('RSSI')]),
									E('td', { 'class': 'td left'}, E('div', {'id': rssi, 'class': 'cbi-progressbar', 'title': '--' }, E('div'))),
								]),
								E('tr', { 'class': 'tr cbi-rowstyle-1' }, [
									E('td', { 'class': 'td left', 'width': '50%', 'id': snrname }, [ _('SINR/EcIO')]),
									E('td', { 'class': 'td left'}, E('div', {'id': sinr, 'class': 'cbi-progressbar', 'title': '--'}, E('div'))),
								]),
								E('tr', { 'class': 'tr cbi-rowstyle-2' }, [
									E('td', { 'class': 'td left', 'width': '50%' }, [ _('RSRP')]),
									E('td', { 'class': 'td left'}, E('div', {'id': rsrp, 'class': 'cbi-progressbar', 'title': '--'}, E('div'))),
								]),
								E('tr', { 'class': 'tr cbi-rowstyle-1' }, [
									E('td', { 'class': 'td left', 'width': '50%' }, [ _('RSRQ')]),
									E('td', { 'class': 'td left'}, E('div', {'id': rsrq, 'class': 'cbi-progressbar', 'title': '--'}, E('div'))),
								])
							])
						])
					])
				)
			}, this.polldata);
			o.anonymous = true;
			o.rmempty = true;
		};
		s.anonymous = true;
		return m.render();

	},
	handleSaveApply: null,
	handleSave: null,
	handleReset: null
});
