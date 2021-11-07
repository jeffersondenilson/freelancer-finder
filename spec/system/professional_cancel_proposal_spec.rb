require 'rails_helper'

describe 'Professional cancel proposal' do
  include ActiveSupport::Testing::TimeHelpers

  it 'successfully if pending' do
    user = create(:user)
    pj1 = Project.create!(
      {
        title: 'Projeto 1',
        description: 'lorem ipsum dolor sit amet',
        desired_abilities: 'UX, banco de dados',
        value_per_hour: 100,
        due_date: '13/10/2021',
        remote: true,
        creator: user
      }
    )
    professional = create(:completed_profile_professional)

    Proposal.create!(
      {
        message: 'Proposta irrecusável',
        value_per_hour: 999,
        hours_per_week: 7,
        finish_date: '10/07/1995',
        project: pj1,
        professional: professional
      }
    )
    login_as professional, scope: :professional

    visit my_projects_path
    click_on 'Cancelar proposta'

    expect(current_path).to eq(my_projects_path)
    expect(page).to have_content('Proposta cancelada com sucesso')
    expect(page).to have_content('Você não fez propostas ainda')
    expect(Proposal.count).to eq(1)
    expect(Proposal.first.status).to eq('canceled_pending')
  end

  it 'and cancel with reason within three days if approved' do
    user = create(:user)
    pj1 = Project.create!(
      {
        title: 'Projeto 1',
        description: 'lorem ipsum dolor sit amet',
        desired_abilities: 'UX, banco de dados',
        value_per_hour: 100,
        due_date: '13/10/2021',
        remote: true,
        creator: user
      }
    )
    professional = create(:completed_profile_professional)

    prop1 = Proposal.create!(
      {
        message: 'Proposta irrecusável',
        value_per_hour: 999,
        hours_per_week: 7,
        finish_date: '10/07/1995',
        project: pj1,
        professional: professional,
        status: :approved,
        approved_at: Date.new(2021, 10, 0o1)
      }
    )
    login_as professional, scope: :professional

    travel_to prop1.approved_at do
      visit my_projects_path
      click_on 'Cancelar proposta'
      fill_in 'Informe por que quer cancelar a proposta:',
              with: 'Lorem ipsum dolor sit amet'
      click_on 'Cancelar proposta'

      expect(page).to have_content('Proposta cancelada com sucesso')
      expect(page).to have_content('Você não fez propostas ainda')
      expect(Proposal.count).to eq(1)
      expect(Proposal.first.status).to eq('canceled_approved')
      expect(Proposal.first.proposal_cancelation.cancel_reason).to eq(
        'Lorem ipsum dolor sit amet'
      )
    end
  end

  it 'and can not cancel after three days if approved' do
    user = create(:user)
    pj1 = Project.create!(
      {
        title: 'Projeto 1',
        description: 'lorem ipsum dolor sit amet',
        desired_abilities: 'UX, banco de dados',
        value_per_hour: 100,
        due_date: '13/10/2021',
        remote: true,
        creator: user
      }
    )
    professional = create(:completed_profile_professional)

    prop1 = Proposal.create!(
      {
        message: 'Proposta irrecusável',
        value_per_hour: 999,
        hours_per_week: 7,
        finish_date: '10/07/1995',
        project: pj1,
        professional: professional,
        status: :approved,
        approved_at: Date.new(2021, 10, 0o1)
      }
    )
    login_as professional, scope: :professional

    travel_to(prop1.approved_at + 3.days) do
      visit my_projects_path
      click_on 'Cancelar proposta'

      expect(page).to have_content(
        'Aprovada em 01/10/2021. '\
        'Não é possível cancelar a proposta após 3 dias.'
      )
      expect(page).to have_content('Proposta irrecusável')
      expect(page).to have_content('Status: Aprovada')
      expect(page).not_to have_content('Você não fez propostas ainda')
      expect(Proposal.count).to eq(1)
    end
  end

  it 'and can not view canceled proposals in my projects page' do
    user = create(:user)
    pj1, pj2, pj3 = Project.create!(
      [
        {
          title: 'Projeto 1',
          description: 'lorem ipsum dolor sit amet',
          desired_abilities: 'UX, banco de dados',
          value_per_hour: 100,
          due_date: '10/10/2021',
          remote: true,
          creator: user
        },
        {
          title: 'Projeto 2',
          description: 'lorem ipsum dolor sit amet',
          desired_abilities: 'UX, banco de dados',
          value_per_hour: 100,
          due_date: '11/10/2021',
          remote: false,
          creator: user
        },
        {
          title: 'Projeto 3',
          description: 'lorem ipsum dolor sit amet',
          desired_abilities: 'UX, banco de dados',
          value_per_hour: 100,
          due_date: '12/10/2021',
          remote: true,
          creator: user
        }
      ]
    )
    professional = create(:completed_profile_professional)

    prop1, prop2, prop3, prop4 = Proposal.create!(
      [
        {
          message: 'Proposta :canceled_pending',
          value_per_hour: 999,
          hours_per_week: 7,
          finish_date: '10/07/1995',
          project: pj1,
          professional: professional,
          status: :canceled_pending
        },
        {
          message: 'Proposta :canceled_approved',
          value_per_hour: 999,
          hours_per_week: 7,
          finish_date: '10/07/1995',
          project: pj2,
          professional: professional,
          status: :canceled_approved,
          approved_at: Date.new(2021, 10, 0o1),
          proposal_cancelation: ProposalCancelation.new(
            cancel_reason: 'whatever'
          )
        },
        {
          message: 'Proposta :pending',
          value_per_hour: 999,
          hours_per_week: 7,
          finish_date: '10/07/1995',
          project: pj3,
          professional: professional,
          status: :pending
        },
        {
          message: 'Proposta :approved',
          value_per_hour: 999,
          hours_per_week: 7,
          finish_date: '10/07/1995',
          project: pj1,
          professional: professional,
          status: :approved,
          approved_at: Date.new(
            2021, 10, 0o1
          )
        }
      ]
    )
    login_as professional, scope: :professional

    visit my_projects_path

    expect(professional.proposals.count).to eq(4)
    expect(page).not_to have_content(prop1.message)
    expect(page).not_to have_content(prop2.message)
    expect(page).to have_content(prop3.message)
    expect(page).to have_content(prop4.message)
  end

  it 'and can not view canceled proposals in project page' do
    user = create(:user)
    pj1 = Project.create!(
      {
        title: 'Projeto 1',
        description: 'lorem ipsum dolor sit amet',
        desired_abilities: 'UX, banco de dados',
        value_per_hour: 100,
        due_date: '10/10/2021',
        remote: true,
        creator: user
      }
    )
    professional = create(:completed_profile_professional)

    prop1, prop2, prop3 = Proposal.create!(
      [
        {
          message: 'Proposta :canceled_pending',
          value_per_hour: 999,
          hours_per_week: 7,
          finish_date: '10/07/1995',
          project: pj1,
          professional: professional,
          status: :canceled_pending
        },
        {
          message: 'Proposta :canceled_approved',
          value_per_hour: 999,
          hours_per_week: 7,
          finish_date: '10/07/1995',
          project: pj1,
          professional: professional,
          status: :canceled_approved,
          approved_at: Date.new(2021, 10, 0o1),
          proposal_cancelation: ProposalCancelation.new(
            cancel_reason: 'whatever'
          )
        },
        {
          message: 'Proposta :pending',
          value_per_hour: 999,
          hours_per_week: 7,
          finish_date: '10/07/1995',
          project: pj1,
          professional: professional,
          status: :pending
        }
      ]
    )
    login_as professional, scope: :professional

    visit project_path(pj1)

    expect(professional.proposals.count).to eq(3)
    expect(page).not_to have_content(prop1.message)
    expect(page).not_to have_content(prop2.message)
    expect(page).to have_content(prop3.message)
  end
end
