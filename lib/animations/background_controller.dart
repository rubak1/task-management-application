import 'package:flutter/material.dart';
import 'scene_red_ball.dart';
import 'scene_neural_wires.dart';
import 'scene_productivity_flow.dart';
import 'scene_calendar_time.dart';
import 'scene_analytics_data.dart';

class BackgroundController extends StatelessWidget {
  final int activeTabIndex;
  final bool reducedMotion;

  const BackgroundController({
    super.key,
    required this.activeTabIndex,
    required this.reducedMotion,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Dedicated Scene Renderer: Only the active tab's scene is active!
            if (activeTabIndex == 0)
              SceneRedBall(isActive: true, reducedMotion: reducedMotion),
            if (activeTabIndex == 1)
              SceneNeuralWires(isActive: true, reducedMotion: reducedMotion),
            if (activeTabIndex == 2)
              SceneProductivityFlow(isActive: true, reducedMotion: reducedMotion),
            if (activeTabIndex == 3)
              SceneCalendarTime(isActive: true, reducedMotion: reducedMotion),
            if (activeTabIndex == 4)
              SceneAnalyticsData(isActive: true, reducedMotion: reducedMotion),
            if (activeTabIndex == 5)
              Container(color: const Color(0xFF07070A)),

            // 2. Translucent dark overlay ensuring crystal clear UI readability
            Container(
              color: Colors.black.withValues(alpha: 0.38),
            ),
          ],
        ),
      ),
    );
  }
}
