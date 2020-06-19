module DrawMethods

  # The constants below store unicode for board components.

  BLK = {:nor => "\u25EF", :cap => "\u25CC", :sel => "\u235C"}
  WHT = {:nor => "\u25CF", :cap => "\u2205", :sel => "\u2741"}
  TER = {:blk => "\u2335", :wht => "\u2340", :sel => "\u256C"}
  TOP = {:l => "\u250C", :m => "\u252C", :r => "\u2510"}
  MID = {:l => "\u251C", :m => "\u253C", :r => "\u2524"}
  BTM = {:l => "\u2514", :m => "\u2534", :r => "\u2518"}
  H_LN = "\u2500\u2500\u2500"
  V_LN = "\u2502"

  def puts_it input
    input.each_index do |i|
      puts input[i]
    end
  end

  def draw_board board
    output = []

    board.each_with_index do |row, y|
      output[y * 2] = ""
      output[y * 2 + 1] = "" unless y == board.length - 1

      row.each_with_index do |pos, x|
        if pos.nil?
          if y == 0
            y_code = TOP
          elsif y == board.length - 1
            y_code = BTM
          else
            y_code = MID
          end
          if x == 0
            x_code = :l
          elsif x == row.length - 1
            x_code = :r
          else
            x_code = :m
          end

          output[y * 2] += y_code[x_code]
          output[y * 2] += H_LN unless x == row.length - 1

          unless y == board.length - 1
            output[y * 2 + 1] += V_LN
            output[y * 2 + 1] += "   " unless x == row.length - 1
          end
        end
      end
    end
    return output
  end
end