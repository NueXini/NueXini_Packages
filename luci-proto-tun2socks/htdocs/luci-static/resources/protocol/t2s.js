'use strict';
'require rpc';
'require form';
'require network';
'require validation';

network.registerPatternVirtual(/^t2s-.+$/);

return network.registerProtocol('t2s', {
	getI18n: function() {
		return _('tun2socks');
	},

	getIfname: function() {
		return this._ubus('l3_device') || 't2s-%s'.format(this.sid);
	},

	getOpkgPackage: function() {
		return 'tun2socks';
	},

	isFloating: function() {
		return true;
	},

	isVirtual: function() {
		return true;
	},

	getDevices: function() {
		return null;
	},

	containsDevice: function(ifname) {
		return (network.getIfnameOf(ifname) == this.getIfname());
	},

	renderFormOptions: function(s) {
		var dev = this.getL3Device() || this.getDevice(), o;


                o = s.taboption('general', form.ListValue, 'proxy', _('Proxy Type'));
		o.value('http', 'HTTP');
                o.value('socks4', 'SOCKS4');
                o.value('socks5', 'SOCKS5');
                o.value('ss', 'Shadowsocks');
                o.value('relay', _('Relay'));
                o.value('direct', _('Direct'));
                o.value('reject', _('Reject'));
		o.default = 'socks5';
                o.rmempty = true;
		
		// TODO
		o = s.taboption('general', form.Flag, 'socket', _('Use Socket'), _('SOCKS5 only!<br />Use Unix Domain Socket instead address'));
		o.rmempty = true;

		o = s.taboption('general', form.Value, 'ipaddr', _('IPv4 Address'));
		o.datatype = 'ip4addr("nomask")';
		o.depends({'proxy': /http|socks4|socks5|relay|ss/ });
		o.rmempty = false;

		o = s.taboption('general', form.Value, 'netmask', _('IPv4 Netmask'));
		o.value('255.255.255.0', '255.255.255.0');
		o.value('255.255.0.0', '255.255.0.0');
		o.depends({'proxy': /http|socks4|socks5|relay|ss/ });
		o.rmempty = false;

		o = s.taboption('general', form.Value, 'gateway', _('IPv4 Gateway'));
		o.datatype = 'ip4addr("nomask")';
		o.depends({'proxy': /http|socks4|socks5|relay|ss/ });
		o.rmempty = false;

		o = s.taboption('general', form.Value, 'host', _('Proxy Address'), _('IP-address or FQDN hostname proxy<br/>Format: <code>host:port</code>'));
		o.datatype = 'or(hostport,ipaddrport)';
		o.depends({'socket': '0', 'proxy': /http|socks4|socks5|relay|ss/ });
		o.rmempty = true;

		o = s.taboption('general', form.Value, 'sockpath', _('Unix Socket'), _('Path to Unix Socket<br/>Format: <code>/path/to/unix.socket</code>'));
		o.depends({'socket': '1' , 'proxy': 'socks5' });

		o = s.taboption('general', form.Flag, 'advanced', _('Autentification'), _('Authentification and encryption.'));
		o.depends({'proxy': /socks4|socks5|relay|ss/ });
		o.rmempty = true;

		o = s.taboption('general', form.Value, 'username', _('Proxy USER'));
		o.depends({'advanced': '1', 'proxy': /socks|relay/});

		o = s.taboption('general', form.ListValue, 'encrypt', _('Encryption'));
		o.value('none','none');
		o.value('table','table');
		o.value('rc4','rc4');
		o.value('rc4-md5','rc4-md5');
		o.value('aes-128-cfb','aes-128-cfb');
		o.value('aes-192-cfb','aes-192-cfb');
		o.value('aes-256-cfb','aes-256-cfb');
		o.value('aes-128-ctr','aes-128-ctr');
		o.value('aes-192-ctr','aes-192-ctr');
		o.value('aes-256-ctr','aes-256-ctr');
		o.value('aes-128-gcm','aes-128-gcm');
		o.value('aes-192-gcm','aes-192-gcm');
		o.value('aes-256-gcm','aes-256-gcm');
		o.value('camellia-128-cfb','camellia-128-cfb');
		o.value('camellia-192-cfb','camellia-192-cfb');
		o.value('camellia-256-cfb','camellia-256-cfb');
		o.value('bf-cfb','bf-cfb');
		o.value('salsa20','salsa20');
		o.value('chacha20','chacha20');
		o.value('chacha20-ietf','chacha20-ietf');
		o.value('chacha20-ietf-poly1305','chacha20-ietf-poly1305');
		o.value('xchacha20-ietf-poly1305','xchacha20-ietf-poly1305');
		o.depends({advanced: '1', proxy: 'ss'});

		o = s.taboption('general', form.Value, 'password', _('Proxy Password'));
		o.password = true;
		o.depends({'advanced': '1', 'proxy': /socks5|relay|ss/ });

		o = s.taboption('general',form.Flag, 'base64enc', _('Encrypt base64'));
		o.depends({'advanced': '1', 'proxy': 'ss' });
		o.rmempty = true;

		o = s.taboption('advanced', form.Value, 'mtu', _('Set MTU'), _('Set device maximum transmission unit'));
		o.placeholder = dev ? (dev.getMTU() || '1500') : '1500';
		o.datatype    = 'max(9200)';
		
		o = s.taboption('advanced', form.ListValue, 'loglevel', _('Logging level'));
		o.value('debug', _('Debug'));
		o.value('info', _('Info'));
		o.value('warning', _('Warning'));
		o.value('error', _('Error'));
		o.value('silent', _('Silent'));
		o.default = 'error';
		
		o = s.taboption('advanced', form.Value, 'opts', _('Advaced options'), _('Command line arguments to tun2socks app'));
		o.rmempty = true;

		o = s.taboption('advanced', form.Flag, 'defaultroute',
			_('Use default gateway'),
			_('If unchecked, no default route is configured'));
		o.default = o.enabled;

		o = s.taboption('advanced', form.Value, 'metric',
			_('Use gateway metric'));
			o.placeholder = '0';
		o.datatype = 'uinteger';
		o.depends('defaultroute', '1');

		o = s.taboption('advanced', form.Flag, 'peerdns',
			_('Use DNS servers advertised by peer'),
			_('If unchecked, the advertised DNS server addresses are ignored'));
		o.default = o.enabled;

	}
});

