class Project < ApplicationRecord
  belongs_to :user

  validates :title, :description, :desired_abilities, :value_per_hour, 
    :due_date, :remote, presence: true
end

# -titulo
# -descrição
# -habilidades
# -valor por hora
# -data limite
# -remoto?
