class Tag < ActiveRecord::Base

  validates :tags, :entity_type, :entity_id, presence: true
  # http://stackoverflow.com/questions/2080347/activerecord-serialize-using-json-instead-of-yaml
  serialize :tags, Array

end
