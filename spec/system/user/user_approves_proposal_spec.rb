require 'rails_helper'

describe 'User approves proposal' do
  it 'successfully' do
    proposal = create(:proposal)

    login_as proposal.project.creator, scope: :user
    visit project_path(proposal.project)
    within '#proposal-1' do
      click_on 'Aprovar'
    end

    expect(current_path).to eq(project_path proposal.project)
    expect(page).to have_content('Proposta aprovada com sucesso. '\
      "Agora você pode trocar mensagens com #{proposal.professional.name}")
    within '#proposal-1' do
      expect(page).to have_content('Status: Aprovada')
    end
  end
end
