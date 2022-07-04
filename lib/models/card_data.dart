import 'package:flutter/material.dart';

class CardData {
  final String id;
  final Color color;
  final double yDragOffset;
  final double angle;
  final double angleDirection;
  final bool moving;
  final AnimationController? controller;

  CardData(this.id, this.color,
      {this.yDragOffset = 0.0,
      this.angle = 0.0,
      this.angleDirection = 1.0,
      this.moving = false,
      this.controller});

  CardData copyWith(
          {String? id,
          Color? color,
          double? yDragOffset,
          double? angle,
          double? angleDirection,
          bool? moving,
          AnimationController? controller}) =>
      CardData(id ?? this.id, color ?? this.color,
          yDragOffset: yDragOffset ?? this.yDragOffset,
          angle: angle ?? this.angle,
          angleDirection: angleDirection ?? this.angleDirection,
          moving: moving ?? this.moving,
          controller: controller ?? this.controller);
}
