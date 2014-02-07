# Linker API and Application

Ruby + Rack implementation of a simple generator of unique links to redirect to given URIs.

This includes an API for creating and querying the links, and an application to provide the redirection.

## Install

To install for deployment, you can do:

    RUBY=/path/to/ruby
    $RUBY/bin/bundle install --deployment --binstubs --shebang $RUBY/bin/ruby

Then to run, you can use the installed rackup executable, e.g.:

    bin/rackup -E production -p 6313 linkerapi.ru
    bin/rackup -E production -p 6314 linkerapp.ru

Or if you prefer to use Puma and Unix domain sockets:

    bin/puma -e production -b unix://./var/linkerapi.sock linkerapi.ru
    bin/puma -e production -b unix://./var/linkerapp.sock linkerapp.ru

There is an Upstart config provided for the latter method, though you'll probably need to adjust the path to linker and the user/group to run as.
