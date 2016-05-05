require 'mongo'

class Migration
  def self.migrate mongo
    puts 'MIGRATE'
    @migrations = {}
    @migrations["28042016"] = lambda { mongo['devices'].indexes.create_one({ "hwid": 1 }, { unique: true }) }
    @migrations["03052016"] = lambda do
      mongo['users'].find({username: nil}).each do |user|
        result = mongo['users'].update_one({ :_id => user['_id'] }, { :username => user['_id'].to_s })
      end
      mongo['users'].indexes.create_one({ "username": 1 }, { unique: true })
    end

    @migrations.each do |id, code|
      if mongo['migrations'].find({id: id}).count > 0
        puts "skip: #{id}"
        next
      end

      result = code.call
      puts "executed: #{id}"
      puts result
      mongo['migrations'].insert_one({id: id, status: 'ok'})
    end
  end
end
