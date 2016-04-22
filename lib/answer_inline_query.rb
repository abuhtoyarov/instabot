class AnswerInlineQuery

    attr_reader :bot
    attr_reader :token
    attr_reader :query
    attr_reader :query_id

  def initialize(id, query, bot, user)
    @query_id = id
    @query = query
    @bot = bot
    @user = User.find_by_uid(user.id)
    @token = @user.try(:instagram_token)
    @params = {}
  end

  def send
    bot.api.answer_inline_query(inline_query_id: query_id, results: results,
                                cache_time: 1, switch_pm_text: @pm_text,
                                switch_pm_parameter: @pm_param)
  end

  private

  def results
    if token.present?
      fill_result
    else
      @pm_text, @pm_param = ['Sign in to Instagram', '/auth']
    end
  end

  def fill_result
    result = []
    for media_item in instagram_client.user_recent_media
      result << Telegram::Bot::Types::InlineQueryResultPhoto.new(
        id: media_item.id,
        photo_url: media_item.images.standard_resolution.url,
        thumb_url: media_item.images.thumbnail.url
      )
    end
    result
  end

  def instagram_client
    Instagram.client(access_token: token)
  end
end
