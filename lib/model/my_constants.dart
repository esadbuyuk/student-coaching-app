import 'package:flutter/material.dart';

// class MyPalette {
//   static bool darkMode = false;
//   static int paletteNo = 1;
//
//   void switchPalette() {
//     paletteNo += 1;
//   }
//
//   void toggleDarkMode() {
//     darkMode != darkMode;
//   }
//
//   static Color myBackgroundColor =
//   darkMode ? Color(0xff010624) : Color(0xff9B9DA9);
//   static Color myPrimaryColor =
//   darkMode ? Color(0xffA3ABAA) : Color(0xff5D5B79);
//   static Color mySecondaryColor =
//   darkMode ? Color(0xffD8EAF0) : Color(0xffDDE1FF);
//   static Color myAccentColor = darkMode ? Color(0xff03A9F4) : Color(0xff2C38BB);
//   static Color myIconsColor = darkMode ? Color(0xffFFFFFE) : Color(0xffFFFFFE);
//   static Color myDividerColor =
//   darkMode ? Color(0xffBDBDBD) : Color(0xffBDBDBD);
//   static Color myTextColor = darkMode ? Color(0xff212121) : Color(0xffB5C1C7);
//   static Color mySecondaryTextColor =
//   darkMode ? Color(0xffB5C1C7) : Color(0xff212121);
//
//   selectPalette(paletteNo) {
//     switch (paletteNo) {
//       case 1:
//       // do something
//         break;
//       case 2:
//       // do something else
//         break;
//     }
//   }
// }

// My Colors
// const bool darkMode = true;
//
// const Color myBackgroundColor = Color(0xff010624);
// const Color myPrimaryColor = Color(0xffA8ADCB);
// const Color mySecondaryColor = Color(0xffDDE1FF);
// const Color myAccentColor = Color(0xff864B6E);
// const Color myIconsColor = Color(0xffFFFFFE);
// const Color myDividerColor = Color(0xffBDBDBD);
// const Color myTextColor = Color(0xff212121);
// const Color mySecondaryTextColor = Color(0xffB5C1C7);

// --- My First Palette
const bool darkMode = true;

const Color myBackgroundColor =
    darkMode ? Color(0xff010624) : Color(0xff9B9DA9);
const Color myPrimaryColor = darkMode ? Color(0xffA3ABAA) : Color(0xff5D5B79);
const Color mySecondaryColor = darkMode ? Color(0xffD8EAF0) : Color(0xffDDE1FF);
const Color myAccentColor = darkMode ? Color(0xff03A9F4) : Color(0xff2C38BB);
const Color myIconsColor = darkMode ? Color(0xffFFFFFE) : Color(0xffFFFFFE);
const Color myDividerColor = darkMode ? Color(0xffBDBDBD) : Color(0xffBDBDBD);
const Color myTextColor = darkMode ? Color(0xff212121) : Color(0xffB5C1C7);
const Color mySecondaryTextColor =
    darkMode ? Color(0xffB5C1C7) : Color(0xff212121);

// --- Palette 3 PitBall
// const bool darkMode = false;
// const Color myBackgroundColor = Color(0xffABC2C2);
// const Color myPrimaryColor = Color(0xff627080);
// const Color mySecondaryColor = Color(0xffDDE1FF);
// const Color myAccentColor = Color(0xff181E3D);
// const Color myIconsColor = Color(0xffFFFFFE);
// const Color myDividerColor = Color(0xffBDBDBD);
// const Color myTextColor = Color(0xffB5C1C7);
// const Color mySecondaryTextColor = Color(0xff212121);

// --- Palette 3 PitBall
// const bool darkMode = true;
//
// const Color myBackgroundColor =
//     darkMode ? Color(0xff141B14) : Color(0xffD1C4BC);
// const Color myPrimaryColor = darkMode ? Color(0xffA3ABAA) : Color(0xff806763);
// const Color mySecondaryColor = darkMode ? Color(0xffD8EAF0) : Color(0xffDDE1FF);
// const Color myAccentColor = darkMode ? Color(0xff03A9F4) : Color(0xff2E0909);
// const Color myIconsColor = darkMode ? Color(0xffFFFFFE) : Color(0xffFFFFFE);
// const Color myDividerColor = darkMode ? Color(0xffBDBDBD) : Color(0xffBDBDBD);
// const Color myTextColor = darkMode ? Color(0xff212121) : Color(0xffB5C1C7);
// const Color mySecondaryTextColor =
//     darkMode ? Color(0xffB5C1C7) : Color(0xff212121);

// --- Palette 2 PitBall
// const Color myBackgroundColor = Color(0xff141B14); // 41575B);//202720);
// const Color myPrimaryColor = Color(0xffA3ABAA);
// const Color mySecondaryColor = Color(0xffD8EAF0);
// const Color myAccentColor = Color(0xff03A9F4);
// const Color myIconsColor = Color(0xffFFFFFE);
// const Color myDividerColor = Color(0xffBDBDBD);
// const Color myTextColor = Color(0xff212121);
// const Color mySecondaryTextColor = Color(0xffB5C1C7);

// ---

// My Text Styles Functions
TextStyle myTonicStyle(Color color,
    {int fontSize = 14, FontWeight fontWeight = FontWeight.w900}) {
  // Using by ProfilePages
  return TextStyle(
    fontFamily: 'MyTonicFont',
    fontSize: fontSize.toDouble(),
    fontWeight: FontWeight.w900,
    color: color,
  );
}

TextStyle mySloganStyle() {
  // Using by HomePage
  return const TextStyle(
    fontFamily: 'MyBeatifulFont',
    fontSize: 14,
    fontWeight: FontWeight.w900,
    color: mySecondaryColor,
  );
}

TextStyle myBrandStyle() {
  return const TextStyle(
      color: myIconsColor, fontFamily: 'MyBrandFont', fontSize: 18);
}

TextStyle myDigitalStyle({int fontSize = 14, Color color = myTextColor}) {
  return TextStyle(
      color: color,
      fontFamily: 'MyDigitalFont',
      fontSize: fontSize.toDouble(),
      fontWeight: FontWeight.w900);
}

TextStyle myThightStyle({Color color = myIconsColor, double fontSize = 9}) {
  // Using by SearchBar
  return TextStyle(
    fontFamily: 'MyTonicFont',
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
    color: color,
  );
}

TextStyle myThinStyle({
  Color color = myTextColor,
  double fontSize = 12,
  FontWeight fontWeight = FontWeight.w100,
}) {
  // Using by SearcBar
  return TextStyle(
    fontFamily: 'MyThinFont',
    fontSize: fontSize, // .sp,
    fontWeight: fontWeight,
    color: color,
  );
}

// UI's Values
const discipleCardWidth = 257;

// Academy's Data
// const String academyName = "PITBALL ACADEMY";
// const String academySlogan = "Prove, Introduce, Thrive";

// Kaihl's Data
// const String academyName = "KARTAL İMAMHATİP";
// const String academySlogan = "Türkiye'ye Öncü, Dünyaya Örnek";
const String kvkk =
    """Kişisel Verilerin Korunması Kanunu (KVKK) Aydınlatma Metni

PITBALL olarak, kişisel verilerinizin gizliliğini önemsiyoruz. 6698 Sayılı Kişisel Verilerin Korunması Kanunu (“KVKK”) kapsamında, kişisel verilerinizi aşağıdaki şekilde işliyoruz.

1. Toplanan Kişisel Veriler

Hizmetlerimiz kapsamında şu kişisel veriler toplanabilir:

Ad ve Soyad

Telefon numarası

E-posta adresi

Şifreler

Özel Nitelikli Veriler:
Sizin açık rızanızla aşağıdaki özel nitelikli verileri işleyebiliriz:

Öğrenci verileri

Biyometrik veriler

Uygulama Verileri:
Uygulamanın doğru çalışabilmesi için aşağıdaki cihaz erişimleri talep edilebilir:

Kamera

Depolama alanı

İnternet
Bu erişimleri cihaz ayarlarından yönetebilirsiniz.

2. Verilerin İşlenme Amaçları

Kişisel verileriniz, aşağıdaki amaçlar doğrultusunda işlenir:

Hizmetlerimizi sağlamak ve geliştirmek

Uygulama güvenliğini sağlamak

Sorun giderme ve analitik süreçleri yürütmek

3. Verilerin Korunması

Kişisel verileriniz, yetkisiz erişime veya kötüye kullanıma karşı uygun teknik ve idari tedbirlerle korunmaktadır.

4. Haklarınız

KVKK kapsamında, kişisel verilerinizin silinmesini, düzeltilmesini veya güncellenmesini talep edebilirsiniz. Talepleriniz için bizimle mahmudesadbuyuk@gmail.com üzerinden iletişime geçebilirsiniz.""";

const String aydinlatmaMetni =
    """ Bu uygulamayı kullanmanız durumunda kişisel verilerinizin işlenmesi hakkında bilgi sahibi olmuş sayılırsınız. Uygulama, kullanıcıların sadece giriş bilgilerini işler, bu bilgiler kimseyle paylaşılmaz.
Veri Sorumlusu olarak, kullanıcı verilerinin gizliliğini sağlamak ve yasal gerekliliklere uygun olarak işlemek için gerekli tedbirleri aldık. KVKK gereğince kişisel verilerinizin korunması ile ilgili haklarınızı kullanabilirsiniz.
Ayrıca uygulamaya devam etmeniz halinde bu metni okuduğunuz ve kabul ettiğiniz varsayılacaktır. Soru ve görüşleriniz için: mahmudesadbuyuk@gmail.com
""";
