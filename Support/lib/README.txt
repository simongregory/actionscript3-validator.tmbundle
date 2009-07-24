
	AS3V v1.0
	
	Author:	Joa Ebert
	Web:	http://www.joa-ebert.com/
			http://blog.joa-ebert.com/
		
	Commandline:
	
		Whenever running AS3V from command line via  "java -jar as3v.jar" you
		will probably have to specify the "-asc" option and point to the
		location of the asc.jar of your Flex SDK.
		
		This is because AS3V dynamically links against the latest version
		of the ActionScript Compiler.
		
		For more information: -help is your friend.
		
	ANT Task:
	
		When using the AS3V Ant task you have to add the as3v.jar and
		asc.jar also to the classpath of the AS3V task. Just
		have a look at the build.xml.
		
		Note: Since AS3V is using the ActionScript Compiler huge projects
		may need more memory. An example is the Flex framework in the build.xml
		which shows how to give AS3V more space.
		
		The AS3V task has also some more options.
		
		<as3v failLevel="1">
			This would let the build fail by simple warnings detected.
			The levels are 0 = info, 1 = low warning, 2 = high warning,
			3 = low error, 4 = high error.
			
			The default fail level is 3.
			
		<as3v logLevel="2">
			This would only log high warnings, low errors and high errors.
			
			The default log level is 0.
			
		<as3v config="myCustomConfig.xml">
			This would load your custom config.xml. A config XML can include
			or exclude specific rules. You can even write your own rules since
			this is all done via reflections.
			
		<as3v maxViolations="2">
			The AS3V task fails when the limit of maximum violations is 
			exceeded.
			
	AS3V Configurations:
	
			Have a look at the as3v-default.xml file. You can add your own
			defines in that file and also specify which rule should be
			included.
			
			Every rule has the following attributes:
			
				class		The qualified classname of the rule to invoke.
				message 	The message this rule creates once a violation occurs.
				level		The level for the generated violation.
							0 is the lowest (info), 4 is the highest (error high).
							
			Some rules have also custom parameters or flags you may use in the
			message.
			
			Every rule from com.joa_ebert.as3v.rules.joa_ebert.naming.* for
			instance can accept the "regexp" attribute as shown in the
			example config. The %s is always the name of the candidate which
			did not match a name.
			
			Some other rules like cyclomatic complexity test, or rules
			which have an upper limit (e.g. for statements in constructor) have
			also a parameter which is most of the time named "maxValue".
			
			A more detailed descrption of rules, possible configuration parameters
			and how to write own rules might follow in the near future :o)
			
	Eclipse Plug-in:
	
		An Eclipse version might come soon. I have a version working but I am
		missing tooltips for the information AS3V creates in FDT. Once the FDT
		guys create an extension point for that a plug-in will be released in no
		time.