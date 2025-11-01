'use strict';
'require form';
'require fs';
'require view';
'require uci';
'require rpc';
'require ui';
'require network';
'require tools.widgets as widgets'

var callLEDs = rpc.declare({
    object: 'luci',
    method: 'getLEDs',
    expect: { '': {} }
});

return view.extend({
    load: function() {
        return Promise.all([
            callLEDs(),
            L.resolveDefault(fs.list('/www' + L.resource('view/system/led-trigger')), []),
            // load config mwan3
            fs.read('/etc/config/mwan3').catch(function(err) { return ''; })
        ]).then(function(data) {
            var plugins = data[1];
            var mwan3Config = data[2];
            var tasks = [];

            // parce ifaces mwan3 config
            var mwan3Interfaces = [];
            if (mwan3Config) {
                var lines = mwan3Config.split('\n');
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim();
                    var match = line.match(/^config interface '([^']+)'/);
                    if (match) {
                        mwan3Interfaces.push(match[1]);
                    }
                }
            }

            for (var i = 0; i < plugins.length; i++) {
                var m = plugins[i].name.match(/^(.+)\.js$/);

                if (plugins[i].type != 'file' || m == null)
                    continue;

                tasks.push(L.require('view.system.led-trigger.' + m[1]).then(L.bind(function(name){
                    return L.resolveDefault(L.require('view.system.led-trigger.' + name)).then(function(form) {
                        return {
                            name: name,
                            form: form,
                        };
                    });
                }, this, m[1])));
            }

            return Promise.all(tasks).then(function(plugins) {
                var value = {};
                value[0] = data[0];
                value[1] = plugins;
                value[2] = mwan3Interfaces; //  add mwan3 iface 
                return value;
            });
        });
    },

    render: function(data) {
        var m, s, o, triggers = [];
        var leds = data[0];
        var mwan3Interfaces = data[2]; // get ifaces from mwan3 config

        for (var k in leds)
            for (var i = 0; i < leds[k].triggers.length; i++)
                triggers[i] = leds[k].triggers[i];

        m = new form.Map('mwan3_led', _('MWAN3 Ledhelper'), _('Flash led on link state.'));
        s = m.section(form.GridSection, 'led', null);
        s.anonymous = false;
        s.addremove = true;

        // filter NetworkSelect
        o = s.option(widgets.NetworkSelect, 'iface', _('Set interface'));
        o.exclude = s.section;
        o.nocreate = true;
        o.optional = true;
        //  filter interfaces
        o.filter = function(section_id, value) {
            return mwan3Interfaces.indexOf(value) !== -1;
        };

        o = s.option(form.ListValue, 'led_on', _('Select LED online'));
        Object.keys(leds).sort().forEach(function(name) {
            o.value(name);
        });
        o.value('', 'Not Use');
        o.default = '';
        o.rmempty = true;

        o = s.option(form.ListValue, 'led_off', _('Select LED offline'));
        Object.keys(leds).sort().forEach(function(name) {
            o.value(name);
        });
	o.value('', 'Not Use');
	o.default = '';
	o.rmempty = true;

        return m.render();
    }
});
