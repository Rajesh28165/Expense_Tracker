import 'package:flutter/material.dart';
import 'package:expense_tracker/constants/extension.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CustomCarousel extends StatefulWidget {
  final List<dynamic>? imagePaths;
  final List<Widget>? elementBuilder;
  final Widget Function(int index)? headerBuilder;
  final double? carouselHeight;
  final ValueChanged<int>? onPageChanged;
  final bool showDot;
  final bool autoPlay;
  final bool enableInfiniteScroll;
  final Duration autoPlayInterval;
  final Duration autoPlayAnimationDuration;
  final Curve autoPlayCurve;

  const CustomCarousel({
    super.key,
    this.imagePaths,
    this.elementBuilder,
    this.headerBuilder,
    this.carouselHeight,
    this.onPageChanged,
    this.showDot = true,
    this.autoPlay = true,
    this.enableInfiniteScroll = true,
    this.autoPlayInterval = const Duration(seconds: 2),
    this.autoPlayAnimationDuration = const Duration(milliseconds: 800),
    this.autoPlayCurve = Curves.fastOutSlowIn,
  }) : assert(
    imagePaths != null || elementBuilder != null,
    "Either imagePaths or elementBuilder must be provided",
  );

  @override
  State<CustomCarousel> createState() => _CustomCarouselState();
}

class _CustomCarouselState extends State<CustomCarousel> {
  int _currentPage = 0;

  List<Widget> _defaultElementBuilder() {
    return widget.imagePaths!.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      if (item is String) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.headerBuilder != null)
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.black.withOpacity(0.6),
                child: widget.headerBuilder!(index),
              ),
            Expanded(
              child: Image.asset(
                item,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ],
        );
      }
      return const SizedBox.shrink();
    }).toList();
  }

  List<Widget> _dotBuilder() {
    final length = widget.elementBuilder?.length ?? widget.imagePaths?.length ?? 0;

    return List.generate(length, (index) {
      return Container(
        width: context.getPercentWidth(5),
        height: context.getPercentHeight(5),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _currentPage == index
              ? Colors.blue
              : Colors.white.withOpacity(0.5),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.elementBuilder ?? _defaultElementBuilder();

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider(
          items: items,
          options: CarouselOptions(
            height: context.getPercentHeight(widget.carouselHeight ?? 80),
            autoPlay: widget.autoPlay,
            enableInfiniteScroll: widget.enableInfiniteScroll,
            autoPlayInterval: widget.autoPlayInterval,
            autoPlayAnimationDuration: widget.autoPlayAnimationDuration,
            autoPlayCurve: widget.autoPlayCurve,
            viewportFraction: 1,
            onPageChanged: (index, reason) {
              setState(() => _currentPage = index);
              widget.onPageChanged?.call(index);
            },
          ),
        ),
        if (widget.showDot)
          Positioned(
            bottom: context.getPercentHeight(2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _dotBuilder(),
            ),
          ),
      ],
    );
  }
}
