module DrawMethods

  # The constants below store unicode for board components.

  THK_V = "\u2506"
  # THN_V = "\u23D0"
  THN_V = "\u2027"
  THK_H = "\u2500"
  THN_H = " "

  @@v_ln = THN_V
  @h_ln = THN_H
  BLK = {:nor => "\u25EF", :cap => "\u25CC", :sel => "\u235C"}
  WHT = {:nor => "\u25CF", :cap => "\u2205", :sel => "\u2741"}
  TER = {:blk => "\u2335", :wht => "\u2340", :sel => "\u256C"}

  TOP = {:l => "\u250C", :m => "\u252C", :r => "\u2510"}
  @@mid = {:l => "\u251C", :m => @@v_ln, :r => "\u2524"}
  BTM = {:l => "\u2514", :m => "\u2534", :r => "\u2518"}
  H_LN = " "

  def prints input
    input.each_index do |i|
      puts input[i]
    end
  end

  def board_type(h, v)
    @@h_ln = h
    @@v_ln = v
  end

  def draw_board board
    output = []
    size = board.length - 1

    board.each_with_index do |row, y|
      line = y
      gap = line + 1

      output[line] = ""

      row.each_with_index do |pos, x|
        if pos.nil?
          if y == 0
            y_code = TOP
          elsif y == size
            y_code = BTM
          else
            y_code = @@mid
          end
          if x == 0
            x_code = :l
          elsif x == size
            x_code = :r
          else
            x_code = :m
          end
          output[line] += y_code[x_code]
        else
          output[line] += pos.type[pos.status]
        end
        unless x == size
          if y == 0 || y == size
            output[line] += THK_H
          else
            output[line] += THN_H
          end
        end
      end
    end
    return output
  end
end