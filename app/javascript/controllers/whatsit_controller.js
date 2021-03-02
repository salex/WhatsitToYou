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
        const last_query = document.getElementById('last_query')
        const inputs = viewer.querySelectorAll('input')
        const inputs_length = inputs.length
        var prev = inputs[inputs_length - 2]
        var last = inputs[inputs_length - 1]
        prev.value = last_query.value
        last.focus()
      }
    })
  }

}