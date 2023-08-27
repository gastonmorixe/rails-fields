require "logger"

module RailsFields
  module Utils
    LOGGER = begin
      logger = Logger.new($stdout)
      logger.level = Rails.env.production? ? Logger::INFO : Logger::DEBUG
      logger
    end
  end
end
