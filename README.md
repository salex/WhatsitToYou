## README

This is a demo/code view of some concepts I've toyed with using Ruby on Rails and Stimulus.js. 

Toyed with mean that they probably have no real value as is, I just wanted to try something to prove I could do it!

* Ruby version. 2.7.2
* Rails version. 6.1.3
* System dependencies
  * gem 'slim-rails'
  * gem 'activerecord_where_assoc'
  * stimulus.js, 2.0
  * marked.js
  * hightlight.js

### WhatsitToYou? A `Back to the Past!` version of Whatsit! or Wow! Howd All That Stuff Get In There!

Whatsit! was a command line database program I first saw at the 1978 West Coast Computer Fair. I think I actually bought it and was amazed by what it could do. I had made several attempts over the years to replicate it using RoR, just for fun. It's alway been a learning attempt, not something that I had any real use for. I decided to make another attempt, but going back to original command line interface. 

The terminal/CLI interface is implemented with: 

* Stimulus fetching the inputs/queries from the terminal/console.
* A Rails helper controlling the flow based on Rail.ujs parameters and formating the responses. 
* A Whatsit class to parse the queries, generate the response, and update the database if needed.

While Whatsit is 40+ year old technology, it was nothing more than a classic join table, linking a Subject and a Value with a Tag. Basically in index card application:

* Steve's HomePhone's 888.555.1212

A query `steve` would return all 3Tuples {subject,tag,value} for Steve. `homePhone` would display all homePhone numbers, `Steve's cellPhone's 888.555.1213` would respond with a confirmation prompt to add a new relation (if it was not found).

I could not find that much about Whatsit and lost what little I had. There is a whatsit.md that was part of the documentation that came with the application. There is also a whatsittoyou.md that give a little more information.

The terminal/console interface is almost like a chat or txt message view, except you're chatting with the DB!

### Marked - A rudimentary Stimulus WYSIWYG markdown editor

I wrota a post on dev.to [A rudimentary Stimulus WYSIWYG markdown editor](https://dev.to/salex/a-rudimentary-stimulus-wysiwyg-markdown-editor-105) that describes what this demo does. I didn't get much response but I that I might as will put up a demo.


### Installation

If you just want to look at the code, that's fine. Since I started with Basic/Assembler/FORTRAN over 40 years ago, there is still some Steve Code out there - but I keep trying.

If you want to run the application, it just a standard ROR clone.

* clone the application
* bundle install stuff
* `bin/rails db:reset` should create the db and seed a few tuples for Whatsit.

WhatsitToYou is the root page.  There is a link in the page to look at the marked demo and vise versa.


