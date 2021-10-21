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
    expect(page).to have_selector('h1', text: 'Freelancer finder')
  end
end
