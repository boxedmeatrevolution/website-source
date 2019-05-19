// How to load an audio file:
//
//  loadAudio("gameMusic1", "assets/music1.ogg");
//
// When the audio file is loaded, 'audioFilesLoaded' is incremented by 1
//
//  if(audioFilesLoaded == 1) {
//    text("One audio file is loaded!");
//  }
//
// How to play the loaded audio file:
//
//  playSound("gameMusic1");
//
// Powered by javascript!
//

// Number of audio files loaded
var audioFilesLoaded = 0;
var nAudioFiles = 0;

// A map of all the audio files that have been loaded
var sounds = new Object();

// Play an audio file from the key 'name'
function playSound(var name)
{
    sounds[name].play();
}

// Load an audio file
// 'name' is the key to retrieve the audio object from 'sounds'
// 'uri' is the path to the file
function loadAudio(var name, var uri)
{
    var audio = new Audio();
    sounds[name] = audio;
    audio.addEventListener("canplaythrough", audioFileLoaded, false); // It works!!
    audio.src = uri;
    nAudioFiles++;
    return audio;
}

// This function will be called when an audio file is loaded
function audioFileLoaded()
{
    audioFilesLoaded++;
}
