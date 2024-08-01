import 'package:flutter/material.dart'
    show
        Alignment,
        AssetImage,
        BlendMode,
        BoxDecoration,
        BoxFit,
        BuildContext,
        ColorFilter,
        Colors,
        Container,
        DecorationImage,
        LinearGradient,
        ShaderMask,
        StatelessWidget,
        Widget;

class Backgroundimage extends StatelessWidget {
  const Backgroundimage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [Colors.green, Colors.black12],
        begin: Alignment.bottomCenter,
        end: Alignment.center,
      ).createShader(bounds),
      blendMode: BlendMode.darken,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/kfuietimg.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
          ),
        ),
      ),
    );
  }
}
