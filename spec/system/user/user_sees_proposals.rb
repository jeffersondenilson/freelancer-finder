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

  it 'and there\'s no proposals yet' do
    project = create(:project)

    login_as project.creator, scope: :user
    visit project_path(project)

    expect(page).to have_content('Esse projeto ainda não recebeu propostas')
  end

  it 'and should not see canceled_pending proposals' do
    project = create(:project)
    proposal = create(:proposal, project: project)
    another_proposal = create(:proposal, project: project,
      message: 'Will be canceled while pending')
    another_proposal.canceled_pending!

    login_as project.creator, scope: :user
    visit project_path(project)

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

    expect(page).not_to have_content("Mensagem: #{another_proposal.message}")
    expect(page).not_to have_content("Enviado por: "\
      "#{another_proposal.professional.name}")
  end

  it 'and should see professional profile' do
    project = create(:project)
    proposal = create(:proposal, project: project)
    professional = proposal.professional

    login_as project.creator, scope: :user
    visit project_path(project)
    click_on professional.name

    expect(current_path).to eq('/professionals/1')
    expect(page).to have_content("Nome: #{professional.name}")
    expect(page).to have_content("E-mail: #{professional.email}")
    expect(page).to have_content("Descrição: #{professional.description}")
    expect(page).to have_content("Formação: #{professional.education}")
    expect(page).to have_content("Experiência: #{professional.experience}")
    expect(page).to have_content("Habilidades: #{professional.abilities}")
  end
end
