require 'tempfile'

class Command
  
  def initialize(command)
    @command = command
  end

  def execute
    puts("Command: #{@command}")
    output = `#{@command} 2>&1`
    unless $?.success?
      message = "Error executing: #{@command}"
      puts(message)
      raise message
    end
    return output
  end

end

namespace :db do
  
  desc 'Backup database contents'
  task :backup => :environment do
    config = ActiveRecord::Base.connection.instance_eval { @config }
    credentials = "-u#{config[:username]}"
    credentials += " -p#{config[:password]}" if config[:password]
    credentials += " -h#{config[:host]}" if config[:host]
    database = config[:database]
    timestamp = Time.now.strftime('%Y-%m-%d-%H%M')
    filename = "#{database}-#{timestamp}.sql.bz2"
    backup_username = '2378'
    backup_host = 'usw-s002.rsync.net'
    backup_path = 'installd-backups'
    destination = "#{backup_username}@#{backup_host}:#{File.join(backup_path, filename)}"
    Tempfile.open(filename) do |tempfile|
      Command.new("mysqldump --opt --single-transaction #{credentials} #{database} | bzip2 -c > #{tempfile.path}").execute
      Command.new("scp #{tempfile.path} #{destination}").execute
    end
  end
  
end
