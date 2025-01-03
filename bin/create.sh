#!/bin/bash
source "$HOME/.rvm/scripts/rvm"

# Exit if RVM is not installed
if ! command -v rvm &> /dev/null; then
  echo "Error: RVM is not installed. Please install RVM first." >&2
  exit 1
fi

# Function to prompt for input with a default value
prompt_for_input() {
  local prompt="$1"
  local default="$2"
  local result

  # Display prompt with default value
  read -r -p "$prompt [$default]: " result
  # Use default if no input is provided
  echo "${result:-$default}"
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --ruby)
      RUBY_VERSION="$2"
      shift 2
      ;;
    --rails)
      RAILS_VERSION="$2"
      shift 2
      ;;
    --name)
      PROJECT_NAME="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

# Set default values if not provided by arguments
DEFAULT_RUBY_VERSION="3.3.6"
DEFAULT_RAILS_VERSION="8.0.1"
DEFAULT_PROJECT_NAME="myapp"

# Prompt for Ruby version even if it's provided as a command-line argument
RUBY_VERSION=$(prompt_for_input "Enter Ruby version" "$DEFAULT_RUBY_VERSION")
RAILS_VERSION=${RAILS_VERSION:-$(prompt_for_input "Enter Rails version" "$DEFAULT_RAILS_VERSION")}
PROJECT_NAME=${PROJECT_NAME:-$(prompt_for_input "Enter project name" "$DEFAULT_PROJECT_NAME")}

echo "You entered the following:"
echo "Project name: $PROJECT_NAME"
echo "Ruby version: $RUBY_VERSION"
echo "Rails version: $RAILS_VERSION"


# Regular expressions for version validation
VERSION_REGEX="^[0-9]+(\\.[0-9]+)*$"
# VERSION_REGEX="^[0-9]+(?:\.[0-9]+)*$"

# Validate Ruby version
if [[ ! "$RUBY_VERSION" =~ $VERSION_REGEX ]]; then
  echo "Error: Invalid Ruby version format. Expected format: 'X.Y.Z' (e.g., 3.3.6)." >&2
  exit 1
fi

# Validate Rails version
if [[ ! "$RAILS_VERSION" =~ $VERSION_REGEX ]]; then
  echo "Error: Invalid Rails version format. Expected format: 'X.Y.Z' (e.g., 8.0.0)." >&2
  exit 1
fi

# Install the specified Ruby version
rvm install "$RUBY_VERSION"

# Use the specified Ruby version
rvm use "$RUBY_VERSION"

# Create .ruby-version file
echo "$RUBY_VERSION" > .ruby-version

# Create a gemset for the project
rvm gemset create "$PROJECT_NAME"

# Create .ruby-gemset file
echo "$PROJECT_NAME" > .ruby-gemset

# Use the gemset
rvm gemset use "$RUBY_VERSION@$PROJECT_NAME"
# rvm use $(cat .ruby-version)@$(cat .ruby-gemset)

bash

# Install Rails with the specified version
gem install rails -v "$RAILS_VERSION"

# Print success message
rails new "$PROJECT_NAME"
echo "Rails project '$PROJECT_NAME' created with Ruby $RUBY_VERSION and Rails $RAILS_VERSION"
