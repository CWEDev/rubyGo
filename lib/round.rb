require "pry"

require "./draw"
require "./ai"

class Board
  include DrawMethods
  attr_accessor :board, :groups, :history
  attr_reader :size
  NEIGHBORS = [[1, 0], [0, 1], [-1, 0], [0, -1]]

  # Builds a 2 dimentional array of empty "Space" objects
  # based on size input.
  def initialize size
    @size = size
    @board = []
    @groups = []
    @territory = []
    @history = [] # Saves a history of previous board states containing ataris or captures (for ko)
    @ataris = []

    @size.times do
      @board.push([])
    end

    board.each_with_index do |row, index|
      @size.times do
        @board[index].push(Space.new(:empty, row.length, index))
      end
    end
  end

  # Creates a reference of the board state for storage and comparison.
  # Only stores the type of each space.
  def make_ref
    board_ref = []
    @size.times do
      board_ref.push([])
    end
    loop_board() do |space|
      board_ref[space.y][space.x] = space.type
    end
    return board_ref
  end
  
  def board_grouper
    @assigned = []
    loop_board() do |space|
      grouper(space, false) unless @assigned.include?(space)
    end
  end

  def grouper(space, clear = true)
    @assigned = [] unless clear == false
    space.type == :empty ? group = Territory.new : group = Stones.new(space.type)
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
  # Manages re-grouping of neighbors, capture logic, and suicide/ko detection.
  # Stores ataris internally, returns capture count.
  def add_piece (space, type)

    return :full unless space.type == :empty # You can only place pieces on empty spaces.

    same = []
    other = []
    @ataris = []
    captures = 0

    # First, create a new group containing space. Temporarily add type.
    group = Stones.new(type)
    group.members.push(space)
    space.type = type

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

    # Capture any eligible neighboring groups
    captures = []
    @ataris = []
    other.each do |other_grp|
      liberties = other_grp.get_liberties
      if liberties.empty?
        captures.push(other_grp)
        detach(other_grp)
      elsif liberties.length == 1
        @ataris.push(liberties[0])
      end
    end

    
    liberties = group.get_liberties
    board_state = make_ref()

    # Check self for suicide or illegal ko state,
    # abort and return condition if true.
    if captures.empty?
      if liberties.empty?
        space.type = :empty
        return :suicide
      end
    else
      if @history.include?(board_state)
        space.type = :empty
        captures.each do |group|
          attach(group)
        end
        return :ko
      end
      @history.push(board_state)
    end

    # Move approved.
    @ataris.push(liberties[0]) if liberties.length == 1
    @history.push(board_state) unless @ataris.empty? || @history.include?(board_state)
    same.each do |same_grp|
      detach(same_grp)
    end
    attach(group)

    return @ataris
  end

  # Removes all references in the group's spaces, neighboring groups and @groups.
  # Sets group members to empty.
  def detach group
    @groups.delete(group)
    group.boarder_grps.each do |b_grp|
      b_grp.boarder_grps.delete(group)
    end
    group.members.each do |member|
      member.type = :empty
      member.group = nil
    end
  end


  # Adds references to the group's spaces, neighboring groups and @groups.
  # Makes sure members comform to group type.
  def attach group
    @groups.push(group) unless @groups.include?(group)
    group.boarder_grps.each do |b_grp|
      b_grp.boarder_grps.push(group) unless b_grp.boarder_grps.include?(group)
    end
    group.members.each do |member|
      member.type = group.type
      member.group = group
    end
  end

  # Play CANNOT CONTINUE after building pseudo-groups. Used for scoring only.
  def build_pseudo
    @groups.each do |group|
      have_parent = !group.parent.nil?
      your_libs = group.get_liberties
      group.boarder_grps.each do |boarder_grp|
        break if have_parent && group.parent == boarder_grp.parent
        shared_libs = 0
        their_libs = boarder_grp.get_liberties
        their_libs.each do |lib|
          shared_libs += 1 if your_libs.include?(lib)
        end
        if shared_libs >= 2
          group.parent = Pseudo.new(group.type, group) unless have_parent
          group.parent.merge(boarder_grp)
        end
      end
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
  attr_accessor :members, :boarder_mems, :boarder_grps
  attr_reader :type

  def initialize type
    @members = []
    @boarder_mems = []
    @boarder_grps = []
    @type = type
  end

  def merge group
    @members.concat(group.members).uniq!
    @boarder_mems.concat(group.boarder_mems).uniq!
    @boarder_grps.concat(group.boarder_grps).uniq!
    @boarder_mems -= @members
  end

  def type=(type)
    @type = type
    @members.each do |mem|
      mem.type = type
    end
  end
end

class Territory < Group
  attr_accessor :status

  def initialize
    super :empty
    @status = nil
  end
end

class Stones < Group
  attr_accessor :liberties, :eyes, :parent

  def initialize type
    super type
    @liberties = 0
    @eyes = 0
    @parent = nil
  end

  def merge group
    super group
    self.parent.update(group) unless self.parent.nil?
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
end

class Pseudo < Stones
  def initialize(type, group)
    super type
    merge(group)
    @children = []
  end

  def merge group
    other_pseudo = group.parent
    return if other_pseudo == self
    if other_pseudo
      other_pseudo.children.each do |child|
        child.parent = nil
        merge(child)
      end
    else
      super group
      group.parent = self
      @children.push(group)
    end
  end

  def update group
    return unless @children.include?(group)
    @members -= group.members
    @boarder_mems -= group.boarder_mems
    @boarder_grps -= group.boarder_grps
    group.parent = nil
    merge(group)
  end
end