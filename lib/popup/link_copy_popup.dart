import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkCopyPopup extends StatelessWidget {
  final String link;
  Uri? url;

  LinkCopyPopup(this.link, {super.key});

  void copyToClipboard(Uri url, context) {
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('링크가 복사되었습니다.')),
    );
  }

  void openLink(Uri url, context) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('링크를 열 수 없습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    url = Uri.parse(link);

    return AlertDialog(
      title: Text('오픈채팅방 링크'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              openLink(url!, context); // 링크를 열기
            },
            child: Text(
              link,
              style: TextStyle(
                color: Colors.blue, // 링크 스타일을 부여
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('취소'),
        ),
        TextButton(
          onPressed: () {
            copyToClipboard(url!, context);
            Navigator.of(context).pop();
          },
          child: Text('복사'),
        ),
      ],
    );
  }
}
