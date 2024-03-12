'use strict';
'require form';
'require fs';
'require view';
'require uci';
'require ui';
'require tools.widgets as widgets'

/*
	Copyright 2022-2023 Rafał Wabik - IceG - From eko.one.pl forum
	Modified for smstools3 by Konstantine Shevlakov <shevlakov@132lan.ru> 2024
	Licensed to the GNU General Public License v3.0.
*/


var cmddesc = _("Each line must have the following format: 'Description;Phone Number'. For user convenience, the file is saved to the location <code>/etc/smstools3.pb</code>."); 

return view.extend({

	render: function() {
		var m, s, o;
		m = new form.Map('smstools3', _('Smstools3: Phonebook'));

		s = m.section(form.TypedSection, 'sms', '', _(''));
		s.anonymous = true;

		o = s.option(form.TextValue, '_tmpl', _('Phonebook'), cmddesc);
		o.rows = 20;
		o.cfgvalue = function(section_id) {
			return fs.trimmed('/etc/smstools3.pb');
		};
		o.write = function(section_id, formvalue) {
			return fs.write('/etc/smstools3.pb', formvalue.trim().replace(/\r\n/g, '\n') + '\n');
		};

		return m.render();
	},
	handleSaveApply: null,
	handleReset: null
});

