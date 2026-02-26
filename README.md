# Feeling Diagnosis App

This is a Flutter mobile application designed for feeling diagnosis using facial emotion recognition. It integrates Firebase for authentication, Google ML Kit for face detection, and TensorFlow Lite for emotion classification.



### Tools \& Prerequisites

To build and run this application, you must have the following tools installed on your development machine.



#### 1\. Flutter SDK

Version Required: Compatible with Dart SDK ^3.8.1 (Ensure you have the latest stable release of Flutter).



#### 2\. Java Development Kit (JDK)

Version Required: Java 11 (Specified in android/app/build.gradle.kts).



#### 3\. Android Studio \& Android SDK

Required for: Android emulation and compiling.

Android NDK Version: 27.0.12077973.

Installation: Open Android Studio > SDK Manager > SDK Tools > Check "NDK (Side by side)" and select version 27.0.x.



#### 4\. Code Editor

Recommended: Visual Studio Code or Android Studio.






### Installation Instructions

1. Clone the Repository

git clone <your-repository-url>
cd flutter_application_2



2. Install Dependencies

Download the required libraries listed in pubspec.yaml:

flutter pub get





3. Firebase Configuration

This project uses Firebase. Ensure the google-services.json file is present in the android/app/ directory.

**Note:** A placeholder or existing file should be located at: android/app/google-services.json.



4\. Assets \& Models

Ensure the following assets are present in the assets/ directory as defined in pubspec.yaml:

emotions\_model.tflite
labels.txt
google\_logo.png



### How to Run

#### Run with Emulator

1. Start an Emulator or Connect a Device

Ensure USB debugging is enabled on your physical Android device, or start an Android Emulator (AVD) via Android Studio.



2\. Run the Application

Execute the following command in your terminal: flutter run

* Note: If you encounter signing issues, the project is currently configured to use the debug signing config for release builds.



##### Installing Existing APK (Recommended)

The project includes a pre-built APK file located at:

build/app/outputs/flutter-apk/app-release.apk



1. Transfer to Phone

Send this file to your Android phone using any method you prefer:

* WhatsApp / Telegram: Send the file to yourself.
* Google Drive: Upload it on PC and download it on your phone.
* USB / Bluetooth: Copy the file directly to your phone's storage.



2\. Install on Phone

&nbsp;	1. Open your File Manager (or the app you used to receive the file).

&nbsp;	2. Tap on app-release.apk.

&nbsp;	3. If prompted, allow "Install from Unknown Sources".

&nbsp;	4. Tap Install.



**Note:** The release APK is signed with the debug key. You may see a "Play Protect" warning because it is not from the Play Store. You can safely click "Install Anyway" for testing.





### Libraries \& Dependencies

The project relies on the following key packages (from pubspec.yaml):



|Package|Version|Purpose|
|-|-|-|
|firebase\_core|^3.15.1|Firebase initialization|
|firebase\_auth|^5.5.4|User authentication|
|flutter\_facebook\_auth|^7.1.2|Facebook login integration|
|google\_sign\_in|^6.2.1|Google login integration|
|camera|^0.11.0|Access device camera|
|google\_mlkit\_face\_detection|^0.13.0|Detect faces in images|
|tflite\_flutter|^0.11.0|Run TensorFlow Lite models|
|image|^4.5.0|Image manipulation (cropping)|
|webview\_flutter|^4.13.0|Display web content|
|shared\_preferences|^2.5.4|Local data storage|

### 



Troubleshooting

* NDK Errors: If you see errors related to the NDK, ensure version 27.0.12077973 is installed via the Android SDK Manager.
* Gradle Errors: The project uses the new Flutter Gradle Plugin (id("dev.flutter.flutter-gradle-plugin")). Ensure your Flutter version is up to date.



