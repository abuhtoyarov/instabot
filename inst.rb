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


token = '196651311:AAHx4bV1LCQrHgcf4L7BLj-qIAyl8R1erfE'

Telegram::Bot::Client.run(token, logger: Logger.new($stderr)) do |bot|
  bot.listen do |message|
    case message

    when Telegram::Bot::Types::InlineQuery

      bot.api.answer_inline_query(inline_query_id: message.id, is_personal: true, results: [], cache_time: 1, switch_pm_text: 'Sign in to Instagram', switch_pm_parameter: "/auth")

    when Telegram::Bot::Types::Message

      if message.text.include? '/auth'
        bot.api.send_message(chat_id: message.chat.id, text: access_token)
      end

      if message.text.include? 'code_'
        kb = [ Telegram::Bot::Types::InlineKeyboardButton.new(text: 'switch inline query', switch_inline_query: '1234' ) ]
        markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)

        bot.api.send_message(chat_id: message.chat.id, text: 'Account successfully connected', reply_markup: markup)
      end

      if message.text.include? 'error_'
        bot.api.send_message(chat_id: message.chat.id, text: 'access_denied')
      end
    end
  end
end

