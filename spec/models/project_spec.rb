require 'rails_helper'

RSpec.describe Project, type: :model do
  it { should belong_to(:creator).class_name('User').with_foreign_key('user_id') }
  it { should have_many :proposals }
  it { should validate_presence_of :title }
  it { should validate_presence_of :description }
  it { should validate_presence_of :desired_abilities }
  it { should validate_presence_of :value_per_hour }
  it { should validate_presence_of :due_date }
end
