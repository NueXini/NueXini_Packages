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
			uci.load('proxyxwan')
		]);
	},

	render: function(data) {

		var m, s, o;

		m = new form.Map('proxyxwan', [_('PROXY XWAN Setup')]);

		s = m.section(form.NamedSection, 'proxy', 'globals', _('PROXY OPTIONS'));
		s.addremove = false;

		o = s.option(form.Flag, 'enable', _("Enabled"));
		o.default = o.disabled;

		s = m.section(form.GridSection, 'line', 'PROXY XWAN LINE');
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

		o = s.option(form.Value, 'username', _('Username'));
		o.rmempty = true;

		o = s.option(form.Value, 'password', _('Password'));
		o.rmempty = true;
		o.password = true;

		o = s.option(form.Value, 'server', _('Server'), _('Domain name or ip address'));
		o.rmempty = false;

		o = s.option(form.Value, 'port', _('Port'), _('Port'));
		o.rmempty = false;
		o.datatype = 'port';
		o.placeholder = 1080;

		o = s.option(form.ListValue, 'type', _('Type'), _('Type'));
		o.rmempty = false;
		o.value('socks5');
		o.value('socks4');
		o.value('http-connect');
		o.value('http-relay');

		return m.render();
	}
});
