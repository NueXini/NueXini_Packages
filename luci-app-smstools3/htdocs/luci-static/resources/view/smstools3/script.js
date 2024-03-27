'use strict';
'require form';
'require fs';
'require view';
'require uci';
'require ui';
'require tools.widgets as widgets'


return view.extend({
	load: function(){
		uci.load('smstools3');
	},

	render: function(data) {
		var desc_head = _('Edit smstools3 user script. Add user\'s actions for incoming and outcoming messages.<br />Is shell script for smstools3 scenario. See \<a href\=\"http://smstools3.kekekasvi.com/index.php?p=eventhandler\"\>smstools3 manual page\</a\> for more details.');
		var config = uci.sections('smstools3');
		var m, s, o;

		m = new form.Map('smstools3', _('Smtools3: User Script'), desc_head);

		s = m.section(form.TypedSection, 'sms', null);
		s.anonymous = true;

		o = s.option(form.TextValue, '_tmpl', _('Edit User script smstools3.<br />File stored in <code>/etc/smstools3.user</code>'));
		o.rows = 20;
		o.cfgvalue = function(section_id) {
			return fs.trimmed('/etc/smstools3.user');
		};
		o.write = function(section_id, formvalue) {
			return fs.write(('/etc/smstools3.user'), formvalue.trim().replace(/\r\n/g, '\n') + '\n');
		};

		return m.render();
	},
	handleSaveApply: null,	
	handleReset:  null
});
