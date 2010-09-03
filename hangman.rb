#!/usr/bin/ruby
#
# hangman.rb
#
# Author: Sean Grieve <seangrieve@gmail.com>
# My first ruby program written 12/29/2009
#

require 'set'

# GameWord is a class that contains the current word in a game of hangman
class GameWord
  attr_reader :word

  def initialize(word)
    @word = word
    @letters = word.chars.to_a
    @guessed = Set.new
    # create a set of letters in the word
    @letter_set = Set.new(@letters)
  end


  # See if all letters of the word have been guessed
  def all_guessed?
    @guessed.superset? @letter_set
  end

  # Guess a letter
  def guess(letter)
    @guessed.add letter 
    @letter_set.member? letter 
  end

  # See if this letter has already been guessed
  def already_guessed?(letter)
    @guessed.member? letter 
  end

  # Print the word with unguessed letters masked by dashes
  def print_masked
    @letters.each do |l|
      print @guessed.member?(l) ? l : "-"
    end
    puts 
  end
end

# Game is a class that sets up game play and stores game state
class Game
  MAX_WRONG = 6

  def initialize
    all_words = IO.readlines("3esl.txt")
    # filter out any words with non-letter chars and less than 5 letters
    @words = all_words.find_all { |w| w =~ /^\w{5,}$/ }
    srand
  end

  # Pick a random word
  def random_word
    @words[rand(@words.length)].chomp.downcase
  end

  # Have we exceeded the max number of wrong guesses allowed?
  def lost?
    @wrong_count >= MAX_WRONG 
  end

  # Have we guessed all letters in the word?
  def won?
    @game_word.all_guessed?
  end

  # Prompt the user for a letter and read it.
  def get_letter
    print "Guess a letter: "
    gets.strip[0,1]
  end  

  # See if the letter is OK
  def letter_accepted?(letter)
    if @game_word.already_guessed? letter
      puts "#{letter} was already guessed."
      return false
    elsif letter !~ /\w/
      puts "#{letter} is not a letter!"
      return false
    end
    return true
  end

  # Play a game of hangman
  def run
    play = true

    while play
      @game_word = GameWord.new(random_word())
      @wrong_count = 0

      until lost? || won?
        @game_word.print_masked
        l = get_letter 
        until letter_accepted? l
          l = get_letter
        end

        if @game_word.guess l 
          puts "Yes! The word does contain #{l}."
        else
          puts "Sorry! No #{l}'s."
          @wrong_count += 1
          puts "Wrong guesses remaining: #{MAX_WRONG - @wrong_count}" 
        end
        puts
      end

      if lost? 
        puts "You lose! The word was #{@game_word.word}"
      else
        puts "You win!!! The word was #{@game_word.word}"
      end

      print "Do you wanna play again? (y/n): "
      play = gets.strip.downcase == "y"
    end
  end
end

Game.new.run
