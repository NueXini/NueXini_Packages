'use strict';
'require dom';
'require fs';
'require ui';
'require view';

/*
 * OTA Update Application
 */

return view.extend({
    load: function() {
        return Promise.resolve();
    },

    checkInitialState: function() {
        var self = this;
        this.verifyCheckResult().then(function(success) {
            if (success) {
                // If files already exist, disable Check button
                self.checkButton.disabled = true;
                // And show information about available update
                self.statusDiv.innerHTML = '';
                self.statusDiv.appendChild(E('div', { 
                    'class': 'alert-message success'
                }, [
                    E('h3', {}, _('Update Available')),
                    E('pre', { 
                        'style': 'white-space: pre-wrap; background: #f5f5f5; padding: 10px; border-radius: 3px; color: black;' 
                    }, self.changelog || '')
                ]));
                // Activate Upgrade button
                self.upgradeButton.disabled = false;
            }
        }).catch(function(err) {
            // No files, leave Check button active
        });
    },

    render: function() {
        var self = this;

        // Create control elements
        this.checkButton = E('button', {
            'class': 'btn cbi-button cbi-button-positive important',
            'click': ui.createHandlerFn(this, 'handleCheck')
        }, _('Check for Updates'));

        this.upgradeButton = E('button', {
            'class': 'btn cbi-button cbi-button-negative important',
            'disabled': true,
            'click': ui.createHandlerFn(this, 'handleUpgrade')
        }, _('Upgrade'));

        this.statusDiv = E('div', { 'class': 'cbi-section' });
        this.progressBar = E('div', {
            'style': 'display: none; margin: 10px 0;'
        });

        // Main layout
        var container = E('div', { 'class': 'cbi-map' }, [
            E('h2', {}, _('OTA System Update')),
            E('div', { 'class': 'cbi-section' }, [
                this.checkButton,
                ' ',
                this.upgradeButton
            ]),
            this.progressBar,
            this.statusDiv
        ]);

        // Check initial state when page loads
        this.checkInitialState();

        return container;
    },

    handleCheck: function() {
        var self = this;
        
        this.checkButton.disabled = true;
        this.statusDiv.innerHTML = '';
        this.statusDiv.appendChild(E('div', { 
            'class': 'spinner' 
        }, _('Checking for updates...')));

        // Execute update check
        return fs.exec('/usr/share/ota.sh', ['check'])
            .then(function() {
                return self.verifyCheckResult();
            })
            .then(function(success) {
                if (success) {
                    self.upgradeButton.disabled = false;
                    self.statusDiv.innerHTML = '';
                    self.statusDiv.appendChild(E('div', { 
                        'class': 'alert-message success'
                    }, [
                        E('h3', {}, _('Update Available')),
                        E('pre', { 
                            'style': 'white-space: pre-wrap; background: #f5f5f5; padding: 10px; border-radius: 3px; color: black;' 
                        }, self.changelog || '')
                    ]));
                } else {
                    self.statusDiv.innerHTML = '';
                    self.statusDiv.appendChild(E('div', { 
                        'class': 'alert-message warning'
                    }, _('No updates available or check failed')));
                }
                self.checkButton.disabled = false;
            })
            .catch(function(err) {
                self.statusDiv.innerHTML = '';
                self.statusDiv.appendChild(E('div', { 
                    'class': 'alert-message error'
                }, _('Check failed: ') + (err.message || err)));
                self.checkButton.disabled = false;
            });
    },

    verifyCheckResult: function() {
        var self = this;
        
        return Promise.all([
            fs.stat('/tmp/profiles.json').catch(function() { return null; }),
            fs.stat('/tmp/update.lock').catch(function() { return null; }),
            fs.read('/tmp/changelog.txt')
                .then(function(content) {
                    self.changelog = content;
                    return content && content.length > 0;
                })
                .catch(function() { return false; })
        ]).then(function(results) {
            // Check that all files exist and changelog is not empty
            return results[0] !== null && 
                   results[1] !== null && 
                   results[2] === true;
        });
    },

    handleUpgrade: function() {
        var self = this;
        
        this.upgradeButton.disabled = true;
        this.checkButton.disabled = true;
        this.progressBar.style.display = 'block';
        
        // Initialize progress bar once
        this.progressBar.innerHTML = '';
        
        // Create progress bar title
        this.progressTitle = E('div', { 
            'class': 'cbi-progressbar-title' 
        }, _('Starting upgrade...'));
        this.progressBar.appendChild(this.progressTitle);
        
        // Create progress bar container
        this.currentProgressBar = E('div', {
            'class': 'cbi-progressbar',
            'style': 'margin: 10px 0;'
        }, E('div', { 'style': 'width: 0%' }));
        this.progressBar.appendChild(this.currentProgressBar);

        // First start progress simulation
        this.simulateProgressBar();

        // Then start update process
        return fs.exec('/usr/share/ota.sh', ['upgrade'])
            .then(function(result) {
                // Wait for progress simulation to complete to 100%
                return new Promise(function(resolve) {
                    var checkCompletion = function() {
                        if (self.progressInterval) {
                            setTimeout(checkCompletion, 100);
                        } else {
                            resolve(result);
                        }
                    };
                    checkCompletion();
                });
            })
            .then(function(result) {
                // Show final message
                self.progressBar.style.display = 'none';
                self.statusDiv.innerHTML = '';
                self.statusDiv.appendChild(E('div', { 
                    'class': 'alert-message warning'
                }, _('Download completed successfully! Start upgrade.<br />DO NOT POWER OFF THIS DEVICE!<br />System will be upgrade completed after reboot!')));
                
                self.upgradeButton.disabled = false;
                self.checkButton.disabled = false;
            })
            .catch(function(err) {
                // Stop progress simulation on error
                if (self.progressInterval) {
                    clearInterval(self.progressInterval);
                    self.progressInterval = null;
                }
                
                // Check if error is XHR timeout
                var errorMessage = err.message || err.toString();
                if (errorMessage.includes('XHR request timed out')) {
                    // For timeout show success message
                    self.progressBar.style.display = 'none';
                    self.statusDiv.innerHTML = '';
                    self.statusDiv.appendChild(E('div', { 
                        'class': 'alert-message warning'
                    }, _('Download completed successfully! Start upgrade.<br />DO NOT POWER OFF THIS DEVICE!<br />System will be upgrade completed after reboot!')));
                } else {
                    // For other errors show error message
                    self.progressTitle.textContent = _('Upgrade failed: ') + errorMessage;
                    self.progressTitle.className = 'cbi-progressbar-title error';
                }
                
                self.upgradeButton.disabled = false;
                self.checkButton.disabled = false;
            });
    },

    simulateProgressBar: function() {
        var self = this;
        
        if (this.progressInterval) {
            clearInterval(this.progressInterval);
        }
        
        let progress = 0;
        this.progressInterval = setInterval(function() {
            progress += Math.random() * 10 + 5; // Slowed down simulation
            if (progress >= 100) {
                progress = 100;
                clearInterval(self.progressInterval);
                self.progressInterval = null;
                self.updateProgressBar(progress, _('Download completed! Prepare upgrade...'));
            } else {
                self.updateProgressBar(progress, _('Downloading: ') + Math.round(progress) + '%');
            }
        }, 800); // Increased interval
    },

    updateProgressBar: function(percent, text) {
        if (!this.currentProgressBar || !this.progressTitle) return;
        
        // Update only text and progress, without recreating elements
        this.progressTitle.textContent = text;
        
        // Update progress bar as in modem example
        var percentValue = Math.min(100, Math.max(0, percent));
        this.currentProgressBar.firstElementChild.style.width = percentValue + '%';
        
        // Add animation as in example
        this.currentProgressBar.firstElementChild.style.animationDirection = "reverse";
    },

    handleSaveApply: null,
    handleSave: null,
    handleReset: null
});
