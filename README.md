# kindle_util

A utility for performing bulk actions against your kindle library, most notably to allow resetting the "last page read" for all your kindle books.

## Installation

    $ gem install kindle_util

And then to reset "last page read" for all books, execute:

    $ kindle_util -a reset_lpr

## Usage

    $ kindle_util -h
    Usage:
        kindle_util [OPTIONS] [FILTER] ...
    
    Parameters:
        [FILTER] ...                  The filters to limit the items acted upon.
                                      These should be given as 'field_name=value',
                                      where value is treated as a regex.  Perform
                                      the list action with --debug to see all
                                      possible fields
    
    Options:
        -u, --username USERNAME       Your amazon username/email
        -p, --password PASSWORD       Your amazon password
        -a, --action ACTION           The action to perform on all the selected
                                      books, where action is one of:
                                        list: Display the selected items
                                        reset_lpr: Reset the last page read marker
                                        (default: "list")
        -c, --[no-]cache              Cache (or not) the full list of purchased
                                      items (default: true)
        -d, --debug                   More verbose logging
        -v, --version                 Show version and exit
        -h, --help                    print help

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
