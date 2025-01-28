// Daha sonra sub-skillcard ların kenarında kıvrık olması için kullanabilirsin
import 'package:flutter/cupertino.dart';
import 'package:pcaweb/model/my_constants.dart';

class MySubSkillCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(5, 0); // Kesik başlangıç noktası
    path.lineTo(0, 5); // Kesik bitiş noktası
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class MyScoreFieldClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(5, 0); // Kesik başlangıç noktası
    path.lineTo(0, size.height); // Kesik bitiş noktası
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class MyCustomIDCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0); // Kesik başlangıç noktası
    path.lineTo(0, 0); // Kesik bitiş noktası
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class MyCustomOverallCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Sol üst köşe kırpması
    path.moveTo(20, 0); // Kesik başlangıç noktası
    path.lineTo(0, 15); // Kesik bitiş noktası

    // Sol kenar ve alt kenar çizgileri
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);

    // Sağ kenar ve sağ üst köşe kırpması
    path.lineTo(size.width, 15);
    path.lineTo(size.width - 20, 0);

    // Path'i kapatma
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class MyCustomPainter extends CustomPainter {
  final Path clipPath;

  MyCustomPainter(this.clipPath);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = myPrimaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2; // Çizgi kalınlığı

    canvas.drawPath(clipPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
