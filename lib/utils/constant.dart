import 'dart:convert';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:mysql1/mysql1.dart';

final secretKey = utf8.encode('evidyalaya');
// ignore: deprecated_member_use
final smtpServer = gmail('evidyalayaerp@gmail.com', "iamzgwdzjjcgolpr");

const senderAdress = Address('evidyalayaerp@gmail.com', 'Admin E-Vidyalaya');

const String dummyUserProfileLink =
    'https://images.unsplash.com/photo-1566753323558-f4e0952af115?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1021&q=80';

final eVidalayaDBsettings = ConnectionSettings(
    host: "database-1.cb0cawk44al5.ap-south-1.rds.amazonaws.com",
    port: 3306,
    user: "admin",
    password: 'pass1234',
    db: 'u878322104_evidalaya');

ConnectionSettings getConnctionSettings(String db) {
  return ConnectionSettings(
      host: "database-1.cb0cawk44al5.ap-south-1.rds.amazonaws.com",
      port: 3306,
      user: "admin",
      password: 'pass1234',
      db: 'u878322104_jmieti');
}

const String privacyPolicy = '''Privacy Policy
Dummy Trade respects the privacy of its visitors by applying practices designed to protect the privacy of website users. We understand that information is the basis of human relationships in the virtual space and that the collection and responsible use of data is vitally important for users who browse our website to feel protected.

This privacy information regulates the processing of personal data within the https://www.dummytrade.es/ website, being responsible for the Dummy Trade business (then Dummy Trade).

Collection, treatment and use of personal data
In compliance with the provisions of Regulation 2016/679, of the European Parliament and of the Council, of April 27, 2016, as responsible for the website, informs all users who provide or will provide their personal data, that these will be object of treatment that has been registered among the Dummy Trade treatment activities, in accordance with the provisions of article 30 of the GDPR.''';

const String termConditions =
    '''These general conditions regulate the terms and conditions of access and use of dummytrade.com, the responsibility of Daniele Caldelli, located in Valencia (Spain), with Tax Identification Code number Y3736398Q and email daniele@dummytrade.com (from here on hereinafter "Dummy Trade"), that the portal user (hereinafter referred to as "You" or "User") must read and accept to use all the services and information provided from the portal. The mere access and / or use of the portal, of all or part of its contents and / or services means full acceptance of these terms and conditions of use.

This website offers visitors and Users information about cryptocurrency investment algorithms and the possibility of contracting the services.

This Agreement governs access and use of the Site, Web Services, Data and Data of third parties and constitutes a binding legal agreement between the User and Dummy Trade.

RECOGNIZE AND AGREE THAT, BY CLICKING ON CHECKBOX OR ACCESSING OR USING THE SITE, WEB SERVICES, YOU ARE INDICATING THAT YOU HAVE READ, UNDERSTAND AND ACCEPTED TO BE BOUND BY THIS AGREEMENT. IF YOU DO NOT ACCEPT THIS AGREEMENT, YOU DO NOT HAVE THE RIGHT TO ACCESS OR USE THE WEBSITE, THE WEB SERVICES. If you accept this Agreement on behalf of a company or other legal entity, you represent and warrant that you have the authority to bind this company or other legal entity to this Agreement and, if so; "User", "You" and "Your" will refer to and apply to that company or other legal person.''';
const String termsAndCondtionsURL =
    'https://www.termsandconditionsgenerator.com/live.php?token=Ls4vzHGoNltHWUEFjIakrDseeWXNRqfi';

const String aboutUsContent =
    "\n\nWelcome to E Cassroom where we share information related to eclassroom. We're dedicated to providing you the very best information and knowledge of the above mentioned topics.\n\n\nWe hope you found all of the information on E Cassroom helpful, as we love to share them with you.\n\nIf you require any more information or have any questions about our site, please feel free to contact us by email at .";

const Map<String, String> extToImage = {
  '.pdf': 'images/pdf.png',
  '.ppt': 'images/ppt.png',
  '.pptx': 'images/ppt.png',
  '.doc': 'images/doc.png',
  '.docx': 'images/doc.png',
  '.xls': 'images/excel.doc',
  '.xlsx': 'images/excel.png',
  '.zip': 'images/zip.png',
  '.mp4': 'images/video.png',
  '.mp3': 'images/audio.png',
};
const String defaultProfilePicture =
    'https://2.bp.blogspot.com/-BVgTOe82aaI/VZln4Ny-LPI/AAAAAAAAA6Y/hKchnruxKtg/s1600/2000px-User_icon_2.svg.png';
