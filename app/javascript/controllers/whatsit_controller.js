import { Controller } from "stimulus"
import Rails from '@rails/ujs';

export default class extends Controller {

  static targets = ["console",'query','input_node']

  connect() {
    this.moveCursor()
     console.log("connected")
  }

  search(){
    if (event.key == 'Enter') {
      var inpts = this.input_nodeTargets
      var tuple_node = inpts.pop()
      // console.log(tuple_node.className)
      this.query(tuple_node)
    }
  }

  clear() {
    this.consoleTarget.innerHTML = '<span>WhatsitToYou?&nbsp;</span><input data-whatsit-target="input_node">'
    this.moveCursor()
  }

  moveCursor(){
    var inpts = this.consoleTarget.querySelectorAll('input')
    // console.log(inpts.length)
    var last = inpts[inpts.length -1]
    last.focus()
  }
 
  query(tuple){
    const cls = tuple.className
    const val = tuple.value
    const confirm = tuple.dataset.confirm
    const qry= this.queryTarget.value
    this.queryTarget.value = val
    var url
    if (confirm == undefined) {
      url = `/whatsit/new.js?search=${encodeURI(val)}&action_type=${cls}`
    }else {
      url = `/whatsit/new.js?confirm=${encodeURI(confirm)}&action_type=${cls}&resp=${val}`
    }
    // console.log(url)
    Rails.ajax({
      url: url,
      type: "get",
      success: function(data) {
        var viewer = document.getElementById('query_results')
        viewer.scrollBy(0,3000)
        var inputs = viewer.querySelectorAll('input')
        var last = (inputs[inputs.length - 1])
        last.focus()
      }
    })
  }

}