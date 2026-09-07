# ft_greet

Little greeter for 42 in your terminal

## Requirements

- jq
- curl

## Usage

### Create an app in the intra

Go to your settings click on API and register a new app.

Fill the name, description, select "Various" as the appliation type and put any url in the redirection URI field as we won't use it.

Nothing else is required for the greeter.

### Add your API credentials

Edit the corresponding script for your system. Put your app UID in the APP_ID variable and the app secret in the APP_SECRET variable.

### Install

Run this command

```bash
$ mkdir -p ~/.local/bin; cp ./ft_greet_$(uname).sh ~/.local/bin/ft_greet.sh; chmod +x ~/.local/bin/ft_greet.sh
```

You can now call the script from your shell config file and optionally alias `clear` to call the script too.

For example with .bashrc

```bash
~/.local/bin/ft_greet.sh
alias clear="clear; ~/.local/bin/ft_greet.sh"
```

### Using the greeter on your personal PC

Override the USER variable and put your intra login instead before calling the script as the script

```bash
USER=tchampio ./ft_greet.sh
```

## Resources

[printf colors](https://gist.github.com/WestleyK/dc71766b3ce28bb31be54b9ab7709082)

## AI usage

The JQ command for the logtime
