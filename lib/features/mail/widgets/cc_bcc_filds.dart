// // 📁 lib/features/mail/widgets/cc_bcc_fields.dart
// import 'package:flutter/material.dart';
// import 'package:hrtz_hrms/widgets/custom_textfield.dart';
//
// class CcBccFields extends StatelessWidget {
//   final bool showCcBcc;
//   final TextEditingController ccController;
//   final TextEditingController bccController;
//   final VoidCallback onToggle;
//   final ValueChanged<String> onCcChanged;
//   final ValueChanged<String> onBccChanged;
//
//   const CcBccFields({
//     super.key,
//     required this.showCcBcc,
//     required this.ccController,
//     required this.bccController,
//     required this.onToggle,
//     required this.onCcChanged,
//     required this.onBccChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         /// Toggle Button
//         TextButton.icon(
//           onPressed: onToggle,
//           icon: Icon(
//             showCcBcc ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
//             color: Colors.blueAccent,
//           ),
//           label: Text(
//             showCcBcc ? 'Hide Cc/Bcc' : 'Add Cc/Bcc',
//             style: const TextStyle(color: Colors.blueAccent),
//           ),
//         ),
//
//         /// Animated Fields
//         AnimatedCrossFade(
//           duration: const Duration(milliseconds: 300),
//           crossFadeState: showCcBcc ? CrossFadeState.showFirst : CrossFadeState.showSecond,
//           firstChild: Column(
//             children: [
//               CustomTextField(controller: ccController, hintText: 'Cc', onChanged: onCcChanged),
//               const SizedBox(height: 8),
//               CustomTextField(controller: bccController, hintText: 'Bcc', onChanged: onBccChanged),
//             ],
//           ),
//           secondChild: const SizedBox.shrink(),
//         ),
//       ],
//     );
//   }
// }
