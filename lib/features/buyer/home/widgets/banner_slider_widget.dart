import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class BannerSliderWidget extends StatelessWidget {
  const BannerSliderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> imgList = [
      'assets/images/banner/banner1.png',
      'assets/images/banner/banner2.png',
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: CarouselSlider(
        options: CarouselOptions(
          autoPlay: true,
          aspectRatio: 2.0,
          enlargeCenterPage: true,
          viewportFraction: 0.9,
          autoPlayInterval: const Duration(seconds: 5),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          autoPlayCurve: Curves.fastOutSlowIn,
        ),
        items: imgList
            .map((item) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                    child: Image.asset(
                      item,
                      fit: BoxFit.cover,
                      width: 1000.0,
                      errorBuilder: (context, error, stackTrace) {
                         return Container(
                           color: Colors.grey[300],
                           child: const Center(
                             child: Icon(Icons.broken_image, color: Colors.grey),
                           ),
                         );
                      },
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
