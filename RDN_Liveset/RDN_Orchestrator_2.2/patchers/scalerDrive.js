var deviceParams = [];

function bang()
{
	initDeviceParams();
}

function initDeviceParams() {
    deviceParams = [];
    for (var i = 0; i <= 20; i++) {
        var trackPath = 'live_set tracks ' + i;
        var track = new LiveAPI(trackPath);

        var trackDevices = [];
        var numDevices = track.get('devices').length;

        for (var j = 2; j < Math.min(6, numDevices); j++) {
            var devicePath = trackPath + ' devices ' + j + ' parameters 0';
            var param = new LiveAPI(devicePath);
            trackDevices.push(param);
        }

        deviceParams.push(trackDevices);
    }
}

function toggleDevices(val) {
    deviceParams.forEach(function(trackDevices) {
        trackDevices.forEach(function(param, index) {
            param.set('value', index < val ? 1 : 0);
        });
    });
}

function msg_int(val) {
    val = Math.max(2, Math.min(val, 6));
    toggleDevices(val);
}
