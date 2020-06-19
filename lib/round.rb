require "pry"

require "./draw"
require "./ai"

class Board
  include DrawMethods

  def build_board size
    board = []
    size.times do
      board.push([])
    end
    board.each_index do |index|
      size.times do
        board[index].push(nil)
      end
    end
  end
end