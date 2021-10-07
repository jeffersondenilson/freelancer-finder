require 'rails_helper'

describe 'Visitor create user account' do
  it 'successfully' do
    visit root_path

    click_on 'Contratar freelancers'
    fill_in 'Nome', with: 'Jane Doe'
    fill_in 'Email', with: 'jane.doe@email.com'
    fill_in 'Senha', with: '123456'
    fill_in 'Confirmação de senha', with: '123456'
    click_on 'Criar conta'

    # TODO: redirecionar usuario para projects
    expect(page).to have_selector('[data-test=username]', text: 'Jane Doe')
  end

  it 'and can not create with empty fields'
end
