import 'package:flutter/material.dart';

class QAScreen extends StatefulWidget {
  const QAScreen({super.key});

  @override
  State<QAScreen> createState() => _QAScreenState();
}

class _QAScreenState extends State<QAScreen> {
  final List<QAItem> _qaItems = [
    QAItem(
      question: 'How do I calculate my EMI?',
      answer: 'You can use the EMI Calculator feature in the app. Navigate to the Home screen and tap on "EMI Calculator". Enter your loan amount, interest rate, and tenure to get instant EMI calculations with detailed breakdowns.',
    ),
    QAItem(
      question: 'What is CIBIL Score?',
      answer: 'CIBIL Score is a 3-digit numeric summary of your credit history. It ranges from 300 to 900, with scores above 750 considered excellent. You can check your CIBIL score using the "CIBIL Score Check" feature in the app.',
    ),
    QAItem(
      question: 'How do I apply for a loan?',
      answer: 'Browse available loans by tapping on the loan cards (25K, 50K, or 1 Lakh) on the home screen. Select a loan that suits your needs and tap "Apply Now" to be redirected to the lender\'s website for application.',
    ),
    QAItem(
      question: 'Can I save my loan calculations?',
      answer: 'Yes! All your calculations are automatically saved in the app. You can view your calculation history by tapping the history icon in the app bar or navigating to the History section.',
    ),
    QAItem(
      question: 'How accurate are the commodity prices?',
      answer: 'Commodity prices are fetched from reliable sources and updated regularly. Prices for fuel (Petrol, Diesel, LPG) are location-specific based on your selected state and city. Financial instruments like Silver and USD/INR are updated in real-time.',
    ),
    QAItem(
      question: 'What calculators are available?',
      answer: 'The app includes multiple calculators: EMI Calculator, Income Tax Calculator, GST Calculator, VAT Calculator, PPF Calculator, SIP Calculator, and Cash Counter. All are accessible from the Home screen.',
    ),
    QAItem(
      question: 'How do I change the app language?',
      answer: 'Go to Profile screen, tap on "Language" option, and select your preferred language (English or Hindi). The app will immediately switch to the selected language.',
    ),
    QAItem(
      question: 'Can I use the app offline?',
      answer: 'Some features like calculators work offline. However, features like loan listings, commodity prices, and CIBIL score checking require an active internet connection.',
    ),
    QAItem(
      question: 'How do I filter loans by category?',
      answer: 'When viewing loan listings, you\'ll see category filter chips at the top. Tap on any category (like "Home Loan", "Personal Loan") to filter loans. Tap "All" to see all available loans.',
    ),
    QAItem(
      question: 'Is my data secure?',
      answer: 'Yes, we take data security seriously. All calculations are stored locally on your device. We do not share your personal information with third parties. For loan applications, you\'ll be redirected to the official lender websites.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF5DADE2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Questions & Answers',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _qaItems.length,
        itemBuilder: (context, index) {
          return _buildQAItem(_qaItems[index], index);
        },
      ),
    );
  }

  Widget _buildQAItem(QAItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getColorForIndex(index).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: _getColorForIndex(index),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: Text(
          item.question,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        iconColor: _getColorForIndex(index),
        collapsedIconColor: Colors.grey.shade600,
        children: [
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: _getColorForIndex(index),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.answer,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      const Color(0xFF5DADE2), // Blue
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.deepOrange,
    ];
    return colors[index % colors.length];
  }
}

class QAItem {
  final String question;
  final String answer;

  QAItem({
    required this.question,
    required this.answer,
  });
}

