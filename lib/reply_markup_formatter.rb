class ReplyMarkupFormatter
  attr_reader :array

  def initialize(array)
    @array = array
  end

  def get_markup
    Telegram::Bot::Types::InlineKeyboardMarkup
      .new(inline_keyboard: array.each_slice(1).to_a)
  end
end
