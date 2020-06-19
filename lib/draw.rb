module DrawMethods

  # The constants below store the unicode for board components.
  # If a hash, they store variants used to illustrate board states.

  BLK = {:nor => "\u25EF", :cap => "\u25CC", :sel => "\u235C"}
  WHT = {:nor => "\u25CF", :cap => "\u2205", :sel => "\u2741"}
  CROSS = {:nor => "\u253C", :blk => "\u2335", :wht => "\u2340", :sel => "\u256C"}

  TL_CNR = "\u250C"
  BL_CNR = "\u2514"
  TR_CNR = "\u2510"
  BR_CNR = "\u2518"
  T_SDE = "\u252C"
  B_SDE = "\u2534"
  L_SDE = "\u251C"
  R_SDE = "\u2524"
  H_LN = "\u2500"
  V_LN = "\u2502"

  def puts_it input
    input.each_index do |index|
      puts input[index]
    end
  end

  def draw_board board
    output = []
    board.each_with_index do |row, index|
    end
  end
end