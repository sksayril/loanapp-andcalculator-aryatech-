import 'package:flutter/material.dart';
import 'package:emi_calculatornew/providers/theme_provider.dart';
import 'package:emi_calculatornew/services/disclaimer_prefs.dart';

class DisclaimerScreen extends StatefulWidget {
  final WidgetBuilder nextScreenBuilder;
  final WidgetBuilder? splashAfterAgreeBuilder;

  const DisclaimerScreen({
    super.key,
    required this.nextScreenBuilder,
    this.splashAfterAgreeBuilder,
  });

  @override
  State<DisclaimerScreen> createState() => _DisclaimerScreenState();
}

class _DisclaimerScreenState extends State<DisclaimerScreen> {
  bool _showHindi = false;

  static const String _englishDisclaimer = '''
This app does not provide any type of loan or financial service.
We only provide general information and guidance related to loans and financial topics.

We are not affiliated with any bank, NBFC, or financial institution.
We do not act as an agent, partner, or intermediary for any loan provider.

We do not promote or perform any kind of affiliate marketing.
All information provided in this app is for educational and informational purposes only.

Users are advised to verify all details from official sources before making any financial decision.
''';

  static const String _hindiDisclaimer = '''
यह ऐप किसी भी प्रकार का लोन या वित्तीय सेवा प्रदान नहीं करता है।
हम केवल लोन और वित्तीय विषयों से संबंधित सामान्य जानकारी और मार्गदर्शन (Guidance) प्रदान करते हैं।

हम किसी भी बैंक, NBFC या वित्तीय संस्था से जुड़े हुए नहीं हैं।
हम किसी भी लोन प्रदाता के एजेंट, पार्टनर या मध्यस्थ (Intermediary) के रूप में कार्य नहीं करते हैं।

हम किसी भी प्रकार की एफिलिएट (Affiliate) सेवा या प्रमोशन नहीं करते हैं।
इस ऐप में दी गई सभी जानकारी केवल शैक्षिक और जानकारी के उद्देश्य से है।

किसी भी वित्तीय निर्णय लेने से पहले, उपयोगकर्ता स्वयं आधिकारिक स्रोतों से जानकारी की पुष्टि अवश्य करें।
''';

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);
    final text = _showHindi ? _hindiDisclaimer : _englishDisclaimer;

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.cardBackground,
        elevation: 0,
        title: Text(
          _showHindi ? 'अस्वीकरण' : 'Disclaimer',
          style: TextStyle(
            color: themeProvider.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_showHindi)
                    TextButton(
                      onPressed: () => setState(() => _showHindi = false),
                      child: const Text('English'),
                    ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => setState(() => _showHindi = true),
                    child: const Text('हिंदी'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  color: themeProvider.cardBackground,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      text,
                      style: TextStyle(
                        color: themeProvider.textSecondary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await DisclaimerPrefs.setAgreed();
                    if (!context.mounted) return;

                    // After Agree, go back to splash flow once (your splash
                    // will skip disclaimer since preference is saved).
                    final builder =
                        widget.splashAfterAgreeBuilder ?? widget.nextScreenBuilder;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: builder,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A5F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _showHindi ? 'सहमत' : 'Agree',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

