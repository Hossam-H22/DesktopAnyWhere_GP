// import 'package:desktop_anywhere/modules/Liveview/liveview.dart';
// import 'package:desktop_anywhere/modules/desktopdata/desktopdata.dart';
// import 'package:desktop_anywhere/modules/homepage/HomePage.dart';
// import 'package:flutter/material.dart';
//
// class ChoseTheOperation extends StatelessWidget {
//   static bool transfer = false;
//   static bool remote = false;
//
//   ChoseTheOperation({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Padding(
//             padding: EdgeInsets.all(25.0),
//             child: Column(
//               children: [
//                 Text(
//                   'Welcome to Desktop Anywhere !',
//                   style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 50,
//                       fontWeight: FontWeight.bold),
//                   textAlign: TextAlign.center,
//                 ),
//                 SizedBox(
//                   height: 15,
//                 ),
//                 Text(
//                   'Chose the wanted process',
//                   style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 25,
//                       fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             width: 350,
//             height: 57,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(
//                 10.0,
//               ),
//               color: Colors.white,
//             ),
//             child: MaterialButton(
//               onPressed: () {
//                 transfer = true;
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => HomePage()),
//                 );
//               },
//               textColor: Colors.black,
//               child: const Text(
//                 'Transfer Files',
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 10),
//           Container(
//             width: 350,
//             height: 57,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(
//                 10.0,
//               ),
//               color: Colors.white,
//             ),
//             child: MaterialButton(
//               onPressed: () {
//                 remote = true;
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => HomePage()),
//                 );
//               },
//               textColor: Colors.black,
//               child: const Text(
//                 'Remote Control Session',
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
