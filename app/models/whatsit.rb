class Whatsit
  include WhatsitHelper
  attr_accessor :query, :words, :confirm, :response, :action, :params

  def initialize
  end

  def search(query)
    query.strip! unless query.blank? # get rid of leading/trailing spaces
    return ["You's asked to find nothing!"] if query.blank?
    # remove the optional what's and who's from query
    query.gsub!(/what's/i, '') if query.starts_with?(/what's/i)
    query.gsub!(/who's/i, '') if query.starts_with?(/who's/i)
    @query = query
    # puts "INITIAL QUERY #{query} ACTION #{action}"
    downcased_query = query.downcase
    # This section calls methods for whatsit commands from downcased version
    return forgets if downcased_query.starts_with?("forget's")
    return changes if downcased_query.starts_with?("change's")
    return subject_names if downcased_query.starts_with?("subject's")
    return relation_names if downcased_query.starts_with?("relation's")
    return value_names if downcased_query.starts_with?("value's")
    return family if downcased_query.starts_with?("family's")
    return tuples if downcased_query.starts_with?("dump's")
    # confirmation may be called from  parse_query if confirmation required
    return confirmation if downcased_query.include?("confirm's")
    @words, error = parse_query
    @action = nil
    # now check for for baic querries or a create action
    return error if error
    return single if words.size == 1
    return double if words.size == 2
    if words.size == 3
      results = tuple
      # if results is an array, the search for subject, relation, value found a match, display them
      return results if results.is_a?(Array) # the words all matched
      # else we're gound to build confirm parmam and go back to console
      create_action = "create|#{words.join('|')}"
      return "Confirm's #{results}"

    end

  end

  # the somthing methods are call from the helper if user agrees to the action
  def change_something
    @words = params[:confirm].split('|')
    what_model = words[1]
    attr_from = words[2]
    attr_to = words[3] # ain't no TO
    obj = send "get_#{what_model}_by_name", attr_from
    if what_model == 'relation'
      obj.update_all(name:attr_to)
    else
      obj.update(name:attr_to)
    end

  end

  def delete_something
    @words = params[:confirm].split('|')
    what_model = words[1]
    attr_del = words[2]
    obj = send "get_#{what_model}_by_name", attr_del
    if what_model == 'relation'
      obj.delete_all
    else
      # since if could be a value or subject, we need to delete all relations
      rel = Relation.where(subject_id:obj.id).or(Relation.where(value_id:obj.id))
      rel.delete_all
      obj.delete
    end
    @words = [subj.name,rel.name,val.name]

  end

  def create_something
    objects = params[:confirm].split('|')
    subject,subj_id =  objects[1].split(':')
    relation,rel_id = objects[2].split(':')#always new
    value,val_id = objects[3].split(':')
    subj = subj_id == 'new' ? Subject.create(name:subject) : Subject.find(subj_id)
    val = val_id == 'new' ? Value.create(name:value) : Value.find(val_id)
    rel = Relation.create(name:relation,subject_id:subj.id,value_id:val.id)
    @words = [subj.name,rel.name,val.name]
  end

  def confirmation
    # something was confirmed, we need to take action on the next time trough whatsit_helper
    return query
  end

  private

  def parse_query
    words = query.match(/'s/i) ? query.split(/'s/i).each{|i| i.strip!} : query.split.each{|i| i.strip!}
    error = nil
    if words.size > 3 
      error = ["Opps, you either have to many words or a malformed query.\n Make sure you use 's to delimit words \n if you have spaces in object name \n or you've used 's on only one word "]
    end
    commands = %w[whats what whos who forgets forget changes change subjects subject relations relation values value dumps dump]
    filter = commands & words
    unless filter.blank?
      if error.nil? 
        error = ["Your query contains a reserved word. Did you forget a 's ?"]
      else
        error << ["Your query contains a reserved word. Did you forget a 's ?"]
      end
    end
    [words, error]

  end

  def query_to_words()
    query.strip!
    @words = query.match(/'s/i) ? query.split(/'s/i).each{|i| i.strip!} : query.split.each{|i| i.strip!}
  end

  def phrase_to_words(phrase)
    phrase.strip!
    phrase.match(/'s/i) ? phrase.split(/'s/i).each{|i| i.strip!} : phrase.split.each{|i| i.strip!}
  end

  # single, double or tuple(triple) is how many words were entered
  def single
    # "going to look for all matching subjects and/or relations #{words}"
    # rember that a Subject or a Value point to the same subject
    @response = []
    subj = get_subject_by_name(words[0])
    if subj
      if subj.relations.present?
        subj.relations.each do |related|
          response << "#{subj.name}'s #{related.name} is #{related.value ? related.value.name : nil}"
        end
      else
        response << "#{subj.name} is an Orphaned Subject (no relations)"
      end
    end
    rel = get_relation_by_name(words[0])
    if rel
      rel.each do |related|
        response << "#{related.name} links #{related.subject ? related.subject.name : nil} and #{related.value ? related.value.name: nil}"
      end
    end
    val = get_value_by_name(words[0])
    if val
      if val.relations.present?
        val.relations.each do |related|
          response << "#{val.name} is #{related.subject.name}'s #{related.name} "
        end
      else
        response << "#{val.name} is an Orphaned Value (no relations)"
      end
    end
    response  << "No Subject, Relation or Value found for #{words[0]} " if response.blank?
    response.sort_by! {|str| str.downcase}

  end

  def double
    # "going to look for all matching relations for subject #{words}"
    @response = []
    w1 = words[0]
    w2 = words[1]
    w1_is_sub, w1_is_rel, w1_is_val = [is_model?('subject', w1),is_model?('relation', w1),is_model?('value', w1)]
    w2_is_sub, w2_is_rel, w2_is_val = [is_model?('subject', w2),is_model?('relation', w2),is_model?('value', w2)]

    if w1_is_sub && w2_is_sub
      response_sub_sub(w1,w2)
    elsif w1_is_sub && w2_is_rel
      response_sub_rel(w1,w2)
    elsif w1_is_rel && w2_is_sub
      response_rel_sub(w1,w2)
    elsif w1_is_rel && w2_is_rel
      response_rel_rel(w1,w2)
    else
      response << "No Subject, Relation or Value found for #{w1} and #{w2}"
    end
    response.sort_by! {|str| str.downcase}

  end

# These are methods that may modifiy to database
  def tuple
    # puts "going to get or update/create a tuple #{words}"
    subject, relation, value = words
    new_subj = new_rel = new_val = nil
    # get relation name
    rel = get_relation_by_name(relation)
    rel_name = rel.present? ? rel.first.name : relation
    # build subject node
    subj = get_subject_by_name(subject)
    # puts "SUBJECT #{subj.inspect}"
    new_subj = subj.present? ? "#{subj.name}:#{subj.id}" : "#{subject}:new"
    # build value node
    val = get_value_by_name(value)
    new_val = val.present? ? "#{val.name}:#{val.id}" : "#{value}:new"

    if subj.present? && val.present?
      curr_rel = Relation.where(subject_id:subj.id,value_id:val.id,name:rel_name)
      # puts curr_rel.inspect
      return ["#{subj.name} #{rel_name}'s #{val.name}"] if curr_rel.present?
    end
    new_rel = "#{rel_name}:new"

    resp =  "create|#{new_subj}|#{new_rel}|#{new_val}"
    self.action = resp
    return resp
  end

  def forgets
    self.query.gsub!(/FORGET'S /i,"")
    words = query_to_words
    valid,errors = validate_forgets_action
    if valid
      self.action = "delete|#{words[0]}|#{words[1]}"
      return "Confirm's #{self.action}"
    else
      return errors
    end
  end

  def validate_forgets_action
    errors = []
    errors << "Forget's only requires a model and value, you had #{words.size} words!" if words.size != 2
    what_model = get_required_model_name(words[0])
    errors << "Forget's requires a valid model #{words[0]} is not valid" if what_model.nil?
    return false,errors  unless errors.blank?
    if what_model == 'relation'
      model = get_relation_by_name(words[1])
      errors << "Relation value '#{words[1]}' was not found" unless model
    else
      model = send "get_#{what_model}_by_name", words[1]
      errors << "#{words[0]} => '#{words[1]}' was not found" unless model
    end
    return errors.blank?,errors
  end

  def get_required_model_name(phrase)
    models =  %w[subject relation value]
    models.each do |model|
      return(model) if phrase.downcase.include?("#{model}")
    end
    nil

  end

  def changes
    self.query.gsub!(/CHANGE'S /i,"")
    if query.match(/ to /i)
      model_from_val, to_val = query.split(/ to /i)
    else
      return ["Change's action requires a 'to' attribute in query"]
    end
    to_val.strip.gsub!(/'s/i,"")
    model = model_from_val.split.first
    from_val = model_from_val.strip.gsub(model,"").gsub(/'s/i,"").strip
    model.gsub!(/'s/i,"")
    valid,errors = validate_changes_action(model,from_val,to_val)
    if valid
      change_action = "update|#{model}|#{from_val}|#{to_val}"
      self.action = change_action
      return "Confirm's #{self.action}"
    else
      return errors
    end

  end

  def validate_changes_action(model,from_val,to_val)
    errors = []
    has_model = get_required_model_name(model)
    errors << "Change's requires a valid model name (#{model}??) 'subject|relation|value'" if has_model.nil?
    if has_model
      check_model = send "get_#{model}_by_name", from_val
      errors << "#{model} => '#{from_val}' was not found" unless check_model
    end
    return errors.blank?,errors

  end


# helpers or response methods format to tuples
  def response_sub_sub(sub1w,sub2w)
    sub1 = get_subject_by_name(sub1w)
    sub2 = get_subject_by_name(sub2w)
    # I've given up on union for not , just do array
    int1 = sub1.relations.pluck(:value_id) 
    int2 = sub2.relations.pluck(:value_id)
    inter = int1 & int2
    # first inter and relations the subject share
    inter.each do |i|
      Relation.where(value_id:i,subject_id:[sub1.id]).each do |r|
        response << "#{r.value.name} is #{sub2.name}'s #{r.name}"
      end
      Relation.where(value_id:i,subject_id:sub2.id).each do |r|
        response << "#{r.value.name} is #{sub1.name}'s #{r.name}"
      end
    end
    # now see if there are and direct relations between subjects
    Relation.where(value_id:sub1.id,subject_id:sub2.id).each do |r|
      response << "#{r.value.name} is #{r.subject.name}'s #{r.name}"
    end
    Relation.where(value_id:sub2.id,subject_id:sub1.id).each do |r|
      response << "#{r.value.name} is #{r.subject.name}'s #{r.name}"
    end
    response << "No relaton found between #{sub1w} and #{sub2w}" if response.blank?
  end

  def response_sub_rel(subw,relw)
    subj = get_subject_by_name(subw)
    if subj
      subj.relations.where(Relation.arel_table[:name].matches(relw)).each do |m|
        response << "#{subj.name}'s #{m.name} is #{m.value.name}"
      end
    end
    response
  end

  def response_rel_sub(relw,subw)
    subj = get_subject_by_name(subw)
    if subj
      subj.relations.where(Relation.arel_table[:name].matches(relw)).each do |m|
        response << "#{m.value.name} is #{subj.name}'s #{m.name} "
      end
    end
    response
  end

  def response_rel_rel(rel1w,rel2w)
    rel1n = get_relation_by_name(rel1w).first.name
    rel2n = get_relation_by_name(rel2w).first.name
    filtered = Subject.where_assoc_exists(:relations, name: rel1w).where_assoc_exists(:relations, name:rel2n).pluck(:id)
    picked = Relation.where(name:[rel1n,rel2n]).where(subject_id:filtered)
    picked.each do |pick|
      response << "#{pick.subject.name}'s #{pick.name} is #{pick.value.name}"
    end
    response
  end

# These are special queries that done use a query(paaams)
  def family
    words = query.split
    subj = words[1] #subject
    relname = words[2].present? ? words[2] : nil
    arr = Subject.family(subj,relname)
  end

  def subject_names
    subject_relations.pluck(:name)
  end

  def value_names
    value_relations.pluck(:name)
  end

  def relation_names
    Relation.order_by_name.pluck(:name).uniq.sort
  end

  def tuples
    tuple = []
    subj = subject_relations
    subj.each do |s|
      s.relations.each do |rel|
        tuple << [s.name, rel.name, rel.value.name]
      end
    end
    tuple
  end
 
# This are model calls used by different queries  or commands

  def subject_relations
    Subject.where(id: subject_ids)
  end

  def value_relations
    Value.where(id: value_ids)
  end

  def subject_ids
    # Subject.order_by_name.where(id: Relation.all.pluck(:subject_id).uniq)
    Relation.all.map(&:subject_id).uniq
  end

  def value_ids
    # Value.order_by_name.where(id: Relation.all.pluck(:value_id).uniq)
    Relation.all.map(&:value_id).uniq
  end

  # what getters are going to get a single subject or value, or all relations by name
  def get_relation_by_name(what)
    Relation.find_by_name(what)
  end

  def get_subject_by_name(what)
    Subject.find_by_name(what)
  end

  def get_value_by_name(what)
    Value.find_by_name(what)
  end

  def is_model?(w1, w2)
    return false unless %w[subject value relation].include?(w1)
    result = send "get_#{w1}_by_name", w2
    result.present?
  end

end
