require 'rails_helper'

describe 'Visitor create professional account' do
  it 'successfully' do
    visit root_path

    click_on 'Encontrar projetos'
    fill_in 'Nome', with: 'John Doe'
    fill_in 'Email', with: 'john.doe@email.com'
    fill_in 'Senha', with: '123456'
    fill_in 'Confirmação de senha', with: '123456'
    click_on 'Criar conta'

    expect(page).to have_selector('li', text: 'John Doe')
  end

  it 'and must fill all fields' do
    visit root_path

    click_on 'Encontrar projetos'
    click_on 'Criar conta'

    expect(current_path).to eq(professional_registration_path)
    expect(page).to have_content('Nome não pode ficar em branco')
    expect(page).to have_content('Email não pode ficar em branco')
    expect(page).to have_content('Senha não pode ficar em branco')
  end
end
