require 'rails_helper'

RSpec.describe ProposalRefusal, type: :model do
  it { should belong_to :proposal }
end
