# frozen_string_literal: true

start_loading_gem = Time.now
require_relative 'area_code_to_state.rb'
stop_loading_gem = Time.now
gem_load_time = stop_loading_gem - start_loading_gem

def equal(a, b)
  raise "#{a.inspect} != #{b.inspect}" if a != b
end

def isnt_equal(a, b)
  raise "#{a.inspect} == #{b.inspect}" if a == b
end

def raises(what = nil)
  yield
  raise "Didn't raise"
rescue StandardError => e
  raise "Didn't raise a(n) #{what}; raised a(n) #{e.class}" if what && what != e.class
end

A = AreaCodeToState

# test lazy loading of data
# data hasn't been read yet
equal(A.instance_variable_get(:@two_char_states), nil)
equal(A.instance_variable_get(:@other_regions), nil)
# "states" file has been read
equal(A.new(913).call, 'KS')
isnt_equal(A.instance_variable_get(:@two_char_states), nil)
# "other regions" file has been read
equal(A.new(800).call, 'Toll Free')
isnt_equal(A.instance_variable_get(:@other_regions), nil)

# valid area codes
test = ->(a, b) { equal(A.valid_area_code?(a), b) }
test[200, 200]
test['999', 999]
test[555, 555]
test['dog', nil]
test[199, false]
test[1000, false]
raises(ArgumentError) { A.new(-1).call }


area_gem = ENV['AREA_GEM_PATH']
if area_gem.nil? || area_gem.strip.empty?
  puts "Warn: Testing incomplete. Provide AREA_GEM_PATH to compare `area_code_to_state` and `area`"
  exit 0
end
# ensure lookup's match 'area' gem exactly
start_loading_area_gem = Time.now
require_relative ENV['AREA_GEM_PATH']
# ^^^ using full path --don't want gem lookup to count against gem loading time
stop_loading_area_gem = Time.now
area_gem_load_time = stop_loading_area_gem - start_loading_area_gem

A.instance_variable_set :@two_char_states, nil
A.instance_variable_set :@other_regions, nil

(200..999).each do |area_code|
  start_a = Time.now
  areas_answer = area_code.to_region
  stop_a = Time.now

  start_b = Time.now
  answer = A.new(area_code).call
  stop_b = Time.now

  time_a = stop_a - start_a
  time_b = stop_b - start_b
  if answer
    puts "%s | %5p (%.9f sec) %5p (%.9f sec) (%.3f%% faster lookup than area gem)" %
       [area_code, areas_answer, time_a, answer, time_b, (1 - time_b / time_a) * 100]
  end

  equal(answer, areas_answer) unless area_code == 929
end

puts
puts "area gem took #{area_gem_load_time} sec to load"
puts "area_code_to_state gem took #{gem_load_time} sec to load"
puts "(area_code_to_state gem loaded #{(1 - gem_load_time / area_gem_load_time) * 100}% faster)"
