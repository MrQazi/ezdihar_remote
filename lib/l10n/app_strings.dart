import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// App translations. Arabic locales render right-to-left, English left-to-right.
class AppStrings {
  const AppStrings._(this.locale, this._values);

  final Locale locale;
  final Map<String, String> _values;

  static const supportedLocales = [Locale('en'), Locale('ar')];
  static const delegate = _AppStringsDelegate();

  static const _en = {
    'brandName': 'MASHAEL AL FURSAN',
    'projectName': 'Mashael\nAlfursan',
    'tagline': 'Discover a New Way of Living',
    'startJourney': 'Start Journey',
    'back': 'Back',
    'horseRacingTrack': 'Horse Racing Track',
    'kingKhalidAirport': 'King Khalid International Airport',
    'khuzamDistrict': 'Khuzam District',
    'equestrianClub': 'Equestrian Club',
    'princessNourahUniversity': 'Princess Nourah Bint Abdulrahman University',
    'kingSalmanAirport': 'King Salman International Airport',
    'imamUniversity': 'Imam Muhammad Ibn Saud Islamic University',
    'expo2030': 'Expo 2030 Riyadh',
    'filters': 'Filters',
    'filtersSubtitle': 'Refine your search to discover the project property',
    'gallery': 'Gallery',
    'floor': 'Floor',
    'sqm': 'sqm',
    'availability': 'Availability',
    'hideUnavailableUnits': 'Hide unavailable units',
    'buildingType': 'Building Type',
    'close': 'Close',
    'rotateLeft': 'Rotate left',
    'rotateRight': 'Rotate right',
    'resetView': 'Reset view',
    'buildingDetails': 'Building Details',
    'buildingNo': 'Building no.',
    'floors': 'Floors',
    'numberOfApartments': 'Number of Apartments',
    'apartmentTypes': 'Apartment Types',
    'totalArea': 'Total Area',
    'areaUnit': 'M²',
    'restart': 'Restart',
    'buildingInfo': 'Building info',
    'apartments': 'Apartments',
    'selectApartment': 'Select your preferred apartment to start tour',
    'apartmentDetails': 'Apartment Details',
    'type': 'Type',
    'brochure': 'Brochure',
    'brochureError': 'Could not open the brochure',
    'previous': 'Previous page',
    'next': 'Next page',
    'previousImage': 'Previous image',
    'nextImage': 'Next image',
    'registerInterest': 'Register Interest',
    'yourInformation': 'Your Information',
    'yourName': 'Your Name',
    'yourNameHint': 'Faisal Al Saud',
    'emailAddress': 'Email Address',
    'emailHint': 'faisal.saud@email.com',
    'contactNumber': 'Contact Number',
    'phoneHint': 'Type here...',
    'interestRegistered': 'Interest Registered!',
    'interestRegisteredBody':
        'Thank you for expressing your interest. Our team will contact you via phone or email with the next steps.',
    'restartExperience': 'Restart Experience',
    'masterplan': 'Masterplan',
    'collapse': 'Collapse',
    'tapBuildingHint': 'Tap a building to explore it',
    'amenity_greenArea': 'Green Area',
    'amenity_playArea': 'Play Area',
    'amenity_padelCourt': 'Padel Court',
    'amenity_waterFountain': 'Water Fountain',
    'amenity_sportsCourt': 'Basketball and Volleyball Court',
    'tapFloorHint': 'Tap a floor to see its apartments',
    'matchCount': '{n} of {total} buildings match',
    'noMatch': 'No buildings match your filters',
    'clearFilters': 'Clear filters',
    'restartConfirmTitle': 'Restart the experience?',
    'restartConfirmBody': 'You will return to the start screen.',
    'cancel': 'Cancel',
    'stillThereTitle': 'Still there?',
    'stillThereBody': 'Returning to the start in {s}s',
    'stillHere': "I'm here",
    'bedrooms': '{n} Bedroom',
    'previousFloor': 'Floor above',
    'nextFloor': 'Floor below',
    'scrollBack': 'Scroll back',
    'scrollForward': 'Scroll forward',
    'nameError': 'Please enter your name',
    'emailError': 'Enter a valid email address',
    'phoneError': 'Enter a valid phone number',
    'browseMore': 'Browse more units',
    'loadError': 'Could not load building data',
    'retry': 'Retry',
    'groundFloorCode': 'GF',
    'floorCode': '{n}F',
    'floorDetails': 'Floor Details',
    'floorArea': 'Floor Area',
    'area': 'Area',
    'size': 'Surface',
    'available': 'Available',
    'unavailable': 'Not Available',
    'connectScreen': 'Connect screen',
    'screenConnected': 'Screen connected',
    'screenConnecting': 'Connecting…',
    'screenOffline': 'Screen offline',
    'scanScreenCode': 'Scan the code on the screen',
    'scanScreenCodeHint': 'The QR code shows on the main screen while no remote is connected',
    'enterManually': 'Or enter the address manually',
    'ipAddress': 'IP address',
    'port': 'Port',
    'connect': 'Connect',
    'invalidIp': 'Enter a valid IP address or host name',
    'invalidPort': 'Port must be 1 to 65535',
    'cameraPermissionDenied': 'Camera permission is denied. Allow it in the settings or enter the address below',
    'tryAgain': 'Try again',
    'notScreenCode': 'This is not an Ezdihar screen code',
    'cameraError': 'The camera is not available',
    'previousLandmark': 'Previous',
    'nextLandmark': 'Next',
    'landmarkDistance': '{min} min',
    'compareApartment': 'Compare Apartment',
    'compareApartments': 'Compare Apartments',
    'apartmentsComparison': 'Apartments Comparison',
    'compareSelectMore': 'Select one more apartment for comparison',
    'compareSelectFirst': 'Select up to 3 apartments to compare',
    'addApartmentToCompare': 'Add apartment to compare',
    'selectBuilding': 'Select Building',
    'selectBuildingNumber': 'Select Building Number',
    'selectFloor': 'Select Floor',
    'apartmentType': 'Apartment Type',
    'buildingTypeName': 'Building Type {type}',
    'apartment': 'Apartment',
    'status': 'Status',
    'removeFromCompare': 'Remove from comparison',
    'alreadyCompared': 'Added',
    'unitType1': '1BR',
    'unitType2': '2BR',
    'unitTypeN': '{n}BR',
    'saveError': 'Could not save your details. Please try again.',
    'storageAccessTitle': 'Allow storage access',
    'storageAccessBody': 'Register Interest details are saved on this tablet, in the folder below. '
        'Allow access to all files to continue; without it the app closes.',
    'storageAccessAllow': 'Allow access',
    'internalStorage': 'Internal storage',
    // Landmark descriptions: "Mashael Al Fursan_ Arabic Content" doc, keyed by landmark id.
    'landmarkDescription_king_salman_airport':
        'King Salman International Airport is a major aviation development planned to expand Riyadh’s passenger '
        'and cargo capacity. The project aims to strengthen the capital’s global connectivity and support its '
        'long-term ambitions as an international travel and logistics hub.',
    'landmarkDescription_king_khalid_airport':
        'King Khalid International Airport is Riyadh’s principal international airport, connecting the capital to '
        'domestic and international destinations. Its extensive flight network supports business and leisure '
        'travel, making it a key transport gateway for residents and visitors.',
    'landmarkDescription_equestrian_club':
        'The Equestrian Club is a destination associated with equestrian sports and horse-related activities in '
        'Riyadh. It provides access to the city’s equestrian scene and contributes to the area’s wider sporting '
        'and recreational appeal.',
    'landmarkDescription_horse_racing_track':
        'The Horse Racing Track is a prominent sporting destination in Riyadh, hosting competitive horse-racing '
        'events and attracting spectators throughout the racing season. Its facilities contribute to the city’s '
        'sporting and entertainment offerings.',
    'landmarkDescription_imam_university':
        'Imam Muhammad ibn Saud Islamic University is a prominent public university in Riyadh, historically '
        'recognised for Islamic and Arabic studies and offering programmes across a wider range of academic '
        'disciplines. Its substantial campus provides an established destination for higher education and '
        'research.',
    'landmarkDescription_princess_nourah_university':
        'Princess Nourah bint Abdulrahman University is a prominent public university dedicated to women’s higher '
        'education in Riyadh. Its extensive campus supports academic programmes, research, and student '
        'development across a diverse range of disciplines.',
    'landmarkDescription_expo_2030':
        'Expo 2030 Riyadh is a global exhibition scheduled to take place from 1 October 2030 to 31 March 2031. '
        'The event will bring together countries and organisations to showcase innovation, culture, '
        'sustainability, and international collaboration.',
    'landmarkDescription_khuzam_district':
        'Khuzam is a residential development in Riyadh designed to support modern community living. Its planned '
        'neighbourhood environment and residential offerings form part of the city’s wider urban expansion and '
        'development of new residential communities.',
  };

  static const _ar = {
    'brandName': 'مشاعل الفرسان',
    'projectName': 'مشاعل\nالفرسان',
    'tagline': 'اكتشف طريقة جديدة للعيش',
    'startJourney': 'ابدأ الرحلة',
    'back': 'رجوع',
    'horseRacingTrack': 'ميدان سباق الخيل',
    'kingKhalidAirport': 'مطار الملك خالد الدولي',
    'khuzamDistrict': 'وجهة خزام',
    'equestrianClub': 'نادي الفروسية',
    'princessNourahUniversity': 'جامعة الأميرة نورة بنت عبد الرحمن',
    'kingSalmanAirport': 'مطار الملك سلمان الدولي',
    'imamUniversity': 'جامعة الإمام محمد بن سعود الإسلامية',
    'expo2030': 'إكسبو 2030 الرياض',
    'filters': 'التصفية',
    'filtersSubtitle': 'حدّد بحثك لاكتشاف العقار المناسب في المشروع',
    'gallery': 'المعرض',
    'floor': 'الطابق',
    'sqm': 'م²',
    'availability': 'التوفر',
    'hideUnavailableUnits': 'إخفاء الوحدات غير المتاحة',
    'buildingType': 'نوع المبنى',
    'close': 'إغلاق',
    'rotateLeft': 'تدوير لليسار',
    'rotateRight': 'تدوير لليمين',
    'resetView': 'إعادة ضبط العرض',
    'buildingDetails': 'تفاصيل المبنى',
    'buildingNo': 'رقم المبنى',
    'floors': 'الطوابق',
    'numberOfApartments': 'عدد الشقق',
    'apartmentTypes': 'أنواع الشقق',
    'totalArea': 'المساحة الإجمالية',
    'areaUnit': 'م²',
    'restart': 'إعادة',
    'buildingInfo': 'معلومات المبنى',
    'apartments': 'الشقق',
    'selectApartment': 'اختر الشقة المفضلة لديك لبدء الجولة',
    'apartmentDetails': 'تفاصيل الشقة',
    'type': 'النوع',
    'brochure': 'الكتيب',
    'brochureError': 'تعذر فتح الكتيب',
    'previous': 'الصفحة السابقة',
    'next': 'الصفحة التالية',
    'previousImage': 'الصورة السابقة',
    'nextImage': 'الصورة التالية',
    'registerInterest': 'سجل اهتمامك',
    'yourInformation': 'معلوماتك',
    'yourName': 'الاسم',
    'yourNameHint': 'فيصل آل سعود',
    'emailAddress': 'البريد الإلكتروني',
    'emailHint': 'faisal.saud@email.com',
    'contactNumber': 'رقم التواصل',
    'phoneHint': 'اكتب هنا...',
    'interestRegistered': 'تم تسجيل اهتمامك!',
    'interestRegisteredBody':
        'شكراً لإبداء اهتمامك. سيتواصل معك فريقنا عبر الهاتف أو البريد الإلكتروني لإبلاغك بالخطوات التالية.',
    'restartExperience': 'إعادة التجربة',
    'masterplan': 'المخطط العام',
    'collapse': 'طيّ',
    'tapBuildingHint': 'اضغط على مبنى لاستكشافه',
    'amenity_greenArea': 'المساحة الخضراء',
    'amenity_playArea': 'منطقة الألعاب',
    'amenity_padelCourt': 'ملعب بادل',
    'amenity_waterFountain': 'نافورة مائية',
    'amenity_sportsCourt': 'ملعب كرة السلة والكرة الطائرة',
    'tapFloorHint': 'اضغط على طابق لعرض شققه',
    'matchCount': '{n} من {total} مبنى مطابق',
    'noMatch': 'لا توجد مبانٍ مطابقة للتصفية',
    'clearFilters': 'مسح التصفية',
    'restartConfirmTitle': 'إعادة التجربة؟',
    'restartConfirmBody': 'ستعود إلى الشاشة الرئيسية.',
    'cancel': 'إلغاء',
    'stillThereTitle': 'هل ما زلت هنا؟',
    'stillThereBody': 'العودة إلى البداية خلال {s} ث',
    'stillHere': 'أنا هنا',
    'bedrooms': '{n} غرف نوم',
    'previousFloor': 'الطابق الأعلى',
    'nextFloor': 'الطابق الأسفل',
    'scrollBack': 'السابق',
    'scrollForward': 'التالي',
    'nameError': 'الرجاء إدخال الاسم',
    'emailError': 'أدخل بريداً إلكترونياً صحيحاً',
    'phoneError': 'أدخل رقم هاتف صحيحاً',
    'browseMore': 'تصفح المزيد من الوحدات',
    'loadError': 'تعذّر تحميل بيانات المباني',
    'retry': 'إعادة المحاولة',
    'groundFloorCode': 'الأرضي',
    'floorCode': 'ط{n}',
    'floorDetails': 'تفاصيل الطابق',
    'floorArea': 'مساحة الطابق',
    'area': 'المساحة',
    'size': 'المساحة',
    'available': 'متاحة',
    'unavailable': 'غير متاحة',
    'connectScreen': 'ربط الشاشة',
    'screenConnected': 'الشاشة متصلة',
    'screenConnecting': 'جارٍ الاتصال…',
    'screenOffline': 'الشاشة غير متصلة',
    'scanScreenCode': 'امسح الرمز الظاهر على الشاشة',
    'scanScreenCodeHint': 'يظهر رمز QR على الشاشة الرئيسية عندما لا يكون هناك جهاز تحكم متصل',
    'enterManually': 'أو أدخل العنوان يدويًا',
    'ipAddress': 'عنوان IP',
    'port': 'المنفذ',
    'connect': 'اتصال',
    'invalidIp': 'أدخل عنوان IP أو اسم مضيف صحيحًا',
    'invalidPort': 'يجب أن يكون المنفذ من 1 إلى 65535',
    'cameraPermissionDenied': 'إذن الكاميرا مرفوض. اسمح به من الإعدادات أو أدخل العنوان أدناه',
    'tryAgain': 'حاول مرة أخرى',
    'notScreenCode': 'هذا الرمز ليس رمز شاشة إزدهار',
    'cameraError': 'الكاميرا غير متاحة',
    'previousLandmark': 'السابق',
    'nextLandmark': 'التالي',
    'landmarkDistance': '{min} دقيقة',
    'compareApartment': 'مقارنة الشقق',
    'compareApartments': 'مقارنة الشقق',
    'apartmentsComparison': 'مقارنة الشقق',
    'compareSelectMore': 'اختر شقة أخرى للمقارنة',
    'compareSelectFirst': 'اختر حتى 3 شقق للمقارنة',
    'addApartmentToCompare': 'أضف شقة للمقارنة',
    'selectBuilding': 'اختر المبنى',
    'selectBuildingNumber': 'اختر رقم المبنى',
    'selectFloor': 'اختر الطابق',
    'apartmentType': 'نوع الشقة',
    'buildingTypeName': 'المبنى من النوع {type}',
    'apartment': 'الشقة',
    'status': 'الحالة',
    'removeFromCompare': 'إزالة من المقارنة',
    'alreadyCompared': 'مضافة',
    'unitType1': 'غرفة نوم واحدة',
    'unitType2': 'غرفتا نوم',
    'unitTypeN': '{n} غرف نوم',
    'saveError': 'تعذّر حفظ بياناتك. يرجى المحاولة مرة أخرى.',
    'storageAccessTitle': 'اسمح بالوصول إلى التخزين',
    'storageAccessBody': 'تُحفظ بيانات تسجيل الاهتمام على هذا الجهاز في المجلد أدناه. '
        'اسمح بالوصول إلى جميع الملفات للمتابعة؛ وبدونه سيُغلق التطبيق.',
    'storageAccessAllow': 'السماح بالوصول',
    'internalStorage': 'وحدة التخزين الداخلية',
    'landmarkDescription_king_salman_airport':
        'يُعد مطار الملك سلمان الدولي مشروعًا رئيسيًا لتطوير قطاع الطيران، ويهدف إلى زيادة الطاقة الاستيعابية '
        'لحركة المسافرين والشحن الجوي في الرياض. ويسعى المشروع إلى تعزيز ارتباط العاصمة بمختلف الوجهات '
        'العالمية، ودعم تطلعاتها طويلة المدى لتصبح مركزًا دوليًا للسفر والخدمات اللوجستية.',
    'landmarkDescription_king_khalid_airport':
        'يُعد مطار الملك خالد الدولي المطار الدولي الرئيسي لمدينة الرياض، حيث يربط العاصمة بالعديد من الوجهات '
        'المحلية والدولية. وتدعم شبكة رحلاته الواسعة السفر لأغراض الأعمال والسياحة والترفيه، مما يجعله بوابة '
        'جوية رئيسية للمقيمين والزوار.',
    'landmarkDescription_equestrian_club':
        'يُعد نادي الفروسية وجهة مرتبطة برياضات الفروسية والأنشطة المتعلقة بالخيل في مدينة الرياض. ويتيح فرصة '
        'للتعرف على رياضة الفروسية وممارستها في المدينة، كما يسهم في تعزيز جاذبية المنطقة بوصفها وجهة للأنشطة '
        'الرياضية والترفيهية.',
    'landmarkDescription_horse_racing_track':
        'يُعد ميدان سباق الخيل وجهة رياضية بارزة في مدينة الرياض، حيث يستضيف منافسات وفعاليات سباقات الخيل '
        'ويستقطب الجماهير طوال موسم السباقات. وتسهم مرافقه في إثراء الخيارات الرياضية والترفيهية المتاحة في '
        'المدينة.',
    'landmarkDescription_imam_university':
        'تُعد جامعة الإمام محمد بن سعود الإسلامية إحدى الجامعات الحكومية البارزة في مدينة الرياض، وتتميز '
        'بتاريخها العريق في الدراسات الإسلامية واللغة العربية، إلى جانب تقديم برامج أكاديمية في مجموعة واسعة من '
        'التخصصات العلمية والمعرفية. وتضم الجامعة حرمًا جامعيًا واسعًا يشكل صرحًا تعليميًا راسخًا للتعليم العالي '
        'والبحث العلمي.',
    'landmarkDescription_princess_nourah_university':
        'تُعد جامعة الأميرة نورة بنت عبد الرحمن إحدى الجامعات الحكومية الرائدة والمتخصصة في التعليم العالي '
        'للمرأة في مدينة الرياض. وتضم حرمًا جامعيًا واسعًا يوفر بيئة تعليمية متكاملة تدعم البرامج الأكاديمية '
        'والبحث العلمي وتنمية مهارات الطالبات في مجموعة متنوعة من التخصصات.',
    'landmarkDescription_expo_2030':
        'إكسبو 2030 الرياض هو معرض عالمي من المقرر إقامته خلال الفترة من 1 أكتوبر 2030 إلى 31 مارس 2031. '
        'وسيجمع المعرض دولًا ومنظمات من مختلف أنحاء العالم لاستعراض الابتكارات والثقافات ومبادرات الاستدامة، '
        'وتعزيز التعاون الدولي.',
    'landmarkDescription_khuzam_district':
        'تُعد وجهة خزام مشروعًا عمرانيًا سكنيًا في مدينة الرياض، صُمم لتوفير بيئة مجتمعية عصرية تلبي احتياجات '
        'الحياة الحديثة. وتتميز الوجهة بأحيائها السكنية المخططة وخياراتها السكنية المتنوعة، وتشكل جزءًا من '
        'التوسع العمراني الذي تشهده المدينة وتطوير مجتمعات سكنية جديدة.',
  };

  static AppStrings of(BuildContext context) =>
      Localizations.of<AppStrings>(context, AppStrings)!;

  bool get isArabic => locale.languageCode == 'ar';

  String get brandName => _values['brandName']!;
  String get projectName => _values['projectName']!;
  String get tagline => _values['tagline']!;
  String get startJourney => _values['startJourney']!;
  String get back => _values['back']!;
  String get horseRacingTrack => _values['horseRacingTrack']!;
  String get kingKhalidAirport => _values['kingKhalidAirport']!;
  String get khuzamDistrict => _values['khuzamDistrict']!;
  String get equestrianClub => _values['equestrianClub']!;
  String get princessNourahUniversity => _values['princessNourahUniversity']!;
  String get kingSalmanAirport => _values['kingSalmanAirport']!;
  String get imamUniversity => _values['imamUniversity']!;
  String get expo2030 => _values['expo2030']!;
  String get filters => _values['filters']!;
  String get filtersSubtitle => _values['filtersSubtitle']!;
  String get gallery => _values['gallery']!;
  String get floor => _values['floor']!;
  String get sqm => _values['sqm']!;
  String get availability => _values['availability']!;
  String get hideUnavailableUnits => _values['hideUnavailableUnits']!;
  String get buildingType => _values['buildingType']!;
  String get close => _values['close']!;
  String get rotateLeft => _values['rotateLeft']!;
  String get rotateRight => _values['rotateRight']!;
  String get resetView => _values['resetView']!;
  String get buildingNo => _values['buildingNo']!;
  String get buildingDetails => _values['buildingDetails']!;
  String get floorDetails => _values['floorDetails']!;
  String get floors => _values['floors']!;
  String get numberOfApartments => _values['numberOfApartments']!;
  String get apartmentTypes => _values['apartmentTypes']!;
  String get totalArea => _values['totalArea']!;
  String get areaUnit => _values['areaUnit']!;
  String get restart => _values['restart']!;
  String get buildingInfo => _values['buildingInfo']!;
  String get apartments => _values['apartments']!;
  String get selectApartment => _values['selectApartment']!;
  String get apartmentDetails => _values['apartmentDetails']!;
  String get type => _values['type']!;
  String get brochure => _values['brochure']!;
  String get brochureError => _values['brochureError']!;
  String get previous => _values['previous']!;
  String get next => _values['next']!;
  String get previousImage => _values['previousImage']!;
  String get nextImage => _values['nextImage']!;
  String get registerInterest => _values['registerInterest']!;
  String get yourInformation => _values['yourInformation']!;
  String get yourName => _values['yourName']!;
  String get yourNameHint => _values['yourNameHint']!;
  String get emailAddress => _values['emailAddress']!;
  String get emailHint => _values['emailHint']!;
  String get contactNumber => _values['contactNumber']!;
  String get phoneHint => _values['phoneHint']!;
  String get interestRegistered => _values['interestRegistered']!;
  String get interestRegisteredBody => _values['interestRegisteredBody']!;
  String get restartExperience => _values['restartExperience']!;
  String get masterplan => _values['masterplan']!;
  String get collapse => _values['collapse']!;
  String get tapBuildingHint => _values['tapBuildingHint']!;
  String get tapFloorHint => _values['tapFloorHint']!;
  String get noMatch => _values['noMatch']!;
  String get clearFilters => _values['clearFilters']!;
  String get restartConfirmTitle => _values['restartConfirmTitle']!;
  String get restartConfirmBody => _values['restartConfirmBody']!;
  String get cancel => _values['cancel']!;
  String get stillThereTitle => _values['stillThereTitle']!;
  String get stillHere => _values['stillHere']!;
  String get previousFloor => _values['previousFloor']!;
  String get nextFloor => _values['nextFloor']!;
  String get scrollBack => _values['scrollBack']!;
  String get scrollForward => _values['scrollForward']!;
  String get nameError => _values['nameError']!;
  String get emailError => _values['emailError']!;
  String get phoneError => _values['phoneError']!;
  String get browseMore => _values['browseMore']!;
  String get loadError => _values['loadError']!;
  String get retry => _values['retry']!;
  String get floorArea => _values['floorArea']!;
  String get area => _values['area']!;
  String get size => _values['size']!;
  String get available => _values['available']!;
  String get unavailable => _values['unavailable']!;
  String get connectScreen => _values['connectScreen']!;
  String get screenConnected => _values['screenConnected']!;
  String get screenConnecting => _values['screenConnecting']!;
  String get screenOffline => _values['screenOffline']!;
  String get scanScreenCode => _values['scanScreenCode']!;
  String get scanScreenCodeHint => _values['scanScreenCodeHint']!;
  String get enterManually => _values['enterManually']!;
  String get ipAddress => _values['ipAddress']!;
  String get port => _values['port']!;
  String get connect => _values['connect']!;
  String get invalidIp => _values['invalidIp']!;
  String get invalidPort => _values['invalidPort']!;
  String get cameraPermissionDenied => _values['cameraPermissionDenied']!;
  String get tryAgain => _values['tryAgain']!;
  String get notScreenCode => _values['notScreenCode']!;
  String get cameraError => _values['cameraError']!;
  String get previousLandmark => _values['previousLandmark']!;
  String get nextLandmark => _values['nextLandmark']!;
  /// Description of the city landmark with id [landmarkId] (e.g. "expo_2030").
  String landmarkDescription(String landmarkId) => _values['landmarkDescription_$landmarkId']!;
  /// Drive time from the project to a landmark ("10 min").
  String landmarkDistance(int minutes) =>
      _values['landmarkDistance']!.replaceAll('{min}', '$minutes');

  /// Floor name in the project sheet's convention: English uses the sheet
  /// code as is ("GF", "1F".."6F"); Arabic uses the same short form
  /// ("الأرضي", "ط1".."ط6").
  String floorName(String code) => code == 'GF'
      ? _values['groundFloorCode']!
      : _values['floorCode']!.replaceAll('{n}', code.replaceAll(RegExp(r'\D'), ''));

  /// Floor name for a floor level (0 = ground), e.g. on the floor filter.
  String floorNameOfLevel(int level) => floorName(level == 0 ? 'GF' : '${level}F');

  String matchCount(int n, int total) =>
      _values['matchCount']!.replaceAll('{n}', '$n').replaceAll('{total}', '$total');
  String stillThereBody(int seconds) => _values['stillThereBody']!.replaceAll('{s}', '$seconds');
  String bedrooms(String n) => _values['bedrooms']!.replaceAll('{n}', n);

  String get compareApartment => _values['compareApartment']!;
  String get compareApartments => _values['compareApartments']!;
  String get apartmentsComparison => _values['apartmentsComparison']!;
  String get compareSelectMore => _values['compareSelectMore']!;
  String get compareSelectFirst => _values['compareSelectFirst']!;
  String get addApartmentToCompare => _values['addApartmentToCompare']!;
  String get selectBuilding => _values['selectBuilding']!;
  String get selectBuildingNumber => _values['selectBuildingNumber']!;
  String get selectFloor => _values['selectFloor']!;
  String get apartmentType => _values['apartmentType']!;
  String get apartment => _values['apartment']!;
  String get status => _values['status']!;
  String get removeFromCompare => _values['removeFromCompare']!;
  String get alreadyCompared => _values['alreadyCompared']!;
  String get saveError => _values['saveError']!;
  String get storageAccessTitle => _values['storageAccessTitle']!;
  String get storageAccessBody => _values['storageAccessBody']!;
  String get storageAccessAllow => _values['storageAccessAllow']!;
  String get internalStorage => _values['internalStorage']!;

  /// "Building Type A" for building type letter [type].
  String buildingTypeName(String type) => _values['buildingTypeName']!.replaceAll('{type}', type);

  /// Apartment type name: the sheet's id in English ("2BR"), the bedrooms in
  /// Arabic ("غرفتا نوم"), as in the compare frames (Figma 689:3472).
  String unitTypeName(String unitType) {
    final n = unitType.replaceAll(RegExp(r'\D'), '');
    return switch (n) {
      '' => unitType,
      '1' => _values['unitType1']!,
      '2' => _values['unitType2']!,
      _ => _values['unitTypeN']!.replaceAll('{n}', n),
    };
  }

  /// Masterplan amenity label, e.g. "Green Area 4"; [kind] is an
  /// `AmenityKind` name.
  String amenity(String kind, int? number) {
    final name = _values['amenity_$kind']!;
    return number == null ? name : '$name $number';
  }
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) => const ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppStrings> load(Locale locale) {
    final isArabic = locale.languageCode == 'ar';
    return SynchronousFuture(
      AppStrings._(locale, isArabic ? AppStrings._ar : AppStrings._en),
    );
  }

  @override
  bool shouldReload(_AppStringsDelegate old) => false;
}
