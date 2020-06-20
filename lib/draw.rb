module DrawMethods

  # Re-design all of this to be much cleaner!

  THK_V = "\u2506"
  THN_V = "\u2027"
  THK_H = "\u2500"
  THN_H = " "

  BLK = {:nor => "\u25EF", :cap => "\u25CC", :sel => "\u235C"}
  WHT = {:nor => "\u25CF", :cap => "\u2205", :sel => "\u2741"}
  TER = {:blk => "\u2335", :wht => "\u2340", :sel => "\u256C", :nor => "\u2629"} # :nor = temp star point

  TOP = {:l => "\u250C", :m => "\u252C", :r => "\u2510"}
  MID = {:l => "\u251C", :m => "\u2027", :r => "\u2524"}
  BTM = {:l => "\u2514", :m => "\u2534", :r => "\u2518"}

  E_TOP = {:l => "\u250F", :m => "\u2501", :r => "\u2513"}
  E_MID = {:l => "\u2503", :m => " ", :r => "\u2503"}
  E_BTM = {:l => "\u2517", :m => "\u2501", :r => "\u251B"}

  H_LN = " "

  def prints input
    input.each_index do |i|
      puts input[i]
    end
  end

  def draw_board board
    output = []
    size = board.length - 1

    output[0] = E_TOP[:l]
    (board.length * 2 + 8).times do
      output[0] += E_TOP[:m]
    end
    output[0] += E_TOP[:r]

    output[1] = "#{E_MID[:l]}     "
    for col in 1..board.length do
      if col.odd?
        output[1] += "#{col}" + " " * (4 - col.to_s.length)
      end
    end
    output[1] += " #{E_MID[:r]}"

    output[2] = "#{E_MID[:l]}     "
    for col in 1..board.length do
      if col.odd?
        output[2] += "\u2575 "
      else
        output[2] += "  "
      end
    end

    output[2] += "   #{E_MID[:r]}"

    board.each_with_index do |row, y|
      line = y + 3

      output[line] = "#{E_MID[:l]} #{(y + 65).chr}"
      if y.even?
        output[line] += " - "
      else
        output[line] += "   "
      end

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
        unless x == size
          if y == 0 || y == size
            output[line] += THK_H
          else
            output[line] += THN_H
          end
        end
      end
      output[line] += "    #{E_MID[:r]}"
    end

    output.push(E_MID[:l])
    (board.length * 2 + 8).times do
      output[-1] += E_MID[:m]
    end
    output[-1] += E_MID[:r]

    output.push(E_BTM[:l])
    (board.length * 2 + 8).times do
      output[-1] += E_BTM[:m]
    end
    output[-1] += E_BTM[:r]

    return output
  end
end