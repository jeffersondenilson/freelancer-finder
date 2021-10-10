require 'rails_helper'

describe 'User sign in' do
  it 'successfully' do
    User.create!(name: 'Jane Doe', email: 'jane.doe@email.com', password: '123456')
    visit root_path

    click_on 'Contratar freelancers'
    click_on 'Entrar'
    fill_in 'Email', with: 'jane.doe@email.com'
    fill_in 'Senha', with: '123456'
    click_on 'Entrar'

    expect(page).to have_selector('li', text: 'Jane Doe')
    expect(page).to have_link('Criar projeto', href: new_project_path)
    expect(page).not_to have_link('Buscar projetos')
  end

  it 'and must fill all fields' do
    User.create!(name: 'Jane Doe', email: 'jane.doe@email.com', password: '123456')
    visit root_path

    click_on 'Contratar freelancers'
    click_on 'Entrar'
    click_on 'Entrar'

    expect(current_path).to eq(new_user_session_path)
    expect(page).to have_content('Email ou senha inválida.')
  end

  it 'and sign out' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com', password: '123456')
    login_as jane, scope: :user
    visit root_path

    click_on 'Sair'

    expect(current_path).to eq(root_path)
    expect(page).to have_selector('h1', text: 'Encontre freelancers!')
  end

  it 'and view professionals'
end
