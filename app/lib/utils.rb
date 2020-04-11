require 'io/console'
require 'enumerator'

module Utils

  LOGO = %q{
    ___
   (_  '_ _   '  _// _   /  _  _/_ _
   /  // (-  //) //)(-  (__(//)/(-/ /)

       p  i  x  e  l  a  t  o  r

}

  def logo
    puts LOGO
  end

  def message(msg)
    puts
    puts "  #{msg}"
    puts
  end

  def wait_for_interrupt
    while true
    end
  rescue Interrupt
    # ignored
  end

  def print_table(data)
    max_widths = []
    data.each do |row|
      row.each_with_index do |value, i|
        max_widths[i] = [max_widths[i]||0, value.to_s.size].max
      end
    end
    table = data.collect do |row|
      row.enum_for(:each_with_index).collect do |value, i|
        value.to_s.ljust(max_widths[i], ' ')
      end.join '  '
    end.join "\n"
    puts table
  end

  def pick_from(list)
    page = 0
    pages = list.size / 9
    choice = nil
    # until choice
      options = {}
      i = 1
      list[(page*9)..((page*8)+8)].each do |item|
        puts "#{i}. #{item}"
        options[i] = item
        i += 1
      end
      if page < pages
        puts '0. more...'
      end
      response = STDIN.getch.strip
      if response == '0' && page < pages
        page += 1
      else
        choice = options[response.to_i]
      end
    # end
    choice
  end

  def symbolize_keys(hash)
    result = {}
    hash.each do |key, value|
      result[key.to_sym] =
          case value
            when Hash
              symbolize_keys value
            when Array
              symbolize_array value
            else
              value
          end
    end
    result
  end

  def symbolize_array(array)
    array.collect do |value|
      case value
        when Hash
          symbolize_keys value
        when Array
          symbolize_array value
        else
          value
      end
    end
  end

  def sum_array(array)
    return 0 if array.empty?

    array.inject(0.0) { |sum, value| sum + value }
  end

  def avg_array(array)
    return 0 if array.empty?

    sum_array(array) / array.size
  end
end