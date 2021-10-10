require 'rails_helper'

describe 'User view projects' do
  it 'and there\'s no projects' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com', 
      password: '123456')
    login_as jane, scope: :user
    
    visit root_path

    expect(page).to have_content('Você ainda não tem projetos')
    expect(page).to have_link('Crie um projeto', href: new_project_path)
  end

  it 'and view owned projects' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com', 
      password: '123456')
    john = User.create!(name: 'John Doe', email: 'john.doe@email.com', 
      password: '123456')
    pj1, pj2 = Project.create!([
      {
        title: 'Projeto 1',
        description: 'lorem ipsum...',
        desired_abilities: 'design',
        value_per_hour: 12.34,
        due_date: '09/10/2021',
        remote: true,
        creator: jane
      },
      {
        title: 'Projeto 2',
        description: 'lorem ipsum dolor sit amet',
        desired_abilities: 'UX, dev, design',
        value_per_hour: 9.99,
        due_date: '19/11/2022',
        remote: false,
        creator: john
      }
    ])
    login_as jane, scope: :user
    
    visit root_path

    expect(Project.count).to eq(2)
    expect(page).to have_content("Título: #{pj1.title}")
    expect(page).to have_content('Criado por: Jane Doe')
    expect(page).not_to have_content("Título: #{pj2.title}")
    expect(page).not_to have_content('Criado por: John Doe')
  end

  it 'and view one project' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com', 
      password: '123456')
    login_as jane, scope: :user

    pj1 = Project.create!({
      title: 'Projeto 1',
      description: 'lorem ipsum...',
      desired_abilities: 'design',
      value_per_hour: 12.34,
      due_date: '09/10/2021',
      remote: true,
      creator: jane
    })

    visit root_path
    click_on 'Projeto 1'

    expect(current_path).to eq(project_path(pj1))
    expect(page).to have_content('Título: Projeto 1')
    expect(page).to have_content('Descrição: lorem ipsum...')
    expect(page).to have_content('Habilidades desejadas: design')
    expect(page).to have_content('Valor por hora: R$ 12,34')
    expect(page).to have_content('Data limite: 09/10/2021')
    expect(page).to have_content('Trabalho remoto')
    expect(page).to have_content('Criado por: Jane Doe')
  end

  it 'and can not view another user\'s project' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com', 
      password: '123456')
    john = User.create!(name: 'John Doe', email: 'john.doe@email.com', 
      password: '123456')
    pj2 = Project.create!({
      title: 'Projeto 2',
      description: 'lorem ipsum dolor sit amet',
      desired_abilities: 'UX, dev, design',
      value_per_hour: 9.99,
      due_date: '19/11/2022',
      remote: false,
      creator: john
    })
    login_as jane, scope: :user
    
    visit project_path(pj2)

    expect(current_path).to eq(root_path)
    expect(page).not_to have_content('Título: Projeto 2')
    expect(page).not_to have_content('Criado por: John Doe')
  end

  it 'and can not view projects index page'
end
