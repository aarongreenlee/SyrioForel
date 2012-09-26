<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	This is another implementation of the CacheBox provider so it can work
	with ColdBox Applications.
----------------------------------------------------------------------->
<cfcomponent output="false" extends="coldbox.system.cache.AbstractCacheBoxProvider" implements="coldbox.system.cache.IColdboxApplicationCache">

	<cffunction name="init" access="public" output="false" returntype="any" hint="Constructor">
		<cfscript>
			super.init();
		
			// Prefixes
			this.VIEW_CACHEKEY_PREFIX 			= "cbox_view-";
			this.EVENT_CACHEKEY_PREFIX 			= "cbox_event-";
			
			// URL Facade Utility
			instance.eventURLFacade		= CreateObject("component","coldbox.system.cache.util.EventURLFacade").init(this);
			
			// ColdBox linkage
			instance.coldbox 			= "";
					
			// CacheBox Provider Property Defaults
			instance.DEFAULTS = {
				objectDefaultTimeout = 60,
				objectDefaultLastAccessTimeout = 30,
				useLastAccessTimeouts = true,
				reapFrequency = 0,
				freeMemoryPercentageThreshold = 0,
				evictionPolicy = "LRU",
				evictCount = 1,
				maxObjects = 200,
				objectStore = "MemcachedStore",
				coldboxEnabled = false
			};
					
			return this;
		</cfscript>
	</cffunction>	

<!------------------------------------------- ColdBox Application Related Operations ------------------------------------------>

	<!--- getViewCacheKeyPrefix --->
    <cffunction name="getViewCacheKeyPrefix" output="false" access="public" returntype="any" hint="Get the cached view key prefix">
    	<cfreturn this.VIEW_CACHEKEY_PREFIX>
    </cffunction>

	<!--- getEventCacheKeyPrefix --->
    <cffunction name="getEventCacheKeyPrefix" output="false" access="public" returntype="any" hint="Get the event cache key prefix">
    	<cfreturn this.EVENT_CACHEKEY_PREFIX>
    </cffunction>

	<!--- getColdbox --->
    <cffunction name="getColdbox" output="false" access="public" returntype="any" hint="Get the coldbox application reference as coldbox.system.web.Controller" colddoc:generic="coldbox.system.web.Controller">
    	<cfreturn instance.coldbox>
    </cffunction>

	<!--- setColdbox --->
    <cffunction name="setColdbox" output="false" access="public" returntype="void" hint="Set the coldbox application reference">
    	<cfargument name="coldbox" type="any" required="true" hint="The coldbox application reference as coldbox.system.web.Controller" colddoc:generic="coldbox.system.web.Controller"/>
    	<cfset instance.coldbox = arguments.coldbox>
	</cffunction>

	<!--- getEventURLFacade --->
    <cffunction name="getEventURLFacade" output="false" access="public" returntype="any" hint="Get the event caching URL facade utility">
    	<cfreturn instance.eventURLFacade>
    </cffunction>

	<!--- Clear All the Events form the cache --->
	<cffunction name="clearAllEvents" access="public" output="false" returntype="void" hint="Clears all events from the cache.">
		<cfargument name="async" type="any" default="false" hint="Run command asynchronously or not"/>
		
		<cfset var threadName = "clearAllEvents_#replace(instance.uuidHelper.randomUUID(),"-","","all")#">
		
		<!--- check if async and not in thread --->
		<cfif arguments.async AND NOT instance.utility.inThread()>
			
			<cfthread name="#threadName#">
				<cfset instance.elementCleaner.clearAllEvents()>
			</cfthread>
		
		<cfelse>
			<cfset instance.elementCleaner.clearAllEvents()>
		</cfif>
	</cffunction>
	
	<!--- clearEvent --->
	<cffunction name="clearEvent" access="public" output="false" returntype="void" hint="Clears all the event permutations from the cache according to snippet and querystring. Be careful when using incomplete event name with query strings as partial event names are not guaranteed to match with query string permutations">
		<cfargument name="eventsnippet" type="any" 	required="true"  hint="The event snippet to clear on. Can be partial or full">
		<cfargument name="queryString" 	type="any" 	required="false" default="" hint="If passed in, it will create a unique hash out of it. For purging purposes"/>
		<cfset instance.elementCleaner.clearEvent(arguments.eventsnippet,arguments.queryString)>
	</cffunction>
	
	<!--- Clear an event Multi --->
	<cffunction name="clearEventMulti" access="public" output="false" returntype="void" hint="Clears all the event permutations from the cache according to the list of snippets and querystrings. Be careful when using incomplete event name with query strings as partial event names are not guaranteed to match with query string permutations">
		<cfargument name="eventsnippets"    type="any"   	required="true"  hint="The comma-delimmitted list event snippet to clear on. Can be partial or full">
		<cfargument name="queryString"      type="any"   required="false" default="" hint="The comma-delimmitted list of queryStrings passed in. If passed in, it will create a unique hash out of it. For purging purposes.  If passed in the list length must be equal to the list length of the event snippets passed in."/>
    	<cfset instance.elementCleaner.clearEventMulti(arguments.eventsnippets,arguments.queryString)>
	</cffunction>
	
	<!--- clearView --->
	<cffunction name="clearView" output="false" access="public" returntype="void" hint="Clears all view name permutations from the cache according to the view name.">
		<cfargument name="viewSnippet"  required="true" type="any" hint="The view name snippet to purge from the cache">
		<cfset instance.elementCleaner.clearView(arguments.viewSnippet)>
	</cffunction>
	
	<!--- clearViewMulti --->
	<cffunction name="clearViewMulti" output="false" access="public" returntype="void" hint="Clears all view name permutations from the cache according to the view name.">
		<cfargument name="viewSnippets"    type="any"   required="true"  hint="The comma-delimmitted list or array of view snippet to clear on. Can be partial or full">
		<cfset instance.elementCleaner.clearViewMulti(arguments.viewSnippets)>
	</cffunction>

	<!--- Clear All The Views from the Cache. --->
	<cffunction name="clearAllViews" access="public" output="false" returntype="void" hint="Clears all views from the cache.">
		<cfargument name="async" type="any" default="false" hint="Run command asynchronously or not"/>
		
		<cfset var threadName = "clearAllViews_#replace(instance.uuidHelper.randomUUID(),"-","","all")#">
		
		<!--- check if async and not in thread --->
		<cfif arguments.async AND NOT instance.utility.inThread()>
			
			<cfthread name="#threadName#">
				<cfset instance.elementCleaner.clearAllViews()>
			</cfthread>
		
		<cfelse>
			<cfset instance.elementCleaner.clearAllViews()>
		</cfif>
		
	</cffunction>

	<!--- validateConfiguration --->
    <cffunction name="validateConfiguration" output="false" access="private" returntype="void" hint="Validate incoming set configuration data">
    	<cfscript>
    		var cacheConfig = getConfiguration();
			var key			= "";
			
			// Validate configuration values, if they don't exist, then default them to DEFAULTS
			for(key in instance.DEFAULTS){
				if( NOT structKeyExists(cacheConfig, key) OR NOT len(cacheConfig[key]) ){
					cacheConfig[key] = instance.DEFAULTS[key];
				}
			}
		</cfscript>
    </cffunction>

	<!--- Configure the Cache for Operation --->
	<cffunction name="configure" access="public" output="false" returntype="void" hint="Configures the cache for operation, sets the configuration object, sets and creates the eviction policy and clears the stats. If this method is not called, the cache is useless.">
		
		<cfset var cacheConfig     	= getConfiguration()>
		<cfset var evictionPolicy  	= "">
		<cfset var objectStore		= "">
		
		<cflock name="CacheBoxProvider.configure.#instance.cacheID#" type="exclusive" timeout="20" throwontimeout="true">
		<cfscript>		
			
			// Prepare the logger
			instance.logger = getCacheFactory().getLogBox().getLogger( this );
			instance.logger.debug("Starting up CacheBox Cache: #getName()# with configuration: #cacheConfig.toString()#");
			
			// Validate the configuration
			validateConfiguration();
			
			// Prepare Statistics
			instance.stats = CreateObject("component","coldbox.system.cache.util.CacheStats").init(this);
			
			// Create the object store the configuration mandated
			try{
				objectStore = locateObjectStore( cacheConfig.objectStore );
				instance.objectStore = CreateObject("component", objectStore).init(this);
			}
			catch(Any e){
				instance.logger.error("Error creating object store: #objectStore#", e);
				getUtil().throwit('Error creating object store #objectStore#','#e.message# #e.detail# #e.stackTrace#','CacheBoxProvider.ObjectStoreCreationException');	
			}
			
			// Enable cache
			instance.enabled = true;
			
			// Enable reporting
			instance.reportingEnabled = false;
			
			// startup message
			instance.logger.info("CacheBox Cache: #getName()# has been initialized successfully for operation");			
		</cfscript>
		</cflock>
		
	</cffunction>
	
	<!--- locateObjectStore --->
    <cffunction name="locateObjectStore" output="false" access="private" returntype="any" hint="Locate the object store">
    	<cfargument name="store" type="string"/>
    	<cfscript>
    		if( fileExists( expandPath("/coldbox/system/cache/store/#arguments.store#.cfc") ) ){
				return "coldbox.system.cache.store.#arguments.store#";
			}
			return arguments.store;
    	</cfscript>
    </cffunction>
	
	<!--- shutdown --->
    <cffunction name="shutdown" output="false" access="public" returntype="void" hint="Shutdown command issued when CacheBox is going through shutdown phase">
   		<cfscript>
   			// Kill connection to memcached
   			instance.objectStore.shutdown();
   			instance.logger.info("CacheBox Cache: #getName()# has been shutdown.");
   		</cfscript>
    </cffunction>
	
	<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Lookup Multiple Keys --->
	<cffunction name="lookupMulti" access="public" output="false" returntype="any" hint="The returned value is a structure of name-value pairs of all the keys that where found or not." colddoc:generic="struct">
		<cfargument name="keys" 	type="any" 	required="true" hint="The comma delimited list or an array of keys to lookup in the cache.">
		<cfargument name="prefix" 	type="any" 	required="false" default="" hint="A prefix to prepend to the keys">
		<cfscript>
			var returnStruct 	= structnew();
			var x 				= 1;
			var thisKey 		= "";
			
			// Normalize keys
			if( isArray(arguments.keys) ){
				arguments.keys = arrayToList( arguments.keys );
			}
			
			// Loop on Keys
			for(x=1;x lte listLen(arguments.keys);x++){
				thisKey = arguments.prefix & listGetAt(arguments.keys,x);
				returnStruct[thiskey] = lookup( thisKey );
			}
			
			return returnStruct;
		</cfscript>
	</cffunction>
	
	<!--- lookup --->
	<cffunction name="lookup" access="public" output="false" returntype="any" hint="Check if an object is in cache, if not found it records a miss." colddoc:generic="boolean">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup.">
		<cfscript>
			return lookupQuiet(objectKey=arguments.objectKey);
		</cfscript>
	</cffunction>
	
	<!--- lookupQuiet --->
	<cffunction name="lookupQuiet" access="public" output="false" returntype="any" hint="Check if an object is in cache quietly, advising nobody!" colddoc:generic="boolean">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup.">
		<cfscript>
			// cleanup the key
			arguments.objectKey = lcase(arguments.objectKey);
			
			return instance.objectStore.lookup( arguments.objectKey );
		</cfscript>
	</cffunction>

	<!--- Get an object from the cache --->
	<cffunction name="get" access="public" output="false" returntype="any" hint="Get an object from cache. If object does not exist it returns null">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup.">
		<cfscript>
			var refLocal = {};
			
			refLocal.results = getQuiet(arguments.objectKey);

			if( structKeyExists(refLocal, "results") ) return refLocal.results;
				
			return;
		</cfscript>
	</cffunction>
	
	
	<!--- Get an object from the cache --->
	<cffunction name="getQuiet" access="public" output="false" returntype="any" hint="Get an object from cache. If object does not exist it returns null">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup.">
		<cfscript>
			var refLocal = {};
			
			// cleanup the key
			arguments.objectKey = lcase(arguments.objectKey);
			
			// get object from store
			refLocal.results = instance.objectStore.get( arguments.objectKey );
			if( structKeyExists(refLocal, "results") ) return refLocal.results;
				
			return;
		</cfscript>
	</cffunction>
	
	<!--- Get multiple objects from the cache --->
	<cffunction name="getMulti" access="public" output="false" returntype="any" hint="The returned value is a structure of name-value pairs of all the keys that where found. Not found values will not be returned" colddoc:generic="struct">
		<!--- ************************************************************* --->
		<cfargument name="keys" 		type="any" 	required="true" hint="The comma delimited list or array of keys to retrieve from the cache.">
		<cfargument name="prefix"		type="any" 	required="false" default="" hint="A prefix to prepend to the keys">
		<!--- ************************************************************* --->
		<cfscript>
			var returnStruct = structnew();
			var thisKey = "";
			
			// Normalize keys
			if;
			
			// Clear Prefix
			arguments.prefix = trim(arguments.prefix);
			
			// Update each key with the prefix if needed
			if (len(trim(arguments.prefix)) == 0)
			{
				var finalizedKeys = (isArray(arguments.keys)) ? arguments.keys : listToArray(arguments.keys);
			} else {
				var tempKeys = (isArray(arguments.keys)) ? arguments.keys : listToArray(arguments.keys);
				var finalizedKeys = [];
				for(var k in tempKeys) arrayAppend(finalizedKeys,arguments.prefix & k);
			}
			
			// Loop keys
			for(var x=1;x lte listLen(arguments.keys);x++)
			{
				thisKey = arguments.prefix & listGetAt(arguments.keys,x);
				
				if( lookup(thisKey) )
				{
					returnStruct[thiskey] = get(thisKey);
				}
			}
			
			return returnStruct;
		</cfscript>
	</cffunction>
			
	<!--- getCachedObjectMetadata --->
	<cffunction name="getCachedObjectMetadata" output="false" access="public" returntype="any" hint="Get the cached object's metadata structure. If the object does not exist, it returns an empty structure." colddoc:generic="struct">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object to lookup its metadata">
		<!--- ************************************************************* --->
		<cfscript>
			return {};
		</cfscript>
	</cffunction>
	
	<!--- getCachedObjectMetadata --->
	<cffunction name="getCachedObjectMetadataMulti" output="false" access="public" returntype="any" hint="Get the cached object's metadata structure. If the object does not exist, it returns an empty structure." colddoc:generic="struct">
		<!--- ************************************************************* --->
		<cfargument name="keys" 	type="any" required="true" hint="The comma delimited list or array of keys to retrieve from the cache.">
		<cfargument name="prefix" 	type="any" required="false" default="" hint="A prefix to prepend to the keys">
		<!--- ************************************************************* --->
		<cfscript>
			return {};
		</cfscript>
	</cffunction>

	<!--- Set Multi Object in the cache --->
	<cffunction name="setMulti" access="public" output="false" returntype="void" hint="Sets Multiple Ojects in the cache. Sets might be expensive. If the JVM threshold is used and it has been reached, the object won't be cached. If the pool is at maximum it will expire using its eviction policy and still cache the object. Cleanup will be done later.">
		<!--- ************************************************************* --->
		<cfargument name="mapping" 				type="any" 	required="true" hint="The structure of name value pairs to cache" colddoc:generic="struct">
		<cfargument name="timeout"				type="any" 	required="false" default="" hint="The timeout to use on the object (if any, provider specific)">
		<cfargument name="lastAccessTimeout"	type="any" 	required="false" default="" hint="The idle timeout to use on the object (if any, provider specific)">
		<cfargument name="prefix" 				type="any" 	required="false" default="" hint="A prefix to prepend to the keys">
		<!--- ************************************************************* --->
		<cfscript>
			var key = 0;
			// Clear Prefix
			arguments.prefix = trim(arguments.prefix);
			// Loop Over mappings
			for(key in arguments.mapping)
			{
				// Cache theses puppies
				set(
					 objectKey=arguments.prefix & key
					,object=arguments.mapping[key]
					,timeout=arguments.timeout
					,lastAccessTimeout=arguments.lastAccessTimeout
				);
			}
		</cfscript>
	</cffunction>
	
	<!--- Set an Object in the cache --->
	<cffunction name="set" access="public" output="false" returntype="any" hint="sets an object in cache. Sets might be expensive. If the JVM threshold is used and it has been reached, the object won't be cached. If the pool is at maximum it will expire using its eviction policy and still cache the object. Cleanup will be done later." colddoc:generic="boolean">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" 			type="any"  	required="true" hint="The object cache key">
		<cfargument name="object"				type="any" 		required="true" hint="The object to cache">
		<cfargument name="timeout"				type="any"  	required="false" default="" hint="The timeout to use on the object (if any, provider specific)">
		<cfargument name="lastAccessTimeout"	type="any" 	 	required="false" default="" hint="The idle timeout to use on the object (if any, provider specific)">
		<cfargument name="extra" 				type="any" 		required="false" hint="A map of name-value pairs to use as extra arguments to pass to a providers set operation" colddoc:generic="struct"/>
		<!--- ************************************************************* --->
		<cfscript>
			var iData = "";
			// Check if updating or not
			var refLocal = {
				oldObject = getQuiet( arguments.objectKey )
			};
			
			// save object
			setQuiet(
				 arguments.objectKey
				,arguments.object
				,arguments.timeout
				,arguments.lastAccessTimeout
			);
			
			// Announce update if it exists?
			if( structKeyExists(refLocal,"oldObject") )
			{
				// interception Data
				iData = {
					cache = this,
					cacheNewObject = arguments.object,
					cacheOldObject = refLocal.oldObject
				};
				
				// announce it
				getEventManager().processState("afterCacheElementUpdated", iData);
			}
			
			// interception Data
			iData = {
				cache = this,
				cacheObject = arguments.object, 	
				cacheObjectKey = arguments.objectKey,
				cacheObjectTimeout = arguments.timeout,
				cacheObjectLastAccessTimeout = arguments.lastAccessTimeout
			};
			
			// announce it
			getEventManager().processState("afterCacheElementInsert", iData);
			
			return true;
		</cfscript>
	</cffunction>
	
	<!--- Set an Object in the cache --->
	<cffunction name="setQuiet" access="public" output="false" returntype="any" hint="sets an object in cache. Sets might be expensive. If the JVM threshold is used and it has been reached, the object won't be cached. If the pool is at maximum it will expire using its eviction policy and still cache the object. Cleanup will be done later." colddoc:generic="boolean">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" 			type="any"  	required="true" hint="The object cache key">
		<cfargument name="object"				type="any" 		required="true" hint="The object to cache">
		<cfargument name="timeout"				type="any"  	required="false" default="" hint="The timeout to use on the object (if any, provider specific)">
		<cfargument name="lastAccessTimeout"	type="any" 	 	required="false" default="" hint="The idle timeout to use on the object (if any, provider specific)">
		<cfargument name="extra" 				type="any" 		required="false" hint="A map of name-value pairs to use as extra arguments to pass to a providers set operation"  colddoc:generic="struct">
		<!--- ************************************************************* --->
		<cfscript>
			var isJVMSafe 		= true;
			var config 			= getConfiguration();
			var iData 			= {};
		
			// cleanup the key
			arguments.objectKey = lcase(arguments.objectKey);
								
			// Provider Default Timeout checks
			if( NOT len(arguments.timeout) OR NOT isNumeric(arguments.timeout) ){
				arguments.timeout = config.objectDefaultTimeout;
			}	
			if( NOT len(arguments.lastAccessTimeout) OR NOT isNumeric(arguments.lastAccessTimeout) ){
				arguments.lastAccessTimeout = config.objectDefaultLastAccessTimeout;
			}		
			
			// save object
			instance.objectStore.set(arguments.objectKey,arguments.object,arguments.timeout,arguments.lastAccessTimeout);
			
			return true;
		</cfscript>
	</cffunction>

	<!--- Clear an object from the cache --->
	<cffunction name="clearMulti" access="public" output="false" returntype="any" hint="Clears objects from the cache by using its cache key. The returned value is a structure of name-value pairs of all the keys that where removed from the operation." colddoc:generic="struct">
		<!--- ************************************************************* --->
		<cfargument name="keys" 		type="any" 	required="true" hint="The comma-delimmitted list or array of keys to remove.">
		<cfargument name="prefix" 		type="any" 	required="false" default="" hint="A prefix to prepend to the keys">
		<!--- ************************************************************* --->
		<cfscript>
			var returnStruct = {};
			var x = 1;
			var thisKey = "";
			
			// Clear Prefix
			arguments.prefix = trim(arguments.prefix);
			
			// array?
			if( isArray(arguments.keys) ){
				arguments.keys = arrayToList( arguments.keys );
			}
			
			// Loop on Keys
			for(x=1;x lte listLen(arguments.keys); x++){
				thisKey = arguments.prefix & listGetAt(arguments.keys,x);
				returnStruct[thiskey] = clear(thisKey);
			}
			
			return returnStruct;
		</cfscript>
	</cffunction>
	
	<!--- Clear By Key Snippet --->
	<cffunction name="clearByKeySnippet" access="public" returntype="void" hint="Clears keys using the passed in object key snippet" output="false" >
		<cfargument name="keySnippet"  	type="any" required="true"  hint="the cache key snippet to use">
		<cfargument name="regex" 		type="any" default="false" hint="Use regex or not" colddoc:generic="boolean">
		<cfargument name="async" 		type="any" default="false" hint="Run command asynchronously or not" colddoc:generic="boolean"/>
		
		<cfset var threadName = "clearByKeySnippet_#replace(instance.uuidHelper.randomUUID(),"-","","all")#">
		
		<!--- Async? --->
		<cfif arguments.async AND NOT instance.utility.inThread()>
			<cfthread name="#threadName#" keySnippet="#arguments.keySnippet#" regex="#arguments.regex#">
				<cfset instance.elementCleaner.clearByKeySnippet(attributes.keySnippet,attributes.regex)>
			</cfthread>	
		<cfelse>
			<cfset instance.elementCleaner.clearByKeySnippet(arguments.keySnippet,arguments.regex)>	
		</cfif>
	</cffunction>

	<!--- clearQuiet --->
	<cffunction name="clearQuiet" access="public" output="false" returntype="any" hint="Clears an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore" colddoc:generic="boolean">
		<cfargument name="objectKey" type="any"  	required="true" hint="The object cache key">
		<cfscript>
			// clean key
			arguments.objectKey = lcase(trim(arguments.objectKey));
			
			// clear key
			return instance.objectStore.clear( arguments.objectKey );
		</cfscript>
	</cffunction>
	
	<!--- clear --->
	<cffunction name="clear" access="public" output="false" returntype="any" hint="Clears an object from the cache by using its cache key. Returns false if object was not removed or did not exist anymore" colddoc:generic="boolean">
		<cfargument name="objectKey" type="any" required="true" hint="The object cache key">
		<cfscript>
			var clearCheck = clearQuiet( arguments.objectKey );
			var iData = {
				cache = this,
				cacheObjectKey 	= arguments.objectKey
			};
			
			// If cleared notify listeners
			if( clearCheck ){
				getEventManager().processState("afterCacheElementRemoved",iData);
			}
			
			return clearCheck;
		</cfscript>		
	</cffunction>
	
	<!--- clearAll --->
    <cffunction name="clearAll" output="false" access="public" returntype="void" hint="Clear all the cache elements from the cache">
    	<cfscript>
			var iData = {
				cache	= this
			};
			
			instance.objectStore.clearAll();		
			
			// notify listeners		
			getEventManager().processState("afterCacheClearAll",iData);
		</cfscript>
    </cffunction>
	
	<!--- Clear an object from the cache --->
	<cffunction name="clearKey" access="public" output="false" returntype="any" hint="Deprecated, please use clear()" colddoc:generic="boolean">
		<cfargument name="objectKey" type="any"  	required="true" hint="The object cache key">
		<cfreturn clear( arguments.objectKey )>
	</cffunction>

	<!--- Get the Cache Size --->
	<cffunction name="getSize" access="public" output="false" returntype="any" hint="Get the cache's size in items" colddoc:generic="numeric">
		<cfreturn instance.objectStore.getSize()>
	</cffunction>

	<!--- reap --->
	<cffunction name="reap" access="public" output="false" returntype="void" hint="Reap the cache, clear out everything that is dead.">
		<cfreturn />
	</cffunction>
	
	<!--- _reap --->
	<cffunction name="_reap" access="public" output="false" returntype="void" hint="Reap the cache, clear out everything that is dead.">
		<cfreturn />
	</cffunction>
	
	<!--- Expire All Objects --->
	<cffunction name="expireAll" access="public" returntype="void" hint="Expire All Objects. Use this instead of clear() from within handlers or any cached object, this sets the metadata for the objects to expire in the next request. Note that this is not an inmmediate expiration. Clear should only be used from outside a cached object" output="false" >
		<cfscript>
			return;
		</cfscript>
	</cffunction>
	
	<!--- Expire an Object --->
	<cffunction name="expireObject" access="public" returntype="void" hint="Expire an Object. Use this instead of clearKey() from within handlers or any cached object, this sets the metadata for the objects to expire in the next request. Note that this is not an inmmediate expiration. Clear should only be used from outside a cached object" output="false" >
		<cfargument name="objectKey" type="any"	required="true" hint="The object cache key">
		<cfscript>
			return;
		</cfscript>
	</cffunction>
	
	<!--- Expire an Object --->
	<cffunction name="expireByKeySnippet" access="public" returntype="void" hint="Same as expireKey but can touch multiple objects depending on the keysnippet that is sent in." output="false" >
		<!--- ************************************************************* --->
		<cfargument name="keySnippet" type="any"  required="true" hint="The key snippet to use">
		<cfargument name="regex" 	  type="any" required="false" default="false" hint="Use regex or not" colddoc:generic="boolean">
		<!--- ************************************************************* --->
		<cfscript>
			return;
		</cfscript>
	</cffunction>
	
	<!--- isExpired --->
    <cffunction name="isExpired" output="false" access="public" returntype="any" hint="Has the object key expired in the cache" colddoc:generic="boolean">
   		<cfargument name="objectKey" type="any" required="true" hint="The object key"/>
		<cfreturn true>
   	</cffunction>
	
	<!--- getObjectStore --->
	<cffunction name="getObjectStore" output="false" access="public" returntype="any" hint="If the cache provider implements it, this returns the cache's object store as type: coldbox.system.cache.store.IObjectStore" colddoc:generic="coldbox.system.cache.store.IObjectStore">
    	<cfreturn instance.objectStore>
	</cffunction>

	<!--- getStoreMetadataReport --->
	<cffunction name="getStoreMetadataReport" output="false" access="public" returntype="any" hint="Get a structure of all the keys in the cache with their appropriate metadata structures. This is used to build the reporting.[keyX->[metadataStructure]]" colddoc:generic="struct">
		<cfscript>
			return {};
		</cfscript>
	</cffunction>
	
	<!--- getStoreMetadataKeyMap --->
	<cffunction name="getStoreMetadataKeyMap" output="false" access="public" returntype="any" hint="Get a key lookup structure where cachebox can build the report on. Ex: [timeout=timeout,lastAccessTimeout=idleTimeout].  It is a way for the visualizer to construct the columns correctly on the reports" colddoc:generic="struct">
		<cfscript>	
			return {};
		</cfscript>
	</cffunction>
	
	<!--- get Keys --->
	<cffunction name="getKeys" access="public" returntype="any" output="false" hint="Get a listing of all the keys of the objects in the cache" colddoc:generic="array">
		<cfreturn ['Unsupported by Memcached']>
	</cffunction>
	
	<!--- Get the Java Runtime --->
	<cffunction name="getJavaRuntime" access="public" returntype="any" output="false" hint="Get the java runtime object for reporting purposes.">
		<cfreturn />
	</cffunction>
</cfcomponent>