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

# Move the contents of TARGET_DIR to DRUPAL_ROOT, excluding the scripts directory
echo "Moving contents from $TARGET_DIR to $DRUPAL_ROOT (excluding scripts directory)"
shopt -s extglob
mv $TARGET_DIR/!(scripts) $DRUPAL_ROOT

# Check if the move was successful
if [ $? -ne 0 ]; then
  echo "Failed to move contents to Drupal root"
  exit 1
fi

# Remove the now empty TARGET_DIR
echo "Cleaning up"
rm -rf $TARGET_DIR

echo "Contents successfully moved to $DRUPAL_ROOT, excluding the scripts directory"
echo "$TARGET_DIR removed"
