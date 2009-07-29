#!/usr/bin/env ruby -wKU

if ARGV.length != 4
  puts "Error: Incorrect number of arguments."
  exit 0
end

def correct_number_literal(uri,ln,col)
  
  #Read the file and locate the line to operate on.
  doc = File.open(uri,"r+").read.split("\n")
  line = doc[ln]
  
  #Our pointer will be to the first number in the string. 
  char = line[col-1,1]
  
  #Find the last number character
  while char =~ /\d/
    char = line[col,1]
    col += 1
  end

  line.insert(col-1,'.0')
  
  #Write our changes to disk.
  o = File.open(uri,"w+" )
  o.puts doc
  o.flush
  o.close
  
end

def correct_postix(uri,ln,col)
  
  #Read the file and locate the line to operate on.
  doc = File.open(uri,"r+").read.split("\n")
  line = doc[ln]
  
  #Our pointer will be to the first + in the string, remove them.
  line[col-1,2] = ''
  
  line.insert(col-2,'++')
  
  #Write our changes to disk.
  o = File.open(uri,"w+" )
  o.puts doc
  o.flush
  o.close
  
end 

def correct_var(uri,ln,col)
  
  #Read the file and locate the line to operate on.
  doc = File.open(uri,"r+").read.split("\n")
  line = doc[ln]
  
  line.sub!('var','const')
  
  #Write our changes to disk.
  o = File.open(uri,"w+" )
  o.puts doc
  o.flush
  o.close
  
end

file_path = ARGV[0].to_s
line_number = ARGV[1].to_i-1
column = ARGV[2].to_i-1
type = ARGV[3].to_s

if type == 'numberLiterals'
  
  correct_number_literal(file_path,line_number,column)
  
elsif type == 'correctPostix'
  
  correct_postix(file_path,line_number,column)
  
elsif type == 'variableShouldBeConstant'
  
  correct_var(file_path,line_number,column)
  
end

class_name = File.basename(file_path).sub('.as','')
puts "Fixed: #{class_name} #{line_number} #{column}"

require ENV['TM_SUPPORT_PATH'] + '/lib/textmate'

TextMate.rescan_project
TextMate.go_to(:file => file_path,:line => line_number+1, :column => column)

