import 'dart:ui';
import 'package:flutter/material.dart';

class BlurAni extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double maxBlur;
 
  const BlurAni({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.maxBlur = 5.0,
  });
  
  @override
  State<BlurAni> createState() => _BlurAniState();
 
  static _BlurAniState? of(BuildContext context) {
    return context.findAncestorStateOfType<_BlurAniState>();
  }
}

class _BlurAniState extends State<BlurAni> with TickerProviderStateMixin {
  late AnimationController _blurCtrl;
  late Animation<double> _blurAnimation;
  bool _isTransitioning = false;
  
  @override
  void initState() {
    super.initState();
    _blurCtrl = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
   
    _blurAnimation = Tween<double>(begin: 0.0, end: widget.maxBlur).animate(
      CurvedAnimation(parent: _blurCtrl, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _blurCtrl.dispose();
    super.dispose();
  }
  
  Future<void> blurTransition(
    VoidCallback onBlurOut, {
    Duration pauseDuration = const Duration(milliseconds: 50),
  }) async {
    if (_isTransitioning) return;
    _isTransitioning = true;
   
    try {
      await _blurCtrl.forward();
      await Future.delayed(pauseDuration);
      onBlurOut();
      await Future.delayed(pauseDuration);
      await _blurCtrl.reverse();
    } finally {
      _isTransitioning = false;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _blurAnimation,
      builder: (context, _) {
        return Stack(
          children: [
            widget.child,
            if (_blurAnimation.value > 0)
              Positioned.fill(
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: _blurAnimation.value,
                      sigmaY: _blurAnimation.value,
                    ),
                    child: Container(
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}