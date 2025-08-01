import 'package:flutter/material.dart';

class FadeAni extends StatefulWidget {
  final Widget child;
  final Duration duration;
  
  const FadeAni({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 100),
  });

  @override
  State<FadeAni> createState() => _FadeAniState();

  static _FadeAniState? of(BuildContext context) {
    return context.findAncestorStateOfType<_FadeAniState>();
  }
}

class _FadeAniState extends State<FadeAni> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(
          parent: _fadeController, 
          curve: Curves.easeInOut,
        ));
    
    _fadeController.forward(); //visible
  }

  @override

  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> fadeTransition(VoidCallback onFadeOut, {Duration pauseDuration = const Duration(milliseconds: 100)}) async {
    await _fadeController.reverse();
    onFadeOut(); 
    await Future.delayed(pauseDuration); 
    _fadeController.forward();
  }


  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: widget.child,
    );
  }
}