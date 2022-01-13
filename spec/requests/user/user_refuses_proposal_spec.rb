require 'rails_helper'

describe 'User refuses proposal' do
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
end
