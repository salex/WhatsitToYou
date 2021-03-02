### WhatsitToYou

WHATSIT or Wow! Howd All That Stuff Get In There!! was a command line database program I first saw at the 1978 West Coast Computer Fair. I think I actually bought it and was amazed by what it could do. I had made several attempts over the years to replicate it using RoR, but only got so far. It's alway been a learning attempt, not something that had any real use for. I decided to make another attempt, but going back to original command line interface. 

I still remember typing in a command, listening the disk spin and grind and spit out the information. I can't find 
much on it on the web, but found this 
<a href="http://www.moofgroup.com/moof/Roby_Sherman/Adventures_in_Silicon/Entries/2006/12/27_Wow!_Howd_All_That_Stuff_Get_In_There.html">
link</a> that display what the command line interaction looked like. This was 1978 and we were still in COBOL index sequential days. Relational databases only lived on DEC equipment and not very prevalent. I know all the disk crunching and grinding was some custom indexing, but being build in basic (maybe some assembler) on an Apple II or CPM system, was impressive.

It was just one of many "Index Card" type applications of the time. It was followed years later with HyperCard, Frountier and other scripting languages. It was meant for you to store your important information if it conformed to a Subject, Tag, Value type system (a classic join table, with the Tag joining the Subject and Value). It was not meant as a group database, but just someplace to put your stuff.

I meant to try to learn Turbo and Hotwire, but that ended up failing because it was above my head without any real example how to implement it. I just stuck with Stimulus.js. I did a few things that may seem strange. I think when I played with it about 8 years ago I was attempting to use an ancestry type approach, parent, child type stuff. I only use two tables instead of the classic 3, but have three models.

May bare model (without the methods displayed), are as follows:

```ruby
class Subject < ApplicationRecord
  has_many :relations, dependent: :destroy
  has_many :values, through: :relations 
end

class Relation < ApplicationRecord
  belongs_to :subject, class_name: 'Subject', foreign_key: :subject_id
  belongs_to :value, class_name: 'Value', foreign_key: :value_id
end

class Value < Subject
  has_many :relations, class_name: 'Relation', foreign_key: :value_id, dependent: :destroy
  has_many :subjects, through: :relations
end
```

To create a new 3Tuple (always wanted to use the word Tuple after reading the early Relational Database books!) you'd type something like

    Steve's child's Lori

If it didn't find and display the tuple you'd be prompted to confirm you want to create a new Tuple. I you respond with a yes, two subjects would be created (Steve and Lori), and a relation `child` would be created linking the subject_id to Steve and the value_id to Lori. Now if you did another Tuple

    Lori's child's Sarrah

only a value record for Sarrah would be create and a relation record linking them.

The name: is the only attribute in the Subject/Value records. All name's are queried case insensitive using arel match queries.

That's the ancestry side of the application, although I don't thing Ancestry.com has anything to worry about!

As just a index card style application, you'd enter things like:

    Lori's homePhone's 888.555.1212
    Lori's cellPhone's 888.555.1213
    lori's doctor appointment's Tuesday Feb 9th at 8:30AM's

Now if this in not going Back to the Past I don't know what is. The 's are optional for single word attributes but are required for multi-word attributes `home phone`. The What's and Who's commands in the original program are also optional. There are other commands:

* Forget's [subject,ralation,value] word  will delete stuff
* Change's [subject,ralation,value] word  to word change stuff
* Dump's dumps the entire database tuples
* Subject's lists the subject names
* Value's list the value names
* Relation's list the relation names (unique)
* Family's word dumps all relations (the family tree) for the word

On the console/terminal side, the console is just a div that is contains the data-controller-whatsit, and a prompt div that contains in input field that has a stimulus data_action change->search that responds to a onchange event. If changed it sends the value of the input field as a param to the controller's new.js action with Rail.ujs.

The controller initializes a new Whatsit class, stuffs the parameters in the class and calls Whatsit helper method whatsit_actions. The helper is the traffic cop. Based on the parameters:

* It will call a search method with the query
  * If it responds with an array, it will be the results of the query, (Tuples or an Error)
  * If it responds with a string it probably to build a confirm prompt
* It will call a do_something method if parameter has a confirm method and the response was y
  * The input will have a data-action that is a structured string the contains the query it was responding to
* It will always end by creating a new prompt at the end of the console div


### Stimulus Controller
The stimulus controller basically:

* Builds the parameter for the ajax call
* Moves the cursor (caret) to the last input field
* Scrolls the console div to the bottom (by focusing on the last input field)


```javascript
import { Controller } from "stimulus"
import Rails from '@rails/ujs';

export default class extends Controller {

  static targets = ["console",'query','input_node']

  connect() {
    this.moveCursor()
  }

  search(){
    const tuple_node = event.target
    this.query(tuple_node)    
  }

  clear() {
    this.consoleTarget.innerHTML = '<span>WhatsitToYou?&nbsp;</span><input data-whatsit-target="input_node" data-action="change->whatsit#search">'
    this.moveCursor()
  }

  moveCursor(){
    const inpts = this.consoleTarget.querySelectorAll('input')
    const last = inpts[inpts.length -1]
    last.focus()
  }
 
  query(tuple){

    const cls = tuple.className
    const val = tuple.value
    const confirm = tuple.dataset.confirm
    const qry = this.queryTarget.value
    this.queryTarget.value = val
    var url
    if (confirm == undefined) {
      url = `/whatsit/new.js?search=${encodeURI(val)}&action_type=${cls}`
    }else {
      url = `/whatsit/new.js?confirm=${encodeURI(confirm)}&action_type=${cls}&resp=${val}`
    }
    Rails.ajax({
      url: url,
      type: "get",
      success: function(data) {
        const viewer = document.getElementById('query_results')
        // const last_query = document.getElementById('last_query')
        const inputs = viewer.querySelectorAll('input')
        const inputs_length = inputs.length
        // var prev = inputs[inputs_length - 2]
        var last = inputs[inputs_length - 1]
        // prev.value = last_query.value
        last.focus()
      }
    })
  }

}
```

One of my goals on this project (that took a week) was to work on writing better Ruby code. Unfortunately, thought I got better, there is still some Steve code

### That's What's it is.  I don't think it has any life other than for me to experiment with.