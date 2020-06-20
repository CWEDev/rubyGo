require "pry"

require "./draw"
require "./round"

testing = Board.new
test_piece_b = Space.new(DrawMethods::BLK)
test_piece_w = Space.new(DrawMethods::WHT)
test_board = testing.build_board(19)
test_points = Space.new(DrawMethods::TER)

50.times do
    test_board[Random.rand(18)][Random.rand(18)] = test_piece_w
end

50.times do
    test_board[Random.rand(18)][Random.rand(18)] = test_piece_b
end

test_board[3][3] = test_points
test_board[15][3] = test_points
test_board[3][15] = test_points
test_board[9][15] = test_points
test_board[15][9] = test_points
test_board[9][9] = test_points
test_board[9][3] = test_points
test_board[3][9] = test_points
test_board[15][15] = test_points

testing.prints(testing.draw_board(test_board))