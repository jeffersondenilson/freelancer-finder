require 'rails_helper'

describe 'User authentication' do
  it 'can not view a project without sign in' do
    jane = User.create!(name: 'Jane Doe', email: 'jane.doe@email.com', password: '123456')
    pj1 = Project.create!(title: 'Projeto 1', description: 'lorem ipsum...', 
      desired_abilities: 'design', value_per_hour: 12.34, due_date: '09/10/2021', 
      remote: true, creator: jane)

    get '/projects/1'

    expect(flash[:alert]).to eq("Você deve estar logado.")
    expect(response).to redirect_to('/')
  end
end
