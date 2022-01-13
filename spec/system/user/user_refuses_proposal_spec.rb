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
    expect(page).to have_content('Proposta recusada com sucesso')
    expect(page).to have_content('Esse projeto ainda não recebeu propostas')
  end

  it 'and refuses proposal at professional profile' do
    project = create(:project)
    proposal = create(:proposal, project: project)
    login_as project.creator, scope: :user

    visit professional_path(proposal.professional)
    within '#proposal-1' do
      click_on 'Recusar'
    end
    fill_in 'Informe por que quer recusar a proposta:', with: 'Recusando'
    click_on 'Recusar proposta'

    expect(Proposal.first.status).to eq('refused')
    expect(ProposalRefusal.first.refuse_reason).to eq('Recusando')
    expect(current_path).to eq('/projects/1')
    expect(page).to have_content('Proposta recusada com sucesso')
    expect(page).to have_content('Esse projeto ainda não recebeu propostas')
  end

  it 'and should not see refused proposal' do
    project = create(:project)
    refused_proposal = create(
      :proposal, project: project, message: 'This is refused'
    )
    refused_proposal.refused!
    ProposalRefusal.create!(
      proposal: refused_proposal, refuse_reason: 'Refusado!'
    )
    
    another_proposal = create(:proposal, project: project, message: 'Pending')
    
    login_as project.creator, scope: :user

    visit project_path(project)
    within '#proposal-2' do
      expect(page).to have_content("Mensagem: #{another_proposal.message}")
    end
    expect(page).not_to have_content("Mensagem: #{refused_proposal.message}")
  end

  it 'and professional see refused proposal' do
    project = create(:project)
    proposal = create(:proposal, project: project)
    proposal.refused!
    ProposalRefusal.create!(proposal: proposal, refuse_reason: 'Refusado!')

    login_as proposal.professional, scope: :professional

    visit project_path(project)
    expect(page).to have_content('Sua proposta')
    within '#proposal-1' do
      expect(page).to have_content("Mensagem: #{proposal.message}")
      expect(page).to have_content("Status: Recusada")
      expect(page).to have_content(
        "Motivo de recusa: #{proposal.proposal_refusal.refuse_reason}"
      )
    end
    expect(page).not_to have_link('Editar')
    expect(page).not_to have_link('Fazer proposta')
  end

  it 'and should refuse approved proposal' do
    project = create(:project)
    proposal = create(:proposal, project: project)
    proposal.approved!
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
    expect(page).to have_content('Proposta recusada com sucesso')
    expect(page).to have_content('Esse projeto ainda não recebeu propostas')
  end

  it 'and should not refuse canceled_approved proposal' do
    project = create(:project)
    proposal = create(:proposal, project: project)
    proposal.canceled_approved!
    ProposalCancelation.create!(proposal: proposal, cancel_reason: 'Canceled')
    login_as project.creator, scope: :user

    visit project_path(project)
    within '#proposal-1' do
      expect(page).not_to have_link('Recusar')
      expect(page).to have_content('Motivo de cancelamento: Canceled')
    end
  end
end
