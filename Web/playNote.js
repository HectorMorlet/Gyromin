
// [Title here]
// Hector Morlet and Jason Chu
// 8/7/2015


var HALF_RANGE = 80
var NUM_NOTES = 11


var notes;

createNotes();
playNote(convertAngles(40, 0), 1000);

function createNotes() {
	notes = [];
	for (i = 0; i < NUM_NOTES; i++) {
		notes[i] = new Audio("Notes/" + i.toString() + ".wav");
	}
}

function convertAngles(pitchAngle, volumeAngle) {
	return Math.floor((pitchAngle + HALF_RANGE)/notes.length);
}

function playNote(pitch, duration) {
	notes[pitch % notes.length].play();

	setTimeout(function() {
		notes[pitch % notes.length].pause();
	}, duration);
}
