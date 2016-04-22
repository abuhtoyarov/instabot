#!/usr/bin/env ruby

require 'telegram/bot'
require "instagram"
require './lib/app_configurator'

config = AppConfigurator.new
config.configure

bot_token = config.get_bot_token
client_id = config.get_inst_client_id
client_secret = config.get_inst_client_secret

Instagram.configure do |config|
  config.client_id = client_id
  config.client_secret = client_secret
end


CALLBACK_URL = "http://localhost:5100/oauth/callback"

access_token = Instagram.authorize_url(:redirect_uri => CALLBACK_URL, :scope => 'comments')

@client = nil



Telegram::Bot::Client.run(bot_token, logger: Logger.new($stderr)) do |bot|
  bot.logger.info('Bot has been started')
  bot.listen do |message|
    case message

    when Telegram::Bot::Types::InlineQuery

      results = []

      unless @client.nil?
        for media_item in @client.user_recent_media
          results << Telegram::Bot::Types::InlineQueryResultPhoto.new(
            id: media_item.id,
            photo_url: media_item.images.thumbnail.url,
            thumb_url: media_item.images.thumbnail.url
          )
        end
      end

      @pm_text, @pm_p = if results.empty?
        ['Sign in to Instagram', '/auth']
      else
        ['Settings', '/settings']
      end

      bot.api.answer_inline_query(inline_query_id: message.id, is_personal: true, results: results, cache_time: 1, switch_pm_text: @pm_text, switch_pm_parameter: @pm_p)

    when Telegram::Bot::Types::Message

      if message.text.include? '/auth'
        bot.api.send_message(chat_id: message.chat.id, text: access_token)
      end

      if message.text.include? 'code_'
        kb = [ Telegram::Bot::Types::InlineKeyboardButton.new(text: 'switch inline query', switch_inline_query: 'some text' ) ]
        markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)

        code = message.text.split('code_').last
        tk = Instagram.get_access_token(code, :redirect_uri => CALLBACK_URL)

        @client = Instagram.client(:access_token => tk.access_token)

        bot.api.send_message(chat_id: message.chat.id, text: "Account successfully connected. Hi #{@client.user.username}", reply_markup: markup)
      end

      if message.text.include? 'error_'
        bot.api.send_message(chat_id: message.chat.id, text: 'access_denied')
      end
    end
  end
end

