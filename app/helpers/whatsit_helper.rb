module WhatsitHelper
  # this helper does three things
  # => 1. Displays a query response. it will be an array which will be formated using  ul/li elements
  # => 2. Builds and call Whatsit.obj in response to a confirmation yes anseer
  # => 3. Builds and display a confirmation prompt for create, destroy or update (change)
  # queries that can modify the db will come thru here twice, once on a inital input and once to confirm
  def whatsit_actions
    # @whatsit passed as class variable from controller are we querying or confirming
    # => 2. Builds and call Whatsit.obj in response to a confirmation yes anseer
    if @whatsit.params[:confirm].present?
      return create if @whatsit.params[:action_type] == 'create'
      return delete if @whatsit.params[:action_type] == 'delete'
      return change if @whatsit.params[:action_type] == 'change'
      return tag.div("#{@whatsit.params}") #basic prompt on own line, should not happen, check
    else
      @query = @whatsit.search(@whatsit.params[:search])
      # => 1. Displays a query response. it will be an array which will be formated using  ul/li elements
      return whatsit_list if @query.is_a?(Array)
      # => 3. Builds and display a confirmation prompt for create, destroy or update (change)
      return confirm if query_contains?("Confirm's")
      return tag.div("#{@whatsit.confirm}") #basic prompt on own line, should not happen, check
    end
  end

  def whatsit_list # dump the list
    q = tag.div("Searching for => #{@whatsit.params[:search]}",style:"font-style: italic;")
    t = tag.ul(whatsit_item,class:'my-ul')
    return (q + t + prompt).html_safe
  end

  def whatsit_item
    list = ""
    @query.each do |a|
      list += tag.li(a)
    end
    return list.html_safe
  end

  def prompt
    s = tag.span("WhatsitToYou?&nbsp;".html_safe)
    i = tag.input("",data:{whatsit_target:'input_node',action:'change->whatsit#search'}, class:'query')
    (s + i).html_safe
  end

  def delete
    resp = @whatsit.params[:resp] #y/n
    if resp.downcase.include?('y')
      @whatsit.delete_something
      br = tag.br
      tg = tag.span("#{@whatsit.words[1]} #{@whatsit.words[2]} deleted.")
      return  (br + tg + br + prompt).html_safe
    else
      br = tag.br
      tg = tag.span("Okay, we'll cancel the forget action!")
      return  (br + tg + br + prompt).html_safe
    end
  end

  def change
    resp = @whatsit.params[:resp] #y/n
    if resp.downcase.include?('y')
      @whatsit.change_something
      br = tag.br
      tg = tag.span("#{@whatsit.words[0]} #{@whatsit.words[1]} to changed.")
      return  (br + tg + br + prompt).html_safe
    else
      br = tag.br
      tg = tag.span("Okay, we'll cancel the forget action!")
      return  (br + tg + br + prompt).html_safe
    end

  end

  def create
    resp = @whatsit.params[:resp] #y/n
    if resp.downcase.include?('y')
      @whatsit.create_something
      br = tag.br
      tg = tag.span("New tuple created Subject: #{@whatsit.words[0]}, Relation: #{@whatsit.words[1]}, Value: #{@whatsit.words[2]}")
      return  (br + tg + br + prompt).html_safe
    else
      br = tag.br
      tg = tag.span("Okay, we'll cancel the create action!")
      return  (br + tg + br + prompt).html_safe
    end
  end

  def confirm
    if @whatsit.action.include?('delete|')
      cclass = 'delete'
      eop = "Delete?"
    elsif @whatsit.action.include?('update|')
      cclass = 'change'
      eop = "Change?"
    elsif @whatsit.action.include?('create|')
      cclass = 'create'
      eop = "Create?"
    end
    q = tag.div("Searching for => #{@whatsit.params[:search]}",style:"font-style: italic;")

    br = tag.br
    i = tag.input("",data:{whatsit_target:'input_node',action:'change->whatsit#search',confirm:"#{@whatsit.action}"}, class:cclass)
    yn = tag.span("(y/n)?&nbsp;".html_safe)
    tg = tag.span("#{@query} #{eop} #{i}".html_safe)
    return  (br + q + tg + br + yn + i).html_safe
  end

  def query_contains?(word)
    !@query.match(/#{word}/i).nil? #|| @whatsit.confirm.match(/#{word}/i).nil?
  end

end
