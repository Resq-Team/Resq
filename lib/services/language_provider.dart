import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'en';

  String get currentLanguage => _currentLanguage;

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // General & Settings Keys
      'app_title': 'ResQ - Smart Disaster Relief',
      'general': 'General',
      'settings': 'Settings',
      'language': 'Language',
      'theme': 'Theme',
      'notifications': 'Notification Settings',
      'account': 'Account',
      'privacy': 'Privacy Policy',
      'terms': 'Terms of Service',
      'about': 'About Resq App',

      // Home Dashboard Keys
      'hello': 'Hello',
      'stay_safe': 'Stay safe, stay prepared',
      'emergency_sos': 'Emergency SOS',
      'disaster_report': 'Disaster\nReport',
      'shelter_locator': 'Shelter\nLocator',
      'alerts': 'Alerts',
      'volunteers': 'Volunteers',
      'donations': 'Donations',
      'resources': 'Resources',
      'missing_persons': 'Missing\nPersons',
      'emergency_contacts': 'Emergency\nContacts',
      'feedback': 'Feedback',
      'admin_sos': 'Admin\nSOS',

      // Profile Screen Keys
      'my_profile': 'My Profile',
      'citizen_role': 'Disaster Victim / Citizen',
      'edit_profile': 'Edit Profile',
      'change_password': 'Change Password',
      'offline_demo': 'Offline State Demo',
      'sync_demo': 'Data Sync State Demo',
      'logout': 'Logout',
      'full_name': 'Full Name',
      'phone_number': 'Phone Number',
      'cancel': 'Cancel',
      'save': 'Save',
      'dark': 'Dark',
      'light': 'Light',
      'profile_updated_msg': 'Profile information updated.',
      'notifications_msg': 'Push notifications are active for high severity alerts.',
      'theme_switched_msg': 'Theme switched to',
      'change_password_msg': 'Password change verification code sent to your mobile.',
    },
    'si': {
      // General & Settings Keys
      'app_title': 'ResQ - ආපදා සහන පද්ධතිය',
      'general': 'සාමාන්‍ය',
      'settings': 'සැකසීම්',
      'language': 'භාෂාව',
      'theme': 'තේමාව',
      'notifications': 'දැනුම්දීම් සැකසීම්',
      'account': 'ගිණුම',
      'privacy': 'පුද්ගලිකත්ව ප්‍රතිපත්තිය',
      'terms': 'සේවා කොන්දේසි',
      'about': 'Resq යෙදවුම ගැන',

      // Home Dashboard Keys
      'hello': 'ආයුබෝවන්',
      'stay_safe': 'ආරක්ෂිතව සිටින්න, සූදානම්ව සිටින්න',
      'emergency_sos': 'හදිසි SOS',
      'disaster_report': 'ආපදා\nවාර්තාව',
      'shelter_locator': 'ආරක්ෂිත\nස්ථාන',
      'alerts': 'අනතුරු ඇඟවීම්',
      'volunteers': 'ස්වේච්ඡා සේවකයින්',
      'donations': 'ආධාර',
      'resources': 'සම්පත්',
      'missing_persons': 'අතුරුදහන් වූවන්',
      'emergency_contacts': 'හදිසි\nඇමතුම්',
      'feedback': 'අදහස්',
      'admin_sos': 'පරිපාලන\nSOS',

      // Profile Screen Keys
      'my_profile': 'මගේ ගිණුම',
      'citizen_role': 'ආපදාවට ලක්වූවෙකු / පුරවැසියෙකු',
      'edit_profile': 'තොරතුරු වෙනස් කරන්න',
      'change_password': 'මුරපදය වෙනස් කරන්න',
      'offline_demo': 'නොබැඳි මාදිලි නිරූපණය',
      'sync_demo': 'දත්ත සමමුහුර්තකරණ නිරූපණය',
      'logout': 'ඉවත් වන්න',
      'full_name': 'සම්පූර්ණ නම',
      'phone_number': 'දුරකථන අංකය',
      'cancel': 'අවලංගු කරන්න',
      'save': 'සුරකින්න',
      'dark': 'තද පැහැති',
      'light': 'ළා පැහැති',
      'profile_updated_msg': 'ගිණුමේ තොරතුරු යාවත්කාලීන කරන ලදී.',
      'notifications_msg': 'අධි අවදානම් අනතුරු ඇඟවීම් සඳහා දැනුම්දීම් සක්‍රියයි.',
      'theme_switched_msg': 'තේමාව මාරු කරන ලදී:',
      'change_password_msg': 'මුරපද වෙනස් කිරීමේ කේතය ඔබගේ දුරකථනයට යවන ලදී.',
    },
    'ta': {
      // General & Settings Keys
      'app_title': 'ResQ - அனர்த்த நிவாரணம்',
      'general': 'பொதுவானவை',
      'settings': 'அமைப்புகள்',
      'language': 'மொழி',
      'theme': 'தீம்',
      'notifications': 'அறிவிப்பு அமைப்புகள்',
      'account': 'கணக்கு',
      'privacy': 'தனியுரிமைக் கொள்கை',
      'terms': 'சேவை விதிமுறைகள்',
      'about': 'Resq பற்றி',

      // Home Dashboard Keys
      'hello': 'வணக்கம்',
      'stay_safe': 'பாதுகாப்பாக இருங்கள்',
      'emergency_sos': 'அவசர SOS',
      'disaster_report': 'அனர்த்த\nஅறிக்கை',
      'shelter_locator': 'தஞ்சமடையும்\nஇடம்',
      'alerts': 'எச்சரிக்கைகள்',
      'volunteers': 'தன்னார்வலர்கள்',
      'donations': 'நன்கொடைகள்',
      'resources': 'வளங்கள்',
      'missing_persons': 'காணாமல் போனவர்கள்',
      'emergency_contacts': 'அவசர\nதொடர்புகள்',
      'feedback': 'கருத்துகள்',
      'admin_sos': 'நிர்வாகி\nSOS',

      // Profile Screen Keys
      'my_profile': 'எனது சுயவிவரம்',
      'citizen_role': 'பாதிக்கப்பட்டவர் / குடிமகன்',
      'edit_profile': 'சுயவிவரத்தைத் திருத்து',
      'change_password': 'கடவுச்சொல்லை மாற்றவும்',
      'offline_demo': 'ஆஃப்லைன் செயல்முறை மாதிரி',
      'sync_demo': 'தரவு ஒத்திசைவு மாதிரி',
      'logout': 'வெளியேறு',
      'full_name': 'முழு பெயர்',
      'phone_number': 'தொலைபேசி எண்',
      'cancel': 'இரத்து செய்',
      'save': 'சேமிக்க',
      'dark': 'இருண்ட',
      'light': 'வெளிச்சமான',
      'profile_updated_msg': 'சுயவிவரத் தகவல் புதுப்பிக்கப்பட்டது.',
      'notifications_msg': 'உயர் எச்சரிக்கை அறிவிப்புகள் செயலில் உள்ளன.',
      'theme_switched_msg': 'தீம் மாற்றப்பட்டது:',
      'change_password_msg': 'கடவுச்சொல் மாற்றக் குறியீடு உங்கள் மொபைலுக்கு அனுப்பப்பட்டது.',
    },
  };

  void changeLanguage(String newLangCode) {
    _currentLanguage = newLangCode;
    notifyListeners(); // මුළු App එකටම Language වෙනස් වූ බව දැනුම් දෙයි
  }

  String getText(String key) {
    return _localizedValues[_currentLanguage]?[key] ?? _localizedValues['en']![key]!;
  }
}