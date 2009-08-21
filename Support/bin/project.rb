#!/usr/bin/env ruby -wKU

require ENV['TM_SUPPORT_PATH'] + '/lib/escape'
require ENV['TM_SUPPORT_PATH'] + '/lib/tm/process'
require ENV['TM_SUPPORT_PATH'] + '/lib/textmate'

BUN_BIN = File.expand_path(File.dirname(__FILE__))
lib = "#{BUN_BIN}/../lib"

flex_path = ENV['TM_FLEX_PATH']

TextMate.exit_show_html("Please create the env var TM_FLEX_PATH and point it to the root of your Flex SDK.") unless flex_path

as3v_jar  = e_sh(lib + '/as3v.jar')
asc_jar   = e_sh(flex_path + '/lib/asc.jar')
conf      = e_sh(lib + '/as3v-default.xml')

@src      = e_sh(ENV['TM_PROJECT_DIRECTORY']+'/src')

cmd = "java -Xms64m -Xmx384m -jar #{as3v_jar} -asc #{asc_jar} -source-path #{@src} -use-config #{conf}"

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

    #NOTE: The column number isn't accurate and will depend on your tab/space settings.
    #      Basically as3v treats a tab as a single char/column whereas TM will expand it.
    c = $1
    ln = $2
    col = $3
    msg = $4
    tip = "#{c} #{ln},#{col}"
    fp = @src + '/' + c.gsub('.','/')+'.as'
    cn  = File.basename(fp).sub('.as','')

    id = cn+ln+col
    fix = ''
    
    if msg =~ /Use\sNumber\sliterals\./

      fix = '<div id="'+id+'" style="display:inline;"><a href="javascript:makeCorrection(\'' + e_url(fp) + '\', ' + ln  + ', ' + col + ', \'' + id + '\', \'numberLiterals\');">fix</a></div>'

    elsif msg =~ /prefix\sinstead\sof\spostix/

      fix = '<div id="'+id+'" style="display:inline;"><a href="javascript:makeCorrection(\'' + e_url(fp) + '\', ' + ln  + ', ' + col + ', \'' + id + '\', \'correctPostix\');">change</a></div>'
    
    elsif msg =~ /Variable is not modified and could be constant/
      
      fix = '<div id="'+id+'" style="display:inline;"><a href="javascript:makeCorrection(\'' + e_url(fp) + '\', ' + ln  + ', ' + col + ', \'' + id + '\', \'variableShouldBeConstant\');">change</a></div>'

    end

    return '['+level+'] <a title="' + tip + '" href="txmt://open?url=file://' + fp +
          '&line='+ ln +
          '&column=' + col +
          '" >' + cn +
          '</a>' + msg + 
          ' ' + fix +
          '<br/>
'
    # 
  end
  
  '['+level+'] ' + str + '<br/>'
  
end

# first escape for use in the shell, then escape for use in a JS string
def e_js_sh(str)
  (e_sh str).gsub("\\", "\\\\\\\\")
end

require ENV['TM_SUPPORT_PATH'] + '/lib/web_preview'

puts html_head( :window_title => "ActionScript 3 Validator",
                :page_title => "ActionScript 3 Validator")

puts	"<link rel='stylesheet' href='file://#{e_url(BUN_BIN)}/../css/validate.css' type='text/css' charset='utf-8' media='screen'>"
puts  "<script src='file://#{e_url(BUN_BIN)}/../js/validate.js' type='text/javascript' charset='utf-8'></script>"
puts "<div id='script-path'>#{BUN_BIN}/</div>"
puts "<h2>Validating...</h2>"

TextMate::Process.run(cmd) do |str|
  STDOUT << parse(str)
end

puts "<div id='tracer'></div>"

html_footer
