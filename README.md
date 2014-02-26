# agig

[![Gem Version](https://badge.fury.io/rb/atig.png)](https://rubygems.org/gems/atig) [![Code Climate](https://codeclimate.com/github/hsbt/agig.png)](https://codeclimate.com/github/hsbt/agig) [![Build Status](https://travis-ci.org/hsbt/agig.png)](https://travis-ci.org/hsbt/agig)

Agig is another Github IRC Gateway, forked cho45's [gig.rb](https://github.com/cho45/net-irc/blob/master/examples/gig.rb)

Modified from original gig.rb:

 * use [Octokit](http://rubygems.org/gems/octokit) instead of libxml-ruby and net/https
 * create new channel, it includes user activities.

## Installation and Usage

    $ gem install agig
    $ agig -d

    # setting a retrieving interval second.
    $ agig -i 60

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Contributor

 * @morygonzalez
 * @taketin
 * @mizoR
 * @ykzts
