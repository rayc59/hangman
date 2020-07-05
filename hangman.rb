module Enumerable
  def random_line
    selected = nil
    each_with_index { |line, lineno| selected = line if line.length >= 5 && line.length <= 12 && rand < 1.0/lineno }
    return selected.chomp if selected 
  end
end

class Hangman
  require 'yaml'
  attr_accessor :secret_word, :word_array, :playing, :guesses_left, :guessed_letters, :program_open
  def initialize 
    @program_open = true
  end
  def word
    f = open('dictionary.txt')
    @secret_word = f.random_line.downcase.split("")
    @word_array = Array.new(@secret_word.length, "_")
  end

  def new_game
    @guessed_letters = []
    @guesses_left = 5
    @playing = true
    self.word
  end

  def game_won
    puts "\nYou win, congratulations"
    @playing = false
  end

  def game_over
    puts "\nYou lose, sorry"
    @playing = false
  end
  
  def load_game(yaml_string)
    @loaded = YAML::load_file("save.yml")
    self.program_open = @loaded.program_open
    self.guessed_letters = @loaded.guessed_letters
    self.guesses_left = @loaded.guesses_left
    self.playing = @loaded.playing
    self.secret_word = @loaded.secret_word
    self.word_array = @loaded.word_array
    self.show_board
    self.check_status
    puts "Make a guess or type save to save."
  end
  
  def serialize
    File.open("save.yml", "w+") { |file| file.write(self.to_yaml)}
    # YAML::dump(self)
  end

  def check_status
    self.game_won if !@word_array.include?('_')
    self.game_over if @guesses_left == 0
    puts "Guesses Left: #{@guesses_left}\n" if @playing == true
    puts "\t\tGuessed Letters:#{@guessed_letters.join(",")}"
  end

  def show_board
    puts "\n"
    @word_array.each { |value| print value + ' '}
    puts "\n"
  end

  def input
    puts "Make a guess or type save to save."
    while input = gets.chomp
      if input.length == 1 && input.match?(/[A-Za-z]{1}/) && !@guessed_letters.include?(input)
        break
      elsif @guessed_letters.include?(input)
        puts "\nYou already guessed that letter, try again."
      elsif input.downcase == 'load'
        self.load_game(@game_save)
      elsif input.downcase == 'save'
        @game_save = self.serialize 
        self.game_over
        break
      else
        puts "\nInvalid input. Try again."
      end
    end
    input
  end
  
end

game = Hangman.new
game.new_game




while game.program_open
  game.new_game
  game.show_board
  while game.playing
    choice = game.input
    game.guessed_letters.push(choice)
    game.secret_word.each_with_index do |letter, index|
      game.word_array[index] = letter if letter == choice
    end
    if !game.secret_word.include?(choice)
      game.guesses_left -= 1
    end
    game.show_board
    game.check_status
  end
  puts "\nPlay again? Y or N"
  if gets.chomp.downcase == 'n'
    game.program_open = false
  end
end


# puts game.secret_word
# puts "***"
# puts game.word_array
# puts "***"
