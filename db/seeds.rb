# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

def create_tuples
  tuples = [
    'Steve|spouse|Janet',
    'Steve|child|Butch',
    'Steve|child|Lori',
    'Steve|child|James',
    'Steve|homePhone|888.555.1111',
    'Steve|cellPhone|888.555.1112',
    'Janet|homePhone|888.555.1111',
    'Janet|cellPhone|888.555.1113',
    'Butch|spouse|Cindy',
    'Lori|spouse|Lee',
    'Lori|child|Sarrah',
    'James|spouse|Janic',
    'James|child|JamesJR',
    'James|child|Chappel',
    'James|child|Drew',
    'Monica|child|Eric',
    'Monica|child|Bryan',
    'Monica|child|Adam',
    'Steve|cousin|Monica'
  ]
  tuples.each do |srv|
    subj, rel, val = srv.split('|')
    s = Subject.find_or_create_by(name:subj)
    v = Subject.find_or_create_by(name:val)
    r = Relation.create(name:rel,subject_id:s.id,value_id:v.id)
  end
end

create_tuples
