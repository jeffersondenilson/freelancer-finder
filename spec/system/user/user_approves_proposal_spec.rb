require 'rails_helper'

describe 'User approves proposal' do
  include ActiveSupport::Testing::TimeHelpers

  it 'successfully' do
    proposal = create(:proposal)

    travel_to '18/01/2022' do
      login_as proposal.project.creator, scope: :user
      visit project_path(proposal.project)
      within '#proposal-1' do
        click_on 'Aprovar'
      end

      expect(current_path).to eq(project_path(proposal.project))
      expect(page).to have_content(
        'Proposta aprovada com sucesso. '\
        "Agora você pode trocar mensagens com #{proposal.professional.name}"
      )
      within '#proposal-1' do
        expect(page).to have_content('Status: Aprovada')
        expect(page).to have_content('Aprovada em 18/01/2022')
      end
    end
  end
end
