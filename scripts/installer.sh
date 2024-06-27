
#!/bin/bash

# Variables
GITHUB_REPO_URL="https://github.com/webfer/ansible-drupal.git"
DRUPAL_ROOT=$(pwd)
TARGET_DIR="${DRUPAL_ROOT}/ansible-drupal"

# Ensure the script is executed with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Check if the Drupal root directory exists
if [ ! -d "$DRUPAL_ROOT" ]; then
  echo "Drupal root directory does not exist: $DRUPAL_ROOT"
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
