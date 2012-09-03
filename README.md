SyrioForel
==========

Use Memcached or AWS ElastiCache within your ColdBox Application.

Syrio Forel of Braavos is a character from the book series "A Song of Ice and Fire" and hit
HBO series "Game of Thrones". Syrio's outlook and dicipline are traits of a great character--and he's a bad ass motherF##K#R!

----------

###Working with AWS ElastiCache
----------
You can only connect to an Amazon ElastiCache instance from your AWS environment. Don't try to connect to your ElastiCache instance from your office, or development servers in Switzerland where you keep your private accounts, right? I mean, am I wrong to keep my money there so Uncle Sam won't tax me? All Americans do this, right? Anyway, just make sure you are only going to pass these settings to an instance that is deployed on your EC2.

####Getting Your Memcached Enpoint(s)
Syrio works hard for you. He can find your endpoints for you if you provide him with your AWS Access and Secret keys. This is sensitive information so be carful in how you do this. For my deployments, I have a build process (could be manual) that saves a "secrets.txt" file to the server. This file is not in version control. When ColdFusion starts I read this file and set Application variables. Not rocket science. Then, I pass the variables as you see below.
```JavaScript
caches = {
  template :
  {
    provider : 'coldbox.system.cache.providers.CacheBoxProvider'
    ,properties :
    {
       objectStore : 'path.to.your.MemcachedStore'
      ,awsSecretKey : application.awsSecretKey // "could be a string"
      ,awsAccessKey : application.awsAccessKey // "could be a string"
      ,discoverEndpoints:true
      ,endpoints:''
    }
  }
}
````
####Defining your own AWS Endpoints
You could also define your endpoints like this and keep your AWS secrets to your self. After all, everyone's entitiled to their secrets if they wish. Syrio won't be looking data you are caching. He's not like the NSA or anything. Wait, uh... I make funny. Only joke. Serious. Don't mind me.
```JavaScript
caches = {
  template :
  {
    provider : 'coldbox.system.cache.providers.CacheBoxProvider'
    ,properties :
    {
       objectStore : 'path.to.your.MemcachedStore'
      ,awsSecretKey : application.awsSecretKey // "could be a string"
      ,awsAccessKey : application.awsAccessKey // "could be a string"
      ,discoverEndpoints:true
      ,endpoints:'aws-0.0.0.0.-some-long-dns-name-or-loadbalancer:11211'
    }
  }
}
````
###Working with Memcached (not AWS ElastiCache)
----------
This is perhaps the easiest way to have Syrio work for you.

Download Memcached Server (linux from Memcached.org; Windows from http://splinedancer.com/memcached-win32/) and get it to work. Running on your local machine should be pretty straight forard. If you are connecting to a external Memcached cluster make note of the endpoint(s).

####Getting Your Memcached Enpoint(s)
If you are using a local Memcached server your endpoint is most likly "127.0.0.1:11211".
If you are connecting to an externally hosted Memcached server(s) make note of their endpoints. Each should be seperated by a space.

####Example CacheBox.cfc Configuration

```JavaScript
caches = {
  template :
  {
    provider : 'coldbox.system.cache.providers.CacheBoxProvider'
    ,properties :
    {
       objectStore : 'path.to.your.MemcachedStore'
      ,awsSecretKey : ''
      ,awsAccessKey : ''
      ,discoverEndpoints:false
      ,endpoints:'127.0.0.1:11211'
    }
  }
}
````