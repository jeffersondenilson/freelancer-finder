require 'rails_helper'

describe 'User create projects' do
  it 'and must be signed in' do
    visit my_projects_projects_path

    expect(current_path).to eq(new_user_session_path)
  end

  it 'successfully' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com', 
      password: 'he217tw8')
    login_as(jane, scope: :user)

    visit my_projects_projects_path
    click_on 'Criar projeto'
    fill_in 'Título', with: 'Meu primeiro projeto'
    fill_in 'Descrição', with: 'Lorem ipsum dolor sit amet'
    fill_in 'Habilidades desejadas', with: 'dev, designer, UX'
    fill_in 'Valor por hora', with: 5.99
    fill_in 'Data limite', with: '08/10/2021'
    check 'Trabalho Remoto?'
    click_on 'Criar'

    expect(Project.count).to eq(1)
    expect(current_path).to eq(project_path(Project.last))
    expect(page).to have_selector('Título: Meu primeiro projeto')
    expect(page).to have_selector('Descrição: Lorem ipsum dolor sit amet')
    expect(page).to have_selector('Habilidades desejadas: dev, designer, UX')
    expect(page).to have_selector('Valor por hora: R$ 5,99')
    expect(page).to have_selector('Data limite: 08/10/2021')
    expect(page).to have_selector('Trabalho remoto')
  end

  it 'and must fill all fields'
  it 'and edit project'

  it 'and there\'s no projects'
  it 'and view own projects'
  it 'and view project'
end
