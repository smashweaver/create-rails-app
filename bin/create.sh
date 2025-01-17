#!/bin/bash
source "$HOME/.rvm/scripts/rvm"

# Exit if RVM is not installed
if ! command -v rvm &> /dev/null; then
  echo "Error: RVM is not installed. Please install RVM first." >&2
  exit 1
fi

# Function to display help message
show_help() {
  echo "Usage: create-rails-app [options]"
  echo "Options:"
  echo "  --ruby <version>    Specify Ruby version (default: 3.3.7)"
  echo "  --rails <version>   Specify Rails version (default: 8.0.1)"
  echo "  --name <name>       Specify project name (default: myapp)"
  echo "  --database <db>     Specify database (options: postgresql, mysql, sqlite3; default: postgresql)"
  echo "  --css <css>         Specify CSS framework (options: css, tailwind, sass, bootstrap, no-css, css-zero; default: css)"
  echo "  --api               Create an API-only Rails project (default: full-stack)"
  echo "  --help              Show this help message"
  exit 0
}

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
    --database)
      DATABASE="$2"
      shift 2
      ;;
    --css)
      CSS_FRAMEWORK="$2"
      shift 2
      ;;
    --api)
      API_ONLY=true
      shift
      ;;
    --help)
      show_help
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

# Set default values if not provided by arguments
DEFAULT_RUBY_VERSION="3.3.7"
DEFAULT_RAILS_VERSION="8.0.1"
DEFAULT_PROJECT_NAME="myapp"
DEFAULT_DATABASE="postgresql"
DEFAULT_CSS_FRAMEWORK="css"

# Only prompt for Ruby version if not provided via command-line argument
if [[ -z "$RUBY_VERSION" ]]; then
  RUBY_VERSION=$(prompt_for_input "Enter Ruby version" "$DEFAULT_RUBY_VERSION")
fi

# Remove 'ruby-' prefix if present
RUBY_VERSION="${RUBY_VERSION//ruby-/}"

# Only prompt for Rails version if not provided via command-line argument
if [[ -z "$RAILS_VERSION" ]]; then
  RAILS_VERSION=$(prompt_for_input "Enter Rails version" "$DEFAULT_RAILS_VERSION")
fi

# Only prompt for project name if not provided via command-line argument
if [[ -z "$PROJECT_NAME" ]]; then
  PROJECT_NAME=$(prompt_for_input "Enter project name" "$DEFAULT_PROJECT_NAME")
fi

# Only prompt for database if not provided via command-line argument
if [[ -z "$DATABASE" ]]; then
  DATABASE=$(prompt_for_input "Enter database (postgresql, mysql, sqlite3)" "$DEFAULT_DATABASE")
fi

# Only prompt for CSS framework if not provided via command-line argument
if [[ -z "$CSS_FRAMEWORK" ]]; then
   CSS_FRAMEWORK=$(prompt_for_input "Enter CSS framework (css, tailwind, sass, bootstrap, no-css, css-zero)" "$DEFAULT_CSS_FRAMEWORK")
fi


# Validate project name
if [[ ! "$PROJECT_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
  echo "Error: Invalid project name. Only letters, numbers, hyphens, and underscores are allowed." >&2
  exit 1
fi

# Check if project directory already exists
if [[ -d "$PROJECT_NAME" ]]; then
  echo "Error: Directory '$PROJECT_NAME' already exists. Please choose a different project name." >&2
  exit 1
fi

# Validate database choice
if [[ ! "$DATABASE" =~ ^(postgresql|mysql|sqlite3)$ ]]; then
  echo "Error: Invalid database choice. Must be one of: postgresql, mysql, sqlite3." >&2
  exit 1
fi

# Validate CSS framework choice
if [[ ! "$CSS_FRAMEWORK" =~ ^(css|tailwind|sass|bootstrap|no-css|css-zero)$ ]]; then
  echo "Error: Invalid CSS framework choice. Must be one of: css, tailwind, sass, bootstrap, no-css, or css-zero." >&2
  exit 1
fi

echo "You entered the following:"
echo "Project name: $PROJECT_NAME"
echo "Ruby version: $RUBY_VERSION"
echo "Rails version: $RAILS_VERSION"
echo "Database: $DATABASE"
echo "CSS Framework: $CSS_FRAMEWORK"
echo "API-only: ${API_ONLY:-false}"

# Regular expressions for version validation
VERSION_REGEX="^[0-9]+(\\.[0-9]+)*$"

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
echo "Installing Ruby $RUBY_VERSION..."
if ! rvm install "$RUBY_VERSION"; then
  echo "Error: Failed to install Ruby $RUBY_VERSION." >&2
  exit 1
fi

# Create and use the gemset for the project
echo "Creating gemset '$PROJECT_NAME' for Ruby $RUBY_VERSION..."
if ! rvm use "$RUBY_VERSION@$PROJECT_NAME" --create; then
  echo "Error: Failed to create or use gemset '$PROJECT_NAME'." >&2
  exit 1
fi

# Install Rails with the specified version
echo "Installing Rails $RAILS_VERSION..."
if ! gem install rails -v "$RAILS_VERSION"; then
  echo "Error: Failed to install Rails $RAILS_VERSION." >&2
  exit 1
fi

# Build the rails new command
RAILS_NEW_COMMAND="rails new $PROJECT_NAME --database=$DATABASE"
if [[ "$API_ONLY" == true ]]; then
  RAILS_NEW_COMMAND="$RAILS_NEW_COMMAND --api"
else
  case "$CSS_FRAMEWORK" in
    "tailwind")
      RAILS_NEW_COMMAND="$RAILS_NEW_COMMAND --css=tailwind"
      ;;
    "sass")
      RAILS_NEW_COMMAND="$RAILS_NEW_COMMAND --css=sass"
      ;;
    "bootstrap")
      RAILS_NEW_COMMAND="$RAILS_NEW_COMMAND --css=bootstrap"
      ;;
    "no-css")
      RAILS_NEW_COMMAND="$RAILS_NEW_COMMAND --no-css"
      ;;
    "css")
      RAILS_NEW_COMMAND="$RAILS_NEW_COMMAND --css=css"
      ;;
    "css-zero")
      RAILS_NEW_COMMAND="$RAILS_NEW_COMMAND --no-css"
      ;;
  esac
fi

# Create Rails project
echo "Creating Rails project '$PROJECT_NAME'..."
if ! eval "$RAILS_NEW_COMMAND"; then
  echo "Error: Failed to create Rails project '$PROJECT_NAME'." >&2
  exit 1
fi

cd "$PROJECT_NAME"

# Install missing gems
echo "Installing missing gems..."
if ! bundle install; then
  echo "Error: Failed to install missing gems. Please check your Gemfile and try again." >&2
  exit 1
fi

# If css-zero is selected, install it
if [[ "$CSS_FRAMEWORK" == "css-zero" ]]; then
  echo "Installing css-zero gem..."
  if ! bundle add css-zero; then
     echo "Error: Failed to add css-zero gem" >&2
     exit 1
  fi
  if ! bundle install; then
     echo "Error: Failed to install missing gems after adding css-zero gem" >&2
     exit 1
  fi
  echo "Running css-zero install generator..."
  if ! bin/rails generate css_zero:install; then
    echo "Error: Failed to install css-zero" >&2
    exit 1
  fi
fi


# Create .ruby-version file
echo "$RUBY_VERSION" > .ruby-version

# Create .ruby-gemset file
echo "$PROJECT_NAME" > .ruby-gemset

# Print success message
echo "Rails project '$PROJECT_NAME' created with:"
echo "  Ruby version: $RUBY_VERSION"
echo "  Rails version: $RAILS_VERSION"
echo "  Database: $DATABASE"
echo "  CSS Framework: $CSS_FRAMEWORK"
echo "  API-only: ${API_ONLY:-false}"
