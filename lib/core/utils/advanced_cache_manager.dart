import 'dart:collection';

/// Advanced Cache Manager using LRU (Least Recently Used) algorithm
/// Provides O(1) access, insertion, and deletion operations
class AdvancedCacheManager<K, V> {
  final int _maxSize;
  final LinkedHashMap<K, V> _cache;
  final Map<K, DateTime> _accessTimes;
  final Map<K, DateTime> _expirationTimes;
  
  AdvancedCacheManager({int maxSize = 100}) 
      : _maxSize = maxSize,
        _cache = LinkedHashMap<K, V>(),
        _accessTimes = <K, DateTime>{},
        _expirationTimes = <K, DateTime>{};

  /// Get value from cache - O(1) complexity
  V? get(K key) {
    // Check if key exists and not expired
    if (!_cache.containsKey(key)) return null;
    
    final expiration = _expirationTimes[key];
    if (expiration != null && DateTime.now().isAfter(expiration)) {
      remove(key);
      return null;
    }
    
    // Update access time for LRU
    _accessTimes[key] = DateTime.now();
    
    // Move to end (most recently used)
    final value = _cache.remove(key);
    if (value != null) {
      _cache[key] = value;
      return value;
    }
    
    return null;
  }

  /// Put value in cache - O(1) complexity
  void put(K key, V value, {Duration? ttl}) {
    // Remove if already exists
    if (_cache.containsKey(key)) {
      _cache.remove(key);
    }
    
    // Check if cache is full
    if (_cache.length >= _maxSize) {
      _evictLRU();
    }
    
    // Add new entry
    _cache[key] = value;
    _accessTimes[key] = DateTime.now();
    
    // Set expiration if TTL provided
    if (ttl != null) {
      _expirationTimes[key] = DateTime.now().add(ttl);
    }
  }

  /// Remove value from cache - O(1) complexity
  V? remove(K key) {
    _accessTimes.remove(key);
    _expirationTimes.remove(key);
    return _cache.remove(key);
  }

  /// Check if key exists in cache - O(1) complexity
  bool containsKey(K key) {
    if (!_cache.containsKey(key)) return false;
    
    // Check expiration
    final expiration = _expirationTimes[key];
    if (expiration != null && DateTime.now().isAfter(expiration)) {
      remove(key);
      return false;
    }
    
    return true;
  }

  /// Get all keys - O(n) complexity
  Iterable<K> get keys => _cache.keys;

  /// Get all values - O(n) complexity
  Iterable<V> get values => _cache.values;

  /// Get cache size - O(1) complexity
  int get length => _cache.length;

  /// Check if cache is empty - O(1) complexity
  bool get isEmpty => _cache.isEmpty;

  /// Clear all cache - O(n) complexity
  void clear() {
    _cache.clear();
    _accessTimes.clear();
    _expirationTimes.clear();
  }

  /// Evict least recently used item - O(1) complexity
  void _evictLRU() {
    if (_cache.isEmpty) return;
    
    // Find LRU key (first key in LinkedHashMap is oldest)
    final lruKey = _cache.keys.first;
    remove(lruKey);
  }

  /// Clean expired entries - O(n) complexity
  void cleanExpired() {
    final now = DateTime.now();
    final expiredKeys = <K>[];
    
    for (final entry in _expirationTimes.entries) {
      if (now.isAfter(entry.value)) {
        expiredKeys.add(entry.key);
      }
    }
    
    for (final key in expiredKeys) {
      remove(key);
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    return {
      'size': _cache.length,
      'maxSize': _maxSize,
      'hitRate': _calculateHitRate(),
      'oldestAccess': _getOldestAccess(),
      'newestAccess': _getNewestAccess(),
    };
  }

  double _calculateHitRate() {
    // This would need hit/miss counters in a real implementation
    return 0.0;
  }

  DateTime? _getOldestAccess() {
    if (_accessTimes.isEmpty) return null;
    return _accessTimes.values.reduce((a, b) => a.isBefore(b) ? a : b);
  }

  DateTime? _getNewestAccess() {
    if (_accessTimes.isEmpty) return null;
    return _accessTimes.values.reduce((a, b) => a.isAfter(b) ? a : b);
  }
}

/// Specialized cache for tasks with efficient operations
class TaskCacheManager {
  static final AdvancedCacheManager<String, Map<String, dynamic>> _taskCache = 
      AdvancedCacheManager<String, Map<String, dynamic>>(maxSize: 200);
  
  static final AdvancedCacheManager<String, List<Map<String, dynamic>>> _queryCache = 
      AdvancedCacheManager<String, List<Map<String, dynamic>>>(maxSize: 50);

  /// Cache single task - O(1)
  static void cacheTask(String taskId, Map<String, dynamic> task) {
    _taskCache.put(taskId, task, ttl: const Duration(minutes: 30));
  }

  /// Get cached task - O(1)
  static Map<String, dynamic>? getCachedTask(String taskId) {
    return _taskCache.get(taskId);
  }

  /// Cache query results - O(1)
  static void cacheQuery(String queryKey, List<Map<String, dynamic>> results) {
    _queryCache.put(queryKey, results, ttl: const Duration(minutes: 10));
  }

  /// Get cached query results - O(1)
  static List<Map<String, dynamic>>? getCachedQuery(String queryKey) {
    return _queryCache.get(queryKey);
  }

  /// Generate cache key for queries
  static String generateQueryKey({
    String? status,
    String? priority,
    String? assignedTo,
    int? limit,
    int? offset,
  }) {
    return 'query_${status ?? 'all'}_${priority ?? 'all'}_${assignedTo ?? 'all'}_${limit ?? 50}_${offset ?? 0}';
  }

  /// Clear all caches
  static void clearAll() {
    _taskCache.clear();
    _queryCache.clear();
  }

  /// Clean expired entries
  static void cleanExpired() {
    _taskCache.cleanExpired();
    _queryCache.cleanExpired();
  }

  /// Get cache statistics
  static Map<String, dynamic> getStats() {
    return {
      'taskCache': _taskCache.getStats(),
      'queryCache': _queryCache.getStats(),
    };
  }
}