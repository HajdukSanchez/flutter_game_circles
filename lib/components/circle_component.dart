import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';

import '/game/circle_game.dart';

/// Ball shape component
///
/// Interacts with other circle components in the game
class BallComponent extends CircleComponent
    with HasGameRef<CircleGame>, Collidable {
  late Vector2 velocity;
  final _speed = 200.0;
  static const ballRadius = 5.0;
  final _collisionColor = Colors.amber;
  final _defaultColor = Colors.cyan;
  var _currentColor = Colors.cyan;
  var _isWallHit = false;
  var _isCollision = false;

  // Components we collision with
  var collisions = <String, BallComponent>{};

  // Normal direction in X and Y cardinales points
  int xDirection = 1;
  int yDirection = 1;

  /// Constructor
  BallComponent(this.initialPosition)
      : super(
          radius: ballRadius,
          position: initialPosition,
          anchor: Anchor.center,
        ) {
    // Add HitBox specification for a component
    addHitbox(HitboxCircle());
  }

  // Initial position where circle starts
  final Vector2 initialPosition;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Set velocity for component when appears on the screen
    final center = gameRef.size / 2;
    velocity = (center - position)..scaleTo(_speed);
  }

  @override
  void update(double dt) {
    super.update(dt);

    _removeResolvedCollisionsObjects();

    // Update X and Y cardinales position od the component
    x += xDirection * _speed * dt;
    y += yDirection * _speed * dt;

    // Assign the component transformation into Rectangle
    final rect = toRect();

    // Check collisions between left and right side of the screen
    if ((rect.left <= 0 && xDirection == -1) ||
        (rect.right >= gameRef.size.x && xDirection == 1)) {
      xDirection = xDirection * -1;
    }

    // Check collisions between top and bottom side of the screen
    if ((rect.top <= 0 && yDirection == -1) ||
        (rect.bottom >= gameRef.size.y && yDirection == 1)) {
      yDirection = yDirection * -1;
    }

    // If component has a collision with other component
    _currentColor = _isCollision ? _collisionColor : _defaultColor;

    if (_isCollision) _isCollision = false;
    if (_isWallHit) _isWallHit = false;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Re render the hit box each time update change
    // Render a Hitbox is very useful in Debug mode
    renderHitboxes(canvas);
    final localCenter = (scaledSize / 2).toOffset();
    // Radius 8 for the HitBox on the center of this component
    canvas.drawCircle(localCenter, ballRadius, Paint()..color = _currentColor);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    super.onCollision(intersectionPoints, other);

    if (other is ScreenCollidable) {
      // Component collision with screen boundaries
      _isWallHit = true;
      return;
    } else if (other is BallComponent) {
      // If we don't hace map the component hit us
      if (!collisions.containsKey(other.hashCode.toString())) {
        // Add the new entry
        collisions[other.hashCode.toString()] = other;
        // Move the ball component reversed
        xDirection = xDirection * -1;
        yDirection = yDirection * -1;
      }
    }
    // Component collision with some component
    _isCollision = true;
  }

  // After we handle a collision, we need to check if the component hit us,
  // Is far enough to avoid another collision with it
  //
  // If the other component is far enough, we can remove it from the map and
  // Allow it again to has a collision with us
  void _removeResolvedCollisionsObjects() {
    // Keys with Collidable object we hit previously
    List keys = [];
    for (var other in collisions.entries) {
      // Check distance between this class anf other component
      if (distance(other.value) > size.x) {
        // If object is far enough, add to the list
        keys.add(other);
      }
    }

    // Check objects on the list and remove from the collision map
    collisions.removeWhere((key, _) => keys.contains(key));
  }
}
