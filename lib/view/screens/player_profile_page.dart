import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../controller/disciple_controller.dart';
import '../../controller/image_clipper.dart';
import '../../controller/ui_controller.dart';
import '../../controller/user_controller.dart';
import '../../model/disciple.dart';
import '../../model/my_constants.dart';
import '../widgets/editable_text.dart';
import '../widgets/my_app_bar.dart';
import '../widgets/my_button.dart';
import '../widgets/next_and_pre_buttons.dart';

class PlayerProfilePage extends StatefulWidget {
  final int? playerId;
  const PlayerProfilePage({Key? key, this.playerId}) : super(key: key);

  @override
  State<PlayerProfilePage> createState() => _PlayerProfilePageState();
}

class _PlayerProfilePageState extends State<PlayerProfilePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late Future<Disciple> playerFuture;
  late DiscipleController _playerController;
  final UserController _userController = UserController();
  bool keyboardClosed = true;
  File? imageFile;
  late int playerID;

  @override
  void initState() {
    super.initState();
    if (widget.playerId == null) {
      playerID = _userController.getUserID();
    } else {
      playerID = widget.playerId!;
    }

    _playerController = DiscipleController(playerID);
    playerFuture = _playerController.fetchPlayerData();

    // Klavye durumunu dinlemek için WidgetsBinding kullanıyoruz.
    WidgetsBinding.instance.addObserver(this);

    imageFile = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _previousPlayer() {
    setState(() {
      playerFuture = _playerController.fetchPreviousPlayerData();
      imageFile = null;
    });
  }

  void _nextPlayer() {
    setState(() {
      playerFuture = _playerController.fetchNextPlayerData();
      imageFile = null;
    });
  }

  void _updateData(int playerID) {
    final NavigatorState navigator = Navigator.of(context);
    navigator.pop();
    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PlayerProfilePage(playerId: playerID)),
    );
  }

  bool _checkUserAuthentication() {
    if (UserController().isUserAuthorized()) {
      return true;
    }

    return _userController
        .checkUserAuthentication(_playerController.getDiscipleID());
  }

  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isKeyboardOpen(context)) {
        setState(() {
          keyboardClosed = false;
        });
      } else {
        setState(() {
          keyboardClosed = true;
        });
      }
    });
  }

  // Future<File?> _cropImage(File imageFile) async {
  //   File? croppedImage = (await ImageCropper()
  //       .cropImage(sourcePath: imageFile.path, aspectRatioPresets: [
  //     CropAspectRatioPreset.square, // Kare kırpma seçeneği (Whatsapp gibi)
  //   ], uiSettings: [
  //     AndroidUiSettings(
  //       toolbarTitle: 'Cropper',
  //       toolbarColor: Colors.deepOrange,
  //       toolbarWidgetColor: Colors.hhite,
  //       initAspectRatio: CropAspectRatioPreset.square,
  //       lockAspectRatio: false,
  //       // aspectRatioPresets: [
  //       //   CropAspectRatioPreset.original,
  //       //   CropAspectRatioPreset.square,
  //       //   CropAspectRatioPreset.ratio4x3,
  //       //   CropAspectRatioPresetCustom(),
  //       // ],
  //     ),
  //     IOSUiSettings(
  //       title: 'Cropper',
  //       // aspectRatioPresets: [
  //       //   CropAspectRatioPreset.original,
  //       //   CropAspectRatioPreset.square,
  //       //   CropAspectRatioPreset.ratio4x3,
  //       //   CropAspectRatioPresetCustom(),
  //       // ],
  //     ),
  //     WebUiSettings(
  //       context: context,
  //       // presentStyle: WebPresentStyle.dialog,
  //       // size: const CropperSize(
  //       //   width: 520,
  //       //   height: 520,
  //       // ),
  //     ),
  //   ]
  //           // uiSettings: AndroidUiSettings(
  //           //   toolbarTitle: 'Fotoğrafı Kırp',
  //           //   toolbarColor: Colors.blue,
  //           //   toolbarWidgetColor: Colors.hhite,
  //           //   activeControlsWidgetColor: Colors.blue,
  //           //   lockAspectRatio: true, // Sabit kare oranında kırpma
  //           //
  //           // )
  //
  //           )) as File?;
  //   return croppedImage != null ? File(croppedImage.path) : null;
  // }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: mySecondaryColor,
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(
                  Icons.delete,
                  color: myTextColor,
                ),
                title: Text(
                  'Fotoğrafı Kaldır',
                  style: myThinStyle(),
                ),
                onTap: () async {
                  // açtıktan sonra kapanabilir.
                  _deletePhoto();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: myTextColor,
                ),
                title: Text(
                  'Galeriden Seç',
                  style: myThinStyle(),
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  imageFile = await pickImageFromGallery();
                  if (imageFile != null) {
                    // imageFile = await _cropImage(imageFile!);
                    _saveNewProfilePhoto(imageFile);
                  }
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_camera,
                  color: myTextColor,
                ),
                title: Text(
                  'Fotoğraf Çek',
                  style: myThinStyle(),
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  imageFile = await pickImageFromCamera();
                  if (imageFile != null) {
                    // imageFile = await _cropImage(imageFile!);
                    _saveNewProfilePhoto(imageFile);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<File?> pickImageFromCamera() async {
    // final picker = ImagePicker();
    // final pickedFile = await picker.pickImage(source: ImageSource.camera);
    //
    // if (pickedFile != null) {
    //   // Seçilen dosyayı geri döndür
    //   return File(pickedFile.path);
    // } else {
    //   return null;
    // }
  }

  Future<File?> pickImageFromGallery() async {
    // final picker = ImagePicker();
    // final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    //
    // if (pickedFile != null) {
    //   // Seçilen dosyayı geri döndür
    //   return File(pickedFile.path);
    // } else {
    //   return null;
    // }
  }

  Future<void> _saveNewProfilePhoto(File? photo) async {
    if (photo != null) {
      await _playerController.uploadProfilePhoto(photo);
      setState(() {
        playerFuture = _playerController.fetchPlayerData();
        imageFile = null;
      });
    }
  }

  Future<void> _deletePhoto() async {
    await _playerController.deleteProfilePhoto();

    setState(() {
      playerFuture = _playerController.fetchPlayerData();
      imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: buildAppBar(
          context,
          true,
        ), // buradan discipleList Page e yönlendiriliyordu
        body: FutureBuilder(
          future: playerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final playerData = snapshot.data as Disciple;
              return Padding(
                padding: EdgeInsets.only(left: 35.w, right: 35.w),
                child: Column(
                  children: [
                    SizedBox(height: 17.h),
                    Stack(
                      children: [
                        SizedBox(
                          width: 90,
                          height: 90,
                          child: PentagonImage(
                            imagePath:
                                imageFile?.path ?? playerData.profilePicture,
                          ),
                        ),
                        if (_checkUserAuthentication())
                          Positioned(
                            right: -7,
                            bottom: -10,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt),
                              onPressed: () async {
                                _showPhotoOptions(context);
                              },
                              color: myAccentColor,
                              iconSize: 24,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 17.h),
                    NextAndPreButtons(
                      nextFunc: _nextPlayer,
                      previousFunc: _previousPlayer,
                      displayName: true,
                      name: playerData.name,
                      surname: playerData.surname,
                      isPaddingOn: false,
                    ),
                    SizedBox(height: 17.h),
                    Flexible(
                      child: Card(
                        elevation: 1,
                        shadowColor: mySecondaryColor,
                        color: myBackgroundColor,
                        child: Padding(
                          padding: EdgeInsets.all(8.h),
                          child: GlowingOverscrollIndicator(
                            axisDirection:
                                AxisDirection.down, // Kaydırma yönünü belirtin
                            color:
                                mySecondaryColor, // Glow efektini tamamen şeffaf yapar
                            child: SingleChildScrollView(
                              child: buildProfileTexts(
                                playerData.id,
                                playerData.name,
                                playerData.surname,
                                playerData.age,
                                playerData.position,
                                playerData.mail,
                                playerData.phoneNumber,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 34.h),
                    if (keyboardClosed)
                      Column(
                        children: [
                          buildBottomButtons(context),
                          SizedBox(height: 34.h),
                        ],
                      ),
                  ],
                ),
              );
            } else {
              return const Center(child: Text('Player not found.'));
            }
          },
        ),
      ),
    );
  }

  Column buildProfileTexts(
      int playerID,
      String? playerName,
      String? playerSurname,
      Object? playerAge,
      String? playerPosition,
      String? mail,
      String? phoneNumber) {
    double spaceBetween = 10.h;
    double topAndBottomSpace = 40.h;
    TextStyle styleOfDarkTexts = myTonicStyle(myPrimaryColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        builtSpacer(topAndBottomSpace),
        Text(
          "NAME: ",
          style: styleOfDarkTexts,
        ),
        builtSpacer(spaceBetween),
        EditableTextWidget(
          isUserAuthenticated: _checkUserAuthentication(),
          initialText: "$playerName",
          onTextChanged: (newText) async {
            await _playerController.changeInformation(
                playerID, "name", newText);
            _updateData(playerID);
          },
        ),
        buildDivider(),
        builtSpacer(spaceBetween),
        Text(
          "SURNAME: ",
          style: styleOfDarkTexts,
        ),
        builtSpacer(spaceBetween),
        EditableTextWidget(
          isUserAuthenticated: _checkUserAuthentication(),
          initialText: "$playerSurname",
          onTextChanged: (newText) async {
            await _playerController.changeInformation(
                playerID, "surname", newText);
            _updateData(playerID);
          },
        ),
        buildDivider(),
        builtSpacer(spaceBetween),
        Text(
          "AGE: ",
          style: styleOfDarkTexts,
        ),
        builtSpacer(spaceBetween),
        EditableTextWidget(
          isUserAuthenticated: _checkUserAuthentication(),
          initialText: "$playerAge",
          onTextChanged: (newText) async {
            await _playerController.changeInformation(playerID, "age", newText);
            _updateData(playerID);
          },
        ),
        buildDivider(),
        builtSpacer(spaceBetween),
        Text(
          "POSITION: ",
          style: styleOfDarkTexts,
        ),
        builtSpacer(spaceBetween),
        EditableTextWidget(
          isUserAuthenticated: _checkUserAuthentication(),
          initialText: "$playerPosition",
          onTextChanged: (newText) async {
            await _playerController.changeInformation(
                playerID, "position", newText);
            _updateData(playerID);
          },
        ),
        buildDivider(),
        Text(
          "MAİL: ",
          style: styleOfDarkTexts,
        ),
        builtSpacer(spaceBetween),
        EditableTextWidget(
          isUserAuthenticated: _checkUserAuthentication(),
          initialText: "$mail",
          onTextChanged: (newText) async {
            await _playerController.changeInformation(
                playerID, "mail", newText);
            _updateData(playerID);
          },
        ),
        buildDivider(),
        builtSpacer(spaceBetween),
        Text(
          "PHONE NUMBER: ",
          style: styleOfDarkTexts,
        ),
        builtSpacer(spaceBetween),
        EditableTextWidget(
          isUserAuthenticated: _checkUserAuthentication(),
          initialText: "$phoneNumber",
          onTextChanged: (newText) async {
            await _playerController.changeInformation(
                playerID, "phoneNumber", newText);
            _updateData(playerID);
          },
        ),
        // buildDivider(),
        builtSpacer(topAndBottomSpace),
      ],
    );
  }
}

SizedBox builtSpacer(double spaceBetween) {
  return SizedBox(
    height: spaceBetween,
  );
}

Divider buildDivider() {
  return const Divider(
    color: myDividerColor,
    thickness: 1,
  );
}

Row buildBottomButtons(BuildContext context) {
  void showErrorSnackBar(BuildContext context, String warningText) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Hide the current SnackBar if one is visible
    scaffoldMessenger.hideCurrentSnackBar();

    // Create the new SnackBar
    final snackBar = SnackBar(
      content: Text(
        warningText,
        style: myTonicStyle(myTextColor),
        textAlign: TextAlign.center,
      ),
      backgroundColor: myPrimaryColor,
      behavior: SnackBarBehavior
          .floating, // Optional: Makes the SnackBar float above the UI
    );

    // Show the new SnackBar
    scaffoldMessenger.showSnackBar(snackBar);
  }

  return Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Column(
        children: [
          SizedBox(
            width: 40.w,
            child: MyButton(
              buttonText: 'VERİLERİ SİL',
              onPressed: () => {
                showErrorSnackBar(
                  context,
                  'Bunun için yetkiniz yok.',
                ),
              },
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          SizedBox(
            width: 40.w,
            child: MyButton(
              buttonText: 'HESABI SİL',
              onPressed: () => {
                showErrorSnackBar(
                  context,
                  'Bunun için yetkiniz yok.',
                ),
              },
            ),
          ),
        ],
      ),
    ],
  );
}
