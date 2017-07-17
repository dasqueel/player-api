=begin

after looking into sinatras built in api methods and desgins

along with a more OOP approach, which I need to practice

here is a non-working, sketch of another way of designing a player api json endpoint

also uses mongo for datastore

I read into this for ~2 hours after handing in my first attempt

=end

# server.rb
require 'sinatra'
require "sinatra/namespace"
require 'mongoid'

# DB Setup
Mongoid.load! "mongoid.config"

# Models
class Player
  include Mongoid::Document

  field :first_name, type: String
  field :last_name, type: String
  field :position, type: String
  field :team, type: String
  field :name_brief, type: String
  field :age, type: Int
  field :average_position_age_diff, type: Int

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :position, presence: true
  validates :team, presence: true
  validates :name_brief, presence: true
  validates :age, presence: true
  validates :average_position_age_diff, presence: true

  #could use scope and index methods as well
end

# Serializers
class playerSerializer

  def initialize(player)
    @player = player
  end

  def as_json(*)
    data = {
      id: @player.id.to_s,
      first_name: @player.first_name,
      last_name: @player.last_name,
      position: @player.position,
      team: @player.team,
      name_brief: @player.name_brief
      age: @player.age
      average_position_age_diff: @player.average_position_age_diff
    }
    data[:errors] = @player.errors if @player.errors.any?
    data
  end

end

namespace '/api/v1' do

  before do
    content_type 'application/json'
  end

  helpers do
    def base_url
      @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
    end

    def json_params
      begin
        JSON.parse(request.body.read)
      rescue
        halt 400, { message: 'Invalid JSON' }.to_json
      end
    end

    def player
      @player ||= Player.where(id: params[:id]).first
    end

    def halt_if_not_found!
      halt(404, { message: 'player Not Found'}.to_json) unless player
    end

    def serialize(player)
      playerSerializer.new(player).to_json
    end
  end

  get '/players' do
    players = Player.all

    [:first_name, :isbn, :last_name].each do |filter|
      players = players.send(filter, params[filter]) if params[filter]
    end

    players.map { |player| playerSerializer.new(player) }.to_json
  end

  get '/players/:id' do |id|
    halt_if_not_found!
    serialize(player)
  end

end
