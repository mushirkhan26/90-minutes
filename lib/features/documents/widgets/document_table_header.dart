import 'package:flutter/material.dart';

class DocumentTableHeader extends StatelessWidget {
  const DocumentTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    const headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.black,
      fontSize: 14,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text('Document', style: headerStyle)),
          Expanded(flex: 2, child: Center(child: Text('Status', style: headerStyle))),
          Expanded(flex: 2, child: Center(child: Text('Type', style: headerStyle))),
          Expanded(flex: 2, child: Center(child: Text('Actions', style: headerStyle))),
        ],
      ),
    );
  }
}
