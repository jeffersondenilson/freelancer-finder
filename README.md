# Freelancer Finder

Projeto que simula plataforma web onde pessoas interessadas em criar um projeto podem encontrar freelancers. Os profissionais podem buscar projetos e enviar propostas. Os donos de projetos podem cadastrar seus projetos e avaliar as propostas.

**Ainda em construção** ([Projeto](https://github.com/jeffersondenilson/freelancer-finder/projects/1))

## Funcionalidades

* TODO

## Tecnologias utilizadas

* [ruby on rails](https://rubyonrails.org)
* [sqlite3](https://github.com/sparklemotion/sqlite3-ruby) como banco de dados (desenvolvimento e teste)
* [devise](https://github.com/heartcombo/devise) para autenticação
* [rspec-rails](https://github.com/rspec/rspec-rails) e [capybara](http://teamcapybara.github.io/capybara/) para testes

## Requisitos

* Ruby 2.7
* Rails 6
* Bundler 2.2
* SQLite3 3.22
* Nodejs 14.17
* Yarn 1.22

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

Na versão de desenvolvimento, é possível logar como usuário usando as credenciais:

```
email: jane.doe@email.com
senha: 123456
```

E como profissional:

```
email: john.doe@email.com
senha: 123456
```

Outros dados podem ser vistos em [db/seeds/development](db/seeds/development)

## Rodando a aplicação

### Browser

```
rails server
```

### Testes

```
rspec
```
