#!/bin/bash

function ansible-install() {
  # Variables
  GITHUB_REPO_URL="https://github.com/webfer/ansible-drupal.git"
  PROJECT_ROOT=$(pwd)
  TARGET_DIR="${PROJECT_ROOT}/tmp/ansible-drupal"

  # Check if "vendor" and "web" directories exist in PROJECT_ROOT
  if [ -d "${PROJECT_ROOT}/vendor" ] && [ -d "${PROJECT_ROOT}/web" ]; then

    # Clone the repository into the TMP directory
    echo "Cloning the repository into $TARGET_DIR"
    git clone $GITHUB_REPO_URL $TARGET_DIR

    # Check if the clone was successful
    if [ $? -ne 0 ]; then
      echo "Failed to clone the repository"
      exit 1
    fi

    echo "Repository successfully cloned into $TARGET_DIR"

    # Move the contents of TARGET_DIR to PROJECT_ROOT.
    echo "Moving contents from $TARGET_DIR to $PROJECT_ROOT"
    # List of files and directories to include
    INCLUDE=("ansible.cfg" "tools" "vault_pass.txt")

    # Move the contents including only the specified files and directories
    for item in "$TARGET_DIR"/*; do
        basename_item=$(basename "$item")
        if [[ " ${INCLUDE[@]} " =~ " ${basename_item} " ]]; then
            mv "$item" "$PROJECT_ROOT"
        fi
    done

    # Check if the move was successful
    if [ $? -ne 0 ]; then
      echo "Failed to move contents to Drupal root"
      exit 1
    fi

    # Remove the now empty TARGET_DIR
    echo "Cleaning up"
    rm -rf $TARGET_DIR

    echo "$TARGET_DIR removed"
    echo "Contents successfully moved to $PROJECT_ROOT, including: $INCLUDE"


  else
    if [ ! -d "${PROJECT_ROOT}/vendor" ]; then
      echo "The 'vendor' directory is missing in ${PROJECT_ROOT}. Make sure ${PROJECT_ROOT} is a Drupal project before running this command!"
    fi
    if [ ! -d "${PROJECT_ROOT}/web" ]; then
      echo "The 'web' directory is missing in ${PROJECT_ROOT}. Make sure ${PROJECT_ROOT} is a Drupal project before running this command!"
    fi
  fi

  # Explicit exit to ensure the function exits properly
  return 0
}


function ansible-deploy() {
  # Function to print usage instructions
  function print_usage() {
    echo "Usage: ansible-deploy [--stage | -s | --live | -l] [--install | -i | --update | -u] [--cleanup-auth | -c] [--with-assets | -a]"
    echo ""
    echo "Options:"
    echo "  --stage,          -s      Deploys the site to a STAGE environment using a basic Auth, also, using an .htpasswd file."
    echo "  --live,           -l      Deploys the site to a LIVE environment"
    echo "  --install,        -i      Deploys the site for the first time, including a complete database import."
    echo "  --update,         -u      Deploys the changes made since the last deployment, and updates the database with a configuration import."
    echo "  --cleanup-auth,   -c      Removes the authentication lines from .htaccess and deletes the .htpasswd file."
    echo "  --with-assets,    -a      (Optional) Deploys and synchronizes the assets from the local machine to the remote server. This option ensures that files deleted locally are also deleted on the remote server."
    echo ""
    echo "Both the environment and action options are required unless using --cleanup-auth. The --with-assets option is optional."
  }

  # Default values for options
  A_OPTION=""
  B_OPTION=""
  C_OPTION=""
  D_OPTION=""

  # Parse arguments
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --live|-l)
        A_OPTION="live"
        shift
        ;;
      --stage|-s)
        A_OPTION="stage"
        shift
        ;;
      --install|-i)
        B_OPTION="install"
        shift
        ;;
      --update|-u)
        B_OPTION="update"
        shift
        ;;
      --with-assets|-a)
        C_OPTION="with-assets"
        shift
        ;;
      --cleanup-auth|-c)
        D_OPTION="cleanup-auth"
        shift
        ;;
      *)
        echo "Error: Invalid option $1"
        print_usage
        return 1
        ;;
    esac
  done

  # Check that the environment and action options are provided unless using --cleanup-auth
  if [[ -z "$A_OPTION" || -z "$B_OPTION" ]] && [[ -z "$D_OPTION" ]]; then
    echo "Error: Both the environment and action options are required unless using --cleanup-auth."
    print_usage
    return 1
  fi

  # Print the selected options
  echo "Selected options: --$A_OPTION --$B_OPTION ${C_OPTION:+--$C_OPTION} ${D_OPTION:+--$D_OPTION}"

  # Set the PROJECT_ROOT variable
  PROJECT_ROOT=$(pwd)

  # Define the yellow color
  YELLOW='\033[1;33m'
  # Reset color
  NC='\033[0m'

  # Set the PROVISION_VAULT_FILE based on the environment
  if [[ "$A_OPTION" == "stage" ]]; then
    PROVISION_VAULT_FILE="${PROJECT_ROOT}/tools/ansible/inventories/stage/group_vars/server.yml"
  elif [[ "$A_OPTION" == "live" ]]; then
    PROVISION_VAULT_FILE="${PROJECT_ROOT}/tools/ansible/inventories/production/group_vars/server.yml"
  fi

  # Check if the correct provision_vault file exists and is encrypted
  if [[ ! -f "$PROVISION_VAULT_FILE" ]]; then
    echo "Error: The file $PROVISION_VAULT_FILE does not exist."
    return 1
  elif ! grep -q "\$ANSIBLE_VAULT;" "$PROVISION_VAULT_FILE"; then
    echo "${YELLOW}🚨 Error: The file $PROVISION_VAULT_FILE is not encrypted. Make sure to encrypt the sensitive information.${NC}"
    return 1
  fi

  # Function to ask for confirmation
  ask_for_confirmation() {
    echo -e "${YELLOW}🚨 Are you sure you want to proceed with the FIRST-TIME installation? Be careful! This action cannot be undone and will overwrite your database. (yes/no):${NC}"
    read CONFIRMATION
    if [[ "$CONFIRMATION" != "yes" ]]; then
      echo "Operation aborted."
      return 1
    fi
    return 0
  }

  # Determine the action based on the options
  if [[ "$D_OPTION" == "cleanup-auth" ]]; then
    echo "Executing cleanup-auth path..."
    ansible-playbook -i tools/ansible/inventories/stage/inventory.yml tools/ansible/stage-deploy.yml --tags 'auth_cleanup'
  else
    case "${A_OPTION}-${B_OPTION}" in
      stage-install)
        echo "Executing stage-install path..."
        if ask_for_confirmation; then
          if [[ "$C_OPTION" == "with-assets" ]]; then
            echo "Including with-assets in deployment..."
            ansible-playbook -i tools/ansible/inventories/stage/inventory.yml tools/ansible/stage-deploy.yml --skip-tags 'import_config, clean_up, auth_cleanup'
          else
            ansible-playbook -i tools/ansible/inventories/stage/inventory.yml tools/ansible/stage-deploy.yml --skip-tags 'import_config, deploy_assets, clean_up, auth_cleanup'
          fi
        else
          return 1
        fi
        ;;
      stage-update)
        echo "Executing stage-update path..."
        ansible-playbook -i tools/ansible/inventories/stage/inventory.yml tools/ansible/stage-deploy.yml --skip-tags 'deploy, unarchive_db, db_update, deploy_assets, auth_cleanup'
        ;;
      live-install)
        echo "Executing live-install path..."
        if ask_for_confirmation; then
          if [[ "$C_OPTION" == "with-assets" ]]; then
            echo "Including with-assets in deployment..."
            ansible-playbook -i tools/ansible/inventories/production/inventory.yml tools/ansible/live-deploy.yml --skip-tags 'import_config, clean_up, auth'
          else
            ansible-playbook -i tools/ansible/inventories/production/inventory.yml tools/ansible/live-deploy.yml --skip-tags 'import_config, deploy_assets, clean_up, auth'
          fi
        else
          return 1
        fi
        ;;
      live-update)
        echo "Executing live-update path..."
        ansible-playbook -i tools/ansible/inventories/production/inventory.yml tools/ansible/live-deploy.yml --skip-tags 'deploy, unarchive_db, db_update, deploy_assets, auth'
        ;;
      *)
        echo "Unexpected combination of options."
        print_usage
        return 1
        ;;
    esac
  fi

  return 0
}


# Define the line to add
LINE="source ~/.bin/ansible-installer.sh"

# Define the target files
ZSHRC_FILE="$HOME/.zshrc"
BASHRC_FILE="$HOME/.bashrc"

# Function to insert the line at the top of the file if not already present
insert_line_if_not_present() {
    local file=$1
    if [ -f "$file" ]; then
        if ! grep -Fxq "$LINE" "$file"; then
            echo -e "$LINE\n$(cat $file)" > $file
            echo "Added the line to $file"
        else
            echo "The line is already present in $file"
        fi
    fi
}

# Function to check for .zshrc and .bashrc and insert the line if they exist
autorun() {
    if [ -f "$ZSHRC_FILE" ]; then
        insert_line_if_not_present "$ZSHRC_FILE"
        source "$ZSHRC_FILE"
    elif [ -f "$BASHRC_FILE" ]; then
        insert_line_if_not_present "$BASHRC_FILE"
        source "$BASHRC_FILE"
    else
        echo "Neither .zshrc nor .bashrc exists."
    fi
}


# Ensure the function is available in both bash and zsh
if [ -n "$ZSH_VERSION" ]; then
  autoload -Uz ansible-deploy
fi