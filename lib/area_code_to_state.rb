# frozen_string_literal: true

class AreaCodeToState
  class << self
    def area_code_to_region(area_code)
      state = two_char_states.slice((area_code - 200) << 1, 2)
      return state unless state[0] == '.'

      case state[1]
      when ',' then nil
      when '>' then other_regions[area_code]
      else; state
      end
    end

    def valid_area_code?(val)
      int = Integer val rescue nil
      int&.between?(200, 999) && int
    end

    def two_char_states
      @two_char_states ||= File.read(path('area_code_regions_blob.txt')).chomp
    end

    def other_regions
      @other_regions ||= begin
        p = path 'area_codes_with_region_names_over_2_chars_long.txt'
        hash = {}
        File.foreach(p) do |line|
          hash[Integer line[0..2]] = line[3..-1].chomp
        end
        hash
      end
    end

    def path(file_name)
      File.join File.dirname(__FILE__), file_name
    end
  end

  attr_reader :area_code

  def initialize(area_code)
    @area_code = area_code
  end

  def call
    valid_area_code = self.class.valid_area_code? area_code
    raise ArgumentError, "Invalid area code: #{area_code.inspect}" unless valid_area_code

    self.class.area_code_to_region valid_area_code
  end
end
