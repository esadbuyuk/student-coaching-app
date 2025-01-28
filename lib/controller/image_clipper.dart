import 'dart:convert';

import 'package:flutter/cupertino.dart';

import '../model/my_constants.dart';
import '../view/widgets/default_profile_image.dart';

// these functions are jpg only!

class HexagonImage extends StatelessWidget {
  final String imagePath;

  const HexagonImage({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: HexagonClipper(),
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
      ),
    );
  }
}

class PentagonImage extends StatelessWidget {
  final String? imagePath;
  final Color? defaultImageColor;

  const PentagonImage(
      {Key? key, required this.imagePath, this.defaultImageColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PentagonPainterWithBottomPadding(),
      child: Container(
        padding: const EdgeInsets.all(1), // strokeWidth
        child: ClipPath(
          clipper: PentagonClipperWithNoPadding(),
          child: imagePath == null
              ? (defaultImageColor != null)
                  ? DefaultProfileImage(
                      backgroundColor: defaultImageColor!,
                    )
                  : const DefaultProfileImage()
              : (imagePath!.startsWith('assets/'))
                  ? Image.asset(
                      imagePath!,
                      fit: BoxFit.cover,
                    )
                  : Image.memory(
                      fit: BoxFit.cover,
                      base64Decode(
                        imagePath!,
                      ),
                    ),
        ),
      ),
    );
  }
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width / 4, 0); // Sol üst köşeden başlat
    path.lineTo(size.width * 0.75, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width * 0.75, size.height);
    path.lineTo(size.width / 4, size.height);
    path.lineTo(0, size.height / 2);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class PentagonPainterWithBottomPadding extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = mySecondaryTextColor
      ..style = PaintingStyle.fill;

    var path = Path();
    path.moveTo(size.width * 0.5, 0); // Üst orta köşeden başlat
    path.lineTo(size.width, size.height * 0.4); // Sağ üst köşe
    path.lineTo(size.width * 0.80, size.height); // Sağ alt köşe
    path.lineTo(size.width * 0.20, size.height); // Sol alt köşe
    path.lineTo(0, size.height * 0.4); // Sol üst köşe
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class PentagonClipperWithBottomPadding extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    double controlPointOffset =
        size.height * 0.1; // Köşelerin aşağıya çekilme miktarı
    path.moveTo(size.width * 0.5, 0); // Üst orta köşeden başlat
    path.lineTo(size.width, size.height * 0.3); // Sağ üst köşe
    path.lineTo(
        size.width * 0.85, size.height - controlPointOffset); // Sağ alt köşe
    path.lineTo(
        size.width * 0.15, size.height - controlPointOffset); // Sol alt köşe
    path.lineTo(0, size.height * 0.3); // Sol üst köşe
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class PentagonClipperWithNoPadding extends CustomClipper<Path> {
  var pathForPainting = Path();
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width * 0.5, 0); // Üst orta köşeden başlat
    path.lineTo(size.width, size.height * 0.4); // Sağ üst köşe
    path.lineTo(size.width * 0.80, size.height); // Sağ alt köşe
    path.lineTo(size.width * 0.20, size.height); // Sol alt köşe
    path.lineTo(0, size.height * 0.4); // Sol üst köşe
    path.close();

    pathForPainting = path;
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;

  Path getPath() {
    return pathForPainting;
  }
}

class PentagonPainter extends CustomPainter {
  final Path path;

  PentagonPainter(this.path);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paintStroke = Paint()
      ..color = mySecondaryColor // Değiştirilebilir
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, paintStroke);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
