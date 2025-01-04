# create-rails-app

A CLI tool to bootstrap Ruby on Rails projects using RVM.

## Prerequisites

- Node.js (version 14 or higher)
- RVM (Ruby Version Manager)

## Usage

```bash
npm create rails-app@latest [options]
```

Or you can run this tool directly using npx:

```bash
npx create-rails-app [options]
```

Or install it globally:

```bash
npm install -g create-rails-app

# Then use it:
create-rails-app [options]
```

### Options

- `--ruby <version>`: Specify Ruby version (default: 3.3.6)
- `--rails <version>`: Specify Rails version (default: 8.0.1)
- `--name <name>`: Specify project name (default: myapp)

### Examples

```bash
npm create rails-app@latest
npm create rails-app@latest --ruby 3.2.0 --rails 7.1.0 --name my-rails-app

# Or using npx (no installation required)
npx create-rails-app
npx create-rails-app --ruby 3.2.0 --rails 7.1.0 --name my-rails-app

# Or if installed globally
create-rails-app
create-rails-app --ruby 3.2.0 --rails 7.1.0 --name my-rails-app
```

## Features

- Automatically installs specified Ruby version using RVM
- Creates a new RVM gemset for project isolation
- Installs Rails with the specified version
- Sets up `.ruby-version` and `.ruby-gemset` files
- Interactive prompts with default values

## Requirements

- Unix-like operating system (Linux, macOS)
- RVM must be installed and properly configured
- Node.js 14 or higher

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
