'use strict';
'require view';
'require dom';
'require poll';
'require uci';
'require rpc';
'require form';

function ip_range_validate(range)
{
	var dot = range.replace('-', '.');
	var d = dot.split('.');
	return (((((((+d[0])*256)+(+d[1]))*256)+(+d[2]))*256)+(+d[3])) <= (((((((+d[4])*256)+(+d[5]))*256)+(+d[6]))*256)+(+d[7]));
}
function nets_validate(nets)
{
	var re_ip = /^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
	var re_ip_cidr = /^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\/([0-9]|1[0-9]|2[0-9]|3[012])$/
	var re_ip_range = /^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)-(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
	var net = nets.split(',');
	for (i = 0; i < net.length; i++) {
		if (net[i].match(re_ip)) continue;
		if (net[i].match(re_ip_cidr)) continue;
		if (net[i].match(re_ip_range) && ip_range_validate(net[i])) continue;
		return false;
	}
	return true
}

return view.extend({
	load: function() {
		return Promise.all([
			uci.changes(),
			uci.load('pptpxwan')
		]);
	},

	render: function(data) {

		var m, s, o;

		m = new form.Map('pptpxwan', [_('PPTP XWAN Setup')]);

		s = m.section(form.NamedSection, 'pptp', 'globals', _('PPTP OPTIONS'));
		s.addremove = false;

		o = s.option(form.DynamicList, 'track_ip', _('Tracking hostname or IP address'));
		o.datatype = 'ip4addr';
		o.cast = 'string';

		o = s.option(form.Flag, 'mppe', _("MPPE enabled"));
		o.default = o.disabled;

		o = s.option(form.Value, 'mtu', _('Override MTU'));
		o.datatype = 'max(9200)';
		o.placeholder = '1450';

		o = s.option(form.Value, 'delay_reload', _('Delay Reload Time'), _('Start interface one by one with delay time (in seconds)'));
		o.datatype = 'max(300)';
		o.placeholder = '0';

		o = s.option(form.Flag, 'enable', _("Enabled"));
		o.default = o.disabled;

		s = m.section(form.GridSection, 'line', 'PPTP XWAN LINE');
		s.addremove = true;
		s.anonymous = true;
		s.nodescriptions = true;
		s.sortable = true;

		o = s.option(form.Value, 'src_net', _('src network'), _('May be entered as a single or multiple ipaddr(s)(/cidr) or iprange, split with comma (eg "192.168.100.0/24,1.2.3.4,172.16.0.100-172.16.0.111") without quotes'));
		o.rmempty = false;
		o.placeholder = '172.16.0.11-172.16.0.22'
		o.validate = function(section_id, value) {
			return nets_validate(value);
		}

		o = s.option(form.Value, 'dst_net', _('dst network'), _('May be entered as a single or multiple ipaddr(s)(/cidr) or iprange, split with comma (eg "192.168.100.0/24,1.2.3.4,172.16.0.100-172.16.0.111") without quotes'));
		o.rmempty = true;
		o.placeholder = '172.16.0.11-172.16.0.22'
		o.validate = function(section_id, value) {
			if (value && value != '')
				return nets_validate(value);
			return true;
		}

		o = s.option(form.Value, 'username', _('PPTP Username'));
		o.rmempty = false;

		o = s.option(form.Value, 'password', _('PPTP Password'));
		o.rmempty = false;
		o.password = true;

		o = s.option(form.Value, 'pptp_server', _('PPTP Server'), _('Domain name or ip address'));
		o.rmempty = false;

		return m.render();
	}
});
