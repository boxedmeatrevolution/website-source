// Build script for the website.

const fs = require('fs');
const html_parser = require('node-html-parser');
const mustache = require('mustache');
const path = require('path');

// Some useful utility functions.
function deepCopy(obj) {
    return JSON.parse(JSON.stringify(obj));
}

function copyFolderRecursiveSync(source, target) {
    let target_dir = path.join(target, path.basename(source));
    if (!fs.existsSync(target_dir)) {
        fs.mkdirSync(target_dir);
    }
    if (fs.lstatSync(source).isDirectory()) {
        fs.readdirSync(source).forEach(function (file) {
            const current_source = path.join(source, file);
            const current_target = path.join(target_dir, file);
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
const home_template = fs.readFileSync('./pages/index.html', 'utf8');
const about_template = fs.readFileSync('./pages/about/index.html', 'utf8');
const game_template = fs.readFileSync('./pages/games/index.html', 'utf8');

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

// Use templates to build the pages.
const view = {
    'scripts': '',
    'developers': developers,
    'games': games
};

let home_view = deepCopy(view);
let home_html = mustache.render(home_template, home_view);
home_view.body = home_html;
home_html = mustache.render(wrapper_template, home_view);

let about_view = deepCopy(view);
about_view.title = 'Our team';
let about_html = mustache.render(about_template, about_view);
about_view.body = about_html;
about_html = mustache.render(wrapper_template, about_view);

// Loop through all games to make a different page for each game.
const games_html = games.map(function (game) {
    // This is a little more complicated: if a web distribution exists, then it
    // must be embedded into the page.
    let game_view = deepCopy(view);
    game_view.title = game.name;
    game_view.game = game;
    if (game.web_dir != null) {
        const embedded_file_path = path.join(
            './games/',
            path.join(
                game.web_dir,
                './index.html'));
        const embedded_html = fs.readFileSync(embedded_file_path, 'utf8');
        const parse_options = {
            script: true,
            style: true,
            pre: true
        };
        const root = html_parser.parse(embedded_html, parse_options);
        const head_html = root.querySelector('head').toString();
        const body_html = root.querySelector('body').toString();
        console.log(head_html);
        console.log(body_html);
        game_view.embedded = body_html;
        game_view.scripts += head_html;
    }
    let game_html = mustache.render(game_template, game_view);
    game_view.body = game_html;
    game_html = mustache.render(wrapper_template, game_view);
    return game_html;
});

// Make directories to store the website pages and resources.
const home_dir = build_dir;
const about_dir = path.join(home_dir, './about/');
const games_dir = path.join(home_dir, './games/');
const downloads_dir = path.join(home_dir, './downloads/');
const images_dir = path.join(home_dir, './images/');
const styles_dir = path.join(home_dir, './styles/');
if (!fs.existsSync(home_dir)) {
    fs.mkdirSync(home_dir);
}
if (!fs.existsSync(about_dir)) {
    fs.mkdirSync(about_dir);
}
if (!fs.existsSync(games_dir)) {
    fs.mkdirSync(games_dir);
}
if (!fs.existsSync(downloads_dir)) {
    fs.mkdirSync(downloads_dir);
}
if (!fs.existsSync(images_dir)) {
    fs.mkdirSync(images_dir);
}
if (!fs.existsSync(styles_dir)) {
    fs.mkdirSync(styles_dir);
}

// Write the HTML files to the filesystem.
fs.writeFileSync(path.join(home_dir, 'index.html'), home_html, 'utf8');
fs.writeFileSync(path.join(about_dir, 'index.html'), about_html, 'utf8');
games.forEach(function (game, index) {
    // For each game, if there is a web distribution, then the whole folder must
    // be copied to the final website (without the old `index.html`).
    const game_dir = path.join(games_dir, game.id);
    if (game.web_dir != null) {
        const source_game_dir = path.join('./games/', game.web_dir);
        copyFolderRecursiveSync(source_game_dir, games_dir);
        const old_game_dir = path.join(games_dir, game.web_dir);
        fs.renameSync(old_game_dir, game_dir);
        const game_index = path.join(game_dir, 'index.html');
        fs.unlinkSync(game_index);
    }
    // Create folder for game if it doesn't already exist.
    if (!fs.existsSync(game_dir)) {
        fs.mkdirSync(game_dir);
    }
    // The game page must be written to the build directory.
    fs.writeFileSync(path.join(game_dir, 'index.html'), games_html[index], 'utf8');
    // Copy the downloads associated with the game to the right place.
    game.downloads.forEach(function (download) {
        const file_name = download.file;
        const source_game_file = path.join('./games/', file_name);
        const target_game_file = path.join(downloads_dir, file_name);
        fs.copyFileSync(source_game_file, target_game_file);
    });
});

// Copy images and styles to the build directory.
copyFolderRecursiveSync('./images/', images_dir);
copyFolderRecursiveSync('./styles/', styles_dir);

