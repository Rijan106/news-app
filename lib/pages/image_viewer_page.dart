import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageViewerPage extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImageViewerPage({
    Key? key,
    required this.imageUrls,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentIndex + 1} / ${widget.imageUrls.length}'),
        backgroundColor: const Color(0xFF59151E),
      ),
      body: PhotoViewGallery.builder(
        pageController: _pageController,
        itemCount: widget.imageUrls.length,
        onPageChanged: onPageChanged,
        builder: (context, index) {
          final imageUrl = widget.imageUrls[index];
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
            heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
          );
        },
        loadingBuilder: (context, event) => Center(
          child: CircularProgressIndicator(
            value: event == null
                ? null
                : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
