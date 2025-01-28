import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../controller/image_clipper.dart';
import '../../controller/trainer_controller.dart';
import '../../controller/ui_controller.dart';
import '../../controller/user_controller.dart';
import '../../model/my_constants.dart';
import '../../model/trainer.dart';
import '../widgets/editable_text.dart';
import '../widgets/my_app_bar.dart';
import '../widgets/my_button.dart';
import '../widgets/next_and_pre_buttons.dart';

class TrainerProfilePage extends StatefulWidget {
  final int? trainerID;

  const TrainerProfilePage({Key? key, this.trainerID}) : super(key: key);

  @override
  State<TrainerProfilePage> createState() => _TrainerProfilePageState();
}

class _TrainerProfilePageState extends State<TrainerProfilePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TrainerController _trainerController = TrainerController();
  final UserController _userController = UserController();
  late Future<Trainer> trainerFuture;
  bool keyboardClosed = true;
  File? imageFile;

  @override
  void initState() {
    super.initState();
    _trainerController = TrainerController();
    trainerFuture = _trainerController.fetchTrainerData();

    // Klavye durumunu dinlemek için WidgetsBinding kullanıyoruz.
    WidgetsBinding.instance.addObserver(this);

    imageFile = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _previousTrainer() {
    setState(() {
      trainerFuture = _trainerController.fetchPreviousTrainerData();
      // _image = null;
    });
  }

  void _nextTrainer() {
    setState(() {
      trainerFuture = _trainerController.fetchNextTrainerData();
      // _image = null;
    });
  }

  void _updateData(int trainerID) {
    final NavigatorState navigator = Navigator.of(context);
    navigator.pop();
    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TrainerProfilePage(trainerID: trainerID)),
    );
  }

  bool _checkUserAuthentication() {
    return _userController
        .checkUserAuthentication(_trainerController.getTrainerID());
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
      await _trainerController.uploadProfilePhoto(photo);
      setState(() {
        trainerFuture = _trainerController.fetchTrainerData();
        imageFile = null;
      });
    }
  }

  Future<void> _deletePhoto() async {
    await _trainerController.deleteProfilePhoto();

    setState(() {
      trainerFuture = _trainerController.fetchTrainerData();
      imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: buildAppBar(context, true),
        body: FutureBuilder(
          future: trainerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final trainerData = snapshot.data as Trainer;
              return Padding(
                padding: EdgeInsets.only(left: 35.w, right: 35.w),
                child: Column(
                  children: [
                    SizedBox(
                      height: 17.h,
                    ),
                    Stack(
                      children: [
                        SizedBox(
                          width: 90,
                          height: 90,
                          child: PentagonImage(
                            imagePath:
                                imageFile?.path ?? trainerData.profilePicture,
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
                    SizedBox(
                      height: 17.h,
                    ),
                    NextAndPreButtons(
                      nextFunc: _nextTrainer,
                      previousFunc: _previousTrainer,
                      displayName: true,
                      name: trainerData.name,
                      surname: trainerData.surname,
                      isPaddingOn: false,
                    ),
                    SizedBox(
                      height: 17.h,
                    ),
                    Flexible(
                      child: Card(
                        elevation: 1,
                        shadowColor: mySecondaryColor,
                        color: myBackgroundColor,
                        child: Padding(
                          padding: EdgeInsets.all(8.w),
                          child: GlowingOverscrollIndicator(
                            axisDirection:
                                AxisDirection.down, // Kaydırma yönünü belirtin
                            color:
                                mySecondaryColor, // Glow efektini tamamen şeffaf yapar
                            child: SingleChildScrollView(
                              child: buildProfileTexts(
                                  trainerData.id,
                                  trainerData.name,
                                  trainerData.surname,
                                  trainerData.age,
                                  trainerData.position),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 34.h,
                    ),
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
            }
          },
        ),
      ),
    );
  }

  Column buildProfileTexts(int trainerID, String? trainerName,
      String? trainerSurname, Object? trainerAge, String? trainerPosition) {
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
          initialText: "$trainerName",
          onTextChanged: (newText) async {
            await _trainerController.changeInformation(
                trainerID, "name", newText);
            _updateData(trainerID);
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
          initialText: "$trainerSurname",
          onTextChanged: (newText) async {
            await _trainerController.changeInformation(
                trainerID, "surname", newText);
            _updateData(trainerID);
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
          initialText: "$trainerAge",
          onTextChanged: (newText) async {
            await _trainerController.changeInformation(
                trainerID, "age", newText);
            _updateData(trainerID);
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
          initialText: "$trainerPosition",
          onTextChanged: (newText) async {
            await _trainerController.changeInformation(
                trainerID, "position", newText);
            _updateData(trainerID);
          },
        ),
        buildDivider(),
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
          MyButton(
            buttonText: 'DELETE ALL DATA',
            onPressed: () => {
              showErrorSnackBar(
                context,
                'Bunun için yetkiniz yok.',
              ),
            },
          ),
          SizedBox(
            height: 10.h,
          ),
          MyButton(
            buttonText: 'DELETE ACCOUNT',
            onPressed: () => {
              showErrorSnackBar(
                context,
                'Bunun için yetkiniz yok.',
              ),
            },
          ),
        ],
      ),
    ],
  );
}
