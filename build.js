// Build script for the website.

import fs from 'node:fs/promises';
import path from 'node:path';

import mustache from 'mustache';
import sass from 'sass';
import sharp from 'sharp';

// Some useful utility functions.
function deepCopy(obj) {
    return JSON.parse(JSON.stringify(obj));
}

async function copyImage(source, target, extension, dimensions=undefined) {
    const target_basename = path.basename(target, path.extname(target));
    const target_dir = path.dirname(target);
    const target_new = path.join(target_dir, target_basename + extension);
    try {
        if (dimensions === undefined) {
            await sharp(source).toFile(target_new);
        } else {
            await sharp(source)
                .resize({ width: dimensions.width, height: dimensions.height })
                .toFile(target_new);
        }
    } catch (error) {
        const message = error.message;
        throw `Error copying image ${source}: ${message}`;
    }
}

async function copyFolderContentsRecursive(source_dir, target_dir, copy_func=fs.copyFile) {
    if ((await fs.lstat(source_dir)).isDirectory()) {
        await Promise.all((await fs.readdir(source_dir)).map(async (file) => {
            const current_source = path.join(source_dir, file);
            const current_target = path.join(target_dir, file);
            if ((await fs.lstat(current_source)).isDirectory()) {
                await copyFolderRecursive(current_source, target_dir);
            } else {
                await copy_func(current_source, current_target);
            }
        }));
    } else {
        throw JSON.stringify(source_dir) + ' is not a directory.';
    }
}

async function copyFolderRecursive(source_dir, target_dir, copy_func=fs.copyFile) {
    const new_target_dir = path.join(target_dir, path.basename(source_dir));
    await fs.mkdir(new_target_dir, { recursive: true });
    await copyFolderContentsRecursive(source_dir, new_target_dir, copy_func);
}

// Load command line arguments.
if (process.argv.length !== 3) {
    throw 'Unexpected number of command line arguments (expected 1).';
}
const build_dir = process.argv[2];

// Test that the build directory exists.
if (!(await fs.lstat(build_dir)).isDirectory()) {
    throw 'Build directory does not exist.';
}

// Read the template file.
let wrapper_template = fs.readFile('./template.html', 'utf8');

// Read the pages.
let home_template = fs.readFile('./pages/index.html', 'utf8');
let about_template = fs.readFile('./pages/about/index.html', 'utf8');
let games_template = fs.readFile('./pages/games/index.html', 'utf8');
let game_template = fs.readFile('./pages/games/game/index.html', 'utf8');

// Read the data which will populate the pages.
let developers = fs.readFile('./data/developers.json', 'utf8');
let games = fs.readFile('./data/games.json', 'utf8');

// Execute.
[ wrapper_template, home_template, about_template, games_template, game_template, developers, games ] = await Promise.all([ wrapper_template, home_template, about_template, games_template, game_template, developers, games ]);

// Parse JSON.
try {
    developers = JSON.parse(developers);
} catch (error) {
    const file_name = 'developers.json';
    const message = error.message;
    throw `Error parsing ${file_name}: ${message}`;
}
try {
    games = JSON.parse(games);
} catch (error) {
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
const game_html_list = games.map((game) => {
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
const styles_dir = path.join(home_dir, './styles/');
const images_dir = path.join(home_dir, './images/');
const screenshots_dir = path.join(images_dir, './screenshots/');
const portraits_dir = path.join(images_dir, './portraits/');
const logos_dir = path.join(images_dir, './logos/');

await fs.mkdir(home_dir, { recursive: true });
await Promise.all([
    fs.mkdir(about_dir, { recursive: true }),
    fs.mkdir(games_dir, { recursive: true }),
    fs.mkdir(downloads_dir, { recursive: true }),
    fs.mkdir(embeds_dir, { recursive: true }),
    fs.mkdir(styles_dir, { recursive: true }),
    fs.mkdir(images_dir, { recursive: true })]);
await Promise.all([
    fs.mkdir(screenshots_dir, { recursive: true }),
    fs.mkdir(portraits_dir, { recursive: true }),
    fs.mkdir(logos_dir, { recursive: true })]);

// Write the HTML files to the filesystem.
const write_html = await Promise.all([
    fs.writeFile(path.join(home_dir, 'index.html'), home_html, 'utf8'),
    fs.writeFile(path.join(about_dir, 'index.html'), about_html, 'utf8'),
    fs.writeFile(path.join(games_dir, 'index.html'), games_html, 'utf8')]
    .concat(games.map(async (game, index) => {
        const game_dir = path.join(games_dir, game.id);
        await fs.mkdir(game_dir, { recursive: true });
        const game_build_dir = path.join('./games/', game['build-dir']);
        // For each game, if there is a web distribution, then the whole folder
        // must be copied to the `embeds` directory.
        let write_embed = Promise.resolve();
        if (game.embed != null) {
            const source_embed_dir = path.join(game_build_dir, game.embed.dir);
            const embed_dir = path.join(embeds_dir, game.id);
            await fs.mkdir(embed_dir, { recursive: true });
            write_embed = copyFolderContentsRecursive(source_embed_dir, embed_dir);
        }
        // The game page must be written to the build directory.
        const write_game_html = fs.writeFile(path.join(game_dir, 'index.html'), game_html_list[index], 'utf8');
        // Copy the downloads associated with the game to the right place.
        const write_downloads = Promise.all(game.downloads.map(async (download) => {
            const file_name = download.file;
            const source_game_file = path.join(game_build_dir, file_name);
            const target_game_file = path.join(downloads_dir, file_name);
            await fs.copyFile(source_game_file, target_game_file);
        }));
        await Promise.all([ write_embed, write_game_html, write_downloads ]);
    })));

// Compile the main SCSS file. The others will be brought in by it, and
// everything will be compiled to a single minified stylesheet.
const style_file = './styles/styles.scss';
// TODO: use asynchronous SASS rendering.
const compiled_styles = sass.renderSync({file: style_file, outputStyle: 'compressed'});
const write_styles = fs.writeFile(path.join(styles_dir, 'styles.css'), compiled_styles.css, 'utf8');

// Copy images to the build directory.
//await copyFolderContentsRecursive('./images/', images_dir);
const write_images = Promise.all([
    fs.copyFile('./images/favicon.ico', path.join(images_dir, 'favicon.ico')),
    copyFolderContentsRecursive(
        './images/screenshots/',
        screenshots_dir,
        (source, target_dir) => copyImage(source, target_dir, '.jpg', { width: 1024, height: 640 })),
    copyFolderContentsRecursive(
        './images/portraits/',
        portraits_dir,
        (source, target_dir) => copyImage(source, target_dir, '.jpg', { width: 512, height: 512 })),
    copyFolderContentsRecursive(
        './images/logos/',
        logos_dir,
        (source, target_dir) => copyImage(source, target_dir, '.png'))]);

await Promise.all([ write_html, write_styles, write_images ]);

