// // lib/core/services/echo_service.dart


// class EchoService {
//   static Echo? _echo;
  
//   static Future<Echo> initialize({
//     required String token,
//     required String userId,
//   }) async {
//     if (_echo != null) return _echo!;
    
//     print('🚀 Initializing Laravel Echo...');
    
//     // تأكد من الحصول على المعلومات الصحيحة من الباكند:
//     // Pusher Key, Pusher Cluster, Host
//     final options = PusherOptions(
//       cluster: 'eu', // أو القيمة الصحيحة من الباكند
//       host: 'mirsoc.com', // Base URL
//       port: null, // أو 6001 إذا كنت تستخدم Reverb/Soketi
//       encrypted: true,
//     );
    
//     final pusherClient = PusherClient(
//       'YOUR_PUSHER_KEY_HERE', // اسأل الباكند عن هذه القيمة
//       options,
//       enableLogging: true,
//     );
    
//     _echo = Echo(
//       client: pusherClient,
//       broadcaster: 'pusher',
//       csrfToken: null,
//       host: 'https://mirsoc.com',
//       namespace: 'App.Events', // تأكد من هذا من الباكند
//       auth: {
//         'headers': {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       },
//       authEndpoint: 'https://mirsoc.com/broadcasting/auth',
//     );
    
//     print('✅ Laravel Echo initialized for user $userId');
//     return _echo!;
//   }
  
//   static Echo? get instance => _echo;
  
//   static void disconnect() {
//     _echo?.disconnect();
//     _echo = null;
//     print('🔌 Laravel Echo disconnected');
//   }
// }