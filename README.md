# 🚀 Ansible-Drupal: Automated Drupal Deployments

<br>
<p align="center">
<img src="ansible/assets/images/cover.jpg" width="650">
</p>
<br>

## 📋 Table of Contents

- [Description](#-description)
- [Key Features](#-key-features)
- [Project Architecture](#-project-architecture)
- [Prerequisites](#-prerequisites)
- [Dependencies](#-dependencies)
- [Quick Start Installation](#-quick-start-installation)
- [Project Structure](#-project-structure)
- [Configuration Files](#-configuration-files)
- [Deployment Workflows](#-deployment-workflows)
- [Advanced Features](#-advanced-features)
- [Rollback Process](#-rollback-process)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)

<br>

## 📖 Description

**Ansible-Drupal** is an enterprise-grade automation framework designed to streamline Drupal application deployments to remote servers. Built on top of Ansible and Ansistrano, this solution provides a robust, repeatable, and reliable deployment pipeline specifically optimized for Drupal projects hosted on Okitup infrastructure.

The framework handles the complete deployment lifecycle including:

- 🔄 Code synchronization
- 🗄️ Database management
- 📦 Asset deployment
- ⚙️ Configuration management
- 🔐 Security and authentication
- 🌐 Environment-specific deployments (Stage/Live)
- 🔙 Zero-downtime rollback capabilities

<br>

## ✨ Key Features

### 🎯 Deployment Modes

- **Initial Installation**: Complete first-time deployment with database import
- **Update Deployment**: Incremental updates with configuration synchronization
- **Asset Synchronization**: Optional file asset management with deletion tracking

### 🌍 Environment Management

- **Stage Environment**: Protected by HTTP Basic Authentication for testing
- **Production Environment**: Optimized live deployment configuration
- **Split Configuration**: Environment-specific Drupal config splits (dev/stage/live)

### 🔒 Security Features

- ✅ Ansible Vault encryption for sensitive data
- ✅ SSH key-based authentication
- ✅ HTTP Basic Auth for staging environments
- ✅ Automated .htaccess and .htpasswd management

### ⚡ Performance Optimizations

- ✅ Zero-downtime deployments using symlink switching
- ✅ Rsync for efficient file transfer
- ✅ Release versioning and history management
- ✅ Automated cache rebuilding
- ✅ Drush integration for Drupal-specific tasks

### 🛠️ Automation Features

- ✅ Automatic translation updates
- ✅ Database updates (updatedb)
- ✅ Configuration import/export
- ✅ Module management
- ✅ File permissions management
- ✅ Shared file and directory handling

<br>

## 🏗️ Project Architecture

The deployment system uses **Ansistrano Deploy**, which implements the [Capistrano](http://capistranorb.com/) deployment workflow:

```
/var/www/project/
├── current/              → Symlink to latest release
├── releases/
│   ├── 20231125120000/  → Timestamped release 1
│   ├── 20231125140000/  → Timestamped release 2
│   └── 20231125160000/  → Timestamped release 3 (current)
└── shared/              → Persistent files across releases
    ├── web/sites/default/files/
    └── private/
```

### Deployment Flow

1. **Setup Phase**: Prepare release directory with timestamp
2. **Update Code**: Rsync files from local to remote (excluding configured patterns)
3. **Symlink Shared**: Link shared directories (files, private)
4. **Before Symlink**: Run Drush commands (cache rebuild, config import, updatedb)
5. **Symlink**: Switch `current` symlink to new release (zero-downtime)
6. **After Symlink**: Update translations, final checks
7. **Cleanup**: Remove old releases (keeps configured number of releases)

<br>

## ⚙️ Prerequisites

Before getting started, ensure you have:

- 🐍 **Python 3.11+** installed on your local machine
- 📦 **Ansible 2.9+** installed ([Installation Guide](https://intranet.tothomweb.com/node/342))
- 🔧 **Ansistrano Deploy** role ([GitHub Repository](https://github.com/ansistrano/deploy))
- 🔑 **SSH access** configured for remote servers
- 💻 **Drupal 9/10** project with Composer and Drush
- 🌐 **Git** for version control
- 📝 Basic understanding of Ansible playbooks and Drupal architecture

<br>

## 📚 Dependencies

This project leverages the following technologies:

| Technology                         | Purpose                                       | Documentation                                                           |
| ---------------------------------- | --------------------------------------------- | ----------------------------------------------------------------------- |
| **Ansible**                        | IT automation engine                          | [Ansible Docs](https://docs.ansible.com/ansible/latest/index.html)      |
| **Ansistrano Deploy**              | Deployment role for Capistrano-style releases | [Ansistrano GitHub](https://github.com/ansistrano/deploy)               |
| **Ansistrano Rollback**            | Quick rollback capabilities                   | [Rollback GitHub](https://github.com/ansistrano/rollback)               |
| **opdavies.drupal_settings_files** | Drupal settings file management               | [Role GitHub](https://github.com/opdavies/ansible-role-drupal-settings) |
| **Drush**                          | Drupal command-line shell                     | [Drush Docs](https://www.drush.org/)                                    |

<br>

## 🚀 Quick Start Installation

### Step 1: Download the Installer

Run this command in your Drupal project root:

```bash
mkdir -p ~/.bin && \
curl -o ~/.bin/ansible-installer.sh https://raw.githubusercontent.com/webfer/ansible-drupal/main/scripts/ansible-installer.sh && \
source ~/.bin/ansible-installer.sh && \
autorun
```

**What this does:**

- Creates a `.bin` directory in your home folder
- Downloads the installation script
- Sources the script to make commands available
- Auto-configures your shell (.zshrc or .bashrc)

### Step 2: Install Ansible Configuration

From your Drupal root directory, run:

```bash
ansible-install
```

**What gets installed:**

- `ansible.cfg` - Ansible configuration file
- `ansible/` - Complete deployment structure
- `vault_pass.txt` - Vault password file (add to .gitignore!)

<br>

## 📂 Project Structure

After installation, your Drupal project will include:

```
drupal-project/
├── ansible.cfg                           # Ansible configuration
├── vault_pass.txt                        # Vault password (KEEP SECURE!)
├── ansible/
│   ├── core/
│   │   ├── .roles/                       # Ansible Galaxy roles
│   │   │   ├── ansistrano.deploy/
│   │   │   ├── ansistrano.rollback/
│   │   │   └── opdavies.drupal_settings_files/
│   │   ├── inventories/
│   │   │   ├── production/
│   │   │   │   ├── inventory.yml         # Production hosts
│   │   │   │   ├── group_vars/
│   │   │   │   │   ├── deploy_vars.yml   # Deployment configuration
│   │   │   │   │   ├── server.yml        # Server connection details (encrypted)
│   │   │   │   │   └── vars.yml          # General variables
│   │   │   │   └── host_vars/
│   │   │   │       └── live.yml          # Host-specific variables
│   │   │   └── stage/
│   │   │       ├── inventory.yml         # Stage hosts
│   │   │       ├── group_vars/
│   │   │       │   ├── deploy_vars.yml
│   │   │       │   ├── server.yml        # (encrypted)
│   │   │       │   └── vars.yml
│   │   │       └── host_vars/
│   │   │           └── stage.yml
│   │   ├── tasks/                        # Deployment task files
│   │   │   ├── after-update-code-tasks.yml
│   │   │   ├── ansistrano_after_symlink_tasks_file.yml
│   │   │   ├── before-cleanup-tasks.yml
│   │   │   ├── before-symlink-shared-tasks.yml
│   │   │   └── before-symlink-tasks.yml
│   │   ├── live-deploy.yml               # Production playbook
│   │   ├── stage-deploy.yml              # Staging playbook
│   │   └── rollback.yml                  # Rollback playbook
│   ├── assets/
│   │   └── images/                       # Documentation images
│   └── tmp/
│       └── logs/                         # Deployment logs
└── web/                                  # Your Drupal installation
```

<br>

## ⚙️ Configuration Files

### 🔧 ansible.cfg

Main Ansible configuration file:

```ini
[defaults]
interpreter_python = /usr/bin/python3.11  # Python interpreter
roles_path = ansible/core/.roles           # Role location
vault_password_file = vault_pass.txt       # Vault password
log_path = ansible/tmp/logs/ansible-latest.log  # Log output
nocows = True                              # Disable cow ASCII art
deprecation_warnings = false               # Hide deprecation notices

[ssh_connection]
pipelining = True                          # SSH performance optimization
```

### 🔐 vault_pass.txt

Contains the encryption password for Ansible Vault. **IMPORTANT**:

- Add to `.gitignore`
- Share securely with team members
- Never commit to version control

### 📋 server.yml (Encrypted)

Contains sensitive connection details:

```yaml
vault_host: 'your-server.com'
vault_user: 'deploy_user'
vault_port: 22
vault_database_host: 'localhost'
vault_database_name: 'drupal_db'
vault_database_user: 'db_user'
vault_database_password: 'secure_password'
vault_keep_releases: 5
```

**To encrypt:**

```bash
ansible-vault encrypt ansible/core/inventories/stage/group_vars/server.yml
```

**To edit:**

```bash
ansible-vault edit ansible/core/inventories/stage/group_vars/server.yml
```

### 🎯 deploy_vars.yml

Deployment-specific configuration:

```yaml
ansistrano_allow_anonymous_stats: false
ansistrano_keep_releases: 5

drupal_settings:
  - drupal_root: '{{ release_drupal_path }}'
    sites:
      - name: default
        filename: settings.live.php
        settings:
          databases: ...
          extra_parameters: |
            $config['config_split.config_split.live']['status'] = TRUE;
```

<br>

## 🚢 Deployment Workflows

### Initial Stage Deployment (Without Assets)

First-time deployment to staging environment:

```bash
ansible-deploy --stage --install
```

**What happens:**

1. ✅ Creates release directory with timestamp
2. ✅ Syncs code via rsync (excludes `.git`, `node_modules`, etc.)
3. ✅ Creates shared directories (`files`, `private`)
4. ✅ Generates `settings.stage.php` with opdavies role
5. ✅ Imports database from backup
6. ✅ Runs database updates (`drush updatedb`)
7. ✅ Rebuilds cache (`drush cr`)
8. ✅ Sets up HTTP Basic Auth (.htaccess + .htpasswd)
9. ✅ Switches symlink to new release
10. ✅ Enables and updates locale module (translations)

### Initial Stage Deployment (With Assets)

Include file assets in deployment:

```bash
ansible-deploy --stage --install --with-assets
```

**Additional steps:**

- ✅ Syncs `web/sites/default/files` directory
- ✅ Handles deletions (files deleted locally are removed remotely)

### Stage Update Deployment

Deploy incremental changes:

```bash
ansible-deploy --stage --update
```

**What happens:**

1. ✅ Creates new release directory
2. ✅ Syncs only changed files via rsync
3. ✅ Rebuilds cache
4. ✅ Imports configuration (`drush config-import`)
5. ✅ Runs database updates
6. ✅ Switches symlink (zero downtime)
7. ✅ Updates translations
8. ✅ Cleans up old releases (keeps 5 by default)

### Production Deployments

**Initial production deployment:**

```bash
ansible-deploy --live --install --with-assets
```

**Production updates:**

```bash
ansible-deploy --live --update
```

**Key differences from stage:**

- ❌ No HTTP Basic Auth
- ✅ Uses `settings.live.php`
- ✅ Enables live config split
- ✅ More restrictive file permissions

### Cleanup Authentication (Stage Only)

Remove HTTP Basic Auth from staging:

```bash
ansible-deploy --cleanup-auth
```

**Actions:**

- Removes auth lines from `.htaccess`
- Deletes `.htpasswd` file
- Opens site for public testing

<br>

## 🔬 Advanced Features

### Environment-Specific Config Splits

The deployment automatically manages Drupal config splits:

| Environment | Dev Split | Stage Split | Live Split |
| ----------- | --------- | ----------- | ---------- |
| **Stage**   | ❌ FALSE  | ✅ TRUE     | ❌ FALSE   |
| **Live**    | ❌ FALSE  | ❌ FALSE    | ✅ TRUE    |

This is configured in `deploy_vars.yml`:

```yaml
extra_parameters: |
  $config['config_split.config_split.dev']['status'] = FALSE;
  $config['config_split.config_split.stage']['status'] = TRUE;
  $config['config_split.config_split.live']['status'] = FALSE;
```

### Rsync Exclusions

Files and directories excluded from deployment:

```yaml
ansistrano_rsync_extra_params:
  - "--exclude='.ddev/'"
  - "--exclude='.git'"
  - "--exclude='node_modules'"
  - "--exclude='web/sites/default/files'"
  - "--exclude='settings.local.php'"
  - "--exclude='vault_pass.txt'"
```

### Shared Resources

Files that persist across deployments:

```yaml
ansistrano_shared_paths:
  - 'web/sites/default/files' # User uploads
  - 'private' # Private files

ansistrano_shared_files:
  - 'web/sites/default/settings.stage.php'
```

### Translation Management

Automatic translation updates after deployment:

1. Checks if locale module is enabled
2. Enables locale module if needed
3. Checks for available translation updates
4. Downloads and installs updates

### Drush Integration

The deployment uses Drush for all Drupal operations:

```yaml
release_drush_path: '{{ ansistrano_release_path.stdout }}/vendor/bin/drush'
# Example commands executed:
# - drush cr                    # Cache rebuild
# - drush config-import --yes   # Import configuration
# - drush updatedb --yes        # Database updates
# - drush locale:update         # Translation updates
```

<br>

## 🔙 Rollback Process

If a deployment fails or causes issues, quickly rollback to the previous release:

```bash
ansible-playbook -i ansible/core/inventories/stage/inventory.yml ansible/core/rollback.yml
```

**What happens:**

1. ✅ Identifies previous release in `releases/` directory
2. ✅ Switches `current` symlink to previous release
3. ✅ Zero downtime rollback
4. ✅ Previous code and configuration active immediately

**Note**: Rollback only affects code. Database changes are NOT reversed. Consider:

- Taking database backups before major deployments
- Testing rollback procedures in staging first
- Documenting database migration rollback steps

<br>

## 🛠️ Troubleshooting

### Common Issues and Solutions

#### 🔴 Vault File Not Encrypted Error

**Error:**

```
🚨 Error: The file server.yml is not encrypted. Make sure to encrypt the sensitive information.
```

**Solution:**

```bash
ansible-vault encrypt ansible/core/inventories/stage/group_vars/server.yml
```

#### 🔴 SSH Connection Failures

**Error:**

```
fatal: [stage]: UNREACHABLE! => {"changed": false, "msg": "Failed to connect to the host"}
```

**Solutions:**

1. Verify SSH key is added to remote server
2. Test SSH connection manually: `ssh user@server.com`
3. Check `server.yml` for correct host/port/user
4. Ensure firewall allows SSH access

#### 🔴 Drush Command Not Found

**Error:**

```
error: drush: command not found
```

**Solution:**
Verify Drush path in `deploy_vars.yml`:

```yaml
release_drush_path: '{{ ansistrano_release_path.stdout }}/vendor/bin/drush'
```

#### 🔴 Permission Denied Errors

**Error:**

```
fatal: [stage]: FAILED! => {"msg": "Permission denied"}
```

**Solutions:**

1. Verify deploy user has write permissions to deployment directory
2. Check file ownership: `chown -R deploy_user:www-data /var/www/project`
3. Verify SSH key permissions: `chmod 600 ~/.ssh/id_rsa`

#### 🔴 Config Import Failures

**Error:**

```
Configuration import failed
```

**Solutions:**

1. Verify configuration files are committed: `git status config/`
2. Check for configuration conflicts in Drupal admin
3. Manually import on server: `drush config-import --yes`
4. Review config differences: `drush config-status`

### Debug Mode

Enable verbose output for troubleshooting:

```bash
ansible-playbook -i ansible/core/inventories/stage/inventory.yml ansible/core/stage-deploy.yml -vvv
```

### View Deployment Logs

```bash
tail -f ansible/tmp/logs/ansible-latest.log
```

<br>

## 📊 Deployment Hooks

The deployment process includes several hooks for custom tasks:

| Hook                    | When It Runs                       | Use Case                                    |
| ----------------------- | ---------------------------------- | ------------------------------------------- |
| `after_update_code`     | After code sync, before symlinking | Generate settings files, create directories |
| `before_symlink_shared` | Before shared resources linked     | Prepare shared directories                  |
| `before_symlink`        | Before current symlink switched    | Run Drush commands, clear cache             |
| `after_symlink`         | After symlink switch (live code)   | Update translations, post-deploy checks     |
| `before_cleanup`        | Before old releases deleted        | Backup data, final validations              |

<br>

## 🤝 Contributing

This Ansible automation framework is specifically designed for Drupal deployments to Okitup servers, providing a tailored solution for streamlined deployment workflows.

### How to Contribute

We welcome contributions from the community! Here's how you can help:

1. **Fork the Repository**

   ```bash
   git clone https://github.com/webfer/ansible-drupal.git
   cd ansible-drupal
   ```

2. **Create a Feature Branch**

   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make Your Changes**

   - Add new features or fix bugs
   - Update documentation as needed
   - Follow existing code style and conventions

4. **Test Your Changes**

   - Test in staging environment first
   - Verify deployment process works as expected
   - Ensure no breaking changes

5. **Submit a Pull Request**
   - Provide clear description of changes
   - Reference any related issues
   - Include testing evidence

### Areas for Contribution

- 🐛 Bug fixes and error handling improvements
- 📚 Documentation enhancements
- ✨ New deployment features
- 🧪 Testing and validation improvements
- 🎨 Better logging and output formatting
- 🔒 Security enhancements

<br>

## 👥 Maintainers

- **Organization**: [webfer](https://github.com/webfer)
- **Repository**: [drupansible](https://github.com/webfer/drupansible)

<br>

## 📄 License

This project is licensed under the **MIT License**.

### MIT License

```
Copyright (c) 2025 Tothom Web

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

See the [LICENSE](LICENSE) file for full details.

---

<p align="center">
  <strong>Built with ❤️ for the Drupal community</strong><br>
  <a href="https://github.com/webfer/ansible-drupal">View on GitHub</a> •
  <a href="https://github.com/webfer/ansible-drupal/issues">Report Bug</a> •
  <a href="https://github.com/webfer/ansible-drupal/issues">Request Feature</a>
</p>
