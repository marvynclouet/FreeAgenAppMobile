import 'package:flutter/material.dart';
import '../services/content_service.dart';
import 'user_avatar.dart';
import '../opportunities_page.dart';

class FeedPostWidget extends StatefulWidget {
  final Map<String, dynamic> post;
  final VoidCallback? onRefresh;

  const FeedPostWidget({
    Key? key,
    required this.post,
    this.onRefresh,
  }) : super(key: key);

  @override
  State<FeedPostWidget> createState() => _FeedPostWidgetState();
}

class _FeedPostWidgetState extends State<FeedPostWidget> {
  final ContentService _contentService = ContentService();
  bool _isLiked = false;
  bool _showComments = false;
  List<Map<String, dynamic>> _comments = [];
  final TextEditingController _commentController = TextEditingController();
  bool _isLoadingComments = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post['isLiked'] ?? false;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _getTimeAgo(dynamic dateString) {
    if (dateString == null) return '';
    DateTime? date;
    try {
      date = DateTime.parse(dateString.toString());
    } catch (_) {
      return '';
    }
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'À l\'instant';
    }
  }

  Future<void> _toggleLike() async {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        widget.post['likes'] = (widget.post['likes'] ?? 0) + 1;
      } else {
        widget.post['likes'] = (widget.post['likes'] ?? 0) - 1;
      }
    });

    try {
      await _contentService.toggleLike(widget.post['id'].toString());
    } catch (e) {
      // Revert on error
      setState(() {
        _isLiked = !_isLiked;
        if (_isLiked) {
          widget.post['likes'] = (widget.post['likes'] ?? 0) + 1;
        } else {
          widget.post['likes'] = (widget.post['likes'] ?? 0) - 1;
        }
      });
    }
  }

  Future<void> _loadComments() async {
    if (_comments.isNotEmpty) {
      setState(() {
        _showComments = !_showComments;
      });
      return;
    }

    setState(() {
      _isLoadingComments = true;
    });

    try {
      final comments =
          await _contentService.getComments(widget.post['id'].toString());
      setState(() {
        _comments = comments;
        _showComments = true;
        _isLoadingComments = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingComments = false;
      });
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final comment = _commentController.text.trim();
    _commentController.clear();

    try {
      final success = await _contentService.addComment(
          widget.post['id'].toString(), comment);
      if (success) {
        setState(() {
          _comments.insert(0, {
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': comment,
            'author_name': 'Vous',
            'author_avatar': null,
            'created_at': DateTime.now().toIso8601String(),
          });
          widget.post['comments'] = (widget.post['comments'] ?? 0) + 1;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Widget _buildOpportunityCard(Map<String, dynamic> post) {
    return GestureDetector(
      onTap: () {
        // Nettoyer et sécuriser les données avant de les passer
        final Map<String, dynamic> cleanOpportunity = {
          'id': post['id']?.toString() ?? '',
          'title': post['title']?.toString() ?? 'Opportunité',
          'description': post['description']?.toString() ?? '',
          'location': post['location']?.toString() ?? '',
          'salary_range': post['salary_range']?.toString() ?? '',
          'requirements': post['requirements'] is List
              ? (post['requirements'] as List)
                  .map((e) => e?.toString() ?? '')
                  .toList()
              : post['requirements']
                      ?.toString()
                      .split(',')
                      .map((e) => e.trim())
                      .toList() ??
                  [],
          'image_url': post['image_url']?.toString(),
          'team_id': post['team_id']?.toString() ?? '',
          'team_name': post['team_name']?.toString() ?? '',
          'created_at': post['created_at']?.toString() ?? '',
          'updated_at': post['updated_at']?.toString() ?? '',
        };

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OpportunityDetailPage(
              opportunity: cleanOpportunity,
              isOwner: false, // On ne sait pas ici, à ajuster si besoin
              onUpdate: widget.onRefresh ?? () {},
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF9B5CFF), width: 2),
        ),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.work, color: Color(0xFF9B5CFF)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      post['title'] ?? 'Opportunité',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (post['image_url'] != null &&
                  post['image_url'].toString().isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    post['image_url'],
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 150,
                        color: Colors.grey[800],
                        child: const Icon(Icons.image, color: Colors.white54),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (post['location'] != null) ...[
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.white54, size: 16),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        post['location'] ?? '',
                        style: const TextStyle(color: Colors.white70),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              if (post['salary_range'] != null) ...[
                Row(
                  children: [
                    const Icon(Icons.attach_money,
                        color: Colors.white54, size: 16),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        post['salary_range'] ?? '',
                        style: const TextStyle(color: Colors.white70),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              if (post['requirements'] != null) ...[
                Wrap(
                  spacing: 8,
                  children: (post['requirements'] is List
                          ? (post['requirements'] as List).cast<String>()
                          : post['requirements'].toString().split(','))
                      .map<Widget>((req) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF9B5CFF).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              req.toString().trim(),
                              style: const TextStyle(
                                color: Color(0xFF9B5CFF),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> post) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2196F3), width: 2),
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event, color: Color(0xFF2196F3)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    post['title'] ?? 'Événement',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (post['image_url'] != null &&
                post['image_url'].toString().isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post['image_url'],
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 150,
                      color: Colors.grey[800],
                      child: const Icon(Icons.image, color: Colors.white54),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (post['event_date'] != null) ...[
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      color: Colors.white54, size: 16),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Date: ${post['event_date']}' +
                          (post['event_time'] != null &&
                                  post['event_time'].toString().isNotEmpty
                              ? ' à ${post['event_time'].toString().substring(0, 5)}'
                              : ''),
                      style: const TextStyle(color: Colors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            if (post['event_location'] != null) ...[
              Row(
                children: [
                  const Icon(Icons.location_on,
                      color: Colors.white54, size: 16),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      post['event_location'] ?? '',
                      style: const TextStyle(color: Colors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String getFullImageUrl(String url) {
    if (url.startsWith('http')) return url;
    return 'http://localhost:3000$url';
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    // Sécurisation des champs auteur/avatar/type
    final String authorName =
        post['author_name'] ?? post['author']?['name'] ?? 'Utilisateur';
    final String? authorAvatar =
        post['author_avatar'] ?? post['author']?['avatar'];
    final String authorType =
        post['author_type'] ?? post['author']?['type'] ?? '';
    final String content = post['content'] ?? '';
    final String type = post['type'] ?? 'post';
    final int likes = post['likes'] ?? post['likes_count'] ?? 0;
    final int comments = post['comments'] ?? post['comments_count'] ?? 0;
    final String createdAt = post['createdAt'] ?? post['created_at'] ?? '';

    // Correction : récupérer la liste d'images peu importe le nom du champ
    final List<dynamic> imageList =
        (post['imageUrls'] is List && (post['imageUrls'] as List).isNotEmpty)
            ? post['imageUrls']
            : (post['image_urls'] is List &&
                    (post['image_urls'] as List).isNotEmpty)
                ? post['image_urls']
                : [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF18171C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              UserAvatar(
                name: authorName,
                imageUrl: authorAvatar,
                radius: 20,
                profileType: authorType,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authorName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _getTimeAgo(createdAt),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white54),
                onSelected: (value) {
                  // Actions du menu
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'share',
                    child: Text('Partager'),
                  ),
                  const PopupMenuItem(
                    value: 'report',
                    child: Text('Signaler'),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Contenu
          Text(
            content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            maxLines: 8,
            overflow: TextOverflow.ellipsis,
          ),

          // Images pour les posts normaux
          if (type == 'post' && imageList.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: imageList.length,
                itemBuilder: (context, index) {
                  final dynamic imageUrl = imageList[index];
                  if (imageUrl is String && imageUrl.isNotEmpty) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          getFullImageUrl(imageUrl),
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 200,
                              height: 200,
                              color: Colors.grey[800],
                              child: const Icon(Icons.image,
                                  color: Colors.white54),
                            );
                          },
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],

          // Carte spéciale selon le type
          if (type == 'opportunity') _buildOpportunityCard(post),
          if (type == 'event') _buildEventCard(post),

          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              // Like
              GestureDetector(
                onTap: _toggleLike,
                child: Row(
                  children: [
                    Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked ? Colors.red : Colors.white54,
                      size: 24,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$likes',
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Commentaires
              GestureDetector(
                onTap: _loadComments,
                child: Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline,
                        color: Colors.white54, size: 24),
                    const SizedBox(width: 4),
                    Text(
                      '$comments',
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Partager
              const Icon(Icons.share, color: Colors.white54, size: 24),
            ],
          ),

          // Section commentaires
          if (_showComments) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white12),
            const SizedBox(height: 12),

            // Zone de commentaire
            Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFF9B5CFF),
                  child: Icon(Icons.person, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Ajouter un commentaire...',
                      hintStyle: TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  onPressed: _addComment,
                  icon: const Icon(Icons.send, color: Color(0xFF9B5CFF)),
                ),
              ],
            ),

            if (_isLoadingComments) ...[
              const SizedBox(height: 12),
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9B5CFF)),
                ),
              ),
            ] else if (_comments.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...(_comments.map<Widget>((comment) {
                final Map<String, dynamic> commentData =
                    comment is Map<String, dynamic>
                        ? comment
                        : <String, dynamic>{};
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFF9B5CFF),
                        child: Text(
                          (commentData['author_name'] ?? 'U')
                              .toString()[0]
                              .toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  commentData['author_name']?.toString() ??
                                      'Utilisateur',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getTimeAgo(commentData['created_at']),
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              commentData['content']?.toString() ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList()),
            ],
          ],
        ],
      ),
    );
  }
}
