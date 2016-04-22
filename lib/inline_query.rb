require './lib/answer_inline_query'

class InlineQuery

  attr_reader :id
  attr_reader :user
  attr_reader :query
  attr_reader :bot

  def initialize(object, bot)
    @id = object.id
    @user = object.from
    @query = object.query
    @bot = bot
  end

  def respond
    AnswerInlineQuery.new(id, query, bot, user).send
  end
end
