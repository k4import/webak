/// Advanced Search Algorithms with optimized data structures
/// Provides efficient searching with O(log n) and O(m) complexities
library search_algorithms;

/// Trie Node for efficient string searching
class TrieNode {
  Map<String, TrieNode> children = {};
  bool isEndOfWord = false;
  Set<String> taskIds = {}; // Store task IDs that contain this prefix
  
  TrieNode();
}

/// Trie data structure for O(m) string search where m is pattern length
class SearchTrie {
  final TrieNode _root = TrieNode();
  
  /// Insert word with associated task ID - O(m) complexity
  void insert(String word, String taskId) {
    TrieNode current = _root;
    
    // Convert to lowercase for case-insensitive search
    word = word.toLowerCase();
    
    for (int i = 0; i < word.length; i++) {
      String char = word[i];
      
      if (!current.children.containsKey(char)) {
        current.children[char] = TrieNode();
      }
      
      current = current.children[char]!;
      current.taskIds.add(taskId); // Add task ID to all prefix nodes
    }
    
    current.isEndOfWord = true;
  }
  
  /// Search for prefix and return matching task IDs - O(m) complexity
  Set<String> searchPrefix(String prefix) {
    if (prefix.isEmpty) return {};
    
    TrieNode current = _root;
    prefix = prefix.toLowerCase();
    
    // Navigate to prefix end
    for (int i = 0; i < prefix.length; i++) {
      String char = prefix[i];
      
      if (!current.children.containsKey(char)) {
        return {}; // Prefix not found
      }
      
      current = current.children[char]!;
    }
    
    return current.taskIds;
  }
  
  /// Get all words with given prefix - O(m + k) where k is number of results
  List<String> getWordsWithPrefix(String prefix) {
    List<String> results = [];
    TrieNode current = _root;
    prefix = prefix.toLowerCase();
    
    // Navigate to prefix
    for (int i = 0; i < prefix.length; i++) {
      String char = prefix[i];
      
      if (!current.children.containsKey(char)) {
        return results;
      }
      
      current = current.children[char]!;
    }
    
    // DFS to collect all words
    _dfsCollectWords(current, prefix, results);
    return results;
  }
  
  void _dfsCollectWords(TrieNode node, String currentWord, List<String> results) {
    if (node.isEndOfWord) {
      results.add(currentWord);
    }
    
    for (String char in node.children.keys) {
      _dfsCollectWords(node.children[char]!, currentWord + char, results);
    }
  }
  
  /// Remove word from trie - O(m) complexity
  void remove(String word, String taskId) {
    word = word.toLowerCase();
    _removeHelper(_root, word, 0, taskId);
  }
  
  bool _removeHelper(TrieNode node, String word, int index, String taskId) {
    if (index == word.length) {
      node.isEndOfWord = false;
      node.taskIds.remove(taskId);
      return node.children.isEmpty && !node.isEndOfWord;
    }
    
    String char = word[index];
    TrieNode? childNode = node.children[char];
    
    if (childNode == null) return false;
    
    bool shouldDeleteChild = _removeHelper(childNode, word, index + 1, taskId);
    
    if (shouldDeleteChild) {
      node.children.remove(char);
    }
    
    childNode.taskIds.remove(taskId);
    
    return node.children.isEmpty && !node.isEndOfWord;
  }
}

/// Advanced Search Engine with multiple algorithms
class AdvancedSearchEngine {
  final SearchTrie _titleTrie = SearchTrie();
  final SearchTrie _descriptionTrie = SearchTrie();
  final SearchTrie _tagsTrie = SearchTrie();
  
  // Inverted index for O(1) lookups
  final Map<String, Set<String>> _statusIndex = {};
  final Map<String, Set<String>> _priorityIndex = {};
  final Map<String, Set<String>> _assignedToIndex = {};
  
  /// Index a task for efficient searching - O(m) where m is total text length
  void indexTask(Map<String, dynamic> task) {
    String taskId = task['id'] as String;
    
    // Index title words
    String title = (task['title'] as String? ?? '').toLowerCase();
    _indexWords(title, taskId, _titleTrie);
    
    // Index description words
    String description = (task['description'] as String? ?? '').toLowerCase();
    _indexWords(description, taskId, _descriptionTrie);
    
    // Index tags
    String tags = (task['tags'] as String? ?? '').toLowerCase();
    _indexWords(tags, taskId, _tagsTrie);
    
    // Index categorical fields
    _indexCategorical('status', task['status'] as String?, taskId, _statusIndex);
    _indexCategorical('priority', task['priority'] as String?, taskId, _priorityIndex);
    _indexCategorical('assigned_to', task['assigned_to'] as String?, taskId, _assignedToIndex);
  }
  
  void _indexWords(String text, String taskId, SearchTrie trie) {
    if (text.isEmpty) return;
    
    // Split by common delimiters and index each word
    List<String> words = text.split(RegExp(r'[\s,،.؛;:!?()\[\]{}"\-]+'));
    
    for (String word in words) {
      word = word.trim();
      if (word.length >= 2) { // Only index words with 2+ characters
        trie.insert(word, taskId);
        
        // Also index prefixes for better search results
        for (int i = 2; i <= word.length; i++) {
          trie.insert(word.substring(0, i), taskId);
        }
      }
    }
  }
  
  void _indexCategorical(String field, String? value, String taskId, Map<String, Set<String>> index) {
    if (value == null || value.isEmpty) return;
    
    index.putIfAbsent(value.toLowerCase(), () => <String>{}).add(taskId);
  }
  
  /// Perform advanced search with multiple criteria - O(m + k) complexity
  Set<String> search({
    String? query,
    String? status,
    String? priority,
    String? assignedTo,
    bool useAndLogic = true,
  }) {
    Set<String> results = <String>{};
    List<Set<String>> resultSets = [];
    
    // Text search in title, description, and tags
    if (query != null && query.isNotEmpty) {
      Set<String> titleResults = _titleTrie.searchPrefix(query.toLowerCase());
      Set<String> descResults = _descriptionTrie.searchPrefix(query.toLowerCase());
      Set<String> tagResults = _tagsTrie.searchPrefix(query.toLowerCase());
      
      // Combine text search results with relevance scoring
      Set<String> textResults = <String>{};
      textResults.addAll(titleResults); // Title matches have highest priority
      textResults.addAll(descResults);
      textResults.addAll(tagResults);
      
      if (textResults.isNotEmpty) {
        resultSets.add(textResults);
      }
    }
    
    // Categorical filters
    if (status != null && status.isNotEmpty) {
      Set<String>? statusResults = _statusIndex[status.toLowerCase()];
      if (statusResults != null) {
        resultSets.add(statusResults);
      }
    }
    
    if (priority != null && priority.isNotEmpty) {
      Set<String>? priorityResults = _priorityIndex[priority.toLowerCase()];
      if (priorityResults != null) {
        resultSets.add(priorityResults);
      }
    }
    
    if (assignedTo != null && assignedTo.isNotEmpty) {
      Set<String>? assignedResults = _assignedToIndex[assignedTo.toLowerCase()];
      if (assignedResults != null) {
        resultSets.add(assignedResults);
      }
    }
    
    // Combine results using AND or OR logic
    if (resultSets.isEmpty) {
      return results;
    }
    
    results = resultSets.first;
    
    for (int i = 1; i < resultSets.length; i++) {
      if (useAndLogic) {
        results = results.intersection(resultSets[i]);
      } else {
        results = results.union(resultSets[i]);
      }
    }
    
    return results;
  }
  
  /// Get search suggestions - O(m + k) complexity
  List<String> getSuggestions(String query, {int maxSuggestions = 10}) {
    if (query.length < 2) return [];
    
    Set<String> suggestions = <String>{};
    
    // Get suggestions from all tries
    suggestions.addAll(_titleTrie.getWordsWithPrefix(query));
    suggestions.addAll(_descriptionTrie.getWordsWithPrefix(query));
    suggestions.addAll(_tagsTrie.getWordsWithPrefix(query));
    
    List<String> result = suggestions.toList();
    
    // Sort by relevance (length and frequency)
    result.sort((a, b) {
      // Prefer shorter matches (more specific)
      int lengthComparison = a.length.compareTo(b.length);
      if (lengthComparison != 0) return lengthComparison;
      
      // Then alphabetical
      return a.compareTo(b);
    });
    
    return result.take(maxSuggestions).toList();
  }
  
  /// Remove task from index - O(m) complexity
  void removeTask(Map<String, dynamic> task) {
    String taskId = task['id'] as String;
    
    // Remove from text indices
    String title = (task['title'] as String? ?? '').toLowerCase();
    _removeWords(title, taskId, _titleTrie);
    
    String description = (task['description'] as String? ?? '').toLowerCase();
    _removeWords(description, taskId, _descriptionTrie);
    
    String tags = (task['tags'] as String? ?? '').toLowerCase();
    _removeWords(tags, taskId, _tagsTrie);
    
    // Remove from categorical indices
    _removeCategorical(task['status'] as String?, taskId, _statusIndex);
    _removeCategorical(task['priority'] as String?, taskId, _priorityIndex);
    _removeCategorical(task['assigned_to'] as String?, taskId, _assignedToIndex);
  }
  
  void _removeWords(String text, String taskId, SearchTrie trie) {
    if (text.isEmpty) return;
    
    List<String> words = text.split(RegExp(r'[\s,،.؛;:!?()\[\]{}"\-]+'));
    
    for (String word in words) {
      word = word.trim();
      if (word.length >= 2) {
        trie.remove(word, taskId);
      }
    }
  }
  
  void _removeCategorical(String? value, String taskId, Map<String, Set<String>> index) {
    if (value == null || value.isEmpty) return;
    
    Set<String>? taskSet = index[value.toLowerCase()];
    if (taskSet != null) {
      taskSet.remove(taskId);
      if (taskSet.isEmpty) {
        index.remove(value.toLowerCase());
      }
    }
  }
  
  /// Clear all indices
  void clear() {
    _statusIndex.clear();
    _priorityIndex.clear();
    _assignedToIndex.clear();
  }
  
  /// Get search statistics
  Map<String, dynamic> getStats() {
    return {
      'statusIndexSize': _statusIndex.length,
      'priorityIndexSize': _priorityIndex.length,
      'assignedToIndexSize': _assignedToIndex.length,
      'totalIndexedStatuses': _statusIndex.values.fold(0, (sum, set) => sum + set.length),
      'totalIndexedPriorities': _priorityIndex.values.fold(0, (sum, set) => sum + set.length),
      'totalIndexedAssignments': _assignedToIndex.values.fold(0, (sum, set) => sum + set.length),
    };
  }
}

/// Singleton instance for global access
class SearchManager {
  static final AdvancedSearchEngine _instance = AdvancedSearchEngine();
  
  static AdvancedSearchEngine get instance => _instance;
}