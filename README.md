# passvault

A mobile utility application made in flutter to store passwords.

## Getting Started
  
The application is a password manager used to store passwords without the need to remember them.
 
The app uses biometric authentication to view the details. As of now, the passwords are AES-encrypted using unique device id as key.

All the details are stored in a local database created using the plugin sqflite.

## Plugins Used

- local_auth
- device_info
- sqflite
- path_provider
- encrypt
- flushbar

## Requirements to run the app

- Any android or iOS device with biometric authentication facility(faceID or fingerprint).
- Android device having sdk version greater than 28 is preferable.

## Commands

- `unzip passvault.zip`
- `cd passvault/`
- `flutter run --release`
- It is considered that Flutter is already installed on the system.

## Drawbacks

- Due to file limit of 5KB, the indentation of code is disturbed but readable.
- No custom app icon
- The size of dart code isn't lower than 5KB, but it is closer.
- Obscure Text for password text field could not be used as it was breaking other text fields. Will rectified in a non-compressed version of this app hopefully.