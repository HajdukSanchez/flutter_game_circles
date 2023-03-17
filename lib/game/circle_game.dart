import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

import '/components/circle_component.dart';

/// Base game class
///
/// - Use collision to handle collisions between components
/// - Use TapDetector to handle interaction with component
class CircleGame extends FlameGame with HasCollidables, TapDetector {
  @override
  bool get debugMode => false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add collision interaction detection with screen boundaries
    add(ScreenCollidable());
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);

    // Add a new circle component into the game with specific direction
    add(BallComponent(info.eventPosition.game));
  }
}
