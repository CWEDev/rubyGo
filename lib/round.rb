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
    @atari = nil
    @ko = false

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
    loop_board() do
      unless @assigned.include?(space)
        space_grouper(space, false)
      end
    end
  end

  def space_grouper(space, clear = true)
    @assigned = [] unless clear == false
    group = Group.new(space.type)
    grouper_crawler(space, group)
    attach(group)
  end

  # Recursive, expands group starting with space
  def grouper_crawler (space, group)
    @assigned.push(space)
    group.members.push(space)

    each_neighbor(space) do |neighbor|

      # Call self on neighbor if same type
      if neighbor.type == space.type
        unless @assigned.include?(neighbor)
          grouper_crawler(neighbor, group)
        end
      
      # Otherwise, add neighbor to boarder_mems
      elsif !group.boarder_mems.include?(neighbor)
        group.boarder_mems.push(neighbor)

        # And the neighbor's group to boarder_grps
        if neighbor.group && !group.boarder_grps.include?(neighbor.group)
          group.boarder_grps.push(neighbor.group)
        end
      end
    end
  end

  def loop_board
    @board.each do |row|
      row.each do |space|
        yield space
      end
    end
  end

  def each_neighbor space
    NEIGHBORS.each do |shift|
      x = shift[0] + space.x
      y = shift[1] + space.y

      if x >= 0 && y >= 0 && x < @size && y < @size # Then it's on the board
        neighbor = @board[y][x]
        yield neighbor
      end
    end
  end

  # Main method for adding new pieces to the board.
  # Manages re-grouping of neighbors, capture logic, and suicide detection.
  def add_piece (space, type)

    return nil unless space.type == :empty # You can only place pieces on empty spaces.

    same = [] # Storage for same-color neighboring groups.
    other = [] # Storage for other-color nieghboring groups.
    @atari = [] # Atari list is reset each turn.

    # First, create a new group containing space.
    group = Group.new(type)
    group.members.push(space)


    # Next, examine neighbors.
    each_neighbor(space) do |neighbor| # 

      # Merge neighboring group with self if same type.
      if neighbor.type == type
        same.push(neighbor.group)
        group.merge(neighbor.group)
      else

        # Add neighbor to boarder_mems if not already there (due to previous merging)
        group.boarder_mems.push(neighbor) unless group.boarder_mems.include?(neighbor)

        # Do the same for it's group if other-color (territory isn't grouped until scoring)
        unless neighbor.type == :empty
          other.push(neighbor.group)
          group.boarder_grps.push(neighbor.group) unless group.boarder_grps.include?(neighbor.group)
        end
      end
    end

    # Capture any eligible neighboring groups, update @atari if needed.
    capture = false
    other.each do |other_grp|
      liberties = other_grp.get_liberties
      binding.pry
      if liberties.empty?
        capture!(other_grp)
        binding.pry
        capture = true
      elsif liberties.length == 1
        @atari.push(liberties[0])
      end
    end

    # If none were captured, check self for capture. Abort if true!
    # Otherwise, update @atari if needed.
    liberties = group.get_liberties
    if capture == false && liberties.empty?
      puts "Scuicide!"
      @atari = []
      return "Scuicide!"
    elsif liberties.length == 1
      @atari.push(liberties[0])
    end

    # Self is uncaptured, move approved.
    # Detach any meged sub-groups from the board and replace with self.
    space.type = type
    same.each do |same_grp|
      detach(same_grp)
    end
    attach(group)
  end

  def capture! group
    group.type = :empty
    detach(group)
  end

  # Removes all references in the group's spaces, neighboring groups and @groups.
  def detach group
    @groups.delete(group)
    group.boarder_grps.each do |b_grp|
      b_grp.boarder_grps.delete(group)
    end
    group.members.each do |member|
      member.group = nil
    end
  end


  # Adds references to the group's spaces, neighboring groups and @groups.
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
    @liberties = []
    @eyes = 0
    @status = nil # for Terrotiry
  end

  def merge group
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

  # check_liberties variant that returns liberties.
  def get_liberties
    liberties = []
    @boarder_mems.each do |mem|
      liberties.push(mem) if mem.type == :empty
    end
    @liberties = liberties.length
    return liberties
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