require 'rails_helper'

describe 'Professional cancel proposal' do
  include ActiveSupport::Testing::TimeHelpers

  it 'successfully' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com', password: '123456')
    pj1 = Project.create!({
      title: 'Projeto 1',
      description: 'lorem ipsum dolor sit amet',
      desired_abilities: 'UX, banco de dados',
      value_per_hour: 100,
      due_date: '13/10/2021',
      remote: true,
      creator: jane
    })
    john = Professional.create!(name: 'John Doe', email: 'john.doe@email.com', 
      password: '123456', birth_date: '01/01/1980', completed_profile: true)
    prop1 = Proposal.create!({
      message: 'Proposta irrecusável',
      value_per_hour: 999,
      hours_per_week: 7,
      finish_date: '10/07/1995',
      project: pj1,
      professional: john
    })
    login_as john, scope: :professional

    visit my_projects_path
    click_on 'Cancelar proposta'

    expect(current_path).to eq(my_projects_path)
    expect(page).to have_content('Você não fez propostas ainda')
    expect(Proposal.count).to eq(0)
  end

  it 'and can not cancel if was approved in less than three days' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com', password: '123456')
    pj1 = Project.create!({
      title: 'Projeto 1',
      description: 'lorem ipsum dolor sit amet',
      desired_abilities: 'UX, banco de dados',
      value_per_hour: 100,
      due_date: '13/10/2021',
      remote: true,
      creator: jane
    })
    john = Professional.create!(name: 'John Doe', email: 'john.doe@email.com', 
      password: '123456', birth_date: '01/01/1980', completed_profile: true)
    prop1 = Proposal.create!({
      message: 'Proposta irrecusável',
      value_per_hour: 999,
      hours_per_week: 7,
      finish_date: '10/07/1995',
      project: pj1,
      professional: john,
      status: :approved,
      approved_at: Time.current
    })
    login_as john, scope: :professional

    visit my_projects_path
    click_on 'Cancelar proposta'

    travel_to Time.current do
      expect(page).to have_content('Você deve esperar 3 dias para cancelar a proposta')
      expect(page).to have_content('Proposta irrecusável')
      expect(Proposal.count).to eq(1)
    end
  end

  it 'and should inform reason to cancel approved'
  it 'and can cancel if approved after three days with reason'
end
