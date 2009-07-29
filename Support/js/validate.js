
function makeCorrection(file,line,col,id,type)
{
    var scriptElt = document.getElementById('script-path');
    var tracer = document.getElementById('tracer');
    var scriptPath = scriptElt.firstChild.nodeValue;
    
    console.log(scriptPath + "fix.rb" );
    
    var res = TextMate.system('"' + scriptPath + 'fix.rb" '+ file + ' ' + line + ' ' + col + ' ' + type, null).outputString;
    tracer.innerHTML = res;
    
    toggleVisibility(id);
}


function toggleVisibility(id)
{
    var e = document.getElementById(id);
    e.style.display = 'none';
}
