import '../model/academy.dart';

class AcademyController {
  final Academy _academyModel;

  // AcademyController()
  //     : _academyModel = Academy(
  //         academyID: 1,
  //         academyName: "PITBALL ACADEMY",
  //         abbreviatedName: 'PITBALL',
  //         academySlogan: "Prove, Introduce, Thrive",
  //         domainName: "http://13.60.244.86/",
  //       );

  AcademyController()
      : _academyModel = Academy(
          academyID: 1,
          academyName: "KAİHL",
          abbreviatedName: 'KAİHL',
          academySlogan: "Türkiye'ye Öncü, Dünyaya Örnek",
          domainName: "http://13.60.244.86/",
        );

  int getAcademyID() {
    return _academyModel.academyID;
  }

  String getAcademyName() {
    return _academyModel.academyName;
  }

  String getAcademyDomain() {
    return _academyModel.domainName;
  }

  String getAbbreviatedName() {
    return _academyModel.abbreviatedName;
  }

  String getAcademySlogan() {
    return _academyModel.academySlogan;
  }
}
