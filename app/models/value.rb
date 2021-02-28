class Value < Subject
  has_many :relations, class_name: 'Relation', foreign_key: :value_id, dependent: :destroy
  has_many :subjects, through: :relations

  def self.find_by_name(name)
    where(arel_table[:name].matches(name)).first
  end
  
  def relations_by_name(related)
    self.relations.where(Relation.arel_table[:name].matches(related))
  end

  def subjects_by_name(value)
    self.subjects.where(Subject.arel_table[:name].matches(value))
  end

end