require 'rails_helper'

describe 'User refuses proposal' do
  it 'and should see refuse reason page' do
    project = create(:project)
    create(:proposal, project: project)
    login_as project.creator, scope: :user

    visit project_path(project)
    within '#proposal-1' do
      click_on 'Recusar'
    end

    expect(current_path).to eq('/proposals/1/refuse')
    expect(page).to have_content('Informe por que quer recusar a proposta:')
  end

  it 'successfully with reason' do
    project = create(:project)
    create(:proposal, project: project)
    login_as project.creator, scope: :user

    visit project_path(project)
    within '#proposal-1' do
      click_on 'Recusar'
    end
    fill_in 'Informe por que quer recusar a proposta:', with: 'Recusando'
    click_on 'Recusar proposta'

    expect(Proposal.first.status).to eq('refused')
    expect(ProposalRefusal.first.refuse_reason).to eq('Recusando')
    expect(current_path).to eq('/projects/1')
    expect(page).to have_content('Esse projeto ainda não recebeu propostas')
  end
end
