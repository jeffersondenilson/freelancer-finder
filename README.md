# Freelancer Finder

Projeto que simula plataforma web onde pessoas interessadas em criar um projeto podem encontrar freelancers. Os profissionais podem buscar projetos e enviar propostas. Os donos de projetos podem cadastrar seus projetos e avaliar as propostas.

http://freelancer-finder-90193.herokuapp.com

## Funcionalidades

**Em construção** ([Projeto](https://github.com/jeffersondenilson/freelancer-finder/projects/1))

- [x] Criação de conta (usuário e profissional)
- [x] Profissional completa perfil
- [x] Profissional faz/cancela proposta em projeto
- [x] Usuário rejeita propostas
- [ ] Usuário aceita propostas
- [ ] Usuário encerra inscrições para projeto
- [ ] Visualizar time do projeto
- [ ] Fornecer feedback após o projeto (usuário e profissional)
- [ ] Marcar usuário/profissional como favorito

## Tecnologias utilizadas

- [ruby on rails](https://rubyonrails.org)
- [sqlite3](https://github.com/sparklemotion/sqlite3-ruby) (desenvolvimento e teste) e [postgresql](https://github.com/ged/ruby-pg) (produção)
- [devise](https://github.com/heartcombo/devise) para autenticação
- [rspec-rails](https://github.com/rspec/rspec-rails) e [capybara](http://teamcapybara.github.io/capybara/) para testes

## Requisitos

- Ruby 3.0.2
- Rails 6.1.4
- Bundler 2.2.8
- SQLite3 3.22
- Postgresql 10+
- Nodejs 14.17
- Yarn 1.22

## Instalação

```
git clone https://github.com/jeffersondenilson/freelancer-finder.git
cd freelancer-finder
bundle install
```

### Database

```
rails db:migrate
```

### Criando dados (seeds)

```
rails db:seed
```

Na versão de desenvolvimento e [neste exemplo](http://freelancer-finder-90193.herokuapp.com), é possível logar como usuário usando as credenciais:

```
email: jane.doe@email.com
senha: 123456
```

E como profissional:

```
email: john.doe@email.com
senha: 123456
```

Outros dados podem ser vistos em [db/seeds/](db/seeds/)

## Rodando a aplicação

### Browser

```
rails server
```

### Testes

```
rspec
```

## Outras informações

### Sobre cancelamento de propostas
- Para cancelar uma proposta aprovada, o profissional deve apresentar um motivo
- Um profissional não pode cancelar uma proposta após 3 dias da sua aprovação
- Usuário não vê propostas canceladas enquanto pendentes, mas vê propostas com motivo de cancelamento (cancelada após ser aprovada)

### Sobre recusa de propostas
- Para recusar uma proposta, um usuário deve apresentar um motivo
- Propostas recusadas não serão vistas pelo usuário, mas serão vistas pelo profissional junto com motivo de recusa
- Não é possível modificar uma proposta recusada
- Um profissional não pode criar novas propostas em um projeto em que teve uma proposta recusada
