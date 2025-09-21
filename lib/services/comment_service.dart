class CommentService {
  Future<void> addComment(String postId, String content) async {
    // No-op: Comments disabled due to Firebase compatibility issues
  }

  Stream<List<Map<String, dynamic>>> getComments(String postId) {
    // Return empty stream
    return Stream.value([]);
  }

  Future<void> reportComment(String commentId) async {
    // No-op: Comments disabled due to Firebase compatibility issues
  }

  Future<void> deleteComment(String commentId) async {
    // No-op: Comments disabled due to Firebase compatibility issues
  }
}
