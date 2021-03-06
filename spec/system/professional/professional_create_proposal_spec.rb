require 'rails_helper'

describe 'Professional create proposal' do
  it 'and must be signed in' do
    user = create(:user)
    pj1 = Project.create!(
      {
        title: 'Projeto 1',
        description: 'lorem ipsum dolor sit amet',
        desired_abilities: 'UX, banco de dados',
        value_per_hour: 100,
        due_date: '13/10/2021',
        remote: true,
        creator: user
      }
    )
    visit new_project_proposal_path(pj1)

    expect(current_path).to eq(new_professional_session_path)
  end

  it 'successfully' do
    user = create(:user)
    pj1 = Project.create!(
      {
        title: 'Projeto 1',
        description: 'lorem ipsum dolor sit amet',
        desired_abilities: 'UX, banco de dados',
        value_per_hour: 100,
        due_date: '13/10/2021',
        remote: true,
        creator: user
      }
    )
    professional = create(:completed_profile_professional)
    login_as professional, scope: :professional

    visit project_path(pj1)
    click_on 'Fazer proposta'
    fill_in 'Mensagem', with: 'Tenho 5 anos de experiência nas tecnologias '\
                              'solicitadas e já trabalhei em empresas do '\
                              'mesmo ramo de atuação.'
    fill_in 'Valor por hora', with: 100
    fill_in 'Horas disponíveis por semana', with: 20
    fill_in 'Expectativa de conclusão', with: '14/10/2021'
    click_on 'Criar Proposta'

    expect(current_path).to eq(project_path(pj1))
    expect(page).to have_content('Sua proposta')
    expect(page).to have_link('Projeto 1', href: project_path(pj1))
    expect(page).to have_content(
      'Mensagem: Tenho 5 anos de experiência nas '\
      'tecnologias solicitadas e já trabalhei em empresas do mesmo ramo de '\
      'atuação.'
    )
    expect(page).to have_content('Valor por hora: R$ 100,00')
    expect(page).to have_content('Horas disponíveis por semana: 20')
    expect(page).to have_content('Expectativa de conclusão: 14/10/2021')
    expect(page).to have_content('Status: Pendente')
  end

  it 'and must fill all fields' do
    user = create(:user)
    pj1 = Project.create!(
      {
        title: 'Projeto 1',
        description: 'lorem ipsum dolor sit amet',
        desired_abilities: 'UX, banco de dados',
        value_per_hour: 100,
        due_date: '13/10/2021',
        remote: true,
        creator: user
      }
    )
    professional = create(:completed_profile_professional)
    login_as professional, scope: :professional

    visit new_project_proposal_path(pj1)
    fill_in 'Valor por hora', with: ''
    fill_in 'Horas disponíveis por semana', with: '0'
    click_on 'Criar Proposta'

    expect(page).to have_content('Mensagem não pode ficar em branco')
    expect(page).to have_content('Valor por hora não pode ficar em branco')
    expect(page).to have_content('Valor por hora não é um número')
    expect(page).to have_content(
      'Horas disponíveis por semana deve ser maior que 0'
    )
    expect(page).to have_content(
      'Expectativa de conclusão não pode ficar em branco'
    )
  end

  it 'and view own proposals' do
    user = create(:user)
    pj1, pj2 = Project.create!(
      [
        {
          title: 'Projeto 1',
          description: 'lorem ipsum dolor sit amet',
          desired_abilities: 'UX, banco de dados',
          value_per_hour: 100,
          due_date: '13/10/2021',
          remote: true,
          creator: user
        },
        {
          title: 'Projeto 2',
          description: 'consectetur adipisicing, elit',
          desired_abilities: 'dev, design',
          value_per_hour: 55,
          due_date: '15/01/2023',
          remote: false,
          creator: user
        }
      ]
    )

    professional = create(:completed_profile_professional)
    another_professional = create(:completed_profile_professional)

    prop1, prop2, prop3 = Proposal.create!(
      [
        {
          message: 'Proposta irrecusável',
          value_per_hour: 999,
          hours_per_week: 7,
          finish_date: '10/07/1995',
          project: pj1,
          professional: professional
        },
        {
          message: 'Proposta irrecusável 2',
          value_per_hour: 9999,
          hours_per_week: 168,
          finish_date: '11/12/1314',
          project: pj2,
          professional: professional
        },
        {
          message: 'Proposta irrecusável 3',
          value_per_hour: 84,
          hours_per_week: 21,
          finish_date: '16/10/2021',
          project: pj2,
          professional: another_professional
        }
      ]
    )
    login_as professional, scope: :professional

    visit root_path
    click_on 'Meus projetos'

    expect(page).to have_content('Minhas propostas')
    expect(page).to have_content(prop1.message)
    expect(page).to have_content(prop2.message)
    expect(page).not_to have_content(prop3.message)
  end

  it 'and there\'s no proposals' do
    user = create(:user)
    pj1 = Project.create!(
      {
        title: 'Projeto 1',
        description: 'lorem ipsum dolor sit amet',
        desired_abilities: 'UX, banco de dados',
        value_per_hour: 100,
        due_date: '13/10/2021',
        remote: true,
        creator: user
      }
    )
    professional = create(:completed_profile_professional)
    another_professional = create(:completed_profile_professional)
    Proposal.create!(
      {
        message: 'Proposta irrecusável',
        value_per_hour: 999,
        hours_per_week: 7,
        finish_date: '10/07/1995',
        project: pj1,
        professional: another_professional
      }
    )
    login_as professional, scope: :professional

    visit my_projects_path

    expect(page).to have_content('Minhas propostas')
    expect(page).to have_content('Você não fez propostas ainda')
    expect(page).not_to have_content(
      "Enviado por: #{another_professional.name}"
    )
  end

  it 'and edit proposal' do
    user = create(:user)
    pj1 = Project.create!(
      {
        title: 'Projeto 1',
        description: 'lorem ipsum dolor sit amet',
        desired_abilities: 'UX, banco de dados',
        value_per_hour: 100,
        due_date: '13/10/2021',
        remote: true,
        creator: user
      }
    )
    professional = create(:completed_profile_professional)
    Proposal.create!(
      {
        message: 'Proposta irrecusável',
        value_per_hour: 999,
        hours_per_week: 7,
        finish_date: '10/07/1995',
        project: pj1,
        professional: professional
      }
    )
    login_as professional, scope: :professional

    visit my_projects_path
    within '#proposal-1' do
      click_on 'Editar'
    end
    fill_in 'Mensagem', with: 'Outra mensagem'
    fill_in 'Valor por hora', with: 100
    fill_in 'Horas disponíveis por semana', with: 20
    fill_in 'Expectativa de conclusão', with: '14/10/2021'
    click_on 'Atualizar Proposta'

    expect(page).to have_link('Projeto 1', href: project_path(pj1))
    expect(page).to have_content('Mensagem: Outra mensagem')
    expect(page).to have_content('Valor por hora: R$ 100,00')
    expect(page).to have_content('Horas disponíveis por semana: 20')
    expect(page).to have_content('Expectativa de conclusão: 14/10/2021')
  end

  it 'and can only make one proposal per project' do
    user = create(:user)
    pj1 = Project.create!(
      {
        title: 'Projeto 1',
        description: 'lorem ipsum dolor sit amet',
        desired_abilities: 'UX, banco de dados',
        value_per_hour: 100,
        due_date: '13/10/2021',
        remote: true,
        creator: user
      }
    )
    professional = create(:completed_profile_professional)
    Proposal.create!(
      {
        message: 'Proposta irrecusável',
        value_per_hour: 999,
        hours_per_week: 7,
        finish_date: '10/07/1995',
        project: pj1,
        professional: professional
      }
    )
    login_as professional, scope: :professional

    visit new_project_proposal_path(pj1)

    expect(current_path).to eq(project_path(pj1))
    expect(page).to have_content('Você já fez uma proposta nesse projeto')
    expect(page).to have_content('Mensagem: Proposta irrecusável')
    expect(page).not_to have_link('Fazer proposta')
  end

  it 'and can not update with empty fields' do
    user = create(:user)
    pj1 = Project.create!(
      {
        title: 'Projeto 1',
        description: 'lorem ipsum dolor sit amet',
        desired_abilities: 'UX, banco de dados',
        value_per_hour: 100,
        due_date: '13/10/2021',
        remote: true,
        creator: user
      }
    )
    professional = create(:completed_profile_professional)
    prop1 = Proposal.create!(
      {
        message: 'Proposta irrecusável',
        value_per_hour: 999,
        hours_per_week: 7,
        finish_date: '10/07/1995',
        project: pj1,
        professional: professional
      }
    )
    login_as professional, scope: :professional

    visit edit_proposal_path(prop1)
    fill_in 'Mensagem', with: ''
    fill_in 'Valor por hora', with: ''
    fill_in 'Horas disponíveis por semana', with: 0
    fill_in 'Expectativa de conclusão', with: ''
    click_on 'Atualizar Proposta'

    expect(page).to have_content('Mensagem não pode ficar em branco')
    expect(page).to have_content('Valor por hora não pode ficar em branco')
    expect(page).to have_content('Valor por hora não é um número')
    expect(page).to have_content(
      'Horas disponíveis por semana deve ser maior que 0'
    )
    expect(page).to have_content(
      'Expectativa de conclusão não pode ficar em branco'
    )
  end
end
