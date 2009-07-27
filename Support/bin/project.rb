#!/usr/bin/env ruby -wKU

require ENV['TM_SUPPORT_PATH'] + '/lib/escape'
require ENV['TM_SUPPORT_PATH'] + '/lib/tm/process'
require ENV['TM_SUPPORT_PATH'] + '/lib/textmate'

lib = File.expand_path(File.dirname(__FILE__)) + '/../lib'

flex_path = ENV['TM_FLEX_PATH']

TextMate.exit_show_html("Please create the env var TM_FLEX_PATH and point it to the root of your Flex SDK.") unless flex_path

as3v_jar  = e_sh(lib + '/as3v.jar')
asc_jar   = e_sh(flex_path + '/lib/asc.jar')
conf      = e_sh(lib + '/as3v-default.xml')

@src      = e_sh(ENV['TM_PROJECT_DIRECTORY']+'/src')

cmd = "java -jar #{as3v_jar} -asc #{asc_jar} -source-path #{@src} -use-config #{conf}"

# Example input
# [i] AS3V working ...
# [w] uk.co.helvector.ApplicationFacade, Ln 90, Col 11: Avoid "x as Class" and use "Class(x)" instead.
# [i] uk.co.helvector.view.skins.RoundedGreyButtonWithWhiteBorderSkin, Ln 38, Col 44: Found a power of two. You can use a binary operator here.
# [-] 495 violation(s) found.
# [i] Completed in 4237ms.

@validator = /\[(w|i|-)\]\s(.*)$/
@link = /^([\w+\.]+),\sLn\s(\d+),\sCol\s(\d+):(.*)$/

def parse(str)
  if str =~ @validator
    if $1 == 'w' || $1 == 'i'
      return link($1,$2)
    end
    return str + '</br>'
  end
  
  #TODO: Log non matching lines.
  ''
end

def link(level,str)
  
  if str =~ @link

    c = $1
    ln = $2
    col = $3
    msg = $4
    fp = @src + '/' + c.gsub('.','/')+'.as'
    cn  = File.basename(fp).sub('.as','')

    return '['+level+'] <a href="txmt://open?url=file://' + fp +
          '&line='+ ln +
          '&column=' + col +
          '" >' + cn +
          '</a>' + msg +
          '<br/>'
    
  end
  
  '['+level+'] ' + str + '<br/>'
  
end

require ENV['TM_SUPPORT_PATH'] + '/lib/web_preview'

puts html_head( :window_title => "ActionScript 3 Validator",
                :page_title => "ActionScript 3 Validator")

puts "<h2>Validating...</h2>"

TextMate::Process.run(cmd) do |str|
  STDOUT << parse(str)
end

html_footer