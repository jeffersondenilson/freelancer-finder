require 'rails_helper'

describe 'User approves proposal' do
  it 'and should be signed in' do
    proposal = create(:proposal)

    put '/proposals/1/approve'

    expect(response).to redirect_to('/users/sign_in')
    expect(flash[:alert]).to eq('Para continuar, efetue login ou registre-se.')
  end 

  it 'successfully' do
    proposal = create(:proposal)

    login_as proposal.project.creator, scope: :user
    put '/proposals/1/approve'

    expect(response).to redirect_to(project_path proposal.project)
    expect(flash[:notice]).to eq('Proposta aprovada com sucesso. '\
      "Agora você pode trocar mensagens com #{proposal.professional.name}")
    expect(Proposal.first.status).to eq('approved')
  end

  it 'and should not approve canceled_pending' do
    proposal = create(:proposal)
    proposal.canceled_pending!

    login_as proposal.project.creator, scope: :user
    put '/proposals/1/approve'

    expect(response).to redirect_to(project_path proposal.project)
    expect(Proposal.first.status).to eq('canceled_pending')
    expect(flash[:alert]).to eq('Não foi possível aprovar a proposta')
  end

  it 'and should not approve canceled_approved' do
    proposal = create(:proposal)
    proposal.canceled_approved!
    ProposalCancelation.create!(proposal: proposal, cancel_reason: 'Canceled')

    login_as proposal.project.creator, scope: :user
    put '/proposals/1/approve'

    expect(response).to redirect_to(project_path proposal.project)
    expect(Proposal.first.status).to eq('canceled_approved')
    expect(flash[:alert]).to eq('Não foi possível aprovar a proposta')
  end

  it 'and should not approve canceled_pending' do
    proposal = create(:proposal)
    proposal.refused!
    ProposalRefusal.create!(proposal: proposal, refuse_reason: 'Refused!')

    login_as proposal.project.creator, scope: :user
    put '/proposals/1/approve'

    expect(response).to redirect_to(project_path proposal.project)
    expect(Proposal.first.status).to eq('refused')
    expect(flash[:alert]).to eq('Não foi possível aprovar a proposta')
  end

  it 'and should not approve proposal in another user\'s project' do
    proposal1 = create(:proposal)
    proposal2 = create(:proposal)

    login_as proposal2.project.creator, scope: :user
    put '/proposals/1/approve'

    expect(response).to have_http_status(:not_found)
    expect(Proposal.first.status).to eq('pending')
  end
end
