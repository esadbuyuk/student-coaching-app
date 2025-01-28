import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../main.dart';
import '../model/user.dart';
import 'academy_controller.dart';

// tur13, 96d (player) Aşağıdaki User ı öntanımlı yaptım.

class UserController {
  static late User? _userModel = User(
    userID: 8,
    userName: "tur13",
    password: "96d",
    isCoach: false,
  );
  static Timer? _connectionTimer;

  String domainName = AcademyController().getAcademyDomain();
  bool connectionIsOn = true;

  Future<bool?> logIn(String username, String password) async {
    final String apiUrl = '$domainName/check_log_data.php';

    startPeriodicConnectionCheck();

    try {
      // API'ye GET isteği gönderme
      final response = await http
          .get(Uri.parse('$apiUrl?username=$username&password=$password'));

      dynamic responseData = json.decode(response.body);
      if (response.statusCode == 200 && responseData != false) {
        // JSON verisini ayrıştırma
        final Map<String, dynamic> data = responseData;

        // API başarılıysa ve kullanıcı verisi döndürülmüşse
        if (data.isNotEmpty) {
          // Gelen veriyi User modeline çeviriyoruz
          _userModel = User(
            userID: data['ID'],
            userName: data['username'],
            password: data['password'],
            isCoach: data['IsCoach'],
          );
          return true;
        } else {
          // Eğer veri gelmediyse false döndür
          return false;
        }
      } else {
        // API'den başarılı bir yanıt alınmadığında false döndür
        return false;
      }
    } catch (e) {
      // Hata durumunda false döndür
      // print('Error: $e');
      return null;
    }
  }

  void logOut() {
    // Kullanıcıyı log out yapma işlemi
    _userModel = null;
    stopPeriodicConnectionCheck();
    // Burada kullanıcıyı log out yapacak başka işlemler de eklenebilir
  }

  String getUserName() {
    return _userModel!.userName;
  }

  bool isUserAuthorized() {
    return _userModel!.isCoach;
  }

  int getUserID() {
    return _userModel!.userID;
  }

  bool checkUserAuthentication(int requesterID) {
    return _userModel!.userID == requesterID;
  }

  void startPeriodicConnectionCheck() {
    _connectionTimer =
        Timer.periodic(const Duration(seconds: 5), (Timer timer) async {
      checkInternetConnection();
    });
  }

  void stopPeriodicConnectionCheck() {
    if (_connectionTimer != null) {
      _connectionTimer!.cancel();
      _connectionTimer = null;
    }
  }

  OverlayEntry? currentOverlayEntry; // Aktif overlay'i takip eden değişken

  void checkInternetConnection() async {
    void showOverlayNotification(String message, {Color color = Colors.red}) {
      // Önceki overlay'i kaldır
      currentOverlayEntry?.remove();

      final overlayState =
          navigatorKey.currentState?.overlay; // Navigator'dan overlay'i al
      if (overlayState != null) {
        OverlayEntry overlayEntry = OverlayEntry(
          builder: (context) => Positioned(
            top: 50.0,
            left: 20.0,
            right: 20.0,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: color, // Renk parametresi ile dinamik renk
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                ),
              ),
            ),
          ),
        );

        // Yeni overlay'i göster ve değişkene kaydet
        overlayState.insert(overlayEntry);
        currentOverlayEntry = overlayEntry;

        if (connectionIsOn == true) {
          // Overlay'i belirli bir süre sonra kaldır
          Future.delayed(const Duration(seconds: 3), () {
            overlayEntry.remove();
            currentOverlayEntry = null;
          });
        }
      }
    }

    Future<bool> isConnected() async {
      try {
        final response = await http
            .get(Uri.parse('https://1.1.1.1/cdn-cgi/trace'))
            .timeout(const Duration(seconds: 2)); // 2 saniyelik zaman aşımı
        return response.statusCode == 200;
      } catch (e) {
        // İstek başarısızsa (timeout, bağlantı sorunu, vb.)
        return false;
      }
    }

    bool hasInternet = await isConnected();
    if (hasInternet == false) {
      // Eğer internet yoksa, logOut işlemi ve uyarı
      if (connectionIsOn) {
        connectionIsOn = false;
        showOverlayNotification("İnternete Bağlı Değilsiniz");
      } else {
        connectionIsOn = false;
      }
    } else {
      // Eğer internet yoksa varsa, önceki uyarıyı kaldır ve yeni uyarıyı göster
      if (connectionIsOn == false) {
        connectionIsOn = true;
        showOverlayNotification("İnternete Bağlanıldı", color: Colors.green);
      } else {
        connectionIsOn = true;
      }
    }
  }
}
