require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = (0...10).map { ('a'..'z').to_a[rand(26)] }
    @start_time = Time.now
  end

  def score
    @userword = params[:userword]
    @letters = params[:letters]
    start_time = Time.parse(params[:starter])
    end_time = Time.now

    grid_compare = @letters.split ''
    user_serialized = open("https://wagon-dictionary.herokuapp.com/#{@userword}").read
    user = JSON.parse(user_serialized)
    attempt_array = @userword.split(//)

    grid_hash = {}
    attempt_hash = {}

    grid_compare.each { |letter| grid_hash[letter] ? grid_hash[letter] += 1 : grid_hash[letter] = 1 }
    attempt_array.each { |letter| attempt_hash[letter] ? attempt_hash[letter] += 1 : attempt_hash[letter] = 1 }

    time_diff = end_time - start_time
    # if the value of each key in attempt_hash is smaller or equal than the value of the same key in grid_hash
    return_logic(attempt_hash, grid_hash, user, time_diff)
  end

  def return_logic(attempt_hash, grid_hash, user, time_diff)
    if attempt_hash.all? { |letter, _value| attempt_hash[letter].to_i <= grid_hash[letter].to_i }
      if user["found"] == true
        @result = { attempt: user['word'], time: time_diff / 60, score: (user["length"]), message: "Well Done!" }
      else
        @result = { attempt: user['word'], time: time_diff / 60, score: 0, message: "Not an english word" }
      end
    else
      @result = { attempt: user['word'], time: time_diff / 60, score: 0, message: "That word was not in the grid!" }
    end
    # return @result
  end
end
