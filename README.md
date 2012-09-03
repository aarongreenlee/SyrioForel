SyrioForel
==========

Use Memcached or AWS ElastiCache within your ColdBox Application.

Syrio Forel of Braavos is a character from the book series "A Song of Ice and Fire" and hit
HBO series "Game of Thrones". It is for Syrio's outlook that I honor him...

"What do we say to death? Not Today!"


Straight Memcached
==========
This is perhaps the easiest way to have Syrio work for you. Download Memcached Server (linux from Memcached.org; Windows from http://splinedancer.com/memcached-win32/) and get it to work. Running on your local machine should be pretty straight forard. If you are connecting to a external Memcached cluster make note of the endpoint(s).

Getting Your Memcached Enpoint(s)
--
If you are using a local Memcached server your endpoint is most likly "127.0.0.1:11211".
If you are connecting to an externally hosted Memcached server(s) make note of their endpoints. Each should be seperated by a space.

Example CacheBox.cfc Configuration
--
```ColdFusion
caches = {
  template =
  {
    provider = 'coldbox.system.cache.providers.CacheBoxProvider'
    ,properties =
    {
       objectStore = 'path.to.your.MemcachedStore'
      ,awsSecretKey = ''
      ,awsAccessKey = ''
      ,discoverEndpoints=false
      ,endpoints='127.0.0.1:11211'
    }
  }
}
````