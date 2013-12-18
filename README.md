# Linker API + Redirecter

Ruby + Rack implementation of a simple generator of unique links to redirect to given pages.

This includes an API for creating and querying the links, and a redirecter app to provide the redirection.

## Install

To install for deployment, you can do:

    RUBY=/path/to/ruby
    $RUBY/bin/gem install bundler -i vendor/gem -n bin
    bin/bundle install --deployment --binstubs --shebang $RUBY/bin/ruby

Then to run, you can use the installed rackup executable, e.g.:

    bin/rackup -E production -p 6313 api.ru
    bin/rackup -E production -p 6314 redirect.ru

There is an Upstart config provided, though you'll probably need to adjust the path to the rackup executable.
