/** Spec Test for MemcachedStore. 
	
	Uses MXUnit with MightyMock support.
**/
import coldbox.system.testing.*;

component
	extends="mxunit.framework.TestCase"
{
	
	WorkingLocalServer = {
		 objectStore = 'coldbox.system.cache.store.MemcachedStore'
		,awsSecretKey = ''
		,awsAccessKey = ''
		,discoverEndpoints=false
		,endpoints='127.0.0.1:11211'		
	};

	function setup ()
	{
		MockBox = new MockBox();

		CacheProvider = MockBox.createStub();
		CacheProvider.$("getConfiguration",WorkingLocalServer);
		
		SUT = new app.cfc.MemcachedStore(CacheProvider);

		MockBox.prepareMock(SUT);
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