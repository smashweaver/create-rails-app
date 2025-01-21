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
  echo "  --no-database       Skip database setup (default: uses selected database)"
  echo "  --css <css>         Specify CSS framework (options: tailwind, sass, postcss; default: uses vanilla css for full-stack, no css for API only)"
  echo "  --test <framework>  Specify testing framework (options: minitest, rspec; default: minitest)"
  echo "  --no-test           Skip test setup (default: uses the selected test framework)"
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
     --no-database)
      NO_DATABASE=true
      shift
      ;;
    --css)
      CSS_FRAMEWORK="$2"
      shift 2
      ;;
    --test)
      TEST_FRAMEWORK="$2"
      shift 2
      ;;
     --no-test)
       NO_TEST=true
       shift
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
DEFAULT_CSS_FRAMEWORK="vanilla"
DEFAULT_TEST_FRAMEWORK="minitest"


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


# Only prompt for database if --no-database is not set
if [[ -z "$DATABASE" ]] && [[ -z "$NO_DATABASE" ]]; then
  DATABASE=$(prompt_for_input "Enter database (postgresql, mysql, sqlite3)" "$DEFAULT_DATABASE")
fi

# Only prompt for CSS framework if not provided via command-line argument
if [[ -z "$CSS_FRAMEWORK" ]] && [[ "$API_ONLY" != true ]]; then
    CSS_FRAMEWORK=$(prompt_for_input "Enter CSS framework (tailwind, sass, postcss)" "$DEFAULT_CSS_FRAMEWORK")
fi


# Only prompt for test framework if --no-test is not set
if [[ -z "$TEST_FRAMEWORK" ]] && [[ -z "$NO_TEST" ]]; then
   TEST_FRAMEWORK=$(prompt_for_input "Enter testing framework (minitest, rspec)" "$DEFAULT_TEST_FRAMEWORK")
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


# Validate database choice if --no-database is not set
if [[ -z "$NO_DATABASE" ]] && [[ ! "$DATABASE" =~ ^(postgresql|mysql|sqlite3)$ ]]; then
  echo "Error: Invalid database choice. Must be one of: postgresql, mysql, sqlite3." >&2
  exit 1
fi

# Validate CSS framework choice
if [[ "$API_ONLY" != true ]] && [[ ! "$CSS_FRAMEWORK" =~ ^(tailwind|sass|postcss|vanilla)$ ]] && [[ -n "$CSS_FRAMEWORK" ]]; then
  echo "Error: Invalid CSS framework choice. Must be one of: tailwind, sass, postcss, or vanilla." >&2
  exit 1
fi


# Validate test framework choice if --no-test is not set
if [[ -z "$NO_TEST" ]] && [[ ! "$TEST_FRAMEWORK" =~ ^(minitest|rspec)$ ]]; then
    echo "Error: Invalid test framework choice. Must be one of: minitest or rspec." >&2
    exit 1
fi

echo "You entered the following:"
echo "Project name: $PROJECT_NAME"
echo "Ruby version: $RUBY_VERSION"
echo "Rails version: $RAILS_VERSION"
if [[ -z "$NO_DATABASE" ]]; then
    echo "Database: $DATABASE"
else
    echo "Database: None (skipped)"
fi
echo "CSS Framework: $CSS_FRAMEWORK"
if [[ -z "$NO_TEST" ]]; then
     echo "Testing Framework: $TEST_FRAMEWORK"
else
     echo "Testing Framework: None (skipped)"
fi
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
RAILS_NEW_COMMAND="rails new $PROJECT_NAME"
if [[ -z "$NO_DATABASE" ]]; then
    RAILS_NEW_COMMAND="$RAILS_NEW_COMMAND --database=$DATABASE"
fi


if [[ "$API_ONLY" == true ]]; then
    RAILS_NEW_COMMAND="$RAILS_NEW_COMMAND --api --no-css"
else
    case "$CSS_FRAMEWORK" in
        "tailwind")
            RAILS_NEW_COMMAND="$RAILS_NEW_COMMAND --css=tailwind"
            ;;
        "sass")
            RAILS_NEW_COMMAND="$RAILS_NEW_COMMAND --css=sass"
            ;;
        "postcss")
            RAILS_NEW_COMMAND="$RAILS_NEW_COMMAND --css=postcss"
            ;;
        "vanilla")
            ;;
    esac
fi

# add the --skip-test option if the user chooses no-test or rspec
if [[ "$NO_TEST" == true ]] || [[ "$TEST_FRAMEWORK" == "rspec" ]] ; then
    RAILS_NEW_COMMAND="$RAILS_NEW_COMMAND --skip-test"
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

# conditionally install RSpec
if [[ "$NO_TEST" != true ]] && [[ "$TEST_FRAMEWORK" == "rspec" ]]; then
    echo "Installing RSpec..."
    if ! bundle add rspec-rails; then
        echo "Error: Failed to install RSpec." >&2
        exit 1
    fi
    if ! rails generate rspec:install; then
      echo "Error: Failed to install rspec" >&2
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
if [[ -z "$NO_DATABASE" ]]; then
    echo "  Database: $DATABASE"
else
     echo "  Database: None (skipped)"
fi
echo "  CSS Framework: $CSS_FRAMEWORK"
if [[ -z "$NO_TEST" ]]; then
     echo "  Testing Framework: $TEST_FRAMEWORK"
else
     echo "  Testing Framework: None (skipped)"
fi
echo "  API-only: ${API_ONLY:-false}"
