module DrawMethods

  # The constants below store unicode for board components.

  BLK = {:nor => "\u25EF", :cap => "\u25CC", :sel => "\u235C"}
  WHT = {:nor => "\u25CF", :cap => "\u2205", :sel => "\u2741"}
  TER = {:blk => "\u2335", :wht => "\u2340", :sel => "\u256C"}
  TOP = {:l => "\u250C", :m => "\u252C", :r => "\u2510"}
  MID = {:l => "\u251C", :m => "\u253C", :r => "\u2524"}
  BTM = {:l => "\u2514", :m => "\u2534", :r => "\u2518"}
  H_LN = " \u2500 "
  V_LN = "\u23D0"

  def prints input
    input.each_index do |i|
      puts input[i]
    end
  end

  def draw_board board
    output = []
    size = board.length - 1

    board.each_with_index do |row, y|
      line = y * 2
      gap = line + 1

      output[line] = ""
      output[gap] = "" unless y == size

      row.each_with_index do |pos, x|
        if pos.nil?
          if y == 0
            y_code = TOP
          elsif y == size
            y_code = BTM
          else
            y_code = MID
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
        output[line] += H_LN unless x == size
        unless y == size
          output[gap] += V_LN
          output[gap] += "   " unless x == size
        end
      end
    end
    return output
  end
end