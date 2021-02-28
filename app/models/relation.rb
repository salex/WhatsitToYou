class Relation < ApplicationRecord
  belongs_to :subject, class_name: 'Subject', foreign_key: :subject_id
  belongs_to :value, class_name: 'Value', foreign_key: :value_id

  validates_presence_of :name
  
  scope :order_by_name, -> {
    order(arel_table['name'].lower.asc)
  }

  def self.find_by_name(name)
    where(arel_table[:name].matches(name))
  end

  def self.subjects(name)
    Relation.find_by_name(name).each{|rel| rel.subject}
  end

  def self.values(name)
    Relation.find_by_name(name).each{|rel| rel.value}
  end

  def self.find_orphans
    resp = []

    Relation.all.each do |r|
      resp << [r.id,r.name,r.subject.present?,r.value.present?]
    end
    resp
  end
  def subjects
    #other sujects with same id
    Relation.where(subject_id:self.subject_id)
  end



  def values
    #other values with same id
    Relation.where(value_id:self.value_id)
  end

  def self.siblings(name)
    Relation.where(name:self.name).each{|rel| rel.sibling_subjects + rel.sibling_values}
  end

  def sibling_subjects
    subject_ids = siblings.pluck(:subject_id)
    Subject.where(id:subject_ids)
  end

  def sibling_values
    value_ids = siblings.pluck(:value_id)
    Value.where(id:value_ids)
  end

  def tuple
    [self.subject.name,self.name,self.value.name]
  end

end

# sva.P@6026B@1710