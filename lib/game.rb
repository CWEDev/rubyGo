require "pry"

require "./draw"
require "./round"

testing = Board.new

testing.puts_it(testing.draw_board(testing.build_board(9)))