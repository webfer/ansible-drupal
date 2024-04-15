/**
 * Imports
 */

/**
 * Plugins
 * 
 * Download third-party plugins from resources like npm
 * and import the needed files (mostly CSS or JS files) here.
 * 
 * By default, Bootstrap's 5 JS bundle is imported here, along with
 * Bootstrap's 5 icon library.
 * 
 * It's up to you to extend the theme with all the plugins your project require.
 */
import 'bootstrap/dist/js/bootstrap.bundle.js';
import 'bootstrap-icons/font/bootstrap-icons.css';
 
/**
 * Assets (images)
 * 
 * Place your theme related images in drupy/src/img folder.
 * 
 * Webpack will automatically copy and place them in
 * drupy/dist/img, the folder managed by the theme for this kind of assets.
 * 
 * If you want to use the imported images in your scss/css as a background-image,
 * you can do it as related in the following example:
 * 
 * background-image: url(../img/dummy_image.png);
 * 
 * At least, but not al last, notice that no image manipulation or optimization 
 * is done here, but you can add additional image handlers in the webpack.config.js 
 * in order to extend this basic behavior.
 * 
 * A dummy image is included for demonstration purposes only.
 */
// import '../img/dummy_image.png';
 
/**
 * Assets (icons)
 * 
 * Place your theme related custom icons in drupy/src/icons folder.
 * 
 * Webpack will automatically copy and place them in
 * drupy/dist/icons, the public folder from which you can handle them, mostly
 * in you scss/css files.
 */
// import '../icons/example.svg';
 
/**
 * Fonts 
 * 
 * This theme aims the installation of fonts through npm & @fontsource.
 * By default, 'Montserrat' font has been included to the package.json and handled
 * in drupy/src/sass/index.scss file.
 * 
 * However, you always can manually add fonts to the theme, by adding the font files
 * in a subfolder within the drupy/src/fonts folder and including them below.
 * 
 * The following is an example for 'Quentin' font, which is not available in @fontsource 
 * repositories. 
 * 
 * Remember to properly handle custom fonts by adding a rule in webpack.config.js 
 * (you'll find a commented example in that file) and implementing a @font-face 
 * declaration in drupy/src/sass/base/fonts.scss file.
 */
// import '../fonts/quentin/quentin.woff';
// import '../fonts/quentin/quentin.woff2';
// import '../fonts/quentin/quentin.eot';
// import '../fonts/quentin/quentin.ttf';
 
/**
 * Styles
 * 
 * The styles are mainly written with SASS, compiled through Webpack and managed
 * by drupy/src/sass/index.scss file.
 * 
 * You'll find an example of folders structure under drupy/src/sass, which can be 
 * changed to fit your needs.
 * 
 * There are two special files besides index.scss: 
 *    * _overrides.scss: used to override default Bootstrap 5 variables
 *    * _vars.scss: used to declare your custom SASS variables.
 * 
 * Please, take a look inside index.scss file to know more about how mixins, 
 * fonts & Bootstrap files (amongst other files) works together in this theme.
 */
import '../sass/index.scss';
 
/**
 * Scripts
 * 
 * Similar to SASS files, we encourage to work with exportable pieces of code, 
 * called modules, for all your custom javascript. You can add as many as you need.
 * 
 * By convention, we named these files with a preceding underscore (like SASS partials do) 
 * to differentiate them from the main index.js file. However you can organize the modules
 * in subfolders or as you prefer.
 * 
 * Once a module is created and exported, you must import it as shown below.
 * 
 * At least, but not at last, you will be able to call your scripts, wrapping 
 * them in a DOMContentLoaded event.
 * 
 * There are two modules included by default in this theme: one as an example, the other 
 * one is a basic implementation for the mobile menu toggler. You can alter or remove both 
 * to fit your needs.
 */
import foo from './_foo';
import menu_toggler from './_menu_toggler';

/**
 * DOMContentLoaded event
 * 
 * Call your scripts here.
 */
document.addEventListener('DOMContentLoaded', () => {
  foo.bar();
  menu_toggler();
});
 