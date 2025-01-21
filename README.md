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

- `--ruby <version>`: Specify Ruby version (default: 3.3.7)
- `--rails <version>`: Specify Rails version (default: 8.0.1)
- `--name <name>`: Specify project name (default: myapp)
- `--database <db>`: Specify database (options: postgresql, mysql, sqlite3; default: postgresql)
- `--no-database`: Skip database setup. If used, the application will use the default in-memory SQLite. (default: uses selected database or prompts for one).
- `--css <css>`: Specify CSS framework (options: tailwind, sass, postcss, no-css; default: no-css). When using `postcss`, this configures your application to use the `cssbundling-rails` gem for CSS bundling.
- `--test <framework>`: Specify testing framework (options: minitest, rspec; default: minitest)
- `--no-test`: Skip test setup. If used, no testing framework will be set up. (default: uses the selected test framework or prompts for one).
- `--api`: Create an API-only Rails project (default: full-stack)
- `--help`: Show this help message

### Examples

```bash
npm create rails-app@latest
npm create rails-app@latest -- --ruby 3.2.0 --rails 7.1.0 --name my-rails-app
npm create rails-app@latest -- --api --database postgresql
npm create rails-app@latest -- --database mysql
npm create rails-app@latest -- --no-database
npm create rails-app@latest -- --css tailwind --name my-tailwind-app
npm create rails-app@latest -- --css sass --name my-sass-app
npm create rails-app@latest -- --css postcss --name my-postcss-app
npm create rails-app@latest -- --css no-css --name my-no-css-app
npm create rails-app@latest -- --test minitest
npm create rails-app@latest -- --test rspec
npm create rails-app@latest -- --no-test

# Or using npx (no installation required)
npx create-rails-app
npx create-rails-app --ruby 3.2.0 --rails 7.1.0 --name my-rails-app
npx create-rails-app --api --database sqlite3
npx create-rails-app --no-database
npx create-rails-app --css tailwind --name my-tailwind-app
npx create-rails-app --css sass --name my-sass-app
npx create-rails-app --css postcss --name my-postcss-app
npx create-rails-app --css no-css --name my-no-css-app
npx create-rails-app --test minitest
npx create-rails-app --test rspec
npx create-rails-app --no-test

# Or if installed globally
create-rails-app
create-rails-app --ruby 3.2.0 --rails 7.1.0 --name my-rails-app
create-rails-app --api --database postgresql
create-rails-app --no-database
create-rails-app --css tailwind --name my-tailwind-app
create-rails-app --css sass --name my-sass-app
create-rails-app --css postcss --name my-postcss-app
create-rails-app --css no-css --name my-no-css-app
create-rails-app --test minitest
create-rails-app --test rspec
create-rails-app --no-test
```

## Features

- Automatically installs specified Ruby version using RVM
- Creates a new RVM gemset for project isolation
- Installs Rails with the specified version
- Sets up `.ruby-version` and `.ruby-gemset` files
- Interactive prompts with default values
- Supports multiple CSS framework options: `tailwind`, `sass`, `postcss`, `no-css`
- When using `postcss` this tool configures your application to use the `cssbundling-rails` gem for CSS bundling.
- Supports testing framework selection with options `minitest`, `rspec`.
- Supports skipping the database setup with the `--no-database` flag.
- Supports skipping test setup with the `--no-test` flag.
- Supports API-only mode with `--api` flag

## Requirements

- Unix-like operating system (Linux, macOS)
- RVM must be installed and properly configured
- Node.js 14 or higher

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
