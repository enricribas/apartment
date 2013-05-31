require 'spec_helper'

describe 'query caching' do
  it 'clears the ActiveRecord::QueryCache after switching databases' do
    Apartment.configure do |config|
      config.excluded_models = ["Company"]
      config.database_names = lambda{ Company.scoped.collect(&:database) }
    end

    db_names = 2.times.map{ Apartment::Test.next_db }

    db_names.collect do |db_name|
      Apartment::Database.create(db_name)
      Company.create :database => db_name

      Apartment::Database.switch db_name
      User.create! name: db_name
    end

    ActiveRecord::Base.connection.enable_query_cache!

    Apartment::Database.switch db_names.first
    User.find_by_name(db_names.first).name.should == db_names.first

    Apartment::Database.switch db_names.last
    User.find_by_name(db_names.first).should be_nil
  end
end