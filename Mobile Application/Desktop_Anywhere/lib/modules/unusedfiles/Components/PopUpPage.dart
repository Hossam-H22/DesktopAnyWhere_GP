// import 'package:flutter/material.dart';
//
// class PopUpPage extends StatelessWidget {
//   const PopUpPage(BuildContext context, {super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Center(
//         child: Text(
//           'Alert !',
//           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
//         ),
//       ),
//       content: const Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Text(
//             "Are you sure that you want to remove this device ?",
//             style: TextStyle(fontWeight: FontWeight.w400, fontSize: 19),
//           ),
//         ],
//       ),
//       actions: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             MaterialButton(
//               onPressed: () {},
//               child: const Text(
//                 'Yes',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.green,
//                   fontSize: 18,
//                 ),
//               ),
//             ),
//             MaterialButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text(
//                 'No',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.red,
//                   fontSize: 18,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
