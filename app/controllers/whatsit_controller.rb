class WhatsitController < ApplicationController

  # GET /subjects or /subjects.json

  def index
    @whatsit = Whatsit.new
    @results = ''
  end

  def new
    @whatsit = Whatsit.new
    #extract params 
    @whatsit.params = {search:params[:search],action_type:params[:action_type],confirm:params[:confirm],resp:params[:resp]}

    puts "WI #{@whatsit.inspect}"
    # puts "Ruby PARAMS #{params[:search]}  QUERY #{@results.inspect} resp #{ @whatsit.inspect}"
  end
  def whatsit_params
    params.require(:whatsit).permit(:params)
  end

end