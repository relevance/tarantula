# Tarantula DSL-based API examples

I'm planning to change the Tarantula configuration API to be more
Ruby-ish, declarative and DSL-like.
This document contains examples of what I'm aiming for, 
as a record of ideas and for discussion.

**This is not a promise to implement all of these features.**
I think all of these feature ideas would be useful, but I already know
some of them will be very costly and difficult to implement.
I'm including them all here because I want to come up with an API
syntax and style that will accommodate a lot of different things.

I don't yet know whether I'll maintain the current association with
test cases; it seems that it might be better to have a standalone
`tarantula_config.rb` file or something like that, with a custom 
Tarantula runner that doesn't depend on test/unit or RSpec.

## Basic crawl, starting from '/'

    Tarantula.crawl
    
## Basic crawl, starting from '/' and '/admin'

    Tarantula.crawl('both') do |t|
      t.root_page '/'
      t.root_page '/admin'
    end
    
## Crawl with the Tidy handler

    # the operand to the crawl method, if supplied, will be used
    # as the tab label in the report.
    Tarantula.crawl("tidy") do |t|
      t.add_handler :tidy
    end
    
## Reorder requests on the queue

This is necessary to fix [this bug](http://github.com/relevance/tarantula/issues#issue/3)

    Tarantula.crawl do |t|
      # Treat the following controllers as "resourceful",
      # reordering appropriately (see my comment on
      # <http://github.com/relevance/tarantula/issues#issue/3>)
      t.resources 'post', 'comment'
      
      # For the 'news' controller, order the actions this way:
      t.reorder_for 'news', :actions => %w{show read unread mark_read}
      
      # For the 'history' controller, supply a comparison function:
      t.reorder_for 'history', :compare => lambda{|x, y| ... }
    end
    
(Unlike most of the declarations in this example document, these will
need to be reusable across multiple crawl blocks somehow.)

## Selectively allowing errors

    Tarantula.crawl("ignoring not-found users") do |t|
      t.allow_errors :not_found, %r{/users/\d+/}
      # or
      t.allow_errors :not_found, :controller => 'users', :action => 'show'
    end

## Attacks

    Tarantula.crawl("attacks") do |t|
      t.attack :xss, :input => "<script>gotcha!</script>", :output => :input
      t.attack :sql_injection, :input => "a'; DROP TABLE posts;"
      t.times_to_crawl 2
    end
    
We should have prepackaged attack suites that understand various techniques.

    Tarantula.crawl("xss suite") do |t|
      t.attack :xss, :suite => 'standard'
    end
    
    Tarantula.crawl("sql injection suite") do |t|
      t.attack :sql_injection, :suite => 'standard'
    end
    
## Timeout

    Tarantula.crawl do |t|
      t.times_to_crawl 2
      t.stop_after 2.minutes
    end
    
## Fuzzing

    Tarantula.crawl do |t|
      # :valid input uses SQL types and knowledge of model validations
      # to attempt to generate valid input.  You can override the defaults.
      t.fuzz_with :valid_input do |f|
        f.fuzz(Post, :title) { random_string(1..40) }
        f.fuzz(Person, :phone) { random_string("%03d-%03d-%04d") }
      end
      
      # The point of fuzzing is to keep trying a lot of things to 
      # see if you can find breakage.
      t.crawl_for 45.minutes
    end
    
    Tarantula.crawl do |t|
      # :typed_input uses SQL types to generate "reasonable" but probably
      # invalid input (e.g., numeric fields will get strings of digits, 
      # but they'll be too large or negative; date fields will get dates,
      # but very far in the past or future; string fields will get very 
      # large strings.)
      t.fuzz_with :typed_input
      t.crawl_for 30.minutes
    end
    
    Tarantula.crawl do |t|
      # :random_input just plugs in random strings everywhere.
      t.fuzz_with :random_input
      t.crawl_for 2.hours
    end
