<?php

use Robo\Tasks;
use Symfony\Component\Yaml\Yaml;

/**
 * Tasks for the project.
 */
class RoboFile extends Tasks {

  // Use drush in non interactive mode.
  const DRUSH = __DIR__ . '/vendor/bin/drush --yes --root=' . __DIR__ . '/web';

  // We use Robo itself to launch parallel tasks.
  const ROBO = __DIR__ . '/vendor/bin/robo';

  // We use npm to build the theme.
  const NPM = __DIR__ . '/vendor/bin/npm';

  /**
   * Decoded composer.json.
   *
   * @var object
   */
  protected $composer;

  /**
   * Devel mode so enable certain modules and actions.
   *
   * @var bool
   */
  protected $devel = FALSE;

  /**
   * Constructor.
   */
  public function __construct() {
    if (file_exists(__DIR__ . '/configsync/system.theme.yml') && file_exists(__DIR__ . '/configsync/system.site.yml')) {
      $this->theme = Yaml::parseFile(__DIR__ . '/configsync/system.theme.yml');
      $this->site = Yaml::parseFile(__DIR__ . '/configsync/system.site.yml');
    }
  }

  /**
   * Imports external MySQL backup to 'PROJECTNAME_db' database.
   */
  public function devExternaldb($opts = ['local' => FALSE]) {
    $host = ($opts['local']) ? 'localhost' : "{$this->project_name}_db";

    // Dump external database that is in 'myblobs' dir.
    $this->taskExec('zcat')
      ->rawArg(__DIR__ . '/myblobs/*.mysql.bck.gz')
      ->rawArg(' | ')
      ->rawArg('mysql -h' . $host . ' -udb -pdb ' . $this->project_name . '_db')
      ->run();
  }

  /**
   * Install a Drupal profile and import the configuration.
   *
   * This is one of the tasks needed to build a full drupal site.
   */
  public function drupalInstallProfile($profile = 'config_installer', $opts = ['devel' => FALSE]) {
    if ($opts['devel']) {
      $this->devel = TRUE;
    }

    // Collection of tasks that need to be run one after the other.
    $collection = $this->collectionBuilder();

    // Add the first task to install the profile.
    $collection->addTask($this->taskExec(self::DRUSH)
      ->arg('site:install')
      ->arg('--account-mail=' . $this->composer->accountmail)
      ->arg('--account-name=' . $this->composer->accountname)
      ->arg('--account-pass=' . $this->composer->accountpass)
      ->arg('--locale=' . $this->site['default_langcode'])
      ->arg('--site-mail=' . $this->composer->sitemail)
      ->arg($profile)
    );

    // Add administrator role to uid 1. Views role permissions don't work
    // without it.
    $collection->addTask($this->taskExec(self::DRUSH)
      ->arg('user:role:add')
      ->arg('administrator')
      ->arg($this->composer->accountname));

    // Run additional drush commands.
    if (isset($this->composer->drushPostInstall)) {
      foreach ($this->composer->drushPostInstall as $command) {
        $collection->addTask($this->taskExec(self::DRUSH)
          ->rawArg($command)
        );
      }
    }

    return $collection->run();
  }

  /**
   * Import the configuration.
   *
   * This is one of the tasks needed to build a full drupal site on update mode.
   */
  public function drupalUpdateConfig($opts = ['devel' => FALSE]) {
    if ($opts['devel']) {
      $this->devel = TRUE;
    }

    // Collection of tasks that need to be run one after the other.
    $collection = $this->collectionBuilder();

    // Config the site as it is on the yaml files.
    $collection->addTask($this->taskExec(self::DRUSH)
      ->arg('config-import'));

    return $collection->run();
  }

  /**
   * Build styles for the default theme.
   */
  public function styles($opts = ['devel' => FALSE]) {
    if ($this->theme['default'] != 'bartik') {
      $theme_path = __DIR__ . '/web/themes/custom/' . $this->theme['default'];

      $collection = $this->collectionBuilder();

      // Add '--no-save' flag to 'npm install' because npm accidentally make
      // changes to 'package-lock.json' file when optional dependencies exists.
      $collection->addTask(
        $this->taskExec(self::NPM)
          ->arg('install')
          ->arg('--no-save')
      );
      // Be sure the C bindings for libsass are correct.
      $collection->addTask(
        $this->taskExec(self::NPM)
          ->arg('rebuild')
          ->arg('node-sass')
      );
      $collection->addTask(
        $this->taskExec(self::NPM)
          ->arg('run')
          ->arg('gulp')
          ->arg($opts['devel'] ? 'build:styles' : 'build:styles-production')
      );

      return $collection->run();
    }
  }

  /**
   * Build the site for development by calling drupalInstall() function.
   */
  public function drupalDev() {
    $this->stopOnFail(TRUE);

    // Set the devel flag.
    $this->devel = TRUE;

    // Prepare permissions.
    $this->_chmod(__DIR__ . '/web/sites/default', 0777);
    $this->_chmod(__DIR__ . '/web/sites/default/settings.php', 0777);

    // Call the main install function.
    $this->drupalInstall();
    $this->_chmod(__DIR__ . '/web/sites/default', 0755);
  }

  /**
   * Build the site for development by calling drupalUpdate.
   */
  public function drupalUpdatedev() {
    $this->stopOnFail(TRUE);
    // Set the devel flag.
    $this->devel = TRUE;

    $this->taskExec('composer')
      ->arg('install')
      ->run();
    $this->dbSync();
    // Call the main install function.
    $this->drupalUpdate();
  }

  /**
   * Synchronize database.
   * Use "--local" when you need a local synchronization.
   *
   * @param string $alias
   *   Environment you want to sync with.
   * @param array $opts
   *   Flag to indicate a synchronization in a local environment.
   */
  public function dbSync(string $alias = 'stage', array $opts = ['local' => FALSE]) {
    // Note: Currently, this method only works for aliases configured in the
    // self.site.yml file.
    $alias = "@self.{$alias}";
    $alias .= ($opts['local']) ? '_local' : '';

    $this->taskExec(self::DRUSH)
      ->arg('sql:sync')
      ->arg($alias)
      ->arg('--structure-tables-list=cache*,flood,sessions,watchdog')
      ->arg('@self')
      ->run();
  }

  /**
   * Backup database.
   */
  public function drupalBackup() {
    $date = date('YmdHi');

    // Create 'backups' directory.
    $this->taskExec('mkdir')
      ->arg(__DIR__ . '/backups')
      ->run();

    // Generate backup.
    $this->taskExec(self::DRUSH)
      ->arg('sql-dump')
      ->arg("--result-file=../backups/backup_{$date}.sql")
      ->run();
  }

  /**
   * Perform a full drupal build including, profile install, translations, styles, etc.
   */
  public function drupalInstall($opts = ['devel' => FALSE]) {
    // Prepare permissions.
    $this->_chmod(__DIR__ . '/web/sites/default', 0777);

    // Since we have no settings.php checked in the repository we copy a default
    // one consisting of the Drupal default plus custom configurations.
    $this->taskFilesystemStack()
      ->copy(__DIR__ . '/web/sites/default/default.settings.php', __DIR__ . '/web/sites/default/settings.php', TRUE)
      ->run();
    $this->taskWriteToFile(__DIR__ . '/web/sites/default/settings.php')
      ->append(TRUE)
      ->line('// Custom configurations.')
      ->line('include $app_root . \'/\' . $site_path . \'/settings.local.php\';')
      ->line('$settings[\'install_profile\'] = \'minimal\';')
      ->line('$settings[\'config_sync_directory\'] = \'../configsync\';')
      ->run();

    $this->_chmod(__DIR__ . '/web/sites/default/settings.php', 0777);

    // Set the devel flag if the option is set.
    if ($opts['devel']) {
      $this->devel = TRUE;
    }
    // Collection of tasks that run one after the other.
    $collection = $this->collectionBuilder();
    // Parallel commands that need to be done first.
    // Note that is just another task that will be added to the collection.
    $install = $this->taskParallelExec()->printed(TRUE);
    // Install the profile with its configuration starting a new robo process.
    // See drupalInstallProfile().
    $install->process(self::ROBO . ' drupal:install-profile' . ($this->devel ? ' --devel' : ''));
    // On production styles are generated by ansible.
    if ($this->devel) {
      // Build the styles in paralel.
      $install->process(self::ROBO . ' styles' . ($this->devel ? ' --devel' : ''));
    }
    // Add the first batch of parallelized tasks.
    $collection->AddTask($install);

    // We are going to add all the commands to this task that can be
    // parallelized with the site already installed.
    $postinstall = $this->taskParallelExec()->printed(TRUE);

    // Parallelize the update of the translations.
    $postinstall->process(self::ROBO . ' locale:update');

    // Add the parallelized tasks that need to run after the drupal installation.
    $collection->AddTask($postinstall);
    // Rebuild cache.
    $collection->AddTask($this->taskExec(self::DRUSH)
      ->arg('cache-rebuild'));

    if ($this->devel) {
      // Import dev configuration to enable migration modules.
      $collection->AddTask($this->taskExec(self::DRUSH)
        ->arg('config-split:import'));
      // Add default content.
      $collection->AddTask($this->taskExec(self::DRUSH)
        ->arg('migrate-import')
        ->arg('--tag=migrate_default_content'));
    }

    if ($this->devel) {
      $collection->AddTask($this->taskExec(self::DRUSH)
        ->arg('@' . $this->project_name . '.local')
        ->arg('user:login')
      );
    }

    // Run all the tasks and return the result.
    return $collection->run();
  }

  /**
   * Perform a Drupal update build including, configuration, translations, styles, etc.
   */
  public function drupalUpdate($opts = ['devel' => FALSE]) {
    // Set the devel flag if the option is set.
    if ($opts['devel']) {
      $this->devel = TRUE;
    }

    // Prepare permissions.
    $this->_chmod(__DIR__ . '/web/sites/default', 0777);

    // Since we have no settings.php checked in the repository we copy a default
    // one consisting of the Drupal default plus custom configurations.
    $this->taskFilesystemStack()
      ->copy(__DIR__ . '/web/sites/default/default.settings.php', __DIR__ . '/web/sites/default/settings.php', TRUE)
      ->run();
    $this->taskWriteToFile(__DIR__ . '/web/sites/default/settings.php')
      ->append(TRUE)
      ->line('// Custom configurations.')
      ->line('include $app_root . \'/\' . $site_path . \'/settings.local.php\';')
      ->line('$settings[\'install_profile\'] = \'minimal\';')
      ->line('$settings[\'config_sync_directory\'] = \'../configsync\';')
      ->run();

    // Collection of tasks that run one after the other.
    $collection = $this->collectionBuilder();

    // Parallel commands that need to be done first.
    // Note that is just another task that will be added to the collection.
    $install = $this->taskParallelExec()->printed(TRUE);
    // Install the profile with its configuration starting a new robo process.
    // See DrupalInstallProfile().
    $install->process(self::ROBO . ' drupal:update-config' . ($this->devel ? ' --devel' : ''));
    // On production styles are generated by ansible.
    if ($this->devel) {
      // Build the styles in paralel.
      $install->process(self::ROBO . ' styles' . ($this->devel ? ' --devel' : ''));
    }
    // Add the first batch of paralelized tasks.
    $collection->AddTask($install);

    // Update the database.
    $collection->AddTask($this->taskExec(self::DRUSH)
      ->arg('updatedb'));

    // We are going to add all the commands to this task that can be paralelized with the site already installed.
    $postinstall = $this->taskParallelExec()->printed(TRUE);

    // Paralelize the update of the translations.
    $postinstall->process(self::ROBO . ' locale:update');

    if ($this->devel) {
      // Add a task to the collection to create the initial content for testing.
      /*
      TODO: Find a way to migrate default content when we clone the stage db.
      First revert all the migrations.
      $collection->AddTask($this->taskExec(self::DRUSH)
      ->arg('migrate-import')
      ->arg('--group=migrate_default_content'));
       */
    }

    // Add the paralelized tasks that need to run after the drupal installation.
    $collection->AddTask($postinstall);
    // Rebuild cache.
    $collection->AddTask($this->taskExec(self::DRUSH)
      ->arg('cache-rebuild'));
    if ($this->devel) {
      $collection->AddTask($this->taskExec(self::DRUSH . ' @' . $this->project_name . '.local user:login'));
    }

    // Run all the tasks and return the result.
    return $collection->run();
  }

  /**
   * Update translations.
   */
  public function localeUpdate() {
    // Update translations.
    if ($this->site['default_langcode'] != 'en') {
      $this->taskExec(self::DRUSH)
        ->arg('locale-check')
        ->run();
      $this->taskExec(self::DRUSH)
        ->arg('locale-update')
        ->run();
    }
  }

  /**
   * Export translations for a module or theme.
   */
  public function localeExport($language, $module) {
    // Get path to module.
    $module_list = json_decode(
      shell_exec(self::DRUSH . ' pm:list --format=json --fields=path')
    );
    $path_to_module = $module_list->{$module}->path;
    $this->taskExec(self::DRUSH)
      ->arg('potx')
      ->arg('single')
      ->arg('--folder=' . $path_to_module)
      ->arg('--api=8')
      ->arg('--language=' . $language)
      ->run();

    // Create dir if it doesn't exist.
    $path = __DIR__ . '/web/' . $path_to_module . '/';
    $translations = $path . 'translations/';
    $this->taskExec('mkdir')
      ->arg('-p')
      ->arg($translations)
      ->run();
    $this->taskExec('mv')
      ->arg(__DIR__ . '/web/general.pot')
      ->arg($translations . $language . '.po')
      ->run();
    // Write to the info file if needed.
    $text = "\n'interface translation project': " . $module . "\n";
    $text .= "'interface translation server pattern': '" . $path_to_module . "/translations/%language.po'";
    $this->taskWriteToFile($path . $module . '.info.yml')
      ->append()
      ->appendUnlessMatches('/interface translation project/', $text)
      ->run();
  }

  /**
   * Check PHP coding standards.
   *
   * @param array $opts
   * @option $fix Fix coding standards errors
   */
  public function lintPhp($opts = ['fix' => FALSE]) {
    $command = ($opts['fix']) ? 'phpcbf' : 'phpcs';

    return $this->taskExec('composer ' . $command)
      ->run();
  }

  /**
   * Check for a valid composer.json.
   */
  public function lintComposer() {
    return $this->taskExec('composer validate')
      ->run();
  }

  /**
   * Run all the linters.
   */
  public function lint() {
    return
      $this->lintComposer()->wasSuccessful() &&
      $this->lintPhp()->wasSuccessful();
  }

  /**
   * Imports external MSSQL DB backup to SQL Server Biblio database.
   */
  public function devMicrosoftdb() {
    $this->taskExec('/opt/mssql-tools/bin/sqlcmd')
      ->rawArg('-S sqlserver -U SA -P Str0ngPassw0rd -Q "RESTORE DATABASE [Biblio] FROM DISK=N\'/var/opt/mssql/backup/Biblio_backup_201804232100.bak\' WITH  FILE = 1, MOVE \'Biblio_Data\' TO N\'/var/opt/mssql/data/Biblio.mdf\', MOVE \'Biblio_Log\' TO N\'/var/opt/mssql/data/Biblio_log.ldf\', NOUNLOAD,  REPLACE,  STATS = 1"')
      ->run();
  }

}
