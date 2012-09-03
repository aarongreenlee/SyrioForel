/*------------------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	    :	Aaron Greenlee
Description :
	
------------------------------------------------------------------------------*/
/** Memcached Store **/
component
output=false
hint="I work with Memcached directly to store and obtain objects from your cache. I work hared. Love me."
implements="coldbox.system.cache.store.IObjectStore"
{		
	
	// Endpoints used by the Memcached Client.
	variables.config = {
		'endpoints' = ''
	};
	variables.instance = {};
	/**
		@cacheProvider The associated cache provider as coldbox.system.cache.ICacheProvider.
	**/
	public MemcachedStore function init(required cacheProvider)
	{
		var strings = {
			 badConfig = 'Invalid MemcachedStore Configuratrion'
			,noCreate = 'Error creating MemcachedStore!'
		};
		
		var config = arguments.cacheProvider.getConfiguration();
		
		// Save the config...
		structAppend(variables.config,config,true);
		
		var requiredConfigKeys = ['awsSecretKey','awsAccessKey','discoverEndpoints','endpoints'];
		var missingKeys = [];
		for(var k in requiredConfigKeys) if (!structKeyExists(config,k)) arrayAppend(missingKeys,k);
		
		// Validations
		//
		// 1. Require All Config Keys
		if (!arrayIsEmpty(missingKeys)) throw(message=strings.noCreate,detail='The MemcachedStore needs some information to be passed via the CacheBox.cfc settings file when a provider is defined for this cache. These settings would typically be passed as settings when a CacheBox Provider is constructed. The missing configuration settings are: #arrayToList(missingKeys)#.');
		// 2. Make sure we have a known endpoint or have permission to find one.
		variables.config.endpoints = (len(trim(config.endpoints)) > 0) ? config.endpoints : "";
		if (!config.discoverEndpoints && len(variables.config.endpoints) == 0) throw(message=strings.badConfig,detail="You have specified you do not want the MemcachedStore to discover endpoints using your AWS credentials; however, you have not provided any endpoints. The MemcachedStore won't know which server to talk to!");
		// 3. Discover Endpoints?
		if (config.discoverEndpoints)
		{
			// todo... load AWS and ask for endpoints.
			variables.config.endpoints &= '';
		}
		// 3. Do we have valid endpoint's yet? 
		if (len(trim(variables.config.endpoints)) == 0) throw(message="MemcachedStore was unable to determine endpoints.",detail="No endpoints were provided and no active ElastiCache endpoints were discovered.")
		// 4. Are all endpoints valid?
		var invalidEndpoints = [];
		for(var endpoint in listToArray(variables.config.endpoints,' ') ) if (listLen(endpoint,':') != 2 || !isNumeric(listLast(endpoint,':'))) arrayAppend(invalidEndpoints,endpoint); 
		if (!arrayIsEmpty(invalidEndpoints)) throw(message="MemcachedStore rejected endpoints.",detail='The following endpoint(s) do not appear to be valid. Expecting something like 127.0.0.1:{11233} or aws-really-long-128.00.11.11-name.elasticache.com. The rejected endpoints are #arrayToList(invalidEndpoints)#.');

		return this;	
	}

	public void function flush(){
		var Memcached = build("memcached");
		Memcached.flush();
		
		return;
	}
	public void function reap(){}
	public void function clearAll(){}
	public any function getIndexer(){}
	public any function getKeys(){
		
	}
	public any function lookup(
		required any objectKey
	){
		
	}
	public any function get(
		required any objectKey
	){
		var Memcached = build("memcached");
		Memcached.get(arguments.objectKey);
				
	}
	public any function getQuiet(
		required any objectKey
	){}
	public void function expireObject(
		required any objectKey
	){}
	public any function isExpired(
		required any objectKey
	){}
	
	public void function set(
		 required any objectKey
		,required any object
		,any timeout=35
		,any lastAccessTimeout=''
		,any extras
	){
		var Memcached = build("memcached");
		
		Memcached.set(JavaCast("string",arguments.objectKey),JavaCast("string",arguments.object));
		
		return;
	}
	public any function clear(
		required any objectKey
	){}
	public any function getSize(){
		var Memcached = build("memcached");
		writeDump(Memcached.getStats());abort;
	}

	// -------------------------------------------------------------------------
	// PRIVATE
	// -------------------------------------------------------------------------
	
	/**
		A mini factory for Memcached.
		@alias An alias for the factory.
		@initArgs Optional init arguments for your target object.
	**/
	private any function build(
		 required string alias
		,any initArgs
	){
		switch(arguments.alias)
		{
			// Singletons
			case 'memcached':
				// Does this singleton exist? If so, just return.
				if (structKeyExists(variables.instance,arguments.alias)) return variables.instance[arguments.alias];
				
				// Begin construction...
				lock name="MemcachedStoreBuilding#arguments.alias#" timeout="25"
				{
					// Before building '
					if (structKeyExists(variables.instance,'Memcached')) return variables.instance[arguments.alias];
					
					lock name="MemcachedStoreBuilding#arguments.alias#_StepTwo" timeout="25"
					{
						switch(arguments.alias)
						{
							case 'memcached':
							{
								var AddrUtil = createObject('java',"net.spy.memcached.AddrUtil").init();
								try {
									variables.instance.memcached = createObject("java","net.spy.memcached.MemcachedClient")
										.init(AddrUtil.getAddresses(variables.config.endpoints));
								} catch (any e) {
									if (structKeyExists(variables.instance,'memcached')) try {memcached.shutdown();} catch (any e) { rethrow; }
								}
								return variables.instance.memcached;								
							}
						}
					}
					
					return variables.instance[arguments.alias];
				}
			break;
			default:
				throw(message="MemcachedStore internalFactory was unable to produce!",detail="Trying to produce alias #arguments.alias#");
			break;
		}
	}
}

