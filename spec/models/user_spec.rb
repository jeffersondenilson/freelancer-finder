require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many(:projects).inverse_of('creator') }
  it { should validate_presence_of :name }
end
