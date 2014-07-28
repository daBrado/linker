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

## Use

You can get an overview of the API by just doing a GET at the base API url; e.g. assuming the port configuration above:

    % curl http://localhost:6313/
    LinkerAPI v[VERSION]
    GET get/id
    POST create/?uri=&reusable=

So, to get a link for `http://google.com/` that will be reused, you might do:

    % curl --data-urlencode 'uri=http://google.com/' -d 'reusable=true' http://localhost:6313/
    R2d2

Given it is reusable, you'd get the same link back if asking again:

    % curl --data-urlencode 'uri=http://google.com/' -d 'reusable=true' http://localhost:6313/
    R2d2

However, if you want a unique link, then set `reusable` to `false`:

    % curl --data-urlencode 'uri=http://google.com/' -d 'reusable=false' http://localhost:6313/
    c3Po

    % curl --data-urlencode 'uri=http://google.com/' -d 'reusable=false' http://localhost:6313/
    j3d1

This would be useful for e.g. creating unique links to track click-backs.

To follow the generated link, you would use the app:

    % curl -v http://localhost:6314/R2d2
    [...]
    < HTTP/1.1 302 Found
    < Location: http://google.com/
    < Content-Length: 0

To get a nicer URL, you might use a reverse proxy in nginx or apache.
