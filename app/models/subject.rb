class Subject < ApplicationRecord
  has_many :relations, dependent: :destroy
  has_many :values, through: :relations 

  validates_presence_of :name
  validates_uniqueness_of :name, case_sensitive: false


  scope :order_by_name, -> {
    order(arel_table['name'].lower.asc)
  }

  def relations_by_name(related)
    self.relations.where(Relation.arel_table[:name].matches(related))
  end

  def values_by_name(value)
    self.values.where(Value.arel_table[:name].matches(value)).first
  end

  def self.intersection(subj1,subj2)
    subjs = Subject.where(Subject.arel_table[:name].matches(subj1).or(Subject.arel_table[:name].matches(subj2)))
    # Subject.where_assoc_exists(:relations,Relation.arel_table[:name].matches('Child'))
  end

  def self.family(name,relname=nil)
    subj = Subject.find_by_name(name)
    return  ["Subject #{name} not found"] if subj.blank?
    if relname
      rel = Relation.find_by_name(relname)
      return ["Subject #{name} Relation #{relname} notfound"] if rel.blank?
      rel = rel.first.name
    end
    vals = subj.values
    resp = []
    kids = []
    vals.each do |v|
      if !rel
        kids << Relation.where(subject_id:v.id).or(Relation.where(value_id:v.id))
      else
        kids << Relation.where(subject_id:v.id,name:rel).or(Relation.where(value_id:v.id,name:rel))
      end
    end

    kids.each do |ks|
      ks.each do |k|
        resp << "#{k.subject.name} #{k.name}'s' #{k.value.name}"
      end
    end
    resp.uniq.sort_by! {|str| str.downcase}

   end

 
  def self.find_by_name(name)
    where(arel_table[:name].matches(name)).first
  end

end
