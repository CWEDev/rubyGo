require "pry"

require "./draw"
require "./ai"

class Board
  include DrawMethods
  attr_accessor :board, :groups
  attr_reader :size
  NEIGHBORS = [[1, 0], [0, 1], [-1, 0], [0, -1]]

  # Builds a 2 dimentional array of empty "Space" objects
  # based on size input.
  def initialize size
    @size = size
    @board = []
    @groups = []

    size.times do
      @board.push([])
    end

    board.each_with_index do |row, index|
      size.times do
        @board[index].push(Space.new(:empty, row.length, index))
      end
    end

  end

  # Loops through each board space, creating new groups for any space not already
  # assigned to a group by a previous call of grouper_crawler. 
  def grouper
    @assigned = []

    @board.each_with_index do |row, y|
      row.each_with_index do |space, x|

        unless @assigned.include?([x, y])
          @assigned.push([x, y])
          if space.type == :empty
            group = Territory.new
          else
            group = PieceGroup.new(space.type)
          end
          space.group = group
          group.members.push(space)
          @groups.push(group)
          grouper_crawler(space, group)
        end

      end
    end

  end

  # Recursive, called by grouper to assign all neighboring spaces of identical
  # type to that space's group. If a neighboring space isn't part of the group,
  # it's added to the group's boarder_mems array.
  # Previously unassigned groups are similarily added to boarder_grps.
  def grouper_crawler (space, group)

    NEIGHBORS.each do |neighbor| # Spaces above, below, left, and right of the current space.
      x = neighbor[0] + space.x
      y = neighbor[1] + space.y

      if x >= 0 && y >= 0 && x < @size && y < @size # Then it's on the board
        check_space = @board[y][x]

        if check_space.type == space.type # Then it's part of our group
          unless @assigned.include?([x, y])
            @assigned.push([x, y])
            group.members.push(check_space)
            check_space.group = group
            grouper_crawler(check_space, group)
          end

        elsif !group.boarder_mems.include?(check_space) # Then it's part of our group's boarder.
          group.boarder_mems.push(check_space)

          # Does the boarder space have a group,
          # and is that group not yet in our group's boarder_grps?
          if check_space.group && !group.boarder_grps.include?(check_space.group)
            group.boarder_grps.push(check_space.group)
          end
        end

      end
    end
  end
end

# Space types are :empty, :blk, or :wht
class Space
  attr_accessor :type, :group
  attr_reader :x, :y

  def initialize(type, x, y)
    @x = x
    @y = y
    @type = type
    @group = nil
  end
end

class Group
  attr_accessor :members, :boarder_mems, :boarder_grps
end

# Groups of pieces on the board.
class PieceGroup < Group
  attr_accessor :color, :liberties, :eyes

  def initialize color
    @members = []
    @boarder_mems = []
    @boarder_grps = []
    @color = color
    @liberties = 0
    @eyes = 0
  end

  def check_liberties
    @liberties = 0
    @boarder_mems.each do |member|
      @liberties += 1 if member.type == :empty
    end
  end
end

# Groups of contiguous empty spaces on the board.
class Territory < Group
  attr_accessor :status

  def initialize
    @members = []
    @boarder_mems = []
    @boarder_grps = []
    @status = nil
  end
end