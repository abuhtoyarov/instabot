require './models/user'
require './lib/message_sender'

class MessageResponder
  attr_reader :message
  attr_reader :bot
  attr_reader :user

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]
    @user = User.find_or_create_by(uid: message.from.id)
    @authorize_url = options[:authorize_url]
    @callback_url = options[:callback_url]
  end

  def respond
    on /^\/start$/ do
      answer_with_greeting_message
    end

    on /^\/stop/ do
      answer_with_farewell_message
    end

    on /\/auth$/ do
      answer_auth
    end

    on /^\/start code_/ do
      answer_get_token(message.text.split('_').last)
    end
  end

  private

  def on regex, &block
    regex =~ message.text

    if $~
      case block.arity
      when 0
        yield
      when 1
        yield $1
      when 2
        yield $1, $2
      end
    end
  end

  def answer_with_greeting_message
    text = I18n.t('greeting_message')

    MessageSender.new(bot: bot, chat: message.chat, text: text).send
  end

  def answer_auth
    MessageSender.new(bot: bot, chat: message.chat, text: @authorize_url).send
  end

  def answer_get_token(code)
    tk = Instagram.get_access_token(code, redirect_uri: @callback_url)

    user.instagram_token = tk.access_token
    user.save!

    kb = [Telegram::Bot::Types::InlineKeyboardButton.new(text: 'switch inline query', switch_inline_query: 'some text' )]

    MessageSender.new(bot: bot, chat: message.chat, text: 'text', answers: kb).send
  end

  def answer_with_farewell_message
    text = I18n.t('farewell_message')

    MessageSender.new(bot: bot, chat: message.chat, text: text).send
  end

  def answer_with_message(text)
    MessageSender.new(bot: bot, chat: message.chat, text: text).send
  end


end
