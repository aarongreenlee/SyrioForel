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
		,awsaccesskey='123'
		,awssecretkey='456'
		,environment='unittest'
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

		Memcached = MockBox.createStub();

		SUT = new MemcachedStore(CacheProvider);

		MockBox.prepareMock(SUT);
	}

	function tearDown()
	{
		try {
			makePublic(SUT,'shutdown');
			SUT.shutDown();
		} catch (any e) {
			// graceful...
		}
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
		Basic integration test to confirm we can obtain multiple values
		from the cache.
	**/
	function integration_bulk_get_works()
	{
		i();

		var map = {
			 'integration_bulk_get_works_1'=createUUID()
			,'integration_bulk_get_works_2'=createUUID()
			,'integration_bulk_get_works_3'=createUUID()
		};

		var tickCount = getTickCount();

		// Create a new instance to store the value...
		for(var k in map) new MemcachedStore(variables.CacheProvider).set(k,map[k]);

		var r = SUT.get(objectKey=structKeyArray(map));

		for(var k in map)
		{
			assert(structKeyExists(map,k),'Expected the key #k# to exist in the cache.');
			assertEquals(map[k],r['#k#:e_unittest'],'Unexpected value for key #k#');
		}
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
			,skipLookupDoubleGet=false
			,environment='unittest'
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
			,skipLookupDoubleGet=false
			,environment='unittest'
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
			,skipLookupDoubleGet=false
		});

		SUT.$('discover','');

		try {
			SUT.init(CacheProvider=CacheProvider);
		} catch (any e) {
			assertEquals("MemcachedStore.BadConfig",e.errorCode,"Unexpected errorCode for CFCatch");
		}
		return;
	};

	function flush() {
		Memcached.$('flush');
		SUT.$property('instance','variables',{'memcached'=Memcached});

		SUT.flush();

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

	function lookup_delegates_to_get_returns_false_for_null() {
		SUT.$('get');

		var r = SUT.lookup('example');

		assertEquals(1,SUT.$count('get'),'Should delegate to GET()');
		assertEquals('example',SUT.$callLog().get[1].objectKey);
		assertFalse(r,'The mocked result from GET was null. Expected false.');
	};
	function lookup_delegates_to_get_returns_true_for_null() {
		SUT.$('get','something exists!');

		var r = SUT.lookup('example');

		assertEquals(1,SUT.$count('get'),'Should delegate to GET()');
		assertEquals('example',SUT.$callLog().get[1].objectKey);
		assert(r,'The mocked result from GET was not null. Expected true.');
	};
	function get()
	{
		SUT.$('blockingGet','result');

		var r = SUT.get('thisOneOrThatOne');

		assertEquals(1,SUT.$count('blockingGet'),'this.blockingGet() call count.');
		assertEquals('thisOneOrThatOne:e_unittest',SUT.$callLog().blockingGet[1][1],'Unexpected argument to blockingGet.');
		assertEquals('result',r,'Expected our mocked result from BlockingGet to be returned.');
	};

	function getQuiet()
	{
		SUT.$('blockingGet','result');

		var r = SUT.getQuiet('thisOneOrThatOne');

		assertEquals(1,SUT.$count('blockingGet'),'this.blockingGet() call count.');
		assertEquals('thisOneOrThatOne:e_unittest',SUT.$callLog().blockingGet[1][1],'Unexpected argument to blockingGet.');
		assertEquals('result',r,'Expected our mocked result from BlockingGet to be returned.');
	};

	/** This method is under test. Nothing to assert. **/
	function expireObject()
	{
		return;
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

		Memcached.$('getStats',{});
		SUT.$property('instance','variables',{'memcached'=Memcached});

		SUT
			.$property('active','variables',true)
			.$('convertHashMapToStruct',{'total_items'=100});

		assertEquals(100,SUT.getSize(),'Total_items in both hosts should be added.');
	}
	function parseKey_should_append_environment()
	{
		makePublic(SUT,'parseKey');
		var k = SUT.parseKey('abc');
		assertEquals('abc:e_unittest',k,'Expected the environment to be appended to the key.');
	}
	function parseKey_should_append_environment_to_array_of_keys()
	{
		makePublic(SUT,'parseKey');
		var k = SUT.parseKey(['Abc','easy_as_123','Or_simple_as','do_re_mi']);
		assertEquals(['Abc:e_unittest','easy_as_123:e_unittest','Or_simple_as:e_unittest','do_re_mi:e_unittest'],k,'Expected the environment to be appended to the keys.');
	}
}