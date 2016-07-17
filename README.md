Status as of July 2016: SyrioForel is stable and can help you cache data using AWS ElastiCache via ColdBox. However, I will not be investing resources in this package going forward. I had done quite a bit of ColdFusion work as a contractor working on projects for Adobe but that time is passed. If you would like to continue to grow this project please reach out to me as I would be happy to add you as a organizer.

SyrioForel
==========

Use Memcached or AWS ElastiCache within your ColdBox Application.

Syrio Forel of Braavos is a character from the book series "A Song of Ice and Fire" and hit
HBO series "Game of Thrones". Syrio's outlook and dicipline are traits of a great character--and he's a bad ass motherF##K#R!

----------

###Getting Started -- This will take a little work!
----------
You need to add this to your ColdBox application.

The basic steps look like this

* Enabling CFCs - You can put the CFCs found within the CFC directory anywhere you like. You might place it in your app's "/models/" directory--or in some lib. Just be sure you know the path and that it can be accessed from your deployed ColdBox application. 
* Enabling JARs - You need to load the JARs in the lib directory. You can use JavaLoader, place the JARs in ColdFusion's main lib directory (google it) or load it within your Application.cfc using ColdFusion 10 or Railo or Open Blue Dragon. If you are using ColdFusion 10 and you get errors about ColdFusion package access being disallowed [you may need to enable access to ColdFusion packages](http://helpx.adobe.com/coldfusion/kb/coldfusion-administrator-fails-permission-denied.html).


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
You could also define your endpoints and keep your secrets to your self. After all, everyone is entitiled to their secrets if they wish. Syrio won't be looking at anything you transmit or cache. He's not like the NSA or anything. uh... I make funny. Only joke. Serious. Don't mind me.
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
