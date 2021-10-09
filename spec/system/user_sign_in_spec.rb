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

    # TODO: redirecionar usuario para projects
    expect(page).to have_selector('li', text: 'Jane Doe')
    # TODO: verificar href de criar projeto
    expect(page).to have_link('Criar projeto')
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

  it 'and view professionals'

  it 'and can not view page without login'
end
