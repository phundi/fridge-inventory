class Obs < ActiveRecord::Base
  self.table_name = :obs
  self.primary_key = :obs_id

  before_create :set_defaults

  def set_defaults
    self.created_at = Time.now
    self.updated_at = Time.now
  end

  def answer_string
    self.to_arr.join(": ")
  end

  def to_arr
    name = Concept.where(concept_id: self.concept_id).first.name
    value = ""

    if self.value_coded.present?
      value = Concept.where(concept_id: self.value_coded).first.name
    elsif self.value_datetime.present?
      value = self.value_datetime.strftime("%Y/%b/%d %H:%M")
    elsif self.value_text
      value = self.value_text
    elsif self.value_numeric
      value = self.value_numeric
    end

    [name, value]
  end
end
