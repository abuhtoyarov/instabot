require 'sinatra'

enable :sessions

get "/oauth/callback" do
  if params[:code]
    redirect "https://telegram.me/instsbot?start=code_#{params[:code]}"
  else
    redirect "https://telegram.me/instsbot?start=error_#{params[:error]}"
  end
end
