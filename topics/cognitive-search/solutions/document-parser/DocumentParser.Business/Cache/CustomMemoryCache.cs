using Microsoft.Extensions.Caching.Memory;

namespace DocumentParser.Business.Cache
{
    public static class CustomMemoryCache
    {
        private static MemoryCache _cache = new MemoryCache(new MemoryCacheOptions());

        public static void BustAllCache()
        {
            _cache.Dispose();
            _cache = new MemoryCache(new MemoryCacheOptions());
        }

        public static object GetOrStore(string key, Func<object> getValue, int expireInSeconds)
        {
            object cacheEntry;
            if (!_cache.TryGetValue(key, out cacheEntry))// Look for cache key.
            {
                cacheEntry = getValue.Invoke();
                var cacheOptions = new MemoryCacheEntryOptions()
                {
                    SlidingExpiration = TimeSpan.FromMinutes(20),
                    //Set to expire in 24hours
                    AbsoluteExpiration = DateTimeOffset.UtcNow.AddSeconds(expireInSeconds)
                };

                //remember to use the above created object as third parameter.
                _cache.Set(key, cacheEntry, cacheOptions);
            }

            return cacheEntry;
        }

        public static object GetOrStore<T>(string key, Func<T, object> getValue, int expireInSeconds, T argument1)
        {
            object cacheEntry;
            if (!_cache.TryGetValue(key, out cacheEntry))// Look for cache key.
            {
                cacheEntry = getValue(argument1);
                var cacheOptions = new MemoryCacheEntryOptions()
                {
                    SlidingExpiration = TimeSpan.FromMinutes(20),
                    //Set to expire in 24hours
                    AbsoluteExpiration = DateTimeOffset.UtcNow.AddSeconds(expireInSeconds)
                };

                //remember to use the above created object as third parameter.
                _cache.Set(key, cacheEntry, cacheOptions);
            }

            return cacheEntry;
        }

        public static object GetOrStore<T, T1>(string key, Func<T, T1, object> getValue, int expireInSeconds, T argument1, T1 argument2)
        {
            object cacheEntry;
            if (!_cache.TryGetValue(key, out cacheEntry))// Look for cache key.
            {
                cacheEntry = getValue(argument1, argument2);
                var cacheOptions = new MemoryCacheEntryOptions()
                {
                    SlidingExpiration = TimeSpan.FromMinutes(20),
                    //Set to expire in 24hours
                    AbsoluteExpiration = DateTimeOffset.UtcNow.AddSeconds(expireInSeconds)
                };

                //remember to use the above created object as third parameter.
                _cache.Set(key, cacheEntry, cacheOptions);
            }

            return cacheEntry;
        }
    }
}