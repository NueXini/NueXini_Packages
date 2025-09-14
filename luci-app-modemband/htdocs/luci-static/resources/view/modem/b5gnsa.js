'use strict';
'require form';
'require fs';
'require view';
'require ui';
'require uci';
'require poll';
'require dom';
'require tools.widgets as widgets';

/*
    Copyright 2022-2025 Rafał Wabik - IceG - From eko.one.pl forum
*/

let CBISelectswitch = form.DummyValue.extend({
    renderWidget: function (section_id, option_id, cfgvalue) {
        let section = this.section;
        return E([], [
            E('span', { 'class': 'control-group' }, [
                E('button', {
                    'class': 'cbi-button cbi-button-apply',
                    'click': ui.createHandlerFn(this, function () {
                        let dropdown = section.getUIElement(section_id, 'set_5gnsabands');
                        dropdown && dropdown.setValue([]);
                    }),
                }, _('Deselect all')),
                ' ',
                E('button', {
                    'class': 'cbi-button cbi-button-action important',
                    'click': ui.createHandlerFn(this, function () {
                        let dropdown = section.getUIElement(section_id, 'set_5gnsabands');
                        if (!dropdown) return;
                        dropdown.setValue(Object.keys(dropdown.choices || {}));
                    })
                }, _('Select all'))
            ])
        ]);
    },
});

let BANDmagic = form.DummyValue.extend({
    load: function () {
        let restoreButton = E('button', {
            'class': 'btn cbi-button cbi-button-reset',
            'click': ui.createHandlerFn(this, function () {
                return handleAction('resetbandz');
            }),
        }, _('Restore'));

        return L.resolveDefault(fs.exec_direct('/usr/bin/modemband.sh'), 'null')
            .then(L.bind(function (html) {
                if (html == null) {
                    this.default = E('em', {}, [_('The modemband error.')]);
                }
                else {
                    this.default = E([
                        E('div', { 'class': 'cbi-value' }, [
                            E('label', { 'class': 'cbi-value-title' }, _('Restore default bands')),
                            E('div', { 'class': 'cbi-value-field', 'style': 'width:25vw' },
                                E('div', { 'class': 'cbi-section-node' }, [
                                    restoreButton,
                                ]),
                            ),
                        ]),
                    ]);
                }
            }, this));
    }
});

let cbiRichListValue = form.ListValue.extend({
    renderWidget: function (section_id, option_index, cfgvalue) {
        let choices = this.transformChoices();
        let widget = new ui.Dropdown(
            (cfgvalue != null) ? cfgvalue : this.default,
            choices,
            {
                id: this.cbid(section_id),
                sort: this.keylist,
                optional: true,
                multiple: true,
                display_items: 5,
                dropdown_items: 10,
                select_placeholder: this.select_placeholder || this.placeholder,
                custom_placeholder: this.custom_placeholder || this.placeholder,
                validate: L.bind(this.validate, this, section_id),
                disabled: (this.readonly != null) ? this.readonly : this.map.readonly
            }
        );

        if (this.option === 'set_5gnsabands')
            window.__set5gnsaBandsDropdown = widget;

        return widget.render();
    },

    value: function (value, title, description) {
        if (description) {
            form.ListValue.prototype.value.call(this, value,
                E([], [
                    E('span', { 'class': 'hide-open' }, [title]),
                    E('div', { 'class': 'hide-close', 'style': 'min-width:25vw' }, [
                        E('strong', [title]),
                        E('br'),
                        E('span', { 'style': 'white-space:normal' }, description)
                    ])
                ])
            );
        }
        else {
            form.ListValue.prototype.value.call(this, value, title);
        }
    }
});

function pop(a, message, severity) {
    ui.addNotification(a, message, severity);
}

function popTimeout(a, message, timeout, severity) {
    ui.addTimeLimitedNotification(a, message, timeout, severity);
}

function handleAction(ev) {
    if (ev === 'reload') {
        location.reload();
    }
    if (ev === 'resetbandz') {
        if (confirm(_('Do you really want to set up all possible 5G NSA bands for the modem?'))) {
            fs.exec_direct('/usr/bin/modemband.sh', ['setbands5gnsa', 'default']);
            popTimeout(null, E('p', _('The new bands settings have been sent to the modem. If the changes are not visible, a restart of the connection, modem or router may be required.')), 5000, 'info');
        }
    }
}

function updateTileColorsFromEnabled5gnsa(enabledArray) {
    try {
        let enabledNs = new Set(
            (enabledArray || [])
                .map(function (v) {
                    let m = v.toString().match(/\d+$/);
                    return m ? ('n' + m[0]) : null;
                })
                .filter(Boolean)
        );

        let grid = document.getElementById('bands-grid');
        if (!grid) return;

        grid.querySelectorAll('[data-band]').forEach(function (node) {
            let key = node.getAttribute('data-band');
            let isOn = enabledNs.has(key);
            node.style.backgroundColor = isOn ? '#34c759' : '#7f8c8d';
            node.style.color = '#ffffff';
        });
    } catch (e) {}
}

function isValid5gData(json) {
    return json && 
           json.supported5gnsa && 
           Array.isArray(json.supported5gnsa) && 
           json.supported5gnsa.length > 0 &&
           json.enabled5gnsa && 
           Array.isArray(json.enabled5gnsa);
}

let pollId;

return view.extend({
    formdata: { modemband: {} },

    load: function () {
        return L.resolveDefault(fs.exec_direct('/usr/bin/modemband.sh', ['json']));
    },

    render: function (data) {
        let json = null;

        if (data != null) {
            try {
                json = JSON.parse(data);
            } catch (err) {
                return E('div', {}, _('5G bands cannot be read. Check if your modem supports this technology and if it is in the list of supported modems.'));
            }
        }

        if (!isValid5gData(json)) {
            return E('div', {}, _('5G bands cannot be read. Check if your modem supports this technology and if it is in the list of supported modems.'));
        }

        let m, s, o;

        let info = _('Configuration modem frequency bands. More information about the modemband application on the %seko.one.pl forum%s.')
            .format('<a href="https://eko.one.pl/?p=openwrt-modemband" target="_blank">', '</a>');

        m = new form.JSONMap(this.formdata, _('5G NSA Bands Configuration'), info);

        s = m.section(form.TypedSection, 'modemband', '', _(''));
        s.anonymous = true;
        s.render = L.bind(function (view, section_id) {
            const TILE_W = 50, TILE_H = 25, RADIUS = 4;
            let textShadow = '0 1px 2px rgba(0,0,0,.4),0 2px 6px rgba(0,0,0,.25)';

            let modemContainer = E('div', {
                'class': 'ifacebox',
                'style': 'margin:.25em;width:100%;text-align:center;'
            }, [
                E('div', {
                    'id': 'modem-title',
                    'class': 'ifacebox-head',
                    'style': 'font-weight:bold;background:#f8f8f8;padding:8px'
                }, [json.modem || '-']),
            ]);

            let blockWrap = E('div', { 'style': 'margin-inline:20px;' });

            let container = E('div', {
                'id': 'bands-grid',
                'style':
                    'display:grid;' +
                    'grid-template-columns:repeat(auto-fill, ' + TILE_W + 'px);' +
                    'grid-auto-rows:' + TILE_H + 'px;' +
                    'justify-content:flex-start;' +
                    'gap:6px;' +
                    'margin-top:10px;padding:10px;margin-bottom:10px;'
            });

            (json.supported5gnsa || []).forEach(function (supported) {
                let band = supported.band.toString();
                let numb = band.match(/\d+$/);
                let bandName = 'n' + (numb ? numb[0] : band);
                let isEnabled = (json.enabled5gnsa || []).includes(supported.band);
                let color = isEnabled ? '#34c759' : '#7f8c8d';
                let textColor = '#ffffff';

                let bandDiv = E('div', {
                    'data-band': bandName,
                    'style':
                        'background-color:' + color + ';' +
                        'color:' + textColor + ';' +
                        'width:' + TILE_W + 'px;min-width:' + TILE_W + 'px;max-width:' + TILE_W + 'px;' +
                        'height:' + TILE_H + 'px;min-height:' + TILE_H + 'px;max-height:' + TILE_H + 'px;' +
                        'border-radius:' + RADIUS + 'px;' +
                        'font-weight:600;text-align:center;' +
                        'display:flex;align-items:center;justify-content:center;' +
                        'text-shadow:' + textShadow + ';' +
                        'user-select:none;'
                }, [bandName]);

                container.appendChild(bandDiv);
            });

            const legendItems = [
                { color: '#34c759', label: _('Currently set 5G NSA bands') },
                { color: '#7f8c8d', label: _('Supported 5G NSA bands') }
            ];

            let legend = E('div', {
                'style': 'display:flex;flex-direction:column;align-items:flex-start;' +
                    'gap:8px;margin-left:12px;margin-top:10px;margin-bottom:14px;'
            }, legendItems.map(function (item) {
                return E('div', { 'style': 'display:flex;align-items:center;gap:10px;' }, [
                    E('div', {
                        'style':
                            'background-color:' + item.color + ';' +
                            'width:' + TILE_W + 'px;min-width:' + TILE_W + 'px;max-width:' + TILE_W + 'px;' +
                            'height:' + TILE_H + 'px;min-height:' + TILE_H + 'px;max-height:' + TILE_H + 'px;' +
                            'border-radius:' + RADIUS + 'px;'
                    }),
                    E('label', {}, item.label)
                ]);
            }));

            blockWrap.appendChild(container);
            blockWrap.appendChild(legend);
            modemContainer.appendChild(blockWrap);
            return modemContainer;
        }, o, this);

        s = m.section(form.TypedSection, 'modemband', _(''));
        s.anonymous = true;
        s.addremove = false;

        s.tab('bandset', _('Preferred bands settings'));

        let bandList = s.taboption('bandset', cbiRichListValue, 'set_5gnsabands',
            _('Modification of the bands'),
            _("Select the preferred band(s) for the modem.")
        );

        (json.supported5gnsa || []).forEach(function (band) {
            bandList.value(band.band, _('n') + band.band, band.txt);
        });

        bandList.multiple = true;
        bandList.placeholder = _('Please select a band(s)');
        bandList.cfgvalue = function (section_id) {
            return L.toArray((json.enabled5gnsa || []).join(' '));
        };

        s.taboption('bandset', CBISelectswitch, '_switch', _('Band selection switch'));

        let bfresh = s.taboption('bandset', form.Button, '_refreshbands');
        bfresh.title = _('Bands configuration');
        bfresh.inputtitle = _('Refresh');
        bfresh.onclick = function () { location.reload(); };

        let s2 = m.section(form.TypedSection);
        s2.anonymous = true;
        s2.option(BANDmagic);

        pollId = poll.add(function () {
            return L.resolveDefault(fs.exec_direct('/usr/bin/modemband.sh', ['json'])).then(function (res) {
                try {
                    let data = JSON.parse(res || '{}');
                    let head = document.getElementById('modem-title');
                    if (head) head.textContent = (data.modem || '-');
                    updateTileColorsFromEnabled5gnsa(data.enabled5gnsa || []);
                } catch (e) {}
            });
        });

        return m.render();
    },

    handleBANDZSETup: function (ev) {
        poll.stop();

        let map = document.querySelector('#maincontent .cbi-map'),
            data = this.formdata;

        return dom.callClassMethod(map, 'save')
            .then(function () {
                let args = [];
                args.push(data.modemband.set_5gnsabands);

                let ax = args.toString().replace(/,/g, ' ').trim();

                try {
                    if (window.__set5gnsaBandsDropdown && typeof window.__set5gnsaBandsDropdown.setValue === 'function') {
                        let picked = ax.length ? ax.split(/\s+/) : [];
                        window.__set5gnsaBandsDropdown.setValue(picked);
                    }
                } catch (e) {}

                if (ax.length >= 1) {
                    fs.exec_direct('/usr/bin/modemband.sh', ['setbands5gnsa', ax]);
                    popTimeout(null, E('p', _('The new bands settings have been sent to the modem. If the changes are not visible, a restart of the connection, modem or router may be required.')), 5000, 'info');
                    
                    return uci.load('modemband').then(function() {
                        try {
                            var wrestart = (uci.get('modemband', '@modemband[0]', 'wanrestart'));
                            var mrestart = (uci.get('modemband', '@modemband[0]', 'modemrestart'));
                            var cmdrestart = (uci.get('modemband', '@modemband[0]', 'restartcmd'));
                            var wname = (uci.get('modemband', '@modemband[0]', 'iface'));
                            var sport = (uci.get('modemband', '@modemband[0]', 'set_port'));
                            
                            if (wrestart == '1') {
                                fs.exec('/sbin/ifdown', [ wname ]);
                                fs.exec('sleep 3');
                                fs.exec('/sbin/ifup', [ wname ]);
                            }

                            if (mrestart == '1') {
                                fs.exec('sleep 20');
                                fs.exec_direct('/usr/bin/sms_tool', [ '-d' , sport , 'at' , cmdrestart ]);
                            }
                        } catch (e) {}
                    });

                } else {
                    ui.addNotification(null, E('p', _('Check if you have selected the bands correctly.')), 'info');
                }

                return L.resolveDefault(fs.exec_direct('/usr/bin/modemband.sh', ['json'])).then(function (res) {
                    try {
                        let fresh = JSON.parse(res || '{}');
                        let head = document.getElementById('modem-title');
                        if (head) head.textContent = (fresh.modem || '-');
                        updateTileColorsFromEnabled5gnsa(fresh.enabled5gnsa || []);

                        if (window.__set5gnsaBandsDropdown) {
                            let current = (fresh.enabled5gnsa || []).map(String);
                            window.__set5gnsaBandsDropdown.setValue(current);
                        }
                    } catch (e) {}
                });
            })
            .finally(function () {
                poll.start();
            });
    },

    addFooter: function () {
        return E('div', { 'class': 'cbi-page-actions' }, [
            E('button', { 'class': 'cbi-button cbi-button-save', 'click': L.ui.createHandlerFn(this, 'handleBANDZSETup') },
                [_('Apply changes')])
        ]);
    }
});
