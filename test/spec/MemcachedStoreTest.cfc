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
	
	function init_accepts_valid_config() {
		SUT.init(cacheProvider=CacheProvider);
		assert(true,"It should have worked.");
	}
	
	function integration_get_set_works()
	{
		var tickCount = getTickCount();
		SUT.set("test1",0,"Hello from #tickCount#");
		sleep(1);
		var getResult = SUT.get("test1");
		
		assertEquals("Hello from #tickCount#",getResult);
	}
	
	function init_throws_when_missing_config_keys() {
		
		CacheProvider.$("getConfiguration",{});

		try {
			SUT.init(CacheProvider);
			fail("Expected SUT to throw during init.");
		} catch (any e) {
			assertEquals("MemcachedStore.BadConfig",e.errorCode,"Unexpected errorCode for CFCatch.");
		}
		return;
	};
	/** Ensure we can either discover servers or servers were provided. **/
	function init_prevent_server_lockout()
	{
		CacheProvider.$("getConfiguration",{
			 objectStore = 'coldbox.system.cache.store.MemcachedStore'
			,awsSecretKey = ''
			,awsAccessKey = ''
			,discoverEndpoints=false
			,endpoints=''		
		});

		try {
			SUT.init(CacheProvider=CacheProvider);
		} catch (any e) {
			assertEquals("MemcachedStore.ServerLockout",e.errorCode,"Unexpected errorCode for CFCatch");
		}

		return;
	};
	function init_invalidates_bad_endpoints() {
		CacheProvider.$("getConfiguration",{
			 objectStore = 'coldbox.system.cache.store.MemcachedStore'
			,awsSecretKey = ''
			,awsAccessKey = ''
			,discoverEndpoints=false
			,endpoints='127.0.0.1'		
		});

		try {
			SUT.init(CacheProvider=CacheProvider);
		} catch (any e) {
			assertEquals("MemcachedStore.InvalidEndpoints",e.errorCode,"Unexpected errorCode for CFCatch");
		}		
		return;
	};
	function init_invalidates_no_endpoints(){
		CacheProvider.$("getConfiguration",{
			 objectStore = 'coldbox.system.cache.store.MemcachedStore'
			,awsSecretKey = ''
			,awsAccessKey = ''
			,discoverEndpoints=true
			,endpoints=''		
		});

		SUT.$('discover','');

		try {
			SUT.init(CacheProvider=CacheProvider);
		} catch (any e) {
			assertEquals("MemcachedStore.NoEndpoints",e.errorCode,"Unexpected errorCode for CFCatch");
		}		
		return;
	};
	
	function flush() { 
		Memcached.$('flush');
		SUT.$('build',Memcached);
		
		SUT.flush();

		assertEquals(1,SUT.$count('build'),'this.build() callcount.');
		assertEquals(1,Memcached.$count('flush'),'Memcached.flush() callcount unexpected.');
	};
	
	function reap() { 
		flush();
	};
	
	function clearAll() { 
		flush();
	};
	
	function getKeys() {
		assertEquals(["Unsupported by Memcached"],SUT.getKeys(),'Unexpected result.');
	};
	
	function lookup_wontBuildWhenActive() { 
		SUT
			.$property('active','variables',true)
			.$('blockingGet',true)
			.$('build');

		var r = SUT.lookup('example');

		assertEquals(0,SUT.$count('build'),'Should not build when active=true.');
		assertEquals(0,SUT.$count('blockingGet'),'this.blockingGet() call count.');
		assert(r,'Mocked value for this.blockingGet() was not returned.');
	};
	function lookup_willBuildWhenInactive() { 
		SUT
			.$property('active','variables',false)
			.$('blockingGet',true)
			.$('build');

		var r = SUT.lookup('WhenTwoShallMeet');

		assertEquals(0,SUT.$count('build'),'Should not build when active=true.');
		assertEquals('WhenTwoShallMeet',SUT.$callLog('blockingGet')[1][1],'Unexpected argument to blockingGet.');
		assert(r,'Mocked value for this.blockingGet() was not returned.');
	};
	
	function get()
	{
		SUT
			.$('blockingGet')
			.get('OneDoesNotKnow');

		assertEquals(1,SUT.$count('blockingGet'),'this.blockingGet() call count.');
		assertEquals('OneDoesNotKnow',SUT.$callLog('blockingGet')[1][1],'Unexpected argument to blockingGet.');
	};

	function getQuiet() {
		SUT
			.$('blockingGet')
			.getQuiet('thisOneOrThatOne');

		assertEquals(1,SUT.$count('blockingGet'),'this.blockingGet() call count.');
		assertEquals('thisOneOrThatOne',SUT.$callLog('blockingGet')[1][1],'Unexpected argument to blockingGet.');
	};
	
	function expireObject() {
		SUT
			.$('delete')
			.expireObject('pickOne');

		assertEquals(1,SUT.$count('delete'),'this.blockingGet() call count.');
		assertEquals('pickOne',SUT.$callLog('delete')[1][1],'Unexpected argument to delete.');
	};
	
	function isExpired() {
		assert(SUT.isExpired("anything"),'IsExpired should always be true.');
	};

	function set() { 
		SUT
			.$('blockingSet')
			.set('KeyToMy','Heart');

		assertEquals(1,SUT.$count('blockingSet'),'this.blockingSet() call count.');
	};
	
	function clear() { 

	};
	
	function getSize() {
		SUT
			.$property('active','variables',true)
			.$('convertHashMapToStruct',{'localhost'={total_items=100}'remotehost'={total_items=26}});

		assertEquals(126,SUT..getSize(),'Total_items in both hosts should be added.');
	}
}