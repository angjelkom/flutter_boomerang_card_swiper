import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'models/card_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Swipable Cards',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Swipable Cards'),
        ),
        body: const SwiperAnimation(),
      ),
    );
  }
}

class SwiperAnimation extends StatefulWidget {
  const SwiperAnimation({super.key});

  @override
  State<SwiperAnimation> createState() => _SwiperAnimationState();
}

class _SwiperAnimationState extends State<SwiperAnimation>
    with TickerProviderStateMixin {
  List<CardData> cards = [];

  @override
  void initState() {
    //Initiate the list of cards by assigning controllers for each card
    setState(() {
      cards = [
        CardData('red', Colors.red.shade300),
        CardData('yellow', Colors.yellow.shade200),
        CardData('blue', Colors.blue.shade300),
        CardData('white', Colors.white),
      ];
      cards = [
        for (var card in cards)
          card.copyWith(
              controller: AnimationController(
                  vsync: this,
                  duration: const Duration(milliseconds: 100),
                  reverseDuration: const Duration(milliseconds: 500))
                ..addStatusListener((status) {
                  // When the animation is reverse (The card starts to slide to the bottom)
                  if (status == AnimationStatus.reverse) {
                    // If the first card in the list matches the card for the controller
                    // And if the card was rotated then remove it from the beginning of the list and add it at the end.
                    var first = cards.first;
                    if (card.id == first.id && first.angle.abs() > 0.1) {
                      setState(() {
                        var first = cards.removeAt(0);
                        cards.add(first);
                      });
                    }
                  }

                  // When the whole animation finishes (The card returns to the bottom)
                  if (status == AnimationStatus.dismissed) {
                    setState(() {
                      cards = [
                        for (final card2 in cards)
                          // If the card matches the card to which this controller was assigned
                          // And the card is moving
                          // Then reset the yDragOffset, angle and moving values
                          if (card.id == card2.id && card2.moving)
                            card2.copyWith(
                                yDragOffset: 0.0, angle: 0.0, moving: false)
                          else
                            card2
                      ];
                    });
                  }
                }))
      ];
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var cardWidth = math.min(width, 500.0) * .85;
    return Stack(
      children: List.generate(cards.length, (index) {
        var card = cards[index];

        return AnimatedCard(
          key: ValueKey(card.id),
          card: card,
          index: index,
          onVerticalDragUpdate: (details) {
            setState(() {
              cards = [
                for (final card2 in cards)
                  // Update the yDragOffset for the card that's being moved
                  if (card.id == card2.id)
                    card2.copyWith(
                        yDragOffset: card2.yDragOffset + details.delta.dy)
                  else
                    card2
              ];
            });
          },
          onVerticalDragStart: (details) {
            setState(() {
              var angleDirection =
                  (details.localPosition.dx > cardWidth / 2 ? -1.0 : 1.0);

              cards = [
                for (final card2 in cards)
                  // Rotate the currently touched card that's being dragged slightly and set the state to `moving`
                  if (card.id == card2.id)
                    card2.copyWith(
                        angleDirection: angleDirection,
                        angle: 0.1 * angleDirection,
                        moving: true)
                  else
                    card2
              ];
            });
            card.controller!.forward();
          },
          onVerticalDragEnd: (details) {
            // When the dragging stops if the card is above the other cards start doing a full rotation
            // Else return the card at the bottom
            if (card.yDragOffset < -((math.min(width, 500.0) * .9) / 2)) {
              setState(() {
                cards = [
                  for (final card2 in cards)
                    if (card.id == card2.id)
                      card2.copyWith(
                          angle:
                              (360 * (math.pi / 180) * -card2.angleDirection) +
                                  card2.angleDirection * 0.1)
                    else
                      card2
                ];
              });
            }
            card.controller!.reverse();
          },
          // The color of the card doesn't change during its movement,
          // So to save uneeded re-rendering we will pass it to the child parameter.
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: card.color,
                ),
              ),
              Positioned(
                left: 40.0,
                bottom: 30.0,
                child: Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.3)),
                ),
              ),
              Positioned(
                left: 100.0,
                bottom: 60.0,
                child: Container(
                  width: 120.0,
                  height: 20.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32.0),
                      color: Colors.black.withOpacity(0.3)),
                ),
              ),
              Positioned(
                left: 100.0,
                bottom: 30.0,
                child: Container(
                  width: 80.0,
                  height: 20.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32.0),
                      color: Colors.black.withOpacity(0.3)),
                ),
              )
            ],
          ),
        );
      }).reversed.toList(),
    );
  }

  @override
  void dispose() {
    for (final card in cards) {
      card.controller!.dispose();
    }
    super.dispose();
  }
}

class AnimatedCard extends AnimatedWidget {
  AnimatedCard(
      {super.key,
      required this.child,
      required this.card,
      required this.index,
      required this.onVerticalDragUpdate,
      required this.onVerticalDragStart,
      required this.onVerticalDragEnd})
      : super(listenable: card.controller!);

  final Widget child;
  final CardData card;
  final int index;
  final void Function(DragUpdateDetails) onVerticalDragUpdate;
  final void Function(DragStartDetails) onVerticalDragStart;
  final void Function(DragEndDetails) onVerticalDragEnd;

  //the animated y position of the card
  late final Animation<double> y =
      Tween<double>(begin: 0, end: card.yDragOffset).animate(
          CurvedAnimation(parent: card.controller!, curve: Curves.easeInOut));

  //Animated angle at which card rotates
  late final Animation<double> angle = Tween<double>(begin: 0, end: card.angle)
      .animate(
          CurvedAnimation(parent: card.controller!, curve: Curves.easeInOut));

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width,
        cardWidth = math.min(width, 500.0) * .85,
        factor = (index * 10);
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 100),
      bottom: (index * 10) + (width - (width * .85)) / 2,
      left: (width - (cardWidth - factor)) / 2,
      width: cardWidth - factor,
      height: cardWidth / 1.6,
      child: Transform.translate(
        offset: Offset(0, card.moving ? y.value : 0),
        child: Transform.rotate(
          angle: card.moving ? angle.value : 0.0,
          alignment: Alignment.center,
          child: index == 0 || card.moving
              ? GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onVerticalDragUpdate: onVerticalDragUpdate,
                  onVerticalDragStart: onVerticalDragStart,
                  onVerticalDragEnd: onVerticalDragEnd,
                  child: child,
                )
              : child,
        ),
      ),
    );
  }
}
