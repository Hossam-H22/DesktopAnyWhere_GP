// import 'package:flutter/material.dart';
//
// class FileComponent extends StatefulWidget {
//   final String fileName;
//
//   const FileComponent({
//     Key? key,
//     required this.fileName,
//   }) : super(key: key);
//
//   @override
//   State<FileComponent> createState() => _FileComponentState();
// }
//
// class _FileComponentState extends State<FileComponent> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.black87,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 2,
//             ),
//             child: Column(
//               //crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     const Icon(Icons.file_present_rounded,
//                         color: Colors.white, size: 35),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 10.0),
//                       child: Text(
//                         widget.fileName,
//                         style: const TextStyle(
//                           fontSize: 25,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 2,
//                 ),
//               ],
//             ),
//           ),
//           Row(
//             children: [
//               IconButton(
//                 onPressed: () {
//                   // Navigator.push(
//                   //   context,
//                   //   MaterialPageRoute(
//                   //     //builder: (context) => const ,
//                   //   ),
//                   //);
//                 },
//                 icon: const Icon(
//                   Icons.more_horiz,
//                   size: 35,
//                   color: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
