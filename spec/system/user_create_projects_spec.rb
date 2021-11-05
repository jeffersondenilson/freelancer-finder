require 'rails_helper'

describe 'User create projects' do
  it 'and must be signed in' do
    visit new_project_path

    expect(current_path).to eq(new_user_session_path)
  end

  it 'successfully' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com',
                        password: 'he217tw8')
    login_as jane, scope: :user

    visit root_path
    click_on 'Criar projeto'
    fill_in 'Título', with: 'Meu primeiro projeto'
    fill_in 'Descrição', with: 'Lorem ipsum dolor sit amet'
    fill_in 'Habilidades desejadas', with: 'dev, designer, UX'
    fill_in 'Valor por hora', with: 5.99
    fill_in 'Data limite', with: '08/10/2021'
    check 'Remoto'
    click_on 'Enviar'

    expect(Project.count).to eq(1)
    expect(current_path).to eq(project_path(Project.last))
    expect(page).to have_content('Projeto salvo com sucesso')
    expect(page).to have_content('Título: Meu primeiro projeto')
    expect(page).to have_content('Descrição: Lorem ipsum dolor sit amet')
    expect(page).to have_content('Habilidades desejadas: dev, designer, UX')
    expect(page).to have_content('Valor por hora: R$ 5,99')
    expect(page).to have_content('Data limite: 08/10/2021')
    expect(page).to have_content('Trabalho remoto')
    expect(page).to have_content('Criado por: Jane Doe')
  end

  it 'and must fill all fields' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com',
                        password: 'he217tw8')
    login_as jane, scope: :user

    visit new_project_path
    fill_in 'Valor por hora', with: ''
    click_on 'Enviar'

    expect(page).to have_content('Título não pode ficar em branco')
    expect(page).to have_content('Descrição não pode ficar em branco')
    expect(page).to have_content('Habilidades desejadas não pode ficar em branco')
    expect(page).to have_content('Valor por hora não pode ficar em branco')
    expect(page).to have_content('Data limite não pode ficar em branco')
  end

  it 'and edit project' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com',
                        password: 'he217tw8')
    project = Project.create!(title: 'Projeto 1', description: 'lorem ipsum...',
                              desired_abilities: 'design', value_per_hour: 12.34, due_date: '09/10/2021',
                              remote: true, creator: jane)
    login_as jane, scope: :user

    visit project_path(project)
    click_on 'Editar'
    fill_in 'Título', with: 'Novo nome'
    uncheck 'Remoto'
    click_on 'Enviar'

    expect(page).to have_content('Projeto atualizado com sucesso')
    expect(page).to have_content('Título: Novo nome')
    expect(page).to have_content('Trabalho presencial')
  end

  it 'and can not update with empty fields' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com',
                        password: 'he217tw8')
    project = Project.create!(title: 'Projeto 1', description: 'lorem ipsum...',
                              desired_abilities: 'design', value_per_hour: 12.34, due_date: '09/10/2021',
                              remote: true, creator: jane)
    login_as jane, scope: :user

    visit project_path(project)
    click_on 'Editar'
    fill_in 'Título', with: ''
    fill_in 'Descrição', with: ''
    fill_in 'Habilidades desejadas', with: ''
    fill_in 'Valor por hora', with: ''
    fill_in 'Data limite', with: ''
    click_on 'Enviar'

    expect(page).to have_content('Título não pode ficar em branco')
    expect(page).to have_content('Descrição não pode ficar em branco')
    expect(page).to have_content('Habilidades desejadas não pode ficar em branco')
    expect(page).to have_content('Valor por hora não pode ficar em branco')
    expect(page).to have_content('Data limite não pode ficar em branco')
  end
end
