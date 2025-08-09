'use strict';                                                                                              
'require baseclass';
'require form';
'require fs';
'require ui';
'require uci';

/*
	Written by Konstantine Shevlakov at <shevlakov@132lan.ru> 2023

	Licensed to the GNU General Public License v3.0.

	Special Thanks to Vladislav Kadulin aka @Kodo-kakaku
	https://github.com/Kodo-kakaku/ to fix update overview page

*/

return baseclass.extend({
	title: _('Cellular network'),
	
	load: async function() {
		uci.load('modeminfo');
		return L.resolveDefault(fs.exec_direct('/usr/bin/modeminfo'));
	},
	
	render: function(data){
		var json = JSON.parse(data);
		var index = uci.sections('modeminfo', 'general');
		let modemTBL = E('div', { 'class': 'cbi-section' });
		
		if (json.modem && index[0].index == "1"){
			for (var i = 0; i < json.modem.length; i++) {
				var signal = document.createElement('div');
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

				var per = p+'%';
				
				var ca;
				if (json.modem[i].lteca > 0) {
					ca = "+";
				} else {
					ca = "";
				}
			
				signal.innerHTML = String.format(
					'<span class="ifacebadge">' + json.modem[i].cops  + " " +  
					'<img src="%s"/><b>'+per.fontcolor(json.modem[i].csq_col) + "</b> " + 
					json.modem[i].mode+ca + '</span>', icon, p );
			
				modemTBL.append( 
					E('table', { 'class': 'table' }, [
						E('tr', { 'class': 'tr' }, [
							E('td', { 'class': 'td left', 'width': '33%' }, [ json.modem[i].device ]),
							E('td', { 'class': 'td left', 'id': 'device' }, [ signal ])
						])
					])
				);
			};
			return modemTBL;
		};
	},
});
