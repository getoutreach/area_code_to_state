# frozen_string_literal: true

def list_possible_regions(areacodes_csv_path)
  two_char_regions = []
  other_regions = []
  File.readlines(areacodes_csv_path, chomp: true).each do |line|
    area_code, region = line.split ','
    if region.length == 2
      two_char_regions
    else
      other_regions
    end << region
  end

  two_char_regions.uniq!.sort!
  other_regions.uniq!.sort!

  puts
  puts two_char_regions.length
  puts
  puts two_char_regions
  puts
  puts other_regions.length
  puts
  puts other_regions
  puts
end

def update_blob!(blob, area_code, value)
  i = (area_code - 200) * 2
  blob[i...i + value.length] = value
end

def read_blob(blob = nil, area_code = nil)
  return File.read('area_code_regions_blob.txt').chomp unless blob || area_code

  blob.slice((area_code - 200) * 2, 2)
end

def write_blob(blob)
  File.open('area_code_regions_blob.txt', 'w') { |f| f.puts blob }
end
