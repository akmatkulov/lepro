# frozen_string_literal: true

require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
  @db=SQLite3::Database.new 'lepro.db'
end

before do
  init_db
end

configure do
    
    @db.execute 'CREATE TABLE IF NOT EXISTS
    "Posts"
      (
        "id" INTEGER PRIMARY KEY AUTOINCREMENT,
        "created_at" DATE,
        "content" TEXT
      )'

    @db.execute 'CREATE TABLE IF NOT EXISTS
    "Comments"
      (
        "id" INTEGER PRIMARY KEY AUTOINCREMENT,
        "created_at" DATE,
        "content" TEXT,
        "post_id" INTEGER
      )'
      
end

get '/' do
  @results = @db.execute 'select * from Posts order by id desc'
  erb :index
end  
get '/new' do
  erb :new
end

post '/new' do
  @content = params['text']
  if @content.length <= 0
    @error = 'Type post text'
    return erb :new
  end

  @db.execute 'insert into Posts (content, created_at) values (?,datetime())',[@content]

  redirect to '/'
end

get '/details/:post_id' do
  post_id = params['post_id']
  results = @db.execute 'select * from Posts where id = ?',[post_id]
  @row = results[0]
  erb :details
end

post '/details/:post_id' do
  post_id = params['post_id']
  content = params['coment']

   @db.execute 'insert into Comments 
   (
    content, 
    created_at, 
    post_id
    ) 
    values 
    (
      ?,
      datetime(),
      ?  
    )',
      [content, post_id]

  redirect to('/details/' + post_id)
end