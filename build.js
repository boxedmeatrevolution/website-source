// Build script for the website.

const fs = require('fs');
const mustache = require('mustache');
const path = require('path');

// Some useful utility functions.
function addProp(obj, key, val) {
    let result = JSON.parse(JSON.stringify(obj));
    result[key] = val;
    return result;
}

function copyFolderRecursiveSync(source, target) {
    let target_folder = path.join(target, path.basename(source));
    fs.mkdirSync(target_folder);
    if (fs.lstatSync(source).isDirectory()) {
        fs.readdirSync(source).forEach(function (file) {
            const current_source = path.join(source, file);
            if (fs.lstatSync(current_source).isDirectory()) {
                copyFolderRecursiveSync(current_source, target_folder);
            }
            else {
                copyFileSync(current_source, target_folder);
            }
        });
    }
    else {
        throw JSON.stringify(source) + " is not a directory.";
    }
}

// Load command line arguments.
if (process.argv.length !== 3) {
    throw "Unexpected number of command line arguments (expected 1).";
}
build_dir = process.argv[2];

// Read the template file.
const template_html = fs.readFileSync('./template.html', 'utf8');

// Read the pages.
let index_html = fs.readFileSync('./pages/index.html', 'utf8');
let about_html = fs.readFileSync('./pages/about.html', 'utf8');
let game_html = fs.readFileSync('./pages/game.html', 'utf8');

// Read the data which will populate the pages.
let developers = fs.readFileSync('./data/developers.json', 'utf8');
let games = fs.readFileSync('./data/games.json', 'utf8');
try {
    developers = JSON.parse(developers);
}
catch (error) {
    const fileName = 'developers.json';
    const message = error.message;
    throw `Error parsing ${fileName}: ${message}`;
}
try {
    games = JSON.parse(games);
}
catch (error) {
    const fileName = 'games.json';
    const message = error.message;
    throw `Error parsing ${fileName}: ${message}`;
}

// Use substitutions to build the pages.
let template_data = {
    'body': '',
    'developers': developers,
    'games': games
};
index_html = mustache.render(template_html, addProp(template_data, 'body', index_html));
about_html = mustache.render(about_html, { 'developers': developers });
about_html = mustache.render(template_html, addProp(template_data, 'body', about_html));
// Loop through all games to make a different page for each game.
const games_html = games.map(function (game) {
    // This is a little more complicated: if a web distribution exists, then it
    // must be embedded into the page.
    let view = { 'game': game };
    if (game.web_folder != null) {
        const embedded_file_path = path.join(
            './data/',
            path.join(
                game.web_folder,
                './index.html'));
        const embedded_html = fs.readFileSync(embedded_file_path, 'utf8');
        view.embedded = embedded_html;
    }
    let game_html = mustache.render(game_html, view);
    game_html = mustache.render(template_html, addProp(template_data, 'body', game_html));
    return game_html;
});

// Save the final pages to the build directory.
fs.writeFileSync(path.join(build_dir, 'index.html'), index_html, 'utf8');
fs.writeFileSync(path.join(build_dir, 'about.html'), about_html, 'utf8');
games.forEach(function (game, index) {
    // Create folder for game if it doesn't already exist.
    const target_folder = path.join(build_dir, path.join('./games/', game.id));
    if (!fs.existsSync(target_folder)) {
        fs.mkdirSync(target_folder);
    }
    // For each game, if there is a web distribution, then the whole folder must
    // be copied to the final website.
    if (game.web_folder != null) {
        const source_folder = path.join('./data/', game.web_folder);
        copyFileRecursive(source_folder, target_folder);
    }
    // The game page must be written to the build directory.
    fs.writeFileSync(path.join(target_folder, game.id + '.html'), games_html[index], 'utf8');
});

// Copy pictures and styles to the build directory.

// Copy the game files themselves to the build directory.

