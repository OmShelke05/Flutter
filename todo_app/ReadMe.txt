CS-696 Multi-Platform Mobile Application Development
To Do Flutter Project

Group Members:
-	Jyoti Nalwade (824909846)
-	Om Shelke (825891138)

Description
Functionality:
‘To Do’ App allows users to create, edit and delete notes.
●	It provides you functionality of adding text notes with optional image and/or hand drawn notes. Users can also insert images from your phone gallery or capture a live one from the camera. Custom drawing area is provided to choose the color of interest and the stroke of brush. Note is also provided with an optional reminder.  You can choose a specific date and time on which notification will pop up. Users can swipe to delete any task.
●	All the notes created will be displayed on the home screen. Initially, only the title is displayed. Tapping on the title expands it to give a more detailed version of the note. Peek button is provided to open the note in edit mode. Notes having upcoming reminders will have a reminder icon in their detailed view. Color coding for different categories.
●	Firebase Integration: All the data is stored using Firebase functionality which makes the app on the go. Authentication functionality includes SignIn, SignUp and Forgot Password. Users once loggedIn stays loggedIn even after the app is restarted. Same account can be used to log in to multiple devices and changes made in one device will sync up in real time in all other devices. Cloud Firestore database is used to store the tasks and user details. 

To create note Single screen functionality is provided for better interaction and performance.
Modal View Controller architecture is used to develop the app for modularity.

Special Instructions
Internet connectivity required at all times. 
We have developed the code in Android Studio. For some reason, it throws errors when compiling in Visual Studio. Kindly run the same in Android Studio.
We have run the app on Pixel running Android 10.0.

Third Party Library
None. All the required libraries have been added to dependencies in pubspec.yaml:
cupertino_icons: ^1.0.0
firebase_auth: ^0.18.3
cloud_firestore: ^0.14.3
firebase_core: ^0.5.2
shared_preferences: ^0.5.12+2
fluttertoast: ^7.1.1
image_picker: ^0.6.7+11
flutter_colorpicker: ^0.3.4
firebase_storage: ^5.2.0
flutter_slidable_list_view: ^1.2.8
flutter_local_notifications: ^3.0.2
rxdart: ^0.25.0


Known Issue
In some cases, multiple notification for same reminder is observed.

Future Development
➔	Offline Support
➔	Audio Notes
➔	Calendar View

