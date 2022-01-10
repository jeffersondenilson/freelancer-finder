require 'rails_helper'

describe 'User sees proposals' do
  it 'successfully' do
    project = create(:project)

    proposal = create(:proposal, project: project)
    another_proposal = create(:proposal, project: project)

    login_as project.creator, scope: :user
    visit root_path
    click_on project.title

    expect(page).to have_content('Propostas')
    within '#proposal-1' do
      expect(page).to have_content("Mensagem: #{proposal.message}")
      expect(page).to have_content("Enviado por: #{proposal.professional.name}")
      expect(page).to have_content("Status: Pendente")
      expect(page).to have_content("Valor por hora: "\
        "R$ #{proposal.value_per_hour.to_s.sub('.', ',')}")
      expect(page).to have_content("Horas disponíveis por semana: "\
        "#{proposal.hours_per_week}")
      expect(page).to have_content("Expectativa de conclusão: "\
        "#{I18n.l proposal.finish_date}")
    end
    within '#proposal-2' do
      expect(page).to have_content("Mensagem: #{another_proposal.message}")
      expect(page).to have_content("Enviado por: "\
        "#{another_proposal.professional.name}")
      expect(page).to have_content("Status: Pendente")
      expect(page).to have_content("Valor por hora: "\
        "R$ #{another_proposal.value_per_hour.to_s.sub('.', ',')}")
      expect(page).to have_content("Horas disponíveis por semana: "\
        "#{another_proposal.hours_per_week}")
      expect(page).to have_content("Expectativa de conclusão: "\
        "#{I18n.l another_proposal.finish_date}")
    end
  end
end
