# Linker API + Redirecter

Ruby + Rack implementation of a simple generator of unique links to redirect to given pages.

This includes an API for creating and querying the links, and a redirecter app to provide the redirection.

## Install

To install for deployment, you can do:

    RUBY=/path/to/ruby/install
    $RUBY/bin/bundle install --deployment --binstubs --shebang $RUBY/bin/ruby

There is an Upstart config provided, though you'll probably need to adjust the path to the rackup executable.
