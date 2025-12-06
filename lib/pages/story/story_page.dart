import 'package:cached_network_image/cached_network_image.dart';
import 'package:safechat/models/user/user.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart'; // YANGI to‘g‘ri paket

class StoryPage extends StatefulWidget {
  const StoryPage({Key? key}) : super(key: key);

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  late User user;
  final CarouselSliderController _controller = CarouselSliderController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    user = ModalRoute.of(context)!.settings.arguments as User;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Asosiy carousel
          CarouselSlider.builder(
            carouselController: _controller,
            itemCount: user.stories!.length,
            itemBuilder: (context, index, realIndex) {
              return CachedNetworkImage(
                imageUrl: user.stories![index].url,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.error, color: Colors.white, size: 50),
              );
            },
            options: CarouselOptions(
              height: MediaQuery.of(context).size.height,
              viewportFraction: 1.0,
              enableInfiniteScroll: false,
              initialPage: 0,
              onPageChanged: (index, reason) {
                setState(() => _currentIndex = index);
              },
            ),
          ),

          // Yuqoridagi header (back, avatar, ism, more)
          Positioned(
            top: 40,
            left: 8,
            right: 8,
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(user.profile),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          'Last seen 2 days ago',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),

          // Pastdagi chiroyli progress indicator (CircularWave o‘rniga)
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Row(
              children: List.generate(
                user.stories!.length,
                (index) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 4,
                    decoration: BoxDecoration(
                      color: _currentIndex >= index
                          ? Colors.white
                          : Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
