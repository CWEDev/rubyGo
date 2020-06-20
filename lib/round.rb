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
        board[index].push(Space.new(:empty))
      end
    end
  end
end

class Space
  attr_accessor :type, :status, :group

  def initialize type
    @type = nil
    @status = :nor
    @group = nil
  end
end

class Group
  attr_accessor :members, :member_grps, :boarder_mems, :boarder_grps
end

class PieceGroup < Group
  attr_accessor :color, :liberties, :eyes
  def initialize (members, color)
    @members = members
    @member_grps = []
    @boarder_mems = []
    @boarder_grps = []
    @color = color
    @liberties = nil
    @eyes = 0
  end
end

class Territory < Group
  attr_accessor :status
  def initialize members
    @members = members
    @member_grps = []
    @boarder_mems = []
    @boarder_grps = []
    @status = nil
  end
end