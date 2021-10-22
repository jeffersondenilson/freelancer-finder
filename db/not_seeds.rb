# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# TODO: apagar
user_1 = User.create!({ name: 'Jane Doe', email: 'jane.doe@email.com', 
  password: '123456' })

user_2 = User.create!({ name: 'Alice', email: 'alice@email.com', 
  password: 'yu$*72u' })

# sempre é redirecionado para editar o perfil
incomplete_profile_professional = Professional.create!({ name: 'Hoo', 
  email: 'hoo@man.com', password: 'hooman' })

complete_profile_professional_1 = Professional.create!({
  name: 'John Doe', 
  email: 'john.doe@email.com',
  password: '123456',
  full_name: 'Just John Doe', 
  birth_date: '01/01/1980',
  education: 'lorem ipsum dolor sit amet', 
  experience: 'amet sit dolor ipsum lorem',
  abilities: 'UX, design, dev',
  profile_picture_url: 'http://placekitten.com/200/300',
  completed_profile: true
})

complete_profile_professional_2 = Professional.create!({
  name: 'Schneider', 
  email: 'schneider@email.com',
  password: 'uw891#&',
  full_name: 'Schneider', 
  birth_date: '16/12/2000',
  education: 'Nisi similique molestiae aut', 
  experience: 'Id sed sint sunt vero ut non et voluptate',
  abilities: 'banco de dados, UX',
  profile_picture_url: 'http://placekitten.com/200/287',
  completed_profile: true
})

project_1 = Project.create!({
  title: 'Jane\'s project 1',
  description: 'Laboriosam non ab aut',
  desired_abilities: 'UX, design',
  value_per_hour: 80,
  due_date: Time.current + 1.day,
  remote: true,
  user_id: user_1.id
})

project_2 = Project.create!({
  title: 'Alice\'s project',
  description: 'Qui quam occaecati repellendus quasi neque eos',
  desired_abilities: 'banco de dados',
  value_per_hour: 9.99,
  due_date: Time.current + 3.day,
  remote: false,
  user_id: user_2.id
})

project_3 = Project.create!({
  title: 'Jane\'s project 2',
  description: 'Neque porro quisquam est qui',
  desired_abilities: 'creatividade',
  value_per_hour: 23.85,
  due_date: Time.current - 3.day,
  remote: false,
  user_id: user_1.id
})

# TODO: criar propostas com status diferentes
proposal_1 = Proposal.create!({
  message: 'John\'s proposal on project 1',
  value_per_hour: 80.80,
  hours_per_week: 20,
  finish_date: Time.current + 3.day,
  status: :pending,
  project: project_1,
  professional: complete_profile_professional_1,
  # approved_at: Time.current,
  # cancel_reason: 'Rerum sed ipsam qui delectus ut excepturi fugit'
})

proposal_2 = Proposal.create!({
  message: 'Schneider\'s proposal on project 1',
  value_per_hour: 99.99,
  hours_per_week: 30,
  finish_date: Time.current + 1.week,
  status: :pending,
  project: project_1,
  professional: complete_profile_professional_2,
  # approved_at: Time.current,
  # cancel_reason: 'Rerum sed ipsam qui delectus ut excepturi fugit'
})

proposal_3 = Proposal.create!({
  message: 'John\'s proposal on project 2',
  value_per_hour: 11,
  hours_per_week: 10,
  finish_date: Time.current + 3.day,
  status: :pending,
  project: project_2,
  professional: complete_profile_professional_1,
  # approved_at: Time.current,
  # cancel_reason: 'Rerum sed ipsam qui delectus ut excepturi fugit'
})
