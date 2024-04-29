require 'sinatra'
require 'sqlite3'
require 'json'
require 'bcrypt'
require 'sinatra/cors'

set :allow_origin, "*"
set :allow_methods, "GET,HEAD,POST,PUT,DELETE"
set :allow_headers, "content-type,if-modified-since"
set :expose_headers, "location,link"

DB = SQLite3::Database.new("usuarios.db", results_as_hash: true)

#Listar o usuarios

get '/usuarios' do
    content_type :json
    usuarios = DB.execute("SELECT * FROM usuarios")
    usuarios.map { |usuario|  {id: usuario['id'],  nome: usuario['nome'], senha: usuario['senha'],  codigo: usuario['codigo'] } }.to_json
end

#Listar o usuarios por Id

get '/usuarios/:id' do |id|
    content_type :json
    usuario = DB.execute("SELECT * FROM usuarios WHERE id = ?", id).first
    if usuario
        {id: usuario['id'], nome: usuario['nome'], senha: usuario['senha'], codigo: usuario['codigo'] } .to_json
    else
        status 404
        {message: "Usuario não encontrado"}.to_json
    end
end

#Cadastrar Usuario

post '/usuarios' do 
    content_type :json
    novo_usuario = JSON.parse(request.body.read)
    nome = novo_usuario['nome']
    senha = BCrypt::Password.create(novo_usuario['senha']).to_s
    codigo = novo_usuario['codigo']
    DB.execute("INSERT INTO usuarios (nome, senha, codigo) VALUES (?,?,?)", [nome, senha, codigo])

    {message: "Usuario criado com Sucesso"}.to_json
end



#Editar Usuario

put '/usuarios/:id' do |id|
    content_type :json
    usuario_atualizado = JSON.parse(request.body.read)
    nome = usuario_atualizado['nome']
    codigo = usuario_atualizado['codigo']
    
    nova_senha = usuario_atualizado['senha']
    nova_senha_criptografada = BCrypt::Password.create(nova_senha).to_s

    DB.execute("UPDATE usuarios SET nome = ?, senha = ?, codigo = ? WHERE id = ?", [nome, nova_senha_criptografada, codigo, id])
    { message: "Usuario atualizado com sucesso!" }.to_json
end

#Deletar Usuario

delete '/usuarios/:id' do |id|
    content_type :json
    DB.execute("DELETE FROM usuarios WHERE id = ? ", id)
    { message: "Usuario deletado com sucesso!"}.to_json
end