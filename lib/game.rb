require "pry"

require "./draw"
require "./round"

class Game
  # This should be re-written into the Board class
  # and be turned into an overall "Round" class, too many @brd specific method calls...
  # Methods can be broken up into modules for cleanliness...
  def new_game (wht = :player, blk = :player, size = 19)
    @brd = Board.new(size)
    @wht = {:ctrl => wht, :colr => DrawMethods::WHT, :captures => 0, :pass => false}
    @blk = {:ctrl => blk, :colr => DrawMethods::BLK, :captures => 0, :pass => false}
  end

  def play_loop
    @plr = @wht
    game_on = true
    result = ""

    while game_on == true
      @brd.prints(@brd.draw_board(@brd.board))
      print result
      print "\n"
      puts "\nWhite's Captures: #{@wht[:captures]}"
      puts "Black's's Captures: #{@blk[:captures]}"
      puts "\nEnter a Row-Letter followed by a Column-Number"
      puts "(Like \"a16\" or \"g4\")\n"
      satisfied = false
      until satisfied
        x = gets.chomp.downcase
        y = (x.slice!(0).codepoints[0] - 97)
        x = x.to_i - 1
        if x >= 0 && x < @brd.size && y >= 0 && y < @brd.size
          satisfied = true
        else
          puts "\nInvalid Input.\n"
        end
      end
      # Kills same color groups in atari! Re-vamping grouper may be more efficient than patching a fix.
=begin
      piece = @brd.board[y][x]
      piece.type = @plr[:colr]
      @brd.board_grouper
      check_groups = @brd.groups
      check_groups.delete(piece.group)
      check_groups.each do |group|
        if group.type != :empty
          group.check_liberties
          if group.liberties == 0
            group.members.each do |member|
              member.type = :empty
              @plr[:captures] += 1
            end
          end
        end
      end

      piece.group.check_liberties
      if piece.group.liberties == 0 && !piece.group.type == :empty
        piece.group.members.each do |member|
          member.type = :empty
          @plr[:captures] += 1
        end
      end
=end
      result = @brd.add_piece(@brd.board[y][x], @plr[:colr])
      toggle_plr()
    end
  end

  def toggle_plr
    if @plr == @wht
      @plr = @blk
    else
      @plr = @wht
    end
  end

end

# All code below is dedicated to testing.
=begin
game = Game.new
boardtest = Board.new(19)
game.new_game
game.play_loop
=begin
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
=end

testboard = Board.new(9)
=begin
testboard.board[0][1].type = DrawMethods::BLK
testboard.board[1][1].type = DrawMethods::BLK
testboard.board[2][0].type = DrawMethods::BLK
testboard.board[2][2].type = DrawMethods::BLK
testboard.board[3][3].type = DrawMethods::BLK
testboard.board[3][1].type = DrawMethods::BLK
testboard.board[4][3].type = DrawMethods::BLK
testboard.board[4][2].type = DrawMethods::BLK
testboard.board[4][1].type = DrawMethods::BLK
testboard.board[4][0].type = DrawMethods::BLK
=end
16.times do
  testboard.board[Random.rand(9)][Random.rand(9)].type = DrawMethods::BLK
end
testboard.board_grouper(DrawMethods::BLK)
testboard.build_pseudo
puts testboard.draw_board(testboard.board)
testboard.groups.each do |group|
  puts group.type
  group.members.each do |member|
    puts "#{member.x} #{member.y}"
  end
  if group.parent
    puts "Parent: #{group.parent}"
    puts "Parent size: #{group.parent.members.length}"
  else
    puts "No Parent"
  end
end