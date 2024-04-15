# Drupy theme

## Introduction
This is a responsive skeleton theme based on Bootstrap 5 and Webpack 5, ready for Drupal 9/10 websites. The theme itself brings you very few CSS styles by default, in order to let you to extend it with your own styles.

However, some common implementations are included by default in the .theme file, to make easiest the process of developing a theme from a skeleton.

The main purpose of this theme is to allow you to build your custom theme without dependencies like base themes, showing a way to grow up your own custom theme as required by your needs. And all managed by an excellent bundler like Webpack.

## Disclaimer
This theme does not follow the Drupal principles as far as themes are concerned, since it is intended for personal use, or for those developers who want to develop their theme the way I do it on a day-to-day basis.

Drupy is intended as a starting point theme and to be modified according to the needs of each developer. This implies that when there are new releases of the theme, they cannot be applied directly to your theme once you have started developing. To do this, perhaps I could planned it as a base theme with a starterkit, but it was not my intention to do so.

That's why I usually download Drupy with Composer and then I clone it to the /themes/custom folder. After that, I uninstall it again with Composer.

Yes, I know, I know. It's not the Drupal way of doing things, but for me it's a convenient way to develop a theme without having to rely on a base theme. I hate it ;-)

## How to use
The theme is self-documented about how to use it in each file, so pay attention to the inline comments you will find.
However, the following are a few tips to getting started.

Once downloaded, just type ```$ npm install``` in your terminal, (assuming you're in the root folder of the theme), and all node dependencies will be added to your theme.

Once all dependencies are properly installed, type ```$ npm run dev``` to let Webpack start watching for changes on your files automatically.

Other npm commands are available, so please take a look on the scripts sections of the package.json.

## What's new since version 1.1.0

I've added Layout Builder's custom layouts + Bootstrap for Drupy theme!

The main idea is to use Layout Builder along with the Bootstrap 5 included in the package.json, getting rid of additional libraries or modules like *Bootstrap Layout Builder*.

To get it working, we suggest you to install [Layout Builder Styles](https://www.drupal.org/project/layout_builder_styles). You'll need it.

### How to get it working?

Once installed and enabled, go to */admin/config/content/layout_builder_style/group*
and click on '**Add layout builder style group**' button.
  - Set 'Region container' as tag and 'region_container' as machine name.
  - Enable '*User may only apply one style from this group per per section or block*' checkbox.
  - Save changes.

Now, go to */admin/config/content/layout_builder_style* and click on '**Add layout builder style**' button
and create a Booststrap container:

  - Set 'Container' as tag, and 'container' as machine name.
  - Set 'container' on the 'CSS classes' textarea.
  - Enable 'Section' on the Type checkboxes section.
  - Ensure the 'Group' is set to 'Region container' you created before.
  - On '*Layout restrictions*', enable this style for all the layouts defined in *drupy.layouts.yml*.
  - Save changes.

Repeat the above steps, now for a Container-fluid container:

  - Set 'Container Fluid' as tag, and 'container_fluid' as machine name.
  - Set 'container-fluid' on the 'CSS classes' textarea.
  - Enable 'Section' on the Type checkboxes section.
  - Ensure the 'Group' is set to 'Region container' you created before.
  - On '*Layout restrictions*', enable this style for all the layouts defined in *drupy.layouts.yml*.
  - Save changes.

Once the above is done, you'll find a new dropdown in the Layout Builder UI, letting you to select the '*Region container*' you want to apply to a given section.

At last, you'll want to define Bootstrap-based column classes to all the regions of your Layout Builder's section: simply expand the '*Region attributes*' and set your required Bootstrap column classes on the '*Choose classes*' fields.
Drupy theme will automatically add the *row* wrappers if they're required, based on your '*Region container*' selection.

Additionally, you might want to disable the default layouts that Layout Builder provides in its UI.
See https://www.drupal.org/project/layout_disable for further information.

This is a list of modules we suggest you to install, in order to improve your user experience using Layout Builder:
  - **Layout Builder Component Attributes**
    https://www.drupal.org/project/layout_builder_component_attributes

  - **Layout Custom Section Classes & Attributes**
    https://www.drupal.org/project/layout_custom_section_classes

  - **Layout Builder Modal**
    https://www.drupal.org/project/layout_builder_modal

    Unfortunatelly, you'll might need to apply a patch along this module. Take a look to the following links:

    > Issue: https://www.drupal.org/project/layout_builder_modal/issues/3133695

    > Patch: https://www.drupal.org/files/issues/2022-12-15/3133695-13.patch

  - **Layout Builder Save And Edit**
    https://www.drupal.org/project/layout_builder_save_and_edit

  - **Layout Builder Symmetric Translations**
    https://www.drupal.org/project/layout_builder_st

## What's new since version 1.2.0?

Since version 1.2.0, this theme relies on Webpack 5, so you must have previously installed NodeJS in your computer.

It has been tested with the latest NodeJS LTS version at the moment (18.14.1). You can easily changes between Node versions if you install *nvm* (Node version manager) in your computer.

Follow the link for further information about nvm: https://github.com/nvm-sh/nvm
