import 'package:flutter/material.dart';
import 'dart:collection'; // Import the collection library for Queue

void main() {
  runApp(MaterialApp(
    home: PostUploadPage(),
    debugShowCheckedModeBanner: false, // Optional: Remove the debug banner
  ));
}

class Post {
  final String title;
  final String content;
  final String creator;

  Post({
    required this.title,
    required this.content,
    required this.creator,
  });
}

// Node class for the Binary Search Tree
class BSTNode {
  Post post;
  BSTNode? left;
  BSTNode? right;

  BSTNode(this.post);
}

// Binary Search Tree class
class BinarySearchTree {
  BSTNode? root;

  void insert(Post post) {
    root = _insertRec(root, post);
  }

  BSTNode? _insertRec(BSTNode? node, Post post) {
    if (node == null) {
      return BSTNode(post);
    }

    if (post.title.compareTo(node.post.title) < 0) {
      node.left = _insertRec(node.left, post);
    } else {
      node.right = _insertRec(node.right, post);
    }
    return node;
  }

  List<Post> search(String query) {
    List<Post> result = [];
    _searchRec(root, query, result);
    return result;
  }

  void _searchRec(BSTNode? node, String query, List<Post> result) {
    if (node == null) return;

    // Check if the current node's post title matches the query
    if (node.post.title.toLowerCase().contains(query.toLowerCase())) {
      result.add(node.post);
    }

    // Search in the left and right subtrees
    _searchRec(node.left, query, result);
    _searchRec(node.right, query, result);
  }
}

class PostUploadPage extends StatefulWidget {
  @override
  _PostUploadPageState createState() => _PostUploadPageState();
}

class _PostUploadPageState extends State<PostUploadPage> {
  final Queue<Post> _posts = Queue(); // Use a Queue to store posts
  final BinarySearchTree _bst = BinarySearchTree(); // BST for searching
  List<Post> _filteredPosts = []; // List to store filtered posts
  String _selectedSortOption = 'Title'; // Default sort option
  String _searchQuery = ''; // Search query

  void _addPost(String title, String content, String creator) {
    final post = Post(title: title, content: content, creator: creator);
    _posts.add(post); // Enqueue operation
    _bst.insert(post); // Insert into BST
    _filteredPosts.add(post); // Add to filtered list as well
    setState(() {});
  }

  void _deletePost() {
    if (_posts.isNotEmpty) {
      setState(() {
        // Dequeue operation
        Post removedPost = _posts.removeFirst();
        _filteredPosts.removeWhere((post) =>
            post.title == removedPost.title &&
            post.content == removedPost.content &&
            post.creator == removedPost.creator);
        // Rebuild the BST after deletion
        _bst.root = null; // Clear the BST
        for (var post in _posts) {
          _bst.insert(post); // Reinsert remaining posts
        }
      });
    }
  }

  void _showPostDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final creatorController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: contentController,
                  decoration: InputDecoration(labelText: 'Content'),
                ),
                TextField(
                  controller: creatorController,
                  decoration: InputDecoration(labelText: 'Creator'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text;
                    final content = contentController.text;
                    final creator = creatorController.text;

                    if (title.isNotEmpty && content.isNotEmpty) {
                      _addPost(title, content, creator);
                      Navigator.of(context).pop(); // Close the dialog
                    }
                  },
                  child: Text('Add Post'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _filterPosts() {
    setState(() {
      _filteredPosts = _bst.search(_searchQuery); // Use BST to search for posts
      _sortPosts(); // Sort the filtered posts after filtering
    });
  }

  void _quickSort(List<Post> posts, int low, int high, String criteria) {
    if (low < high) {
      int pi = _partition(posts, low, high, criteria);
      _quickSort(posts, low, pi - 1, criteria); // Before pi
      _quickSort(posts, pi + 1, high, criteria); // After pi
    }
  }

  int _partition(List<Post> posts, int low, int high, String criteria) {
    Post pivot = posts[high]; // pivot
    int i = (low - 1); // Index of smaller element

    for (int j = low; j < high; j++) {
      bool condition;
      if (criteria == 'Title') {
        condition = posts[j].title.compareTo(pivot.title) < 0;
      } else {
        condition = posts[j].creator.compareTo(pivot.creator) < 0;
      }

      if (condition) {
        i++;
        // swap posts[i] and posts[j]
        Post temp = posts[i];
        posts[i] = posts[j];
        posts[j] = temp;
      }
    }

    // swap posts[i + 1] and posts[high] (or pivot)
    Post temp = posts[i + 1];
    posts[i + 1] = posts[high];
    posts[high] = temp;

    return i + 1; // Return the partition index
  }

  void _sortPosts() {
    _quickSort(
        _filteredPosts, 0, _filteredPosts.length - 1, _selectedSortOption);
    setState(() {}); // Update the UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: Text("Post Upload")),
            DropdownButton<String>(
              value: _selectedSortOption,
              icon: Icon(Icons.sort),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSortOption = newValue!;
                  _sortPosts(); // Sort posts when the option changes
                });
              },
              items: <String>['Title', 'Creator']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deletePost, // Call delete function
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search by Title',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _searchQuery = value;
                _filterPosts(); // Filter posts as the user types
              },
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredPosts.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Title: ${_filteredPosts[index].title}",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Content: ${_filteredPosts[index].content}",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Creator: ${_filteredPosts[index].creator}",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showPostDialog, // Show the post dialog
        child: Icon(Icons.add),
      ),
    );
  }
}
