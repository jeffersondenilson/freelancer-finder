require 'rails_helper'

describe 'Professional sign in' do
  it 'successfully' do
    Professional.create!(name: 'John Doe', email: 'john.doe@email.com', password: '123456')
    visit root_path

    click_on 'Encontrar projetos'
    click_on 'Entrar'
    fill_in 'Email', with: 'john.doe@email.com'
    fill_in 'Senha', with: '123456'
    click_on 'Entrar'

    expect(page).to have_selector('li', text: 'John Doe')
    expect(page).to have_link('Buscar projetos', href: projects_path)
    expect(page).not_to have_link('Criar projeto', href: new_project_path)
  end

  it 'and must fill all fields' do
    Professional.create!(name: 'John Doe', email: 'john.doe@email.com', password: '123456')
    visit root_path

    click_on 'Encontrar projetos'
    click_on 'Entrar'
    click_on 'Entrar'

    expect(current_path).to eq(new_professional_session_path)
    expect(page).to have_content('Email ou senha inválida.')
  end

  it 'and sign out' do
    john = Professional.create!(name: 'John Doe', email: 'john.doe@email.com', password: '123456')
    login_as john, scope: :professional
    visit root_path

    click_on 'Sair'

    expect(current_path).to eq(root_path)
    expect(page).to have_selector('h1', text: 'Encontre freelancers!')
  end

  # TODO: mover testes de completar perfil para outro arquivo
  it 'and view complete profile page' do
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
    fill_in 'Foto de perfil', with: 'http://placekitten.com/200/300'
    fill_in 'Senha atual', with: '123456'
    click_on 'Enviar'

    expect(current_path).to eq(root_path)
    expect(page).to have_content('Sua conta foi atualizada com sucesso.')
    expect(page).to have_content('Meu perfil')
    expect(page).to have_selector('li', text: 'J. Doe')
    expect(page).to have_content('Nome social: J. Doe')
    expect(page).to have_content('Nome completo: Just John Doe')
    expect(page).to have_content('Data de nascimento: 01/01/1980')
    expect(page).to have_content('Formação: Lorem Ipsum')
    expect(page).to have_content('Descrição: Lorem ipsum dolor sit amet')
    expect(page).to have_content('Experiência: consectetur adipisicing elit')
    expect(page).to have_content('Habilidades: dev, UX, designer')
    expect(page).to have_selector('img#profile-picture')
  end

  it 'and must fill all required fields to complete profile'

  # TODO: mover para testes de profissional vê projetos
  it 'and view projects'
end

# :full_name, :string, default: ""
# :birth_date, :date, default: ""
# :education, :text, default: ""
# :description, :text, default: ""
# :experience, :text, default: ""
# :abilities, :text, default: ""
# :profile_picture_url, :string, default: ""
# :completed_profile, :boolean, default: false
