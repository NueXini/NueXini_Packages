'use strict';
'require view';
'require fs';
'require form';
'require ui';
'require tools.widgets as widgets';

/*
	Copyright 2022 Rafał Wabik - IceG - From eko.one.pl forum
*/

return view.extend({
	load: function() {
		return L.resolveDefault(fs.exec_direct('/usr/bin/loaded.sh', [ 'json' ]));
	},

	render: function(data) {
		var m, s, o;

		var json = JSON.parse(data);

		if (json.modem == '') {
						L.ui.showModal(_('Modemband'), [
						E('p', { 'class': 'spinning' }, _('Waiting to read data from the modem...'))
						]);

						window.setTimeout(function() {
						location.reload();
						//L.hideModal();
						}, 25000).finally();
					}
					else {
					L.hideModal();
					}

		m = new form.Map('modemband', _('Modemband configuration'), _('Settings panel for the modemband application that allows you to customize the package for your modem.'));

		s = m.section(form.TypedSection, 'modemband', '', _(''));
		s.anonymous = true;

		s.tab('general',  _('General Settings'));
		s.tab('template', _('Edit script'), _('modemband / '+json.modem));

		o = s.taboption('template', form.TextValue, '_tmpl', null,
			_('Supported bands depend on the region in which the modem operates. By modifying the DEFAULT_LTE_BANDS variable, you can easily adapt the package to your modem.'));
		o.rows = 10;
		o.cfgvalue = function(section_id) {
			return fs.trimmed('/usr/share/modemband/'+json.modem);
		};
		o.write = function(section_id, formvalue) {
			return fs.write('/usr/share/modemband/'+json.modem, formvalue.trim().replace(/\r\n/g, '\n') + '\n');
		};

		return m.render();
	},

	handleSaveApply: null,
	handleReset: null
});
