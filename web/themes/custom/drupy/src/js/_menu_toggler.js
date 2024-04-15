/**
 * Handler for the menu toggler.
 *
 * @return  {void}
 */
const menu_toggler = () => {
  const body = document.querySelector('body');
  const button = document.getElementById('menu-toggler');
  const menus = document.getElementById('menus');
  button.addEventListener('click', (event) => {
    body.classList.toggle('menu-open');
    button.classList.toggle('active');
    menus.classList.toggle('active');

    if (body.classList.contains('menu-open')) {
      openMenu();
    }
    else {
      closeMenu();
    }
  });
}

/**
 * Behaviors to apply when mobile menu is opened, such as:
 *
 * - Avoid continue scrolling on the page.
 * - Read the scroll applied in the page.
 * - Set the scroll applied to the <body>.
 *
 * @see     https://codepen.io/geoffgraham/pen/LogERe
 *
 * @return  {void}
 */
const openMenu = () => {
  const scrollY = document.documentElement.style.getPropertyValue('--scroll-y');
  const body = document.body;
  body.style.position = 'fixed';
  body.style.top = `-${scrollY}`;
};

/**
 * Behaviors to apply when mobile menu is closed, such as:
 *
 * - Allow continue scrolling on the page again.
 * - Restore the scroll previously applied in the page, before the menu was opened.
 *
 * @see     https://codepen.io/geoffgraham/pen/LogERe
 *
 * @return  {void}
 */
const closeMenu = () => {
  const body = document.body;
  const scrollY = body.style.top;
  body.style.position = '';
  body.style.top = '';
  window.scrollTo(0, parseInt(scrollY || '0') * -1);
}

/**
 * Handler that reads the amount of pixels the page has been scrolled,
 * triggered on a 'scroll' event.
 *
 * @see     https://codepen.io/geoffgraham/pen/LogERe
 *
 * @return  {void}
 */
window.addEventListener('scroll', () => {
  document.documentElement.style.setProperty('--scroll-y', `${window.scrollY}px`);
});

export default menu_toggler;


