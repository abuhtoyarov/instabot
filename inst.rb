require 'telegram/bot'
require "instagram"

Instagram.configure do |config|
  config.client_id = "40f62eea197e4d09ac9c0018aaed05c2"
  config.client_secret = "88e0122b29c34ed88d27d20df38ab417"
  # For secured endpoints only
  #config.client_ips = '<Comma separated list of IPs>'
end


CALLBACK_URL = "http://localhost:5100/oauth/callback"

access_token = Instagram.authorize_url(:redirect_uri => CALLBACK_URL, :scope => 'comments')

@client = nil

token = '196651311:AAHx4bV1LCQrHgcf4L7BLj-qIAyl8R1erfE'

Telegram::Bot::Client.run(token) do |bot|
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

      begin
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
      rescue Exception => e
        bot.api.send_message(chat_id: message.chat.id, text: e.to_s)
      end

    end
  end
end

