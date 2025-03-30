import 'package:flutter/material.dart';

class MovingText extends StatefulWidget {
  final String text;
  final TextStyle style;
  const MovingText({super.key, required this.text,required this.style});
  
  @override
  _MovingTextState createState() => _MovingTextState();
}

class _MovingTextState extends State<MovingText> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late bool _isOverflowing=true;
    void _checkOverflow() {
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: MediaQuery.of(context).size.width - 3);

    setState(() {
      _isOverflowing = textPainter.width > MediaQuery.of(context).size.width - 3;
    });
  }
  @override
    void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkOverflow();
      if (_isOverflowing) {
        print("??????");
        _startScrolling();
      }
    });
  }

    void _startScrolling() {
      print("1-1--1-1-1-1-;");
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 4),
        curve: Curves.linear,
      ).then((_) {
        Future.delayed(const Duration(seconds: 1), () {
          _scrollController.jumpTo(0);
          _startScrolling();
        });
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      alignment: Alignment.centerLeft,
      child: _isOverflowing
          ? SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Text(widget.text, style: widget.style),
            )
          : Text(widget.text, style: widget.style),
    );
  }
  }
