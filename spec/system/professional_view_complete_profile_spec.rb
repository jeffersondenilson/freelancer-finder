require 'rails_helper'

describe 'Professional view complete profile' do
  it 'successfully' do
    john = Professional.create!(name: 'John Doe', email: 'john.doe@email.com', password: '123456')
    login_as john, scope: :professional
    
    visit root_path

    expect(current_path).to eq(edit_professional_registration_path(john))
    expect(page).to have_selector('h2', text: 'Complete o seu perfil para continuar')
  end

  it 'and must complete profile to navigate' do
    john = Professional.create!(name: 'John Doe', email: 'john.doe@email.com', password: '123456')
    login_as john, scope: :professional
    
    visit root_path
    click_on 'Buscar projetos'

    expect(current_path).to eq(edit_professional_registration_path(john))
    expect(page).to have_selector('h2', text: 'Complete o seu perfil para continuar')
  end

  it 'and complete profile' do
    john = Professional.create!(name: 'John Doe', email: 'john.doe@email.com', password: '123456')
    login_as john, scope: :professional
    
    visit root_path
    fill_in 'Nome social', with: 'J. Doe'
    fill_in 'Nome completo', with: 'Just John Doe'
    fill_in 'Data de nascimento', with: '01/01/1980'
    fill_in 'Formação', with: 'Lorem Ipsum'
    fill_in 'Descrição', with: 'Lorem ipsum dolor sit amet'
    fill_in 'Experiência', with: 'consectetur adipisicing elit'
    fill_in 'Habilidades', with: 'dev, UX, designer'
    fill_in 'URL da foto de perfil', with: 'http://placekitten.com/200/300'
    fill_in 'Senha atual', with: '123456'
    click_on 'Enviar'

    expect(current_path).to eq(root_path)
    expect(page).to have_content('Sua conta foi atualizada com sucesso.')
    expect(page).to have_content('Meu perfil')
    expect(page).to have_selector('[data-test=username]', text: 'J. Doe')
    expect(page).to have_content('Nome social: J. Doe')
    expect(page).to have_content('Nome completo: Just John Doe')
    expect(page).to have_content('Data de nascimento: 01/01/1980')
    expect(page).to have_content('Formação: Lorem Ipsum')
    expect(page).to have_content('Descrição: Lorem ipsum dolor sit amet')
    expect(page).to have_content('Experiência: consectetur adipisicing elit')
    expect(page).to have_content('Habilidades: dev, UX, designer')
    expect(page).to have_selector('img#profile-picture')
  end

  it 'and must fill all required fields to complete profile' do
    john = Professional.create!(name: 'John Doe', email: 'john.doe@email.com', password: '123456')
    login_as john, scope: :professional
    
    visit root_path
    fill_in 'Nome social', with: ''
    fill_in 'Senha atual', with: '123456'
    click_on 'Enviar'

    expect(page).to have_content('Não foi possível salvar profissional')
    expect(page).to have_content('Nome não pode ficar em branco')
    expect(page).to have_content('Nome completo não pode ficar em branco')
    expect(page).to have_content('Data de nascimento não pode ficar em branco')
    expect(page).to have_content('Formação não pode ficar em branco')
    expect(page).to have_content('Descrição não pode ficar em branco')
    expect(page).to have_content('Habilidades não pode ficar em branco')
    expect(page).not_to have_content('Experiência não pode ficar em branco')
    expect(page).not_to have_content('Foto de perfil não pode ficar em branco')
  end

  it 'and can edit profile after completing'
end
