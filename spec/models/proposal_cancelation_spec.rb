require 'rails_helper'

RSpec.describe ProposalCancelation, type: :model do
  it { should belong_to :proposal }
end
