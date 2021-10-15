import 'package:email_validator/email_validator.dart';
import 'network.dart';

String validateFirstName(enteredFirstName) {
  String firstNameValidationString;
  Pattern pattern = r'(^[A-Za-z]*$)';
  RegExp regex = new RegExp(pattern);
  if (enteredFirstName.isEmpty)
    firstNameValidationString = 'Enter First Name';
  else if (!regex.hasMatch(enteredFirstName))
    firstNameValidationString = 'Enter only alphabets';

  return firstNameValidationString;
}

String validateLastName(enteredLastName) {
  String lastNameValidationString;
  Pattern pattern = r'(^[A-Za-z]*$)';
  RegExp regex = new RegExp(pattern);
  if (enteredLastName.isEmpty)
    lastNameValidationString = 'Enter Last Name';
  else if (!regex.hasMatch(enteredLastName))
    lastNameValidationString = 'Enter only alphabets';

  return lastNameValidationString;
}

Future<String> validateNickName(enteredNickName) async {
  String nickNameValidationString;
  var nickNameResponse = await nicknameExists(enteredNickName);
  if (nickNameResponse == true)
    nickNameValidationString =
        'Nick Name already Exists! Please enter a different one';
  else if (enteredNickName.isEmpty)
    nickNameValidationString = 'Enter Nick Name';

  return nickNameValidationString;
}

Future<String> validateEmail(enteredEmail) async {
  String emailValidationString;
  var emailResponse = await emailExists(enteredEmail);
  if (emailResponse == true)
    emailValidationString = 'Email already Exists';
  else if (!EmailValidator.validate(enteredEmail))
    emailValidationString = 'Please enter a valid Email';

  return emailValidationString;
}

String validatePassword(enteredPassword) {
  String passwordValidationString;
  if (enteredPassword.isEmpty)
    passwordValidationString = 'Enter Password';
  else if (enteredPassword.length < 3)
    passwordValidationString = 'Must be at least 3 characters';

  return passwordValidationString;
}

String validateNumber(enteredNumber) {
  String numberValidationString;
  List val= ['r1','r2','r3','r4','r5'];

  //Empty String validation
  enteredNumber='r'+enteredNumber;

  if(enteredNumber=='r') {
    return numberValidationString;
  }
  if (!val.contains(enteredNumber))
    numberValidationString = 'Enter number [1-5]';

  return numberValidationString;
}

String validateText(enteredText){
  String textValidationString;
  if(enteredText.length>0 && enteredText.length<=144)
    return textValidationString;
  else
    return 'Enter valid post text (Length: 1-144)';
}

String validateHashTags(enteredHashTags){
  String hashTagsValidationString;
  List hashTags;
  if(enteredHashTags.length==0)
    return 'Enter hash tag';

  hashTags=enteredHashTags.split(' ');
  for(int i=0; i<hashTags.length;i++){
    if(hashTags[i][0]!='#')
      return 'Start hash tag with \'#\'  Eg: #first #second';
    if(hashTags[i].length<2)
      return 'Hash tag length must be at least 2 characters';
  }
    return hashTagsValidationString;
}