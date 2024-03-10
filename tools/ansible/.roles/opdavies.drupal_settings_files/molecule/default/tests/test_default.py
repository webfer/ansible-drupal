import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')

def test_drupal_site_directory_exists(host):
    directory = host.file('/var/www/test/sites/default')

    assert directory.exists
    assert directory.is_directory

def test_drupal_settings_file_exists(host):
    file = host.file('/var/www/test/sites/default/settings.test.php')

    assert file.exists
    assert file.is_file
