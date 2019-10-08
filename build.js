// Build script for the website.

const fs = require('fs');
const mustache = require('mustache');
const path = require('path');
const sass = require('sass');

// Some useful utility functions.
function deepCopy(obj) {
    return JSON.parse(JSON.stringify(obj));
}

function copyFolderContentsRecursiveSync(source_dir, target_dir) {
    if (fs.lstatSync(source_dir).isDirectory()) {
        fs.readdirSync(source_dir).forEach(function (file) {
            const current_source = path.join(source_dir, file);
            const current_target = path.join(target_dir, file);
            if (fs.lstatSync(current_source).isDirectory()) {
                copyFolderRecursiveSync(current_source, target_dir);
            }
            else {
                fs.copyFileSync(current_source, current_target);
            }
        });
    }
    else {
        throw JSON.stringify(source_dir) + ' is not a directory.';
    }
}

function copyFolderRecursiveSync(source_dir, target_dir) {
    const new_target_dir = path.join(target_dir, path.basename(source_dir));
    if (!fs.existsSync(new_target_dir)) {
        fs.mkdirSync(new_target_dir);
    }
    copyFolderContentsRecursiveSync(source_dir, new_target_dir);
}

// Load command line arguments.
if (process.argv.length !== 3) {
    throw 'Unexpected number of command line arguments (expected 1).';
}
build_dir = process.argv[2];

// Test that the build directory exists.
if (!fs.existsSync(build_dir)) {
    throw 'Build directory does not exist.';
}

// Read the template file.
const wrapper_template = fs.readFileSync('./template.html', 'utf8');

// Read the pages.
const home_template = fs.readFileSync('./pages/index.html', 'utf8');
const about_template = fs.readFileSync('./pages/about/index.html', 'utf8');
const games_template = fs.readFileSync('./pages/games/index.html', 'utf8');
const game_template = fs.readFileSync('./pages/games/game/index.html', 'utf8');

// Read the data which will populate the pages.
let developers = fs.readFileSync('./data/developers.json', 'utf8');
let games = fs.readFileSync('./data/games.json', 'utf8');
try {
    developers = JSON.parse(developers);
}
catch (error) {
    const file_name = 'developers.json';
    const message = error.message;
    throw `Error parsing ${file_name}: ${message}`;
}
try {
    games = JSON.parse(games);
}
catch (error) {
    const file_name = 'games.json';
    const message = error.message;
    throw `Error parsing ${file_name}: ${message}`;
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
about_view.title = 'About';
let about_html = mustache.render(about_template, about_view);
about_view.body = about_html;
about_html = mustache.render(wrapper_template, about_view);

let games_view = deepCopy(view);
games_view.title = 'Games';
let games_html = mustache.render(games_template, games_view);
games_view.body = games_html;
games_html = mustache.render(wrapper_template, games_view);

// Loop through all games to make a different page for each game.
const game_html_list = games.map(function (game) {
    let game_view = deepCopy(view);
    game_view.title = game.name;
    game_view.game = game;
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
const embeds_dir = path.join(home_dir, './embeds/');
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
if (!fs.existsSync(embeds_dir)) {
    fs.mkdirSync(embeds_dir);
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
fs.writeFileSync(path.join(games_dir, 'index.html'), games_html, 'utf8');
games.forEach(function (game, index) {
    const game_dir = path.join(games_dir, game.id);
    if (!fs.existsSync(game_dir)) {
        fs.mkdirSync(game_dir);
    }
    const game_build_dir = path.join('./games/', game['build-dir']);
    // For each game, if there is a web distribution, then the whole folder must
    // be copied to the `embeds` directory.
    if (game.embed != null) {
        const source_embed_dir = path.join(game_build_dir, game.embed.dir);
        const embed_dir = path.join(embeds_dir, game.id);
        if (!fs.existsSync(embed_dir)) {
            fs.mkdirSync(embed_dir);
        }
        copyFolderContentsRecursiveSync(source_embed_dir, embed_dir);
    }
    // The game page must be written to the build directory.
    fs.writeFileSync(path.join(game_dir, 'index.html'), game_html_list[index], 'utf8');
    // Copy the downloads associated with the game to the right place.
    game.downloads.forEach(function (download) {
        const file_name = download.file;
        const source_game_file = path.join(game_build_dir, file_name);
        const target_game_file = path.join(downloads_dir, file_name);
        fs.copyFileSync(source_game_file, target_game_file);
    });
});

// Compile the main SCSS file. The others will be brought in by it, and
// everything will be compiled to a single minified stylesheet.
const style_file = './styles/styles.scss';
const compiled_styles = sass.renderSync({file: style_file, outputStyle: 'compressed'});
fs.writeFileSync(path.join(styles_dir, 'styles.css'), compiled_styles.css, 'utf8');

// Copy images to the build directory.
copyFolderContentsRecursiveSync('./images/', images_dir);

