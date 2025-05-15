inlets = 1;
outlets = 3; // 0 = pitch, 1 = velocity, 2 = status message

var n = 3; // ON
var m = 2; // OFF
var noteCount = 0; // Position dans le motif n+m

var activeNotes = {}; // pitch -> true/false

function list(pitch, velocity) {
    if (velocity > 0) {
        // NOTE ON
        var pos = noteCount % (n + m);
        var allow = (pos < n); // Dans la zone ON

        if (allow) {
            activeNotes[pitch] = true;
            outlet(0, pitch);
            outlet(1, velocity);
        } else {
            activeNotes[pitch] = false;
        }

        outlet(2, "NoteOn " + pitch + ": " + (allow ? "PASS" : "BLOCK") + " (" + (pos+1) + "/" + (n + m) + ")");
        noteCount++;

    } else {
        // NOTE OFF
        if (activeNotes[pitch]) {
            outlet(0, pitch);
            outlet(1, velocity);
        }
        activeNotes[pitch] = false;
    }
}

function set(a, b) {
    n = Math.max(1, a);
    m = Math.max(0, b);
    noteCount = 0;
    activeNotes = {};
    outlet(2, "Set pattern: " + n + " ON / " + m + " OFF");
}

function reset() {
    noteCount = 0;
    outlet(2, "Cycle reset");
}
