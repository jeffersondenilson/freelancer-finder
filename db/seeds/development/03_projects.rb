project_1 = Project.create!({
  title: 'Jane\'s project 1',
  description: 'Laboriosam non ab aut',
  desired_abilities: 'UX, design',
  value_per_hour: 80,
  due_date: Time.current + 1.day,
  remote: true,
  user_id: 1
})

project_2 = Project.create!({
  title: 'Alice\'s project',
  description: 'Qui quam occaecati repellendus quasi neque eos',
  desired_abilities: 'banco de dados',
  value_per_hour: 9.99,
  due_date: Time.current + 3.day,
  remote: false,
  user_id: 2
})

project_3 = Project.create!({
  title: 'Jane\'s project 2',
  description: 'Neque porro quisquam est qui',
  desired_abilities: 'criatividade',
  value_per_hour: 23.85,
  due_date: Time.current - 3.day,
  remote: false,
  user_id: 1
})

project_4 = Project.create!({
  title: 'Alice\'s project 2',
  description: 'Maiores dolor autem similique et ratione labore consequuntur',
  desired_abilities: 'banco de dados',
  value_per_hour: 10.00,
  due_date: Time.current + 4.day,
  remote: false,
  user_id: 2
})
