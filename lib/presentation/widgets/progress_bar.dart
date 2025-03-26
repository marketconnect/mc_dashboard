import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class McProgressBar extends StatelessWidget {
  static const double kSize = 30;

  const McProgressBar({super.key});
  @override
  Widget build(BuildContext context) {
    final randomIntFrom0to4 = Random().nextInt(5);
    if (randomIntFrom0to4 == 0) {
      return LoadingAnimationWidget.flickr(
        leftDotColor: Theme.of(context).colorScheme.primary,
        rightDotColor: Theme.of(context).colorScheme.onPrimary,
        size: kSize,
      );
    } else if (randomIntFrom0to4 == 1) {
      return LoadingAnimationWidget.inkDrop(
        color: Theme.of(context).colorScheme.onPrimary,
        size: kSize,
      );
    } else if (randomIntFrom0to4 == 2) {
      return LoadingAnimationWidget.twistingDots(
        leftDotColor: Theme.of(context).colorScheme.primary,
        rightDotColor: Theme.of(context).colorScheme.onPrimary,
        size: kSize,
      );
    } else if (randomIntFrom0to4 == 3) {
      return LoadingAnimationWidget.discreteCircle(
          color: Theme.of(context).colorScheme.onPrimary,
          size: kSize,
          secondRingColor: Theme.of(context).colorScheme.primary,
          thirdRingColor: Theme.of(context).colorScheme.onPrimary);
    }
    return LoadingAnimationWidget.threeArchedCircle(
      color: Theme.of(context).colorScheme.onPrimary,
      size: kSize,
    );
  }
}
