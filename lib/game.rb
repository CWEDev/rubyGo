require "pry"

require "./draw"
require "./round"

testing = Board.new
test_piece_b = Piece.new(DrawMethods::BLK)
test_piece_w = Piece.new(DrawMethods::WHT)
test_board = testing.build_board(19)

30.times do
    test_board[Random.rand(18)][Random.rand(18)] = test_piece_w
end

30.times do
    test_board[Random.rand(18)][Random.rand(18)] = test_piece_b
end

testing.prints(testing.draw_board(test_board))