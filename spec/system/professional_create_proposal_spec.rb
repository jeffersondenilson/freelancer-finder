require 'rails_helper'

describe 'Professional create proposal' do
  it 'and must be signed in' do
    visit new_proposal_path

    expect(current_path).to eq(new_professional_session_path)
  end

  it 'successfully' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com', password: '123456')
    pj1 = Project.create!({
      title: 'Projeto 1',
      description: 'lorem ipsum dolor sit amet',
      desired_abilities: 'UX, banco de dados',
      value_per_hour: 100,
      due_date: '13/10/2021',
      remote: true,
      creator: jane
    })
    john = Professional.create!(name: 'John Doe', email: 'john.doe@email.com', 
      password: '123456', birth_date: '01/01/1980', completed_profile: true)
    login_as john, scope: :professional

    visit project_path(pj1)
    click_on 'Fazer proposta'
    fill_in 'Mensagem', with: 'Tenho 5 anos de experiência nas tecnologias '\
      'solicitadas e já trabalhei em empresas do mesmo ramo de atuação.'
    fill_in 'Valor por hora', with: 100
    fill_in 'Horas disponíveis por semana', with: 20
    fill_in 'Expectativa de conclusão', with: '14/10/2021'
    click_on 'Criar Proposta'

    expect(current_path).to eq(project_path(pj1))
    expect(page).to have_content('Sua proposta')
    expect(page).to have_content('Mensagem: Tenho 5 anos de experiência nas '\
      'tecnologias solicitadas e já trabalhei em empresas do mesmo ramo de atuação.')
    expect(page).to have_content('Valor por hora: R$ 100,00')
    expect(page).to have_content('Horas disponíveis por semana: 20')
    expect(page).to have_content('Expectativa de conclusão: 14/10/2021')
    expect(page).to have_content('Status: pendente')
  end

  it 'and must fill all fields'
  it 'and view own proposals'
  it 'and edit proposal'
  it 'and cancel proposal'
end
