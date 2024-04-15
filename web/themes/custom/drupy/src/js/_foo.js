const foo = {

 /**
  * Example method of foo.
  * Expand the foo object with additional methods which will exported
  * and imported afterwards in src/js/index.js
  *
  * @return  {void}
  */
  bar: () => {
    console.log('It works!');
  }
}

export default foo;
