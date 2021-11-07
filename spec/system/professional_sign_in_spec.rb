require 'rails_helper'

describe 'Professional sign in' do
  it 'successfully' do
    professional = create(:professional)

    visit root_path

    click_on 'Encontrar projetos'
    click_on 'Entrar'
    fill_in 'Email', with: professional.email
    fill_in 'Senha', with: professional.password
    click_on 'Entrar'

    expect(page).to have_selector(
      '[data-test=username]', text: professional.name
    )
    expect(page).to have_link('Buscar projetos', href: projects_path)
    expect(page).not_to have_link('Criar projeto', href: new_project_path)
  end

  it 'and must fill all fields' do
    create(:professional)

    visit root_path

    click_on 'Encontrar projetos'
    click_on 'Entrar'
    click_on 'Entrar'

    expect(current_path).to eq(new_professional_session_path)
    expect(page).to have_content('Email ou senha inválida.')
  end

  it 'and sign out' do
    professional = create(:professional)
    login_as professional, scope: :professional
    visit root_path

    click_on 'Sair'

    expect(current_path).to eq(root_path)
    expect(page).to have_selector('h1', text: 'Freelancer finder')
  end
end
