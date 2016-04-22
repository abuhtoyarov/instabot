require 'logger'
require './lib/database_connector'

class AppConfigurator

  def configure
    setup_database
  end

  def get_bot_token
    YAML::load(IO.read('config/secrets.yml'))['telegram_bot_token']
  end

  def get_inst_client_id
    YAML::load(IO.read('config/secrets.yml'))['instagram_client_id']
  end

  def get_inst_client_secret
    YAML::load(IO.read('config/secrets.yml'))['instagram_client_secret']
  end

  def get_logger
    Logger.new(STDOUT, Logger::DEBUG)
  end

  private

  def setup_database
    DatabaseConnector.establish_connection
  end
end
