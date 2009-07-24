#!/usr/bin/env ruby -wKU

as3v = File.expand_path(File.dirname(__FILE__)) + '/../lib/as3v.jar'

puts `java -jar "#{as3v}" -help`