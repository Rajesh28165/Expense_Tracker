import 'package:kharchasutra/presentation/widgets/generalComponents.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kharchasutra/constants/extension.dart';
import '../../../constants/app_constants.dart';
import '../../../util/colors.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: AppConstants.supportEmail,
    );

    try {
      await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WidgetColors.page,
      appBar: context.customAppBar(title: 'Support'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.mail_outline_rounded,
              size: 52, 
              color: WidgetColors.indigo400
            ),
            SizedBox(height: context.getPercentHeight(2)),
            Text(
              'Reach us at',
              style: GoogleFonts.sora(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: WidgetColors.ink3,
              ),
            ),
            SizedBox(height: context.getPercentHeight(1)),
            GestureDetector(
              onTap: _launchEmail,
              child: Text(
                AppConstants.supportEmail,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: WidgetColors.indigo400,
                  decoration: TextDecoration.underline,
                  decorationColor: WidgetColors.indigo400,
                )
              )
            )
          ]
        )
      )
    );
  }
}