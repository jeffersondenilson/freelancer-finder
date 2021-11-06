require 'rails_helper'

RSpec.describe Professional, type: :model do
  it { should have_many :proposals }
  it { should validate_presence_of :name }
  it { should validate_presence_of(:full_name).on(:update) }
  it { should validate_presence_of(:birth_date).on(:update) }
  it { should validate_presence_of(:education).on(:update) }
  it { should validate_presence_of(:description).on(:update) }
  it { should validate_presence_of(:abilities).on(:update) }
  it { should_not validate_presence_of(:experience).on(:update) }
  it { should_not validate_presence_of(:profile_picture_url).on(:update) }

  it 'should set profile as completed when update profile' do
    john = Professional.create!(name: 'John Doe', email: 'john.doe@email.com',
                                password: '123456')

    john.update!(
      full_name: 'Just John Doe',
      birth_date: '01/01/1980',
      education: 'lorem ipsum dolor sit amet',
      description: 'Cupiditate laudantium sapiente',
      abilities: 'UX, design, dev'
    )

    expect(john.completed_profile).to eq(true)
    expect(john.errors.empty?).to eq(true)
  end

  it 'should only find not canceled proposals' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com',
                        password: '123456')
    pj1, pj2, pj3 = Project.create!(
      [
        {
          title: 'Projeto 1',
          description: 'lorem ipsum dolor sit amet',
          desired_abilities: 'UX, banco de dados',
          value_per_hour: 100,
          due_date: '10/10/2021',
          remote: true,
          creator: jane
        },
        {
          title: 'Projeto 2',
          description: 'lorem ipsum dolor sit amet',
          desired_abilities: 'UX, banco de dados',
          value_per_hour: 100,
          due_date: '11/10/2021',
          remote: false,
          creator: jane
        },
        {
          title: 'Projeto 3',
          description: 'lorem ipsum dolor sit amet',
          desired_abilities: 'UX, banco de dados',
          value_per_hour: 100,
          due_date: '12/10/2021',
          remote: true,
          creator: jane
        }
      ]
    )
    john = Professional.create!(name: 'John Doe', email: 'john.doe@email.com',
      password: '123456', birth_date: '01/01/1980', completed_profile: true)
    prop1, prop2, prop3, prop4 = Proposal.create!(
      [
        {
          message: 'Proposta :canceled_pending',
          value_per_hour: 999,
          hours_per_week: 7,
          finish_date: '10/07/1995',
          project: pj1,
          professional: john,
          status: :canceled_pending
        },
        {
          message: 'Proposta :canceled_approved',
          value_per_hour: 999,
          hours_per_week: 7,
          finish_date: '10/07/1995',
          project: pj2,
          professional: john,
          status: :canceled_approved,
          approved_at: Date.new(
            2021, 10, 0o1
          ),
          proposal_cancelation: ProposalCancelation.new(cancel_reason: 'whatever')
        },
        {
          message: 'Proposta :pending',
          value_per_hour: 999,
          hours_per_week: 7,
          finish_date: '10/07/1995',
          project: pj3,
          professional: john,
          status: :pending
        },
        {
          message: 'Proposta :approved',
          value_per_hour: 999,
          hours_per_week: 7,
          finish_date: '10/07/1995',
          project: pj1,
          professional: john,
          status: :approved,
          approved_at: Date.new(
            2021, 10, 0o1
          )
        }
      ]
    )

    not_canceled_proposals = john.not_canceled_proposals

    expect(john.proposals.count).to eq(4)
    expect(not_canceled_proposals).to eq([prop3, prop4])
    expect(not_canceled_proposals).not_to include([prop1, prop2])
  end
end
