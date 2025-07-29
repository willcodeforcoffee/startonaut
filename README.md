# Startonaut

A new start page for Internauts!

## Getting Started

This app is designed to work under the [Mise en Place](https://mise.jdx.dev/lang/ruby.html)
version manager.

### Setup `.env` File

Follow these steps to setup the `.env` file:

1. Copy the example file: `cp .env.example .env`
2. Use a text editor to edit the example values to the values for your environment.

The example file has all the values documented.

### Setting up Kamal for Deployment

[Kamal](https://kamal-deploy.org/) is a great way to deploy Startonaut. Kamal relies on
a file in `config/deploy.yml`. Because this is open source and to make self-hosting
easier there is a [rake](https://ruby.github.io/rake/) task to generate the deploy
file for your environment.
You will need to set all the values in `.env` first.
`bin/rails deploy:generate_config` will generate the config file.

You can use `rails deploy:show_env_vars` to check which values will be used.
