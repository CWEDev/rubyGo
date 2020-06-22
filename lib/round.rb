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

  
  def board_grouper
    @assigned = []
    @board.each do |row|
      row.each do |space|
        unless @assigned.include?(space)
          space_grouper(space, false)
        end
      end
    end
  end

  def space_grouper(space, clear = true)
    @assigned = [] unless clear == false
    group = Group.new(space.type)
    grouper_crawler(space, group)
    attach(group)
  end

  # Recursive, called by grouper methods to assign all neighboring spaces of identical
  # type to that space's group. If a neighboring space isn't part of the group,
  # it's added to the group's boarder_mems array.
  # Previously unassigned groups are similarily added to boarder_grps.
  def grouper_crawler (space, group)
    @assigned.push(space)
    group.members.push(space)

    NEIGHBORS.each do |neighbor| # Spaces above, below, left, and right of the current space.
      x = neighbor[0] + space.x
      y = neighbor[1] + space.y

      if x >= 0 && y >= 0 && x < @size && y < @size # Then it's on the board
        check_space = @board[y][x]

        if check_space.type == space.type # Then it's part of our group
          unless @assigned.include?(check_space)
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

  def add_piece (space, type)
    return nil unless space.type == :empty

    NEIGHBORS.each do |neighbor| # Spaces above, below, left, and right of the current space.
      x = neighbor[0] + space.x
      y = neighbor[1] + space.y

      if x >= 0 && y >= 0 && x < @size && y < @size # Then it's on the board
        check_space = @board[y][x]
      end
    end
  end

  # Removes all connections this group has to spaces, neighboring groups and @groups.
  def purge group
    @groups.delete(group)
    group.boarder_grps.each do |b_grp|
      b_grp.boarder_grps.delete(group)
    end
    group.members.each do |member|
      member.group = nil
    end
  end

  # Connects this group to its spaces, neighboring groups and @groups.
  def attach group
    @groups.push(group) unless @groups.include?(group)
    group.boarder_grps.each do |b_grp|
      b_grp.boarder_grps.push(group) unless b_grp.boarder_grps.include?(group)
    end
    group.members.each do |member|
      member.group = group
    end
  end
end

# Space and Group types are :empty, :blk, or :wht
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
  attr_accessor :members, :boarder_mems, :boarder_grps, :liberties, :eyes, :status
  attr_reader :type

  def initialize type
    @members = []
    @boarder_mems = []
    @boarder_grps = []
    @type = type
    @liberties = 0
    @eyes = 0
    @status = nil # for Terrotiry - can belong to black, white, or contested.
  end

  def add group
    @members.concat(group.members).uniq!
    @boarder_mems.concat(group.boarder_mems).uniq!
    @boarder_grps.concat(group.boarder_grps).uniq!
    @boarder_mems -= @members
  end

  def check_liberties
    @liberties = 0
    @boarder_mems.each do |mem|
      @liberties += 1 if mem.type == :empty
    end
  end

  def type=(type)
    @type = type
    @members.each do |mem|
      mem.type = type
    end
  end
end

class SudoGroup < Group
  attr_accessor :groups
end