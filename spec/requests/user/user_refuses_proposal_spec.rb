require 'rails_helper'

describe 'User refuses proposal' do
  it 'and should be signed in' do
    create(:proposal)

    delete '/proposals/1', params: {
      proposal: {
        refuse_reason: 'Should not refuse this'
      }
    }

    expect(Proposal.first.status).to eq('pending')
    expect(response).to redirect_to(root_path)
    expect(flash[:alert]).to eq('Você deve estar logado.')
  end

  it 'successfully if pending' do
    proposal = create(:proposal)

    login_as proposal.project.creator, scope: :user
    delete '/proposals/1', params: {
      proposal: {
        refuse_reason: 'Refused'
      }
    }

    expect(Proposal.first.status).to eq('refused')
    expect(ProposalRefusal.first.refuse_reason).to eq('Refused')
    expect(response).to redirect_to('/projects/1')
    expect(flash[:notice]).to eq('Proposta recusada com sucesso')
  end

  it 'successfully if approved' do
    proposal = create(:proposal, status: :approved, approved_at: Time.current)

    login_as proposal.project.creator, scope: :user
    delete '/proposals/1', params: {
      proposal: {
        refuse_reason: 'Refused!'
      }
    }

    expect(Proposal.first.status).to eq('refused')
    expect(ProposalRefusal.first.refuse_reason).to eq('Refused!')
    expect(response).to redirect_to('/projects/1')
    expect(flash[:notice]).to eq('Proposta recusada com sucesso')
  end

  it 'and should not refuse proposal in another user\'s project' do
    proposal1, = create_list(:proposal, 2)

    login_as proposal1.project.creator, scope: :user
    delete '/proposals/2', params: {
      proposal: {
        refuse_reason: 'Should not refuse this'
      }
    }

    expect(response).to have_http_status(:not_found)
  end

  it 'and should not see refuse form for another user\'s project' do
    proposal1, = create_list(:proposal, 2)

    login_as proposal1.project.creator, scope: :user
    get '/proposals/2/refuse'

    expect(response).to have_http_status(:not_found)
  end

  it 'and should not refuse canceled_approved proposal' do
    proposal = create(:proposal, status: :approved, approved_at: Time.current)
    proposal.canceled_approved!
    ProposalCancelation.create!(proposal: proposal, cancel_reason: 'canceled')

    login_as proposal.project.creator, scope: :user
    delete '/proposals/1', params: {
      proposal: {
        refuse_reason: 'Should not refuse this'
      }
    }

    expect(Proposal.first.status).to eq('canceled_approved')
    expect(response).to redirect_to(project_path(proposal.project))
    expect(flash[:alert]).to eq('Não é possível recusar essa proposta')
  end

  it 'and should not refuse canceled_pending proposal' do
    proposal = create(:proposal)
    proposal.canceled_pending!

    login_as proposal.project.creator, scope: :user
    delete '/proposals/1', params: {
      proposal: {
        refuse_reason: 'Should not refuse this'
      }
    }

    expect(Proposal.first.status).to eq('canceled_pending')
    expect(response).to redirect_to(project_path(proposal.project))
    expect(flash[:alert]).to eq('Não é possível recusar essa proposta')
  end

  it 'and should not refuse refused proposal' do
    proposal = create(:proposal)
    proposal.refused!
    ProposalRefusal.create!(proposal: proposal, refuse_reason: 'refused')

    login_as proposal.project.creator, scope: :user
    delete '/proposals/1', params: {
      proposal: {
        refuse_reason: 'Should not refuse this'
      }
    }

    expect(Proposal.first.status).to eq('refused')
    expect(response).to redirect_to(project_path(proposal.project))
    expect(flash[:alert]).to eq('Não é possível recusar essa proposta')
  end
end
