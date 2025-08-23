import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webak/core/utils/advanced_cache_manager.dart';

/// Multi-level cache system with memory, disk, and network layers
/// Provides hierarchical caching with automatic fallback and optimization
class MultiLevelCache {
  static final MultiLevelCache _instance = MultiLevelCache._internal();
  static MultiLevelCache get instance => _instance;
  
  MultiLevelCache._internal();

  // Level 1: Memory Cache (Fastest - O(1))
  final AdvancedCacheManager<String, dynamic> _memoryCache = 
      AdvancedCacheManager<String, dynamic>(maxSize: 500);
  
  // Level 2: Disk Cache (Fast - O(1) file access)
  final Map<String, DateTime> _diskCacheIndex = {};
  Directory? _cacheDirectory;
  
  // Level 3: Network Cache Headers
  final Map<String, Map<String, String>> _networkHeaders = {};
  
  // Cache statistics
  int _memoryHits = 0;
  int _diskHits = 0;
  int _networkHits = 0;
  int _totalRequests = 0;

  /// Initialize cache system
  Future<void> initialize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDirectory = Directory('${appDir.path}/cache');
      
      if (!await _cacheDirectory!.exists()) {
        await _cacheDirectory!.create(recursive: true);
      }
      
      await _loadDiskCacheIndex();
      await _cleanExpiredDiskCache();
    } catch (e) {
      debugPrint('Cache initialization error: $e');
    }
  }

  /// Get value from multi-level cache with automatic fallback
  Future<T?> get<T>(String key, {
    Duration? ttl,
    Future<T> Function()? networkFallback,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    _totalRequests++;
    
    try {
      // Level 1: Memory Cache - O(1)
      final memoryResult = _memoryCache.get(key);
      if (memoryResult != null) {
        _memoryHits++;
        if (memoryResult is T) {
          return memoryResult;
        } else if (fromJson != null && memoryResult is Map<String, dynamic>) {
          return fromJson(memoryResult);
        }
      }

      // Level 2: Disk Cache - O(1) file access
      final diskResult = await _getDiskCache<T>(key, fromJson: fromJson);
      if (diskResult != null) {
        _diskHits++;
        // Promote to memory cache
        _memoryCache.put(key, diskResult, ttl: ttl);
        return diskResult;
      }

      // Level 3: Network Fallback
      if (networkFallback != null) {
        _networkHits++;
        final networkResult = await networkFallback();
        
        if (networkResult != null) {
          // Store in all cache levels
          await put(key, networkResult, ttl: ttl);
          return networkResult;
        }
      }

      return null;
    } catch (e) {
      debugPrint('Cache get error for key $key: $e');
      return null;
    }
  }

  /// Store value in all cache levels
  Future<void> put<T>(String key, T value, {
    Duration? ttl,
    Map<String, dynamic> Function(T)? toJson,
  }) async {
    try {
      final effectiveTtl = ttl ?? const Duration(hours: 24);
      
      // Level 1: Memory Cache
      _memoryCache.put(key, value, ttl: effectiveTtl);
      
      // Level 2: Disk Cache
      await _setDiskCache(key, value, ttl: effectiveTtl, toJson: toJson);
      
    } catch (e) {
      debugPrint('Cache put error for key $key: $e');
    }
  }

  /// Remove from all cache levels
  Future<void> remove(String key) async {
    try {
      // Remove from memory
      _memoryCache.remove(key);
      
      // Remove from disk
      await _removeDiskCache(key);
      
      // Remove network headers
      _networkHeaders.remove(key);
      
    } catch (e) {
      debugPrint('Cache remove error for key $key: $e');
    }
  }

  /// Clear all cache levels
  Future<void> clear() async {
    try {
      // Clear memory
      _memoryCache.clear();
      
      // Clear disk
      if (_cacheDirectory != null && await _cacheDirectory!.exists()) {
        await for (final entity in _cacheDirectory!.list()) {
          if (entity is File) {
            await entity.delete();
          }
        }
      }
      
      _diskCacheIndex.clear();
      _networkHeaders.clear();
      
      // Reset statistics
      _memoryHits = 0;
      _diskHits = 0;
      _networkHits = 0;
      _totalRequests = 0;
      
    } catch (e) {
      debugPrint('Cache clear error: $e');
    }
  }

  /// Get cache statistics and performance metrics
  Map<String, dynamic> getStatistics() {
    final memoryStats = _memoryCache.getStats();
    
    return {
      'memory': {
        'hits': _memoryHits,
        'size': memoryStats['size'],
        'maxSize': memoryStats['maxSize'],
        'hitRate': _totalRequests > 0 ? (_memoryHits / _totalRequests * 100).toStringAsFixed(2) : '0.00',
      },
      'disk': {
        'hits': _diskHits,
        'size': _diskCacheIndex.length,
        'hitRate': _totalRequests > 0 ? (_diskHits / _totalRequests * 100).toStringAsFixed(2) : '0.00',
      },
      'network': {
        'hits': _networkHits,
        'hitRate': _totalRequests > 0 ? (_networkHits / _totalRequests * 100).toStringAsFixed(2) : '0.00',
      },
      'overall': {
        'totalRequests': _totalRequests,
        'totalHits': _memoryHits + _diskHits + _networkHits,
        'overallHitRate': _totalRequests > 0 
            ? ((_memoryHits + _diskHits + _networkHits) / _totalRequests * 100).toStringAsFixed(2) 
            : '0.00',
        'averageResponseTime': _calculateAverageResponseTime(),
      },
    };
  }

  /// Preload frequently accessed data
  Future<void> preload(Map<String, Future<dynamic> Function()> preloadMap) async {
    final futures = preloadMap.entries.map((entry) async {
      try {
        final value = await entry.value();
        await put(entry.key, value, ttl: const Duration(hours: 12));
      } catch (e) {
        debugPrint('Preload error for ${entry.key}: $e');
      }
    });
    
    await Future.wait(futures);
  }

  /// Warm up cache with predicted data
  Future<void> warmUp(List<String> keys, Future<dynamic> Function(String) dataLoader) async {
    final futures = keys.map((key) async {
      if (!_memoryCache.containsKey(key)) {
        try {
          final value = await dataLoader(key);
          await put(key, value, ttl: const Duration(hours: 6));
        } catch (e) {
          debugPrint('Warm up error for $key: $e');
        }
      }
    });
    
    await Future.wait(futures);
  }

  /// Disk cache operations
  Future<T?> _getDiskCache<T>(String key, {
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      if (_cacheDirectory == null) return null;
      
      final file = File('${_cacheDirectory!.path}/${_sanitizeKey(key)}.json');
      
      if (!await file.exists()) return null;
      
      // Check expiration
      final expiration = _diskCacheIndex[key];
      if (expiration != null && DateTime.now().isAfter(expiration)) {
        await _removeDiskCache(key);
        return null;
      }
      
      final content = await file.readAsString();
      final data = json.decode(content);
      
      if (data is T) {
        return data;
      } else if (fromJson != null && data is Map<String, dynamic>) {
        return fromJson(data);
      }
      
      return data as T?;
    } catch (e) {
      debugPrint('Disk cache get error for $key: $e');
      return null;
    }
  }

  Future<void> _setDiskCache<T>(String key, T value, {
    Duration? ttl,
    Map<String, dynamic> Function(T)? toJson,
  }) async {
    try {
      if (_cacheDirectory == null) return;
      
      final file = File('${_cacheDirectory!.path}/${_sanitizeKey(key)}.json');
      
      dynamic dataToStore = value;
      if (toJson != null) {
        dataToStore = toJson(value);
      } else if (value is! String && value is! num && value is! bool && value is! List && value is! Map) {
        // For complex objects, try to convert to JSON-serializable format
        try {
          dataToStore = json.decode(json.encode(value));
        } catch (e) {
          debugPrint('Cannot serialize $key to JSON: $e');
          return;
        }
      }
      
      await file.writeAsString(json.encode(dataToStore));
      
      // Update index with expiration
      if (ttl != null) {
        _diskCacheIndex[key] = DateTime.now().add(ttl);
        await _saveDiskCacheIndex();
      }
    } catch (e) {
      debugPrint('Disk cache set error for $key: $e');
    }
  }

  Future<void> _removeDiskCache(String key) async {
    try {
      if (_cacheDirectory == null) return;
      
      final file = File('${_cacheDirectory!.path}/${_sanitizeKey(key)}.json');
      
      if (await file.exists()) {
        await file.delete();
      }
      
      _diskCacheIndex.remove(key);
      await _saveDiskCacheIndex();
    } catch (e) {
      debugPrint('Disk cache remove error for $key: $e');
    }
  }

  Future<void> _loadDiskCacheIndex() async {
    try {
      if (_cacheDirectory == null) return;
      
      final indexFile = File('${_cacheDirectory!.path}/cache_index.json');
      
      if (await indexFile.exists()) {
        final content = await indexFile.readAsString();
        final data = json.decode(content) as Map<String, dynamic>;
        
        _diskCacheIndex.clear();
        data.forEach((key, value) {
          _diskCacheIndex[key] = DateTime.parse(value as String);
        });
      }
    } catch (e) {
      debugPrint('Load disk cache index error: $e');
    }
  }

  Future<void> _saveDiskCacheIndex() async {
    try {
      if (_cacheDirectory == null) return;
      
      final indexFile = File('${_cacheDirectory!.path}/cache_index.json');
      
      final data = <String, String>{};
      _diskCacheIndex.forEach((key, value) {
        data[key] = value.toIso8601String();
      });
      
      await indexFile.writeAsString(json.encode(data));
    } catch (e) {
      debugPrint('Save disk cache index error: $e');
    }
  }

  Future<void> _cleanExpiredDiskCache() async {
    try {
      final now = DateTime.now();
      final expiredKeys = <String>[];
      
      _diskCacheIndex.forEach((key, expiration) {
        if (now.isAfter(expiration)) {
          expiredKeys.add(key);
        }
      });
      
      for (final key in expiredKeys) {
        await _removeDiskCache(key);
      }
    } catch (e) {
      debugPrint('Clean expired disk cache error: $e');
    }
  }

  String _sanitizeKey(String key) {
    return key.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  }

  double _calculateAverageResponseTime() {
    // Simplified calculation - in real implementation, you'd track actual response times
    if (_totalRequests == 0) return 0.0;
    
    final memoryTime = _memoryHits * 1.0; // 1ms average for memory
    final diskTime = _diskHits * 10.0; // 10ms average for disk
    final networkTime = _networkHits * 100.0; // 100ms average for network
    
    return (memoryTime + diskTime + networkTime) / _totalRequests;
  }
}

/// Specialized cache for different data types
class TypedCache {
  static final MultiLevelCache _cache = MultiLevelCache.instance;

  /// Cache for task data
  static Future<T?> getTask<T>(String taskId, {
    Future<T> Function()? networkFallback,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return await _cache.get<T>(
      'task_$taskId',
      ttl: const Duration(minutes: 30),
      networkFallback: networkFallback,
      fromJson: fromJson,
    );
  }

  static Future<void> setTask<T>(String taskId, T task, {
    Map<String, dynamic> Function(T)? toJson,
  }) async {
    await _cache.put(
      'task_$taskId',
      task,
      ttl: const Duration(minutes: 30),
      toJson: toJson,
    );
  }

  /// Cache for user data
  static Future<T?> getUser<T>(String userId, {
    Future<T> Function()? networkFallback,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return await _cache.get<T>(
      'user_$userId',
      ttl: const Duration(hours: 2),
      networkFallback: networkFallback,
      fromJson: fromJson,
    );
  }

  static Future<void> setUser<T>(String userId, T user, {
    Map<String, dynamic> Function(T)? toJson,
  }) async {
    await _cache.put(
      'user_$userId',
      user,
      ttl: const Duration(hours: 2),
      toJson: toJson,
    );
  }

  /// Cache for search results
  static Future<List<T>?> getSearchResults<T>(String query, {
    Future<List<T>> Function()? networkFallback,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final result = await _cache.get<List<dynamic>>(
      'search_${query.hashCode}',
      ttl: const Duration(minutes: 10),
      networkFallback: networkFallback != null ? () async {
        final results = await networkFallback();
        return results.cast<dynamic>();
      } : null,
    );
    
    if (result != null && fromJson != null) {
      return result.map((item) => fromJson(item as Map<String, dynamic>)).toList();
    }
    
    return result?.cast<T>();
  }

  static Future<void> setSearchResults<T>(String query, List<T> results, {
    Map<String, dynamic> Function(T)? toJson,
  }) async {
    List<dynamic> dataToStore = results;
    if (toJson != null) {
      dataToStore = results.map(toJson).toList();
    }
    
    await _cache.put(
      'search_${query.hashCode}',
      dataToStore,
      ttl: const Duration(minutes: 10),
    );
  }

  /// Cache for configuration data
  static Future<T?> getConfig<T>(String configKey, {
    Future<T> Function()? networkFallback,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return await _cache.get<T>(
      'config_$configKey',
      ttl: const Duration(hours: 12),
      networkFallback: networkFallback,
      fromJson: fromJson,
    );
  }

  static Future<void> setConfig<T>(String configKey, T config, {
    Map<String, dynamic> Function(T)? toJson,
  }) async {
    await _cache.put(
      'config_$configKey',
      config,
      ttl: const Duration(hours: 12),
      toJson: toJson,
    );
  }
}