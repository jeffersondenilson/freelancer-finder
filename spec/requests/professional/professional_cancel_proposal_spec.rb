require 'rails_helper'

describe 'Professional cancel proposal' do
  include ActiveSupport::Testing::TimeHelpers

  it 'successfully if pending' do
    proposal = create(:proposal)

    login_as proposal.professional, scope: :professional

    delete '/proposals/1'

    expect(Proposal.first.status).to eq('canceled_pending')
    expect(response).to redirect_to('/projects/my')
    expect(flash[:notice]).to eq('Proposta cancelada com sucesso')
  end

  it 'successfully if approved' do
    proposal = create(:proposal, status: :approved, approved_at: Time.current)

    login_as proposal.professional, scope: :professional

    delete '/proposals/1', params: {
      proposal: {
        cancel_reason: 'canceling'
      }
    }

    expect(Proposal.first.status).to eq('canceled_approved')
    expect(ProposalCancelation.first.cancel_reason).to eq('canceling')
    expect(response).to redirect_to('/projects/my')
    expect(flash[:notice]).to eq('Proposta cancelada com sucesso')
  end

  it 'and should not cancel approved proposal after three days' do
    proposal = create(:proposal, status: :approved, approved_at: '10/10/2021')
    login_as proposal.professional, scope: :professional

    delete '/proposals/1', params: {
      proposal: {
        cancel_reason: 'cancel it'
      }
    }

    travel_to proposal.approved_at + 3.days do
      expect(response.body).to include(
        'Aprovada em 10/10/2021. '\
        'Não é possível cancelar a proposta após 3 dias.'
      )
      expect(Proposal.first.status).to eq('approved')
    end
  end

  it 'and should not view cancel form if is pending' do
    proposal = create(:proposal)
    login_as proposal.professional, scope: :professional

    get '/proposals/1/cancel'

    expect(response).to redirect_to('/projects/my')
    expect(flash[:notice]).to eq('Proposta cancelada com sucesso')
    expect(Proposal.first.status).to eq('canceled_pending')
  end

  it 'and should not see cancel form if refused' do
    proposal = create(:proposal)
    proposal.refused!
    ProposalRefusal.create!(proposal: proposal, refuse_reason: 'Refused!')

    login_as proposal.professional, scope: :professional

    get '/proposals/1/cancel'

    expect(Proposal.first.status).to eq('refused')
    expect(response).to redirect_to(project_path proposal.project)
    expect(flash[:alert]).to eq('Propostas recusadas não podem ser alteradas')
  end

  it 'and should not cancel if refused' do
    proposal = create(:proposal)
    proposal.refused!
    ProposalRefusal.create!(proposal: proposal, refuse_reason: 'Refused!')

    login_as proposal.professional, scope: :professional

    delete '/proposals/1'

    expect(Proposal.first.status).to eq('refused')
    expect(response).to redirect_to(project_path proposal.project)
    expect(flash[:alert]).to eq('Propostas recusadas não podem ser alteradas')
  end

  it 'and should not cancel if already canceled_pending' do
    proposal = create(:proposal)
    proposal.canceled_pending!

    login_as proposal.professional, scope: :professional
    delete '/proposals/1'

    expect(Proposal.first.status).to eq('canceled_pending')
  end

  it 'and should not cancel if already canceled_approved' do
    proposal = create(:proposal)
    proposal.canceled_approved!
    ProposalCancelation.create!(proposal: proposal, cancel_reason: 'Cancel')

    login_as proposal.professional, scope: :professional
    delete '/proposals/1'

    expect(Proposal.first.status).to eq('canceled_approved')
  end
end
