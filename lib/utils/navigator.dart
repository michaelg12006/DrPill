import 'package:dr_drugs/utils/circular_reveal_route.dart';
import 'package:dr_drugs/utils/fade_slide_route.dart';
import 'package:dr_drugs/utils/vertical_reveal_route.dart';
import 'package:flutter/material.dart';

void navigate(BuildContext context, Widget page, bool back, 
  {
    bool? isCircularTransition = false, Offset? origin,
    bool? isFadeTransition = false,
    bool? isVerticalReveal = false,
  }
) {
  Route route;

  if (isCircularTransition == true && origin != null) {
    route = CircularRevealRoute(
      page: page,
      origin: origin,
    );
  } else if (isFadeTransition == true) {
    route = FadeSlideRoute(
      page: page
    );
  } else if (isVerticalReveal == true) {
    route = VerticalRevealRoute(
      page: page,
    );
  } else {
    route = MaterialPageRoute(
      builder: (context) {
        return page;
      },
    );
  }

  if (back == true) {
    Navigator.push(context, route);
  } else {
    Navigator.pushAndRemoveUntil(
      context,
      route,
      (route) => false,
    );
  }
}

void navigateBack(BuildContext context) {
  Navigator.pop(context);
}