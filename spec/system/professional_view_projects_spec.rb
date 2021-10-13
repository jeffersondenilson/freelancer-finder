require 'rails_helper'

describe 'Professional view projects' do
  it 'successfully' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com',
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
        creator: jane
      }
    ])
    john = Professional.create!(name: 'John Doe', email: 'john.doe@email.com',
      password: '123456', birth_date: '01/01/1980', completed_profile: true)
    login_as john, scope: :professional

    visit root_path
    click_on 'Buscar projetos'

    expect(current_path).to eq(projects_path)
    expect(page).to have_content('Título: Projeto 1')
    expect(page).to have_content('Título: Projeto 2')
  end

  it 'and view one project' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com',
      password: '123456')
    pj1 = Project.create!({
      title: 'Projeto 1',
      description: 'lorem ipsum...',
      desired_abilities: 'design',
      value_per_hour: 12.34,
      due_date: '09/10/2021',
      remote: true,
      creator: jane
    })
    john = Professional.create!(name: 'John Doe', email: 'john.doe@email.com',
      password: '123456', birth_date: '01/01/1980', completed_profile: true)
    login_as john, scope: :professional

    visit root_path
    click_on 'Buscar projetos'
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

  it 'and search projects' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com',
      password: '123456')
    pj1, pj2, pj3 = Project.create!([
      {
        title: 'Laughing Pancake',
        description: 'Similique illo, asperiores eos officiis',
        desired_abilities: 'design',
        value_per_hour: 12.34,
        due_date: '09/10/2021',
        remote: true,
        creator: jane
      },
      {
        title: 'Symmetrical Octo Parakeet',
        description: 'lorem ipsum dolor sit amet',
        desired_abilities: 'UX, dev, design',
        value_per_hour: 9.99,
        due_date: '19/11/2022',
        remote: false,
        creator: jane
      },
      {
        title: 'Redesigned Sniffle',
        description: 'fantastic octo potato',
        desired_abilities: 'UX, dev, design',
        value_per_hour: 9.99,
        due_date: '19/11/2022',
        remote: false,
        creator: jane
      }
    ])
    john = Professional.create!(name: 'John Doe', email: 'john.doe@email.com',
      password: '123456', birth_date: '01/01/1980', completed_profile: true)
    login_as john, scope: :professional

    visit root_path
    click_on 'Buscar projetos'
    fill_in 'Buscar por', with: 'octo'
    click_on 'Buscar'

    expect(page).to have_content(pj2.title)
    expect(page).to have_content(pj3.title)
    expect(page).not_to have_content(pj1.title)
  end

  it 'and can not view projects with closed registrations'
  it 'and can not view finished projects'
end
