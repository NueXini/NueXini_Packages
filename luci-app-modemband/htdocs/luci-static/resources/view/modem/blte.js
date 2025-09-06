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
    renderWidget: function(section_id, option_id, cfgvalue) {
        let section = this.section;
        return E([], [
            E('span', { 'class': 'control-group' }, [
                E('button', {
                    'class': 'cbi-button cbi-button-apply',
                    'click': ui.createHandlerFn(this, function() {
                        let dropdown = section.getUIElement(section_id, 'set_bands');
                        dropdown && dropdown.setValue([]);
                    }),
                }, _('Deselect all')),
                ' ',
                E('button', {
                    'class': 'cbi-button cbi-button-action important',
                    'click': ui.createHandlerFn(this, function() {
                        let dropdown = section.getUIElement(section_id, 'set_bands');
                        if (!dropdown) return;
                        let all = Object.keys(dropdown.choices || {});
                        dropdown.setValue(all);
                    })
                }, _('Select all'))
            ])
        ]);
    },
});

let BANDmagic = form.DummyValue.extend({
    load: function() {
        let restoreButton = E('button', {
            'class': 'btn cbi-button cbi-button-reset',
            'click': ui.createHandlerFn(this, function() {
                return handleAction('resetbandz');
            }),
        }, _('Restore'));

        return L.resolveDefault(fs.exec_direct('/usr/bin/modemband.sh'), 'null')
            .then(L.bind(function(html) {
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
    renderWidget: function(section_id, option_index, cfgvalue) {
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

        if (this.option === 'set_bands')
            window.__setBandsDropdown = widget;

        return widget.render();
    },

    value: function(value, title, description) {
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
    ui.addNotification(a, message, severity)
}

function popTimeout(a, message, timeout, severity) {
    ui.addTimeLimitedNotification(a, message, timeout, severity)
}

function handleAction(ev) {
    if (ev === 'reload') {
        location.reload();
    }
    if (ev === 'resetbandz') {
        if (confirm(_('Do you really want to set up all possible bands for the modem?'))) {
            fs.exec_direct('/usr/bin/modemband.sh', ['setbands', 'default']);
            popTimeout(null, E('p', _('The new bands settings have been sent to the modem. If the changes are not visible, a restart of the connection, modem or router may be required.')), 5000, 'info');
        }
    }
}

function updateTileColorsFromEnabled(enabledArray) {
    try {
        let enabledNums = new Set((enabledArray || []).map(function(v) {
            return parseInt(v, 10);
        }));

        let grid = document.getElementById('bands-grid');
        if (!grid) return;

        grid.querySelectorAll('[data-band]').forEach(function(node) {
            let key = node.getAttribute('data-band');
            let m = key ? key.match(/\d+$/) : null;
            let num = m ? parseInt(m[0], 10) : null;
            let isOn = (num != null) && enabledNums.has(num);
            node.style.backgroundColor = isOn ? '#34c759' : '#7f8c8d';
            node.style.color = '#ffffff';
        });
    } catch (e) {
        console.log('updateTileColorsFromEnabled error:', e);
    }
}

let pollId;

return view.extend({
    formdata: { modemband: {} },

    load: function() {
        return L.resolveDefault(fs.exec_direct('/usr/bin/modemband.sh', ['json']));
    },

    render: function(data) {
        let m, s, o;
        let json = null;

        if (data != null) {
            try {
                json = JSON.parse(data);
            } catch (err) {
                console.log('Error: ', err.message);
            }
        }

        let info = _('Configuration modem frequency bands. More information about the modemband application on the %seko.one.pl forum%s.')
            .format('<a href="https://eko.one.pl/?p=openwrt-modemband" target="_blank">', '</a>');

        m = new form.JSONMap(this.formdata, _('LTE Bands Configuration'), info);

        s = m.section(form.TypedSection, 'modemband', '', _(''));
        s.anonymous = true;
        s.render = L.bind(function(view, section_id) {
            if (json && json.enabled && json.supported) {
                const TILE_W = 50;
                const TILE_H = 25;
                const RADIUS = 4;

                let modemContainer = E('div', { 'class': 'ifacebox', 'style': 'margin:.25em;width:100%;text-align:center;' }, [
                    E('div', { 'id': 'modem-title', 'class': 'ifacebox-head', 'style': 'font-weight:bold;background:#f8f8f8;padding:8px' }, [
                        json.modem || '-'
                    ]),
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

                let textShadow = '0 1px 2px rgba(0,0,0,.4),0 2px 6px rgba(0,0,0,.25)';

                json.supported.forEach(function(supportedBand) {
                    let band = supportedBand.band.toString();
                    let numb = band.match(/\d+$/);
                    let bandName = 'B' + numb;
                    let isEnabled = json.enabled.includes(supportedBand.band);
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
                    { color: '#34c759', label: _('Currently set LTE bands') },
                    { color: '#7f8c8d', label: _('Supported LTE bands') }
                ];

                let legend = E('div', {
                    'style': 'display:flex;flex-direction:column;align-items:flex-start;' +
                             'gap:8px;margin-left:12px;margin-top:10px;margin-bottom:14px;'
                }, legendItems.map(function(item) {
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
            }
            else {
                return E('div', {}, _('LTE bands cannot be read. Check if your modem supports this technology and if it is in the list of supported modems.'));
            }
        }, o, this);

        s = m.section(form.TypedSection, 'modemband', _(''));
        s.anonymous = true;
        s.addremove = false;

        s.tab('bandset', _('Preferred bands settings'));

        let bandList = s.taboption('bandset', cbiRichListValue, 'set_bands', _('Modification of the bands'),
            _("Select the preferred band(s) for the modem."));

        if (json && json.supported) {
            for (let i = 0; i < json.supported.length; i++) {
                bandList.value(json.supported[i].band, _('B') + json.supported[i].band, json.supported[i].txt);
            }
        }

        bandList.multiple = true;
        bandList.placeholder = _('Please select a band(s)');
        bandList.cfgvalue = function(section_id) {
            if (!json || !json.enabled) return [];
            return L.toArray((json.enabled).join(' '));
        };

        s.taboption('bandset', CBISelectswitch, '_switch', _('Band selection switch'));

        let s2 = m.section(form.TypedSection);
        s2.anonymous = true;
        s2.option(BANDmagic);

        pollId = poll.add(function() {
            return L.resolveDefault(fs.exec_direct('/usr/bin/modemband.sh', ['json'])).then(function(res) {
                try {
                    let data = JSON.parse(res || '{}');
                    let head = document.getElementById('modem-title');
                    if (head) head.textContent = (data.modem || '-');
                    updateTileColorsFromEnabled(data.enabled || []);
                } catch (e) {
                    console.log('poll update error:', e);
                }
            });
        });

        let bfresh = s.taboption('bandset', form.Button, '_refreshbands');
        bfresh.title = _('Bands configuration');
        bfresh.inputtitle = _('Refresh');
        bfresh.onclick = function () {
            location.reload();
        };

        return m.render();
    },

    handleBANDZSETup: function(ev) {
        poll.stop();

        let map = document.querySelector('#maincontent .cbi-map'),
            data = this.formdata;

        return dom.callClassMethod(map, 'save')
            .then(function() {
                let args = [];
                args.push(data.modemband.set_bands);
                let ax = args.toString().replace(/,/g, ' ');

                try {
                    if (window.__setBandsDropdown && typeof window.__setBandsDropdown.setValue === 'function') {
                        window.__setBandsDropdown.setValue(ax.trim().length ? ax.trim().split(/\s+/) : []);
                    }
                } catch (e) {
                    console.log('set dropdown selection error:', e);
                }

                if (ax.length >= 1) {
                    fs.exec_direct('/usr/bin/modemband.sh', ['setbands', ax]);
                    popTimeout(null, E('p', _('The new bands settings have been sent to the modem. If the changes are not visible, a restart of the connection, modem or router may be required.')), 5000, 'info');

                    return uci.load('modemband').then(function() {
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
				            //sms_tool -d $_DEVICE at "cmd"
				            fs.exec_direct('/usr/bin/sms_tool', [ '-d' , sport , 'at' , cmdrestart ]);
				            }
        			});

                } else {
                    ui.addNotification(null, E('p', _('Check if you have selected the bands correctly.')), 'info');
                }

                return L.resolveDefault(fs.exec_direct('/usr/bin/modemband.sh', ['json'])).then(function(res) {
                    try {
                        let fresh = JSON.parse(res || '{}');
                        let head = document.getElementById('modem-title');
                        if (head) head.textContent = (fresh.modem || '-');
                        updateTileColorsFromEnabled(fresh.enabled || []);
                    } catch (e) {
                        console.log('post-save refresh error:', e);
                    }
                });
            })
            .finally(function() {
                poll.start();
            });
    },

    addFooter: function() {
        return E('div', { 'class': 'cbi-page-actions' }, [
            E('button', { 'class': 'cbi-button cbi-button-save', 'click': L.ui.createHandlerFn(this, 'handleBANDZSETup') },
                [_('Apply changes')])
        ]);
    }
});
