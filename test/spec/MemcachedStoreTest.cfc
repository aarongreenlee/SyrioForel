/*------------------------------------------------------------------------------
Author 	    : 	Aaron Greenlee
				(C) WRECKINGBALL Media, LLC.
				This work is licensed under a Creative Commons Attribution-Share-Alike 3.0 Unported License
				http://wreckingballmedia.com/
				
Description : 	Spec for MemcachedStore
------------------------------------------------------------------------------*/

import coldbox.system.testing.*;
import app.cfc.*;

component extends="mxunit.framework.TestCase"
{
	// Point this to your working Memcached DB/ElastiCache server.
	// This will be used for integration testing.
	WorkingLocalServer =
	{
		 objectStore = 'coldbox.system.cache.store.MemcachedStore'
		,awsSecretKey = ''
		,awsAccessKey = ''
		,discoverEndpoints=false
		,endpoints='127.0.0.1:11211'	
		,dotNotationPathToCFCs='app.cfc'
		,skipLookupDoubleGet = true	
	};

	// You can disable integration testing eaisly by changing this flag.
	VARIABLES.REALLY_USE_MEMCACHED = true;
	/** Fail if integration testing is disabled. **/
	private function i() { if (!VARIABLES.REALLY_USE_MEMCACHED) fail('Integration testing disabled');}

	function setup ()
	{
		MockBox = new MockBox();

		variables.CacheProvider = MockBox.createStub();
		variables.CacheProvider.$("getConfiguration",WorkingLocalServer);
		
		SUT = new MemcachedStore(CacheProvider);

		MockBox.prepareMock(SUT);
	}
	
	function tearDown()
	{
		makePublic(SUT,'shutdown');
		SUT.shutDown();
	}
	
	function init_accepts_valid_config() {
		SUT.init(cacheProvider=CacheProvider);
		assert(true,"It should have worked.");
	}
	
	/**
		Basic verification that we can talk to Memcached, set a value and
		get the same value back. We'll test two different instances of the
		SUT just to make sure we're talking only to the Memcached server and
		no in-memory funkyness could be happening.
	**/
	function integration_get_set_works()
	{	
		i();
		
		var k ="integration_get_set_works";
		
		var tickCount = getTickCount();
		
		// Create a new instance to store the value...
		new MemcachedStore(variables.CacheProvider).set(k,"Hello from #tickCount#");
		
		var r = SUT.get(k);
		
		assertFalse(isNull(r),'Null result returned from cache!');
		
		// Use the SUT for our test asserting the cached value was returned.
		assertEquals("Hello from #tickCount#",r);
	}
	/**
		Confirm we can cache complex objects. In this case, a struct.
	**/
	function integration_caches_struct()
	{	
		i();
		var k = 'integration_caches_struct';		
		
		var a = {'AlphA' = 'Bet','soup' = [2,4,6],tick=getTickCount()};
		
		SUT.set(k,a);				
		var b = SUT.get(k);
				
		assertFalse(isNull(b),'Null result returned from cache!');
		
		 // Change a key on r to confirm we've got a unique reference...
		b.tick = getTickCount();
		assertNotEquals(a.tick,b.tick,'The tickcount should not be the same.');

		// Test for key equality for all keys but 'tick'...		
		var keys = ['alpha','soup'];
		for(var k in keys)
		{
			assert(structKeyExists(a,k),'A is missing key #k#');
			assert(structKeyExists(b,k),'B is missing key #k#');
			assertEquals(a[k],b[k],'A does not equal B for key #k#.');
		}
	}

	/**
		We should be able to set a value and look it up.
	**/
	function integration_lookup()
	{	
		i();
		var k = 'integration_lookup';		
		
		var a = 1;
		
		SUT.set(k,a);				
		assert(SUT.lookup(k),"The lookup was false!");
	}
	
	function init_throws_when_missing_config_keys() { return; };
	function init_prevent_server_lockout() { return; };
	function init_invalidates_bad_endpoints() { return; };
	function init_invalidates_no_endpoints(){ return; };
	function init_throws_when_AWS_library_is_missing(){ return; };
	
	
	function flush() { return; };
	
	function reap() { return; };
	
	function clearAll() { return; };
	
	function getKeys() { return; };
	
	function lookup() { return; };
	
	function get() { return; };

	function getQuiet() { return; };
	
	function expireObject() { return; };
	
	function isExpired() { return; };

	function set() { return; };
	
	function clear() { return; };
	
	function getSize() { return; }
	
}