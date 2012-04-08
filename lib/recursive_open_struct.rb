# Stolen from https://github.com/aetherknight/recursive-open-struct/blob/master/lib/recursive_open_struct.rb
require 'ostruct'

class RecursiveOpenStruct < OpenStruct

  def new_ostruct_member(name)
    name = name.to_sym
    unless self.respond_to?(name)
      class << self; self; end.class_eval { define_accessors name, name }
    end
    name
  end

  def keys
    @table.keys
  end

###

  def self.define_accessors( *args )
    define_getter *args
    define_setter *args
    define_getter_as_a_hash *args
  end

  def self.define_getter( method_name, hash_key )
    define_method( method_name ) do
      v = @table[hash_key]
      v.is_a?(Hash) ? self.class.new(v) : v
    end
  end

  def self.define_setter( method_name, hash_key )
    define_method("#{method_name}=") { |x| modifiable[hash_key] = x }
  end

  def self.define_getter_as_a_hash( method_name, hash_key )
    define_method("#{method_name}_as_a_hash") { @table[hash_key] }
  end

###

  def debug_inspect(indent_level = 0, recursion_limit = 12)
    display_recursive_open_struct(@table, indent_level, recursion_limit)
  end

  def display_recursive_open_struct(ostrct_or_hash, indent_level, recursion_limit)

    if recursion_limit <= 0 then
      # protection against recursive structure (like in the tests)
      puts '  '*indent_level + '(recursion limit reached)'
    else
      #puts ostrct_or_hash.inspect
      if ostrct_or_hash.is_a?(self.class) then
        ostrct_or_hash = ostrct_or_hash.marshal_dump
      end

      # We'll display the key values like this :    key =  value
      # to align display, we look for the maximum key length of the data that will be displayed
      # (everything except hashes)
      data_indent = ostrct_or_hash
        .reject { |k, v| v.is_a?(self.class) || v.is_a?(Hash) }
          .max {|a,b| a[0].to_s.length <=> b[0].to_s.length}[0].length
      # puts "max length = #{data_indent}"

      ostrct_or_hash.each do |key, value|
        if (value.is_a?(self.class) || value.is_a?(Hash)) then
          puts '  '*indent_level + key.to_s + '.'
          display_recursive_open_struct(value, indent_level + 1, recursion_limit - 1)
        else
          puts '  '*indent_level + key.to_s + ' '*(data_indent - key.to_s.length) + ' = ' + value.inspect
        end
      end
    end

    true
  end

end