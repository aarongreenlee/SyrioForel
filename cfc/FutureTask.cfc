<cfcomponent output="false">

	<!----------
					Cancel() - returns a boolean - allows you to cancel the operation
					get( int, variables.timeunit ) - returns object - when an interger is sent in, you can 
							get the result in that amount of time.
					get() - returns an object - get the result when it is available.
					isCancelled() -  returns boolean - lets you know if the operation was cancelled
					isDone() - returns boolean - 
	---------->
	<cfset variables._futureTask = "">
	<cfset variables.inited = false>
	
	<cffunction name="init" access="public" output="false" returntype="Any" hint="init func to set the futureTask">
		<cfargument name="myFutureTask" required="true" type="any" 
			hint="this must be a future Task returned by the java memcached client otherwise, this will fail.">
		
		<cfset variables._futureTask = arguments.myFutureTask>
		<cfif isObject(arguments.myFutureTask)>
			<cfset variables.inited = true>
		</cfif>
		
		<cfset variables.timeUnit = createObject("java","java.util.concurrent.TimeUnit") />
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="isDone" access="public" output="false" returntype="boolean" 
			hint="returns true when the operation has finished. otherwise it returns false">
		<cfscript>
			var ret = false;
			if (variables.inited )	{
				ret = variables._futureTask.isDone();
			}
			if (not isDefined("ret")) {
				ret = false;
			}	
		</cfscript>
		<cfreturn ret>
	</cffunction>

	<Cffunction name="isCancelled" access="public" output="false" returntype="boolean"
			hint="Returns true if the fetch has been cancelled. false otherwise">
		<cfscript>
			var ret = false;
			if (variables.inited )	{
				ret = variables._futureTask.isCancelled();
			}
			if (not isDefined("ret")) {
				ret = false;
			}	
		</cfscript>
		<cfreturn ret>
	</Cffunction>

	<cffunction name="cancel" access="public" output="false" returntype="boolean" 
			hint="cancels the returning result.">
		<cfscript>
			var ret = false;
			if (variables.inited )	{
				ret = variables._futureTask.cancel(true);
			}
			if (not isDefined("ret")) {
				ret = false;
			}
		</cfscript>
		<cfreturn ret>
	</cffunction>

	<cffunction name="get" access="public" output="false" returntype="any" 
			hint="Gets the result, when available. if the result is not available, it will return an null">
		<cfargument name="timeout" type="numeric" required="false" default="#variables.defaultRequestTimeout#" 
				hint="the number of milliseconds to wait until for the response.  
				a timeout setting of 0 will wait forever for a response from the server"/>
		<cfargument name="timeoutUnit" type="string" required="false" default="#variables.defaultTimeoutUnit#"
				hint="The timeout unit to use for the timeout"/>
		<cfscript>
			// gotta go through all this to catch the nulls.
			try	{
				if ( arguments.timeout neq 0 and variables.inited)	{
					var ret = variables._futureTask.Get(arguments.timeout, getTimeUnitType(arguments.timeoutUnit));
				} else if (variables.inited ) {
					var ret = variables._futureTask.Get();
				}
				// additional processing might be required.
				if (not isdefined("ret")) {
					var ret = JavaCast("null",'');
				} else {
					var ret = deserialize(ret);
				}
			} catch(Any e)	{
				var ret = JavaCast("null",'');
				cancel();
				rethrow;
			}
		</cfscript>
		
		<cfif isNull(ret)>
			<cfreturn JavaCast("null","") />
		<cfelse>
			<cfreturn ret />
		</cfif>

	</cffunction> 

	<cffunction name="setDefaultTimeoutUnit" access="public" output="false" returntype="boolean">
		<cfargument name="timeoutUnit" type="string" required="false" default="SECONDS"/>
		<cfset var isSet = false>
		<cfif listfind("MILLISECONDS,NANOSECONDS,MICROSECONDS,SECONDS",ucase(arguments.timeoutUnit))>
			<cfset variables.defaultTimeoutUnit = arguments.timeoutUnit>
			<cfset isSet = true>
		</cfif>
		<cfreturn isSet>
	</cffunction>
	
	<cffunction name="setDefaultRequestTimeout" access="public" output="false" returntype="boolean">
		<cfargument name="timeout" type="numeric" required="false" default="3"/>
		<cfset var isSet = false>
		<cfif arguments.timeout gt -1>
			<cfset variables.defaultRequestTimeout = arguments.timeout>
			<cfset isSet = true>
		</cfif>
		<cfreturn isSet>
	</cffunction>

	<cffunction name="serialize" access="private" output="false" returntype="any"
		hint="Serializes the given value from a byte stream.">
		<cfargument name="value" required="true" />
		<cfscript>
			var byteOutStream = CreateObject("java", "java.io.ByteArrayOutputStream").init();
			var objOutputStream = CreateObject("java", "java.io.ObjectOutputStream").init(byteOutStream);
			var ret = "";
			if (isSimpleValue(arguments.value))	{
				ret = arguments.value;
			} else {
				objOutputStream.writeObject(arguments.value);
				ret = byteOutStream.toByteArray();
				objOutputStream.close();
				byteOutStream.close();
			}
		</cfscript>
		<cfreturn ret>
	</cffunction>

	<cffunction name="deserialize" access="private" output="false" returntype="any"
		hint="Deserializes the given value from a byte stream. this works with multiple keys being returned" >
		<cfargument name="value" required="true" type="any" default="" />
		<cfscript>
			var ret = "";
			var byteInStream = CreateObject("java", "java.io.ByteArrayInputStream");
			var objInputStream = CreateObject("java", "java.io.ObjectInputStream");
			var keys = "";
			var i =1;
			// all these trys in here are to catch null values that come across from java
			if ( isStruct(arguments.value) )	{
				// got a struct here.  go over the struct of keys and return
				// values for each of the items
				ret = structNew();
				keys = listToArray(structKeyList(arguments.value));
				for (i=1; i lte arrayLen(keys);i=i+1)	{
					try 	{
						if (structKeyExists(arguments.value,keys[i]))	{
							ret[keys[i]] = doDeserialize(arguments.value[keys[i]],objInputStream,byteInStream);
						} else {
							ret[keys[i]] = "";
						}
					} catch(Any excpt)	{
						ret[keys[i]] = "";
					}
				}
			}  else if ( isArray(arguments.value) and not isBinary(arguments.value) )	{
				// if the returned value is an array, then we need to loop over the array
				// and return the value  we have to check against the isBinary
				// because apparently coldfusion can't differentiate between an array and a binary
				// value
				ret = arrayNew(1);
				for (i=1; i lte arrayLen(arguments.value); i=i+1)	{
					try	{
						// this try is necessary because null values can be returned
						// from java and this is the only way we have to check for them
						arrayAppend(ret,doDeserialize(arguments.value[i],objInputStream,byteInStream));	
					} catch (Any excpt)	{
						arrayAppend(ret,"");
					}
				}
			} else {
				// we either got a simple value here or we've gotten nothing returned
				// if we get an empty value, then we pretty much assume that it's 
				// a bum value and we'll return a false
				try {
					ret = doDeserialize(arguments.value,objInputStream,byteInStream);
				} catch(Any excpt)	{
					ret = "";
				}
			}
		</cfscript>
		<cfreturn ret />
	</cffunction>	
	
	<cffunction name="doDeserialize" access="private" output="false" returntype="Any"
			hint="this is pretty much for use by the deserialize method  please 
			don't use this function unless absolutely necessary.  if you do use this function,
			please remember to use try - catch around it.  java returns null values which can
			be deadly for coldfusion.">
		<cfargument name="value" required="true" type="any" default="" />
		<cfargument name="objInputStream" required="false" default="#CreateObject('java', 'java.io.ObjectInputStream')#">
		<cfargument name="byteInStream" required="false" default="#CreateObject('java', 'java.io.ByteArrayInputStream')#">
		<Cfscript>
			var ret = "";
			
				if ( isSimpleValue(arguments.value) )	{
					ret = arguments.value;
				} else {
					objInputStream.init(byteInStream.init(arguments.value));
					ret = objInputStream.readObject();
					objInputStream.close();
					byteInStream.close();
				} 
		</Cfscript>
		<cfreturn ret>
	</cffunction>	

	<cffunction name="getTimeUnitType" output="false" access="private" returntype="any">
		<cfargument name="timeUnit" type="string" required="false" default="SECONDS"/>

		<cfif arguments.timeUnit eq "nanoseconds">
			<cfreturn variables.timeUnit.NANOSECONDS>
		<cfelseif arguments.timeUnit eq "microseconds">
			<cfreturn variables.timeUnit.MICROSECONDS>
		<cfelseif arguments.timeUnit eq "milliseconds">
			<cfreturn variables.timeUnit.MILLISECONDS>
		<cfelse>
			<cfreturn variables.timeUnit.SECONDS>
		</cfif>
	</cffunction>

</cfcomponent>