#!/bin/bash

function ansible-install() {
  # Variables
  GITHUB_REPO_URL="https://github.com/webfer/ansible-drupal.git"
  PROJECT_ROOT=$(pwd)
  TARGET_DIR="${PROJECT_ROOT}/ansible-drupal"

  # Check if "vendor" and "web" directories exist in PROJECT_ROOT
  if [ -d "${PROJECT_ROOT}/vendor" ] && [ -d "${PROJECT_ROOT}/web" ]; then


    # Check if the Drupal root directory exists
    if [ ! -d "$PROJECT_ROOT" ]; then
      echo "Drupal root directory does not exist: $PROJECT_ROOT"
      exit 1
    fi

    # Clone the repository into the Drupal root directory
    echo "Cloning the repository into $TARGET_DIR"
    git clone $GITHUB_REPO_URL $TARGET_DIR

    # Check if the clone was successful
    if [ $? -ne 0 ]; then
      echo "Failed to clone the repository"
      exit 1
    fi

    echo "Repository successfully cloned into $TARGET_DIR"

    # Move the contents of TARGET_DIR to PROJECT_ROOT, excluding the scripts directory
    echo "Moving contents from $TARGET_DIR to $PROJECT_ROOT (excluding scripts directory)"
    for item in "$TARGET_DIR"/*; do
        # Skip the scripts directory
        if [ "$(basename "$item")" != "scripts" ]; then
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

    echo "Contents successfully moved to $PROJECT_ROOT, excluding the scripts directory"
    echo "$TARGET_DIR removed"


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

# Ensure the function is available in both bash and zsh
if [ -n "$ZSH_VERSION" ]; then
  autoload -Uz ansible-install
fi

function ansible-deploy() {
  # Function to print usage instructions
  function print_usage() {
    echo "Usage: ansible-deploy [--stage | --live] [--install | --update]"
    echo ""
    echo "Options:"
    echo "  --stage    Deploys the site to a STAGE environment using a basic Auth, also, using an .htpasswd file."
    echo "  --live     Deploys the site to a LIVE environment"
    echo "  --install  Deploys the site for the first time, including a complete database import."
    echo "  --update   Deploys the changes made since the last deployment, and updates the database with a configuration import."
    echo ""
    echo "Both the environment and action options are required."
  }

  # Default values for options
  A_OPTION=""
  B_OPTION=""

  # Parse arguments
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --live)
        A_OPTION="live"
        shift
        ;;
      --stage)
        A_OPTION="stage"
        shift
        ;;
      --install)
        B_OPTION="install"
        shift
        ;;
      --update)
        B_OPTION="update"
        shift
        ;;
      *)
        echo "Error: Invalid option $1"
        print_usage
        return 1
        ;;
    esac
  done

  # Check that both options are provided
  if [[ -z "$A_OPTION" || -z "$B_OPTION" ]]; then
    echo "Error: Both the environment and action options are required."
    print_usage
    return 1
  fi

  # Print the selected options
  echo "Selected options: --$A_OPTION --$B_OPTION"

  # Function to ask for confirmation
  ask_for_confirmation() {
    read -p "Are you sure you want to proceed with the FIRST-TIME INSTALLATION? Type 'YES' to continue: " CONFIRMATION
    if [[ "$CONFIRMATION" != "YES" ]]; then
      echo "Operation aborted."
      return 1
    fi
    return 0
  }

  # Conditional logic based on the options
  if [[ "$A_OPTION" == "stage" && "$B_OPTION" == "install" ]]; then
    echo "Executing stage-install path..."
    if ask_for_confirmation; then
      ansible-playbook tools/ansible/deploy.yml --skip-tags 'import_config'
    else
      return 1
    fi
  elif [[ "$A_OPTION" == "stage" && "$B_OPTION" == "update" ]]; then
    echo "Executing stage-update path..."
    ansible-playbook  tools/ansible/deploy.yml --skip-tags 'ideploy, unarchive_db, db_update, ini_theming'
  elif [[ "$A_OPTION" == "live" && "$B_OPTION" == "install" ]]; then
    echo "Executing live-install path..."
    if ask_for_confirmation; then
    # TODO: ansible-playbook command for live-install goes here
    else
      return 1
    fi
  elif [[ "$A_OPTION" == "live" && "$B_OPTION" == "update" ]]; then
    echo "Executing live-update path..."
    # TODO: Add your live-update logic here
  else
    echo "Unexpected combination of options."
    print_usage
    return 1
  fi

  return 0
}

# Ensure the function is available in both bash and zsh
if [ -n "$ZSH_VERSION" ]; then
  autoload -Uz ansible-deploy
fi