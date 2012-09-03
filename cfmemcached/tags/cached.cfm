<cfif thisTag.ExecutionMode EQ "start">
	<cfscript>
		thisTag.isCached = "false";
		mc = application.memcachedFactory.getMemcached();
		object = mc.get(attributes.key);
	</cfscript>
	<cfif isBoolean(object) AND object EQ false>
	<cfelse>
		<cfset evaluate("caller.#attributes.variable# = object") />
		<cfexit method="EXITTAG" />
	</cfif>
<cfelse>
	<cfscript>
		if (thisTag.isCached EQ false) {
			mc.add(attributes.key, evaluate("caller." & attributes.variable), attributes.timeout);
		}
	</cfscript>
</cfif>

