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
    if (!fs.existsSync(target_folder)) {
        fs.mkdirSync(target_folder);
    }
    if (fs.lstatSync(source).isDirectory()) {
        fs.readdirSync(source).forEach(function (file) {
            const current_source = path.join(source, file);
            const current_target = path.join(target_folder, file);
            if (fs.lstatSync(current_source).isDirectory()) {
                copyFolderRecursiveSync(current_source, current_target);
            }
            else {
                fs.copyFileSync(current_source, current_target);
            }
        });
    }
    else {
        throw JSON.stringify(source) + ' is not a directory.';
    }
}

// Load command line arguments.
if (process.argv.length !== 3) {
    throw 'Unexpected number of command line arguments (expected 1).';
}
build_dir = process.argv[2];

// Test that build directory exists and is empty.
if (!fs.existsSync(build_dir)) {
    throw 'Build directory does not exist.';
}
if (fs.readdirSync(build_dir).length != 0) {
    console.log(`Build directory is not empty. Perhaps you should clean first with \`node clean ${build_dir}\`?`);
}

// Read the template file.
const wrapper_template = fs.readFileSync('./template.html', 'utf8');

// Read the pages.
let index_html = fs.readFileSync('./pages/index.html', 'utf8');
let about_template = fs.readFileSync('./pages/about.html', 'utf8');
let game_template = fs.readFileSync('./pages/game.html', 'utf8');

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
let wrapper_data = {
    'body': '',
    'developers': developers,
    'games': games
};
index_html = mustache.render(wrapper_template, addProp(wrapper_data, 'body', index_html));
let about_html = mustache.render(about_template, { 'developers': developers });
about_html = mustache.render(wrapper_template, addProp(wrapper_data, 'body', about_html));
// Loop through all games to make a different page for each game.
const games_html = games.map(function (game) {
    // This is a little more complicated: if a web distribution exists, then it
    // must be embedded into the page.
    let game_data = { 'game': game };
    if (game.web_folder != null) {
        // TODO: Merge `index.html` correctly with the `game_template`, by
        // merging the `head`, `body`, etc. indivdually.
        const embedded_file_path = path.join(
            './games/',
            path.join(
                game.web_folder,
                './index.html'));
        const embedded_html = fs.readFileSync(embedded_file_path, 'utf8');
        game_data.embedded = embedded_html;
    }
    let game_html = mustache.render(game_template, game_data);
    game_html = mustache.render(wrapper_template, addProp(wrapper_data, 'body', game_html));
    return game_html;
});

// Save the final pages to the build directory.
fs.writeFileSync(path.join(build_dir, 'index.html'), index_html, 'utf8');
fs.writeFileSync(path.join(build_dir, 'about.html'), about_html, 'utf8');
const games_folder = path.join(build_dir, './games/');
if (!fs.existsSync(games_folder)) {
    fs.mkdirSync(games_folder);
}
games.forEach(function (game, index) {
    // For each game, if there is a web distribution, then the whole folder must
    // be copied to the final website.
    if (game.web_folder != null) {
        const source_game_folder = path.join('./games/', game.web_folder);
        copyFolderRecursiveSync(source_game_folder, games_folder);
    }
    const game_folder = path.join(games_folder, game.id);
    // Create folder for game if it doesn't already exist.
    if (!fs.existsSync(game_folder)) {
        fs.mkdirSync(game_folder);
    }
    // The game page must be written to the build directory.
    fs.writeFileSync(path.join(game_folder, game.id + '.html'), games_html[index], 'utf8');
});

// Copy pictures and styles to the build directory.

// Copy the game files themselves to the build directory.

