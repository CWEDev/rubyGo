require "pry"

require "./draw"
require "./round"


# All code below is dedicated to testing.

test_board = Board.new(19)

5.times do
  x = Random.rand(18)
  y = Random.rand(18)
  test_board.board[x][y].type = DrawMethods::BLK
end

5.times do
  x = Random.rand(18)
  y = Random.rand(18)
  test_board.board[x][y].type = DrawMethods::WHT
end

test_board.prints(test_board.draw_board(test_board.board))

test_board.grouper

test_board.groups.each do |group|
  puts ""
  puts group
  puts "Members:"
  group.members.each do |member|
    print member.x.to_s + ","
    puts member.y
  end
  puts ""
  puts "Boarder Members:"
  group.boarder_mems.each do |member|
    print member.x.to_s + ","
    puts member.y
  end
  if group.is_a?(PieceGroup)
    group.check_liberties
    puts "Liberties: #{group.liberties}"
  end
end