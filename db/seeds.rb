# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
u = User.create(
    username: 'administrator',
    password: BCrypt::Password.create('12345'),
    first_name: 'Kenneth',
    last_name: 'Kapundi',
    middle_name: 'Moses',
    email: 'kennethkapundi1@gmail.com',
    gender: 1,
    designation: 'Software Developer'
)

r = Role.create(
    name: 'Administrator', description: '---'
)

UserRole.create(
    user_id: u.id, role_id: r.id
)

begin
  ActiveRecord::Base.transaction do
    require Rails.root.join('db','load_location_tags.rb')
    require Rails.root.join('db','load_countries.rb')
    require Rails.root.join('db','load_districts.rb')
    require Rails.root.join('db','load_tas_and_villages.rb')
    require Rails.root.join('db','load_health_facilities.rb')
    require Rails.root.join('db','load_conditions.rb')
    require Rails.root.join('db','load_activities.rb')
  end
rescue => e
  puts "Error ::::  #{e.message}  ::  #{e.backtrace.inspect}"
end
