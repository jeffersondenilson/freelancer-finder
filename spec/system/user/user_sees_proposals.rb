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
      expect(page).to have_content('Status: Pendente')
      expect(page).to have_content('Valor por hora: R$ 9,99')
      expect(page).to have_content('Horas disponíveis por semana: '\
                                   "#{proposal.hours_per_week}")
      expect(page).to have_content('Expectativa de conclusão: '\
                                   "#{I18n.l proposal.finish_date}")
    end
    within '#proposal-2' do
      expect(page).to have_content("Mensagem: #{another_proposal.message}")
      expect(page).to have_content('Enviado por: '\
                                   "#{another_proposal.professional.name}")
      expect(page).to have_content('Status: Pendente')
      expect(page).to have_content('Valor por hora: R$ 9,99')
      expect(page).to have_content('Horas disponíveis por semana: '\
                                   "#{another_proposal.hours_per_week}")
      expect(page).to have_content('Expectativa de conclusão: '\
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
    another_proposal = create(
      :proposal, project: project, message: 'Will be canceled while pending'
    )
    another_proposal.canceled_pending!

    login_as project.creator, scope: :user
    visit project_path(project)

    expect(page).to have_content('Propostas')
    within '#proposal-1' do
      expect(page).to have_content("Mensagem: #{proposal.message}")
      expect(page).to have_content("Enviado por: #{proposal.professional.name}")
      expect(page).to have_content('Status: Pendente')
      expect(page).to have_content('Valor por hora: R$ 9,99')
      expect(page).to have_content('Horas disponíveis por semana: '\
                                   "#{proposal.hours_per_week}")
      expect(page).to have_content('Expectativa de conclusão: '\
                                   "#{I18n.l proposal.finish_date}")
    end

    expect(page).not_to have_content("Mensagem: #{another_proposal.message}")
    expect(page).not_to have_content('Enviado por: '\
                                     "#{another_proposal.professional.name}")
  end

  it 'and should see cancel reason when canceled_approved' do
    project = create(:project)
    proposal = create(:proposal, project: project, approved_at: Time.zone.today)
    proposal.canceled_approved!
    ProposalCancelation.create!(
      cancel_reason: 'This was canceled',
      proposal: proposal
    )

    login_as project.creator, scope: :user
    visit project_path(project)

    within '#proposal-1' do
      expect(page).to have_content("Mensagem: #{proposal.message}")
      expect(page).to have_content("Enviado por: #{proposal.professional.name}")
      expect(page).to have_content('Status: Cancelada')
      expect(page).to have_content(
        "Motivo de cancelamento: #{proposal.proposal_cancelation.cancel_reason}"
      )
      expect(page).to have_content('Valor por hora: R$ 9,99')
      expect(page).to have_content('Horas disponíveis por semana: '\
                                   "#{proposal.hours_per_week}")
      expect(page).to have_content('Expectativa de conclusão: '\
                                   "#{I18n.l proposal.finish_date}")
    end
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

  it 'and should authenticate to see professional profile' do
    professional = create(:full_profile_professional)

    visit professional_path(professional)

    expect(current_path).to eq('/users/sign_in')
    expect(page).to have_content('Para continuar, efetue login ou registre-se.')
  end

  it 'and should see proposals at professional profile' do
    user = create(:user)
    project1 = create(:project, creator: user)
    project2 = create(:project, creator: user)

    professional = create(:full_profile_professional)
    proposal1 = create(
      :proposal, project: project1, professional: professional
    )
    proposal2 = create(
      :proposal, project: project2, professional: professional
    )
    login_as user, scope: :user

    visit professional_path(professional)

    expect(page).to have_content('Propostas pendentes')
    within '#proposal-1' do
      expect(page).to have_content("Projeto: #{project1.title}")
      expect(page).to have_content("Mensagem: #{proposal1.message}")
      expect(page).to have_content("Enviado por: #{professional.name}")
    end
    within '#proposal-2' do
      expect(page).to have_content("Projeto: #{project2.title}")
      expect(page).to have_content("Mensagem: #{proposal2.message}")
      expect(page).to have_content("Enviado por: #{professional.name}")
    end
  end

  it 'and should not see another projects proposals at professional profile' do
    project1 = create(:project)
    project2 = create(:project)

    professional = create(:full_profile_professional)
    proposal1 = create(
      :proposal, project: project1, professional: professional
    )
    proposal2 = create(
      :proposal, project: project2, professional: professional,
                 message: 'Should not be seen'
    )
    login_as project1.creator, scope: :user

    visit professional_path(professional)

    expect(page).to have_content('Propostas pendentes')
    within '#proposal-1' do
      expect(page).to have_content("Projeto: #{project1.title}")
      expect(page).to have_content("Mensagem: #{proposal1.message}")
      expect(page).to have_content("Enviado por: #{professional.name}")
    end
    expect(page).not_to have_content("Projeto: #{project2.title}")
    expect(page).not_to have_content("Mensagem: #{proposal2.message}")
  end

  it 'and should see only pending proposals at professional profile' do
    project = create(:project)

    professional = create(:full_profile_professional)
    proposal1 = create(
      :proposal, project: project, professional: professional
    )
    proposal2 = create(
      :proposal, project: project, professional: professional,
                 message: 'Should not be seen'
    )
    proposal2.canceled_pending!
    login_as project.creator, scope: :user

    visit professional_path(professional)

    expect(page).to have_content('Propostas pendentes')
    within '#proposal-1' do
      expect(page).to have_content("Projeto: #{project.title}")
      expect(page).to have_content("Mensagem: #{proposal1.message}")
      expect(page).to have_content("Enviado por: #{professional.name}")
    end
    expect(page).not_to have_content("Mensagem: #{proposal2.message}")
  end
end
