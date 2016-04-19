require 'telegram/bot'
require "instagram"

token = '215100861:AAGNTNWI4NekICmGQlcx0rqg8e4eBVuFs_M'

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message
    when Telegram::Bot::Types::InlineQuery
      results = [
        [1, 'First article', 'Very interesting text goes here.'],
        [2, 'Second article', 'Another interesting text here.']
      ].map do |arr|
        Telegram::Bot::Types::InlineQueryResultArticle.new(
          id: arr[0],
          title: arr[1],
          input_message_content: Telegram::Bot::Types::InputTextMessageContent.new(message_text: arr[2])
        )
      end

      bot.api.answer_inline_query(inline_query_id: message.id, results: results)
    when Telegram::Bot::Types::Message
      bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}!")
    end
  end
end
