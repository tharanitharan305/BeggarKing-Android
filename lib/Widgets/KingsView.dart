import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Assuming these are your actual import paths.
// Make sure they are correct in your project.
import '../Screens/Maps.dart';
import 'CommandView.dart';
import 'Likeviewer.dart';

/// A responsive screen that displays a list of "Kings" from Firestore.
///
/// It shows a vertical list on mobile devices and a responsive grid
/// on wider screens like tablets or web browsers, with an improved UI and animations.
class KingsView extends StatefulWidget {
  const KingsView({Key? key}) : super(key: key);

  @override
  State<KingsView> createState() => _KingsViewState();
}

class _KingsViewState extends State<KingsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a clean white background for a more modern feel.
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('King details')
            .orderBy('Launched_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Something went wrong: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No Contributions Found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final kingList = snapshot.data!.docs;

          // The layout is now a single-column ListView for a feed-style experience.
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: kingList.length,
            itemBuilder: (ctx, i) {
              final kingData = kingList[i].data() as Map<String, dynamic>;
              // Add an entry animation to each list item.
              return _AnimatedListItem(
                index: i,
                child: _KingListItem(kingData: kingData),
              );
            },
          );
        },
      ),
    );
  }
}

/// A reusable widget that displays a single "King" item in a refined post format.
class _KingListItem extends StatefulWidget {
  final Map<String, dynamic> kingData;

  const _KingListItem({Key? key, required this.kingData}) : super(key: key);

  @override
  _KingListItemState createState() => _KingListItemState();
}

class _KingListItemState extends State<_KingListItem>
    with TickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  late Animation<double> _likeScaleAnimation;
  late AnimationController _heartAnimationController;
  late Animation<double> _heartAnimation;
  bool _isHeartAnimating = false;

  @override
  void initState() {
    super.initState();
    // Animation controller for the like button pop effect
    _likeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _likeScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _likeAnimationController, curve: Curves.easeOut),
    );

    // Animation controller for the double-tap heart animation
    _heartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _heartAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
        parent: _heartAnimationController, curve: Curves.elasticOut));

    _heartAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isHeartAnimating = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    _heartAnimationController.dispose();
    super.dispose();
  }

  void _triggerLikeAnimation() {
    _likeAnimationController.forward().then((_) => _likeAnimationController.reverse());
  }

  void _onDoubleTap() {
    setState(() {
      _isHeartAnimating = true;
    });
    _heartAnimationController.forward(from: 0);
    // Here you would also call your actual "like" logic.
    // For now, we just trigger the button animation too.
    _triggerLikeAnimation();
  }

  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            color: Colors.white,
            child: CommandsView(
              comments: widget.kingData['comments'] ?? [],
              uuid: widget.kingData['uuid'] ?? '',
            ),
          );
        },
      ),
    );
  }

  void _navigateToMap(BuildContext context) {
    final lat =
    double.tryParse(widget.kingData['latitude']?.toString() ?? '0.0');
    final log =
    double.tryParse(widget.kingData['longitude']?.toString() ?? '0.0');

    if (lat != null && log != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Maps(lat: lat, log: log)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid location data.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl = widget.kingData['King_url'] ?? '';
    final String address = widget.kingData['Address'] ?? 'No Address Provided';
    final String area = widget.kingData['Area'] ?? 'Unknown Area';
    final String district = widget.kingData['district'] ?? '';
    final String localPin = widget.kingData['localPin'] ?? '';
    final String state = widget.kingData['state'] ?? '';
    final String country = widget.kingData['country'] ?? '';
    final String fullAddress =
    "$address, $district, $state $localPin, $country".trim();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PostHeader(area: area, district: district, state: state),
          if (imageUrl.isNotEmpty)
            GestureDetector(
              onDoubleTap: _onDoubleTap,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    child: FadeInImage.assetNetwork(
                      placeholder: 'images/logo.png',
                      image: imageUrl,
                      fit: BoxFit.cover,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(Icons.broken_image,
                                  color: Colors.grey, size: 40),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (_isHeartAnimating)
                    ScaleTransition(
                      scale: _heartAnimation,
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 80,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                    ),
                ],
              ),
            ),
          _PostActions(
            scaleAnimation: _likeScaleAnimation,
            onLikeTap: _triggerLikeAnimation,
            onCommentTap: () => _showComments(context),
            onMapTap: () => _navigateToMap(context),
            kingData: widget.kingData,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
            child: Text(
              fullAddress,
              style: TextStyle(
                  color: Colors.grey[850], fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Helper Widgets for better structure ---

class _PostHeader extends StatelessWidget {
  final String area;
  final String district;
  final String state;

  const _PostHeader({
    Key? key,
    required this.area,
    required this.district,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.teal.shade50,
            child: Text(
              area.isNotEmpty ? area[1].toUpperCase() : 'K',
              style: TextStyle(
                color: Colors.teal.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  area,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.black87),
                ),
                if ("$district, $state".trim() != ',')
                  Text(
                    "$district, $state",
                    style:
                    TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostActions extends StatelessWidget {
  final Animation<double> scaleAnimation;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;
  final VoidCallback onMapTap;
  final Map<String, dynamic> kingData;

  const _PostActions({
    Key? key,
    required this.scaleAnimation,
    required this.onLikeTap,
    required this.onCommentTap,
    required this.onMapTap,
    required this.kingData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                ScaleTransition(
                  scale: scaleAnimation,
                  child: GestureDetector(
                    onTap: onLikeTap,
                    child: LikeManager(
                      like: kingData['likedUsers'] ?? [],
                      dislike: kingData['dislikedUsers'] ?? [],
                      uuid: kingData['uuid'] ?? '',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.mode_comment_outlined,
                      color: Colors.grey.shade800),
                  onPressed: onCommentTap,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.location_on_outlined,
                color: Colors.grey.shade800),
            onPressed: onMapTap,
          ),
        ],
      ),
    );
  }
}

/// A widget to animate list items as they appear.
class _AnimatedListItem extends StatefulWidget {
  final int index;
  final Widget child;

  const _AnimatedListItem({Key? key, required this.index, required this.child})
      : super(key: key);

  @override
  _AnimatedListItemState createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<_AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
        begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Start the animation with a slight delay based on the item's index.
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}

