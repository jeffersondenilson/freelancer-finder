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

# sempre é redirecionado para editar o perfil
incomplete_profile_professional = Professional.create!({ name: 'Hoo', 
  email: 'hoo@man.com', password: 'hooman' })
