import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../firebase_options.dart';
// عند تفعيل تحديث الـ token تلقائياً، أعِد استيراد:
// import '../services/http/apis/user_api.dart';
import '../widgets/order_alert_screen.dart';
import 'package:ma7lola_vendor/view/screens/main_screen/tabs/winch/winch_order_details_screen.dart';
import 'package:ma7lola_vendor/view/screens/main_screen/tabs/emergency/emergency_order_details_screen.dart';
import 'package:ma7lola_vendor/view/screens/main_screen/tabs/my_orders_tab/order_details_screen.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final helper = NotificationsHelper();
  await helper._ensureBackgroundReady();
  await helper.processIncomingMessage(message);
}
class NotificationsHelper {

  static final NotificationsHelper _instance = NotificationsHelper._internal();
  factory NotificationsHelper() => _instance;

  NotificationsHelper._internal();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  static const String orderChannelId = 'order_alerts_channel';
  static const String visitChannelId = 'visit_alerts_channel';

  /// معرف ثابت — كل إشعار جديد يستبدل السابق (إشعار واحد فقط في الشريط)
  static const int _alertNotificationId = 9001;

  /// نمط اهتزاز قوي ومكرر
  static final Int64List _strongVibrationPattern = Int64List.fromList([
    0, 1000, 300, 1000, 300, 1000, 300, 1000, 300, 1000, 300, 1500,
  ]);

  static Map<String, dynamic>? _pendingAlertData;
  static String? _lastProcessedAlertKey;
  static DateTime? _lastProcessedAt;
  static bool _isAlertScreenOpen = false;
  static String? _openAlertOrderKey;

  // Global Navigator Key للوصول للـ context من أي مكان
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Initialize Firebase Messaging and set up listeners
  Future<void> initialize() async {
    await _initializeFirebase();
    await _initializeLocalNotifications();

    // طلب إعفاء من تحسين البطارية — يساعد على استمرار وصول الإشعارات
    // على أجهزة OEM (شاومي/أوبو/هواوي...) التي تقتل التطبيقات في الخلفية.
    await _requestBatteryOptimizationExemption();

    // Setup Firebase Cloud Messaging (FCM) listeners for incoming messages
    _setupFCMListeners();

    // Get FCM token (optional, if you want to store or use it)
    await _getFCMToken();
  }

  /// طلب استثناء التطبيق من تحسين البطارية (مرة واحدة طالما مرفوض)
  Future<void> _requestBatteryOptimizationExemption() async {
    try {
      if (await Permission.ignoreBatteryOptimizations.isDenied) {
        await Permission.ignoreBatteryOptimizations.request();
      }
    } catch (e) {
      print('⚠️ تعذّر طلب إعفاء تحسين البطارية: $e');
    }
  }

  /// يُستدعى بعد أول إطار عندما يكون الـ Navigator جاهزاً
  Future<void> handleLaunchNotification() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationOpenedApp(initialMessage);
    }
  }

  /// Initialize Firebase
  Future<void> _initializeFirebase() async {
    // التحقق إذا كان Firebase مُهيأ بالفعل
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      if (e.toString().contains('duplicate-app')) {
        print('✅ Firebase already initialized');
      } else {
        rethrow;
      }
    }
    
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request notification permissions for iOS
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iOSSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );
    
    await flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();

    // إنشاء قناة إشعارات عالية الأهمية للطلبات (تظهر من فوق الشاشة + صوت + اهتزاز)
    final AndroidNotificationChannel orderChannel = AndroidNotificationChannel(
      orderChannelId,
      'طلبات التوصيل',
      description: 'إشعارات الطلبات الجديدة للمندوبين',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      vibrationPattern: _strongVibrationPattern,
      showBadge: true,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
    );

    // إنشاء قناة إشعارات للزيارات
    final AndroidNotificationChannel visitChannel = AndroidNotificationChannel(
      visitChannelId,
      'مواعيد الزيارات',
      description: 'تنبيهات مواعيد الزيارات للمندوبين',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      vibrationPattern: _strongVibrationPattern,
      showBadge: true,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 165, 0),
    );

    await androidPlugin?.createNotificationChannel(orderChannel);
    await androidPlugin?.createNotificationChannel(visitChannel);
  }

  /// تهيئة الإشعارات المحلية في الـ background isolate
  Future<void> _ensureBackgroundReady() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iOSSettings = DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(settings);

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    final AndroidNotificationChannel orderChannel = AndroidNotificationChannel(
      orderChannelId,
      'طلبات التوصيل',
      description: 'إشعارات الطلبات الجديدة للمندوبين',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      vibrationPattern: _strongVibrationPattern,
      showBadge: true,
    );

    final AndroidNotificationChannel visitChannel = AndroidNotificationChannel(
      visitChannelId,
      'مواعيد الزيارات',
      description: 'تنبيهات مواعيد الزيارات للمندوبين',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      vibrationPattern: _strongVibrationPattern,
      showBadge: true,
    );

    await androidPlugin?.createNotificationChannel(orderChannel);
    await androidPlugin?.createNotificationChannel(visitChannel);
  }

  /// Setup listeners for Firebase Cloud Messaging
  void _setupFCMListeners() {
    // Handle incoming notifications when the app is in the foreground
    FirebaseMessaging.onMessage.listen(_handleIncomingNotification);

    // ملاحظة: onBackgroundMessage يتم تسجيله في main() قبل runApp مباشرة
    // عشان يشتغل والتطبيق مقفول تماماً.

    // Handle when notification is tapped
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpenedApp);

    // تحديث الـ token تلقائياً عند تجديده وإرساله للسيرفر
    FirebaseMessaging.instance.onTokenRefresh.listen(_syncFcmToken);
  }

  /// Handle when notification is opened from background (عند الضغط على الإشعار)
  void _handleNotificationOpenedApp(RemoteMessage message) {
    print("📱 فتح التطبيق من الإشعار: ${message.data}");
    if (message.data.isEmpty) return;
    _openDetailsAndAlertFromData(message.data);
  }

  /// هل يستحق هذا الإشعار فتح شاشة التنبيه الكاملة؟
  /// - ونش/طوارئ: عند طلب جديد (new) أو بعد قبول العميل (accepted/preparing/on_the_run)
  /// - قطع غيار/إطارات/بطاريات: الطلبات الجديدة فقط (new)
  static bool _isActionableAlert(Map<String, dynamic> data) {
    if (data.isEmpty) return false;
    final status = data['status']?.toString() ?? '';
    final type = data['type']?.toString() ?? '';
    final isWinchOrEmergency = type == 'winch' || type == 'emergency';

    if (isWinchOrEmergency) {
      return status == 'new' ||
          status == 'accepted' ||
          status == 'preparing' ||
          status == 'on_the_run';
    }
    return status == 'new';
  }

  static String _alertDedupeKey(Map<String, dynamic> data) {
    final orderId = data['order_vendor_id']?.toString() ?? '';
    final status = data['status']?.toString() ?? '';
    final eventType = data['event_type']?.toString() ?? '';
    return '$orderId|$status|$eventType';
  }

  bool _shouldProcessAlert(Map<String, dynamic> data) {
    if (!_isActionableAlert(data)) return false;
    final key = _alertDedupeKey(data);
    final now = DateTime.now();
    if (_lastProcessedAlertKey == key &&
        _lastProcessedAt != null &&
        now.difference(_lastProcessedAt!) < const Duration(seconds: 5)) {
      return false;
    }
    _lastProcessedAlertKey = key;
    _lastProcessedAt = now;
    return true;
  }

  void _openAlertFromData(Map<String, dynamic> data) {
    if (!_isActionableAlert(data)) return;
    _pendingAlertData = Map<String, dynamic>.from(data);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showFullScreenOrderAlert(data);
    });
  }

  /// عند الضغط على الإشعار: نفتح صفحة التفاصيل المناسبة للنوع،
  /// وفوقها شاشة التنبيه (لو الطلب يتطلب إجراء). إغلاق التنبيه يرجّع للتفاصيل.
  void _openDetailsAndAlertFromData(Map<String, dynamic> data) {
    if (data.isEmpty) return;
    _pendingAlertData = Map<String, dynamic>.from(data);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToDetails(data);
      if (_isActionableAlert(data)) {
        showFullScreenOrderAlert(data);
      }
    });
  }

  /// التنقل لصفحة تفاصيل الطلب حسب نوع الخدمة
  static void _navigateToDetails(Map<String, dynamic> data) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final nd = NotificationData.fromMap(data);
    final type = nd.type;
    final isWinchOrEmergency = type == 'winch' || type == 'emergency';

    // ونش/طوارئ يستخدمان order_id، أما قطع الغيار فتستخدم order_vendor_id
    final id = isWinchOrEmergency
        ? (int.tryParse(nd.orderId) ?? int.tryParse(nd.orderVendorId))
        : (int.tryParse(nd.orderVendorId) ?? int.tryParse(nd.orderId));
    if (id == null) return;

    final phone = nd.customerPhone ?? '';
    Widget? page;
    switch (type) {
      case 'winch':
        page = WinchOrderDetails(orderNum: id, userNum: phone, vendorName: '');
        break;
      case 'emergency':
        page =
            EmergencyOrderDetails(orderNum: id, vendorNum: phone, vendorName: '');
        break;
      case 'battery':
        page = OrderDetails(orderNum: id, orderType: 0);
        break;
      case 'tire':
        page = OrderDetails(orderNum: id, orderType: 1);
        break;
      case 'car-parts':
        page = OrderDetails(orderNum: id, orderType: 2);
        break;
    }
    if (page == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page!),
    );
  }

  /// Handle incoming FCM notifications when the app is in the foreground
  void _handleIncomingNotification(RemoteMessage message) {
    processIncomingMessage(message, showFullScreen: true);
  }

  /// معالجة الإشعار الوارد (foreground / background / مغلق)
  Future<void> processIncomingMessage(
    RemoteMessage message, {
    bool showFullScreen = false,
  }) async {
    // لا نتجاهل إلا الرسائل الفارغة تماماً
    if (message.data.isEmpty && message.notification == null) return;

    final data = message.data;
    final actionable = _isActionableAlert(data);
    final hasContext = navigatorKey.currentContext != null;

    if (data.isNotEmpty) {
      _pendingAlertData = Map<String, dynamic>.from(data);
    }

    // التطبيق مفتوح + تنبيه طلب فعلي: افتح صفحة التنبيه مباشرة
    // (الصوت والاهتزاز من الشاشة نفسها، بدون إشعار في الشريط)
    if (showFullScreen && hasContext && actionable) {
      if (_shouldProcessAlert(data)) {
        _openAlertFromData(data);
      }
      return;
    }

    final title = message.notification?.title ??
        data['title']?.toString() ??
        'طلب توصيل جديد 🚨';
    final body = message.notification?.body ??
        data['body']?.toString() ??
        'لديك إشعار جديد يحتاج انتباهك';
    final type = _resolveNotificationType(data, title, body);

    // الخلفية/مغلق: اعرض إشعاراً في الشريط لكل رسالة واردة
    // (لا نكرر إذا كان FCM عرض الإشعار بالفعل من خلال notification payload)
    final fcmAlreadyDisplayed = message.notification != null;
    if (!fcmAlreadyDisplayed) {
      await _showHighPriorityNotification(
        title,
        body,
        type,
        alertData: data,
      );
    }

    // لو التطبيق رجع للواجهة (background غير مغلق) وفيه تنبيه فعلي افتح الشاشة
    if (hasContext && actionable && _shouldProcessAlert(data)) {
      _openAlertFromData(data);
    }
  }

  String _resolveNotificationType(
    Map<String, dynamic> data,
    String title,
    String body,
  ) {
    final combined = '$title $body'.toLowerCase();
    if (combined.contains('زيارة') || combined.contains('visit')) {
      return 'visit';
    }
    return 'order';
  }

  /// Handle FCM data messages (background or foreground)
  Future<void> _handleDataMessage(Map<String, dynamic> data) async {
    final title = data['title']?.toString() ?? 'طلب توصيل جديد 🚨';
    final body = data['body']?.toString() ?? 'لديك إشعار جديد يحتاج انتباهك';
    final type = _resolveNotificationType(data, title, body);

    await _showHighPriorityNotification(title, body, type);

    if (navigatorKey.currentContext != null) {
      showFullScreenOrderAlert(data);
    }
  }
  
  // /// تحديد نوع الإشعار (طلب أو زيارة)
  // String _getNotificationType(RemoteNotification data) {
  //   // يمكن التحقق من العنوان أو محتوى الإشعار
  //   final title = data.title?.toLowerCase() ?? '';
  //   final body = data.body?.toLowerCase() ?? '';
  //
  //   if (title.contains('زيارة') || title.contains('visit') ||
  //       body.contains('زيارة') || body.contains('visit')) {
  //     return 'visit';
  //   }
  //   return 'order';
  // }

  /// عرض Full Screen Alert للطلب الجديد
  static void showFullScreenOrderAlert(Map<String, dynamic> data) {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    if (!_isActionableAlert(data)) return;

    final orderKey = _alertDedupeKey(data);
    if (_isAlertScreenOpen && _openAlertOrderKey == orderKey) return;

    _isAlertScreenOpen = true;
    _openAlertOrderKey = orderKey;

    final notificationData = NotificationData.fromMap(data);
    final legacyOrderId = notificationData.orderId.isNotEmpty
        ? notificationData.orderId
        : notificationData.orderVendorId;

    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => OrderAlertScreen(
          notificationData: notificationData,
          notificationTitle: data['title']?.toString(),
          notificationBody: data['body']?.toString(),
          orderId: legacyOrderId,
          orderReference: data['title']?.toString() ?? 'N/A',
          customerName: extractCustomerName(data['body']?.toString()),
          location: extractLocation(data['body']?.toString()),
          orderDetails: data['body']?.toString(),
        ),
        fullscreenDialog: true,
      ),
    )
        .then((_) {
      _isAlertScreenOpen = false;
      _openAlertOrderKey = null;
    });
  }

  /// عرض Full Screen Alert للزيارة
  // void _showFullScreenVisitAlert(RemoteNotification data) {
  //   final context = navigatorKey.currentContext;
  //   if (context != null) {
  //     // استخراج visit_id من الإشعار
  //     final visitId = _extractVisitId(data.title);
  //
  //     // محاولة إيجاد VisitDetailsData من القائمة
  //     // VisitDetailsData? visitData = _findVisitData(visitId);
  //
  //     // // فتح شاشة Full Screen Alert للزيارة
  //     // Navigator.of(context).push(
  //     //   MaterialPageRoute(
  //     //     builder: (context) => VisitAlertScreen(
  //     //       visitId: visitId,
  //     //       businessName: visitData?.businessName ?? _extractBusinessName(data.body),
  //     //       customerName: visitData?.customerName ?? _extractCustomerName(data.body),
  //     //       location: visitData?.customerLocation ?? _extractLocation(data.body),
  //     //       visitDate: visitData?.createdAt ?? _extractVisitDate(data.body),
  //     //       visitData: visitData, // تمرير البيانات الكاملة إذا وُجدت
  //     //     ),
  //     //     fullscreenDialog: true,
  //     //   ),
  //     // );
  //   }
  //
  //   // عرض notification عادي كـ backup
  //   _showHighPriorityNotification(data.title, data.body, 'visit');
  // }

  /// استخراج order_vendor_id من العنوان
  String _extractOrderId(String? title) {
    if (title == null) return 'unknown';
    // مثال: "ORD-12345" → "12345"
    final parts = title.split('-');
    return parts.length > 1 ? parts.last : title;
  }
  
  /// استخراج visit_id من العنوان
  String _extractVisitId(String? title) {
    if (title == null) return 'unknown';
    // مثال: "VISIT-12345" → "12345" أو استخراج الأرقام من النص
    final parts = title.split('-');
    if (parts.length > 1) return parts.last;
    
    // محاولة استخراج الأرقام من النص
    final numbers = RegExp(r'\d+').firstMatch(title);
    return numbers?.group(0) ?? title;
  }

  // /// محاولة إيجاد OrderModel من القائمة الموجودة
  // OrderModel? _findOrderModel(String orderId) {
  //   try {
  //     // البحث في الطلبات الجديدة
  //     final order = OrdersServices.dataNew.firstWhere(
  //       (order) => order.id.toString() == orderId || order.reference == orderId,
  //       orElse: () => throw Exception('Order not found'),
  //     );
  //     return order;
  //   } catch (e) {
  //     print('⚠️ لم يتم العثور على الطلب في القائمة المحلية: $orderId');
  //     return null;
  //   }
  // }
  //
  // /// محاولة إيجاد VisitDetailsData من القائمة الموجودة
  // VisitDetailsData? _findVisitData(String visitId) {
  //   try {
  //     // البحث في الزيارات (يمكن تعديله حسب كيفية تخزين الزيارات)
  //     // افترض أن هناك قائمة VisitsServices.visits
  //     // final visit = VisitsServices.visits.firstWhere(
  //     //   (visit) => visit.id.toString() == visitId,
  //     //   orElse: () => throw Exception('Visit not found'),
  //     // );
  //     // return visit;
  //
  //     print('⚠️ لم يتم العثور على الزيارة في القائمة المحلية: $visitId');
  //     return null;
  //   } catch (e) {
  //     print('⚠️ خطأ في البحث عن الزيارة: $e');
  //     return null;
  //   }
  // }

  /// استخراج اسم العميل من body الإشعار
  static String extractCustomerName(String? body) {
    if (body == null) return 'عميل جديد';
    // TODO: تحسين الاستخراج بناءً على صيغة الإشعار من Backend
    return body.split(':').first.trim();
  }
  
  /// استخراج اسم المنشأة التجارية من body الإشعار
  String _extractBusinessName(String? body) {
    if (body == null) return 'غير محدد';
    // TODO: تحسين الاستخراج بناءً على صيغة الإشعار من Backend
    final parts = body.split('|');
    return parts.isNotEmpty ? parts.first.trim() : 'غير محدد';
  }

  /// استخراج الموقع من body الإشعار
  static String extractLocation(String? body) {
    if (body == null) return 'غير محدد';
    // TODO: تحسين الاستخراج بناءً على صيغة الإشعار من Backend
    final parts = body.split(':');
    return parts.length > 1 ? parts[1].trim() : 'غير محدد';
  }
  
  /// استخراج موعد الزيارة من body الإشعار
  String _extractVisitDate(String? body) {
    if (body == null) return 'غير محدد';
    // TODO: تحسين الاستخراج بناءً على صيغة الإشعار من Backend
    final dateMatch = RegExp(r'\d{4}-\d{2}-\d{2}').firstMatch(body ?? '');
    return dateMatch?.group(0) ?? 'غير محدد';
  }

  String _encodeNotificationPayload(String type, Map<String, dynamic> data) {
    return jsonEncode({'type': type, 'data': data});
  }

  Map<String, dynamic>? _decodeNotificationPayload(String? payload) {
    if (payload == null || payload.isEmpty) return _pendingAlertData;
    try {
      final decoded = jsonDecode(payload) as Map<String, dynamic>;
      final data = decoded['data'];
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
    } catch (_) {}
    return _pendingAlertData;
  }

  /// عرض إشعار ذو أولوية عالية — يظهر من فوق الشاشة مع صوت واهتزاز قوي
  Future<void> _showHighPriorityNotification(
    String? title,
    String? body,
    String type, {
    Map<String, dynamic>? alertData,
  }) async {
    await flutterLocalNotificationsPlugin.cancel(_alertNotificationId);
    final isVisit = type == 'visit';
    final channelId = isVisit ? visitChannelId : orderChannelId;
    final channelName = isVisit ? 'مواعيد الزيارات' : 'طلبات التوصيل';
    final channelDesc = isVisit
        ? 'تنبيهات مواعيد الزيارات للمندوبين'
        : 'إشعارات الطلبات الجديدة للمندوبين';

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      vibrationPattern: _strongVibrationPattern,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      ticker: isVisit ? 'موعد زيارة قريب 🚨' : 'طلب توصيل جديد 🚨',
      autoCancel: true,
      ongoing: false,
      onlyAlertOnce: false,
      channelAction: AndroidNotificationChannelAction.createIfNotExists,
      additionalFlags: Int32List.fromList([4]), // FLAG_INSISTENT — يكرر الصوت
      ledOnMs: 1000,
      ledOffMs: 500,
      styleInformation: BigTextStyleInformation(
        body ?? '',
        contentTitle: title,
        summaryText: isVisit ? 'موعد زيارة' : 'طلب جديد',
      ),
    );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true, 
      //sound: 'order_alert.caf', // صوت مخصص لـ iOS
      categoryIdentifier: 'ALERT_CATEGORY',
      interruptionLevel: InterruptionLevel.critical, // مهم جداً لـ iOS
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    final data = alertData ?? _pendingAlertData ?? {};
    final payload = _encodeNotificationPayload(type, data);

    await flutterLocalNotificationsPlugin.show(
      _alertNotificationId,
      title ?? (isVisit ? "موعد زيارة قريب 🚨" : "طلب توصيل جديد 🚨"),
      body ?? (isVisit ? "لديك زيارة محددة تحتاج موافقتك" : "لديك طلب جديد يحتاج موافقتك"),
      platformDetails,
      payload: payload,
    );
  }

  /// معالجة النقر على الإشعار المحلي — فتح صفحة التفاصيل + التنبيه
  void _onNotificationTapped(NotificationResponse response) {
    final alertData = _decodeNotificationPayload(response.payload);
    if (alertData == null || alertData.isEmpty) return;
    _openDetailsAndAlertFromData(alertData);
  }

  // /// Background message handler (to handle notifications when the app is in the background)
  // static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  //   final helper = NotificationsHelper();
  //   if (message.notification!=null) {
  //     helper._handleDataMessage(message.notification!);
  //   }
  // }

  /// Get FCM token ويرسله للسيرفر إذا كان المستخدم مسجّلاً
  Future<String?> _getFCMToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    print("FCM Token: $token");
    await _syncFcmToken(token);
    return token;
  }

  /// إرسال الـ FCM token للسيرفر عند تجديده تلقائياً.
  ///
  /// ⚠️ لا يوجد endpoint في الباك حالياً لتحديث الـ token بشكل مستقل.
  /// الـ token يُرسَل وقت تسجيل الدخول فقط (UserApi.login -> "fcm_token").
  /// بمجرد إضافة endpoint في الباك، فعّل السطر داخل try أدناه فقط.
  Future<void> _syncFcmToken(String? token) async {
    if (token == null || token.isEmpty) return;
    print('🔄 FCM token تجدّد: $token');
    // try {
    //   await UserApi.updateFcmToken(token: token);
    // } catch (e) {
    //   print('⚠️ تعذّر تحديث FCM token على السيرفر: $e');
    // }
  }

  /// Unsubscribe from topic (optional, if you are using FCM topics)
  Future<void> unsubscribeFromTopic(String topic) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.unsubscribeFromTopic(topic);
    print("Unsubscribed from topic: $topic");
  }

  /// Subscribe to a topic (optional, if you are using FCM topics)
  Future<void> subscribeToTopic(String topic) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.subscribeToTopic(topic);
    print("Subscribed to topic: $topic");
  }
  void handleBackgroundNotification(RemoteMessage message) {
    processIncomingMessage(message);
  }


}
