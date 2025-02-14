'use strict';
'require form';
'require fs';
'require ui';
'require uci';
'require view';
'require poll';
'require dom';

return view.extend({

	render: function(modems) {
		var m, s, o

		m = new form.Map('ssw', _('SSW - SIM Card switch'))

		s = m.section(form.TypedSection, 'modem');
		o = s.option(form.ListValue, 'value', _('State'));
		o.value(1, _('Enable'));
		o.value(0, _('Disable'));

		s = m.section(form.TypedSection, 'sim');
		o = s.option(form.ListValue, 'value', _('Default SIM Slot'));
		o.value(1, _('SLOT 1'));
		o.value(0, _('SLOT 2'));

		s = m.section(form.TypedSection, 'failover');
		o = s.option(form.Flag, 'enable', _('Enable'));

		o = s.option(form.Flag, 'revert', _('Revert'),
			_('Revert to default sim slot. Each failed attempt doubles revert time.'));
		o.depends({enable: '1'});

		o = s.option(form.ListValue, 'rsrp', _('RSRP value'),
			_('Switch sim lower by value.'));
		for (var rsrp = -120; rsrp <= -80; rsrp++) {
			o.value(rsrp, rsrp +' '+ _('dBm'));
		};
		o.depends({enable: '1'});

		o = s.option(form.Value, 'interval',
			_('Interval check. sec'));
		for (var sec = 5; sec <= 60; sec+=5) {
			o.value(sec,sec +' '+  _('sec'));
		};
		o.depends({enable: '1'});

		o = s.option(form.Value, 'times_rsrp', _('Probes'),
			_('RSRP check average values.<br />NOTE: all time check is <code>Interval*Probes</code><br />Example: <code>Interval=60</code> sec, <code>Probes=5</code> times, all time check <code>300</code> sec.'));
		for (var p = 5; p <=10; p++) {
			o.value(p,p);
		};
		o.depends({enable: '1'});

		return m.render();
	}
});
