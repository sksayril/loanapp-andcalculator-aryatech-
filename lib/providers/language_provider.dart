import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('languageCode') ?? 'en';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> setLanguage(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    notifyListeners();
  }

  static LanguageProvider of(BuildContext context) {
    return Provider.of<LanguageProvider>(context, listen: true);
  }
  
  static LanguageProvider ofWithoutListen(BuildContext context) {
    return Provider.of<LanguageProvider>(context, listen: false);
  }
}

// Translation strings
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    // Try to get from LanguageProvider first, then fallback to Localizations
    try {
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      return AppLocalizations(languageProvider.locale);
    } catch (e) {
      return Localizations.of<AppLocalizations>(context, AppLocalizations);
    }
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // English translations
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'Loan Sathi',
      'home': 'Home',
      'profile': 'Profile',
      'settings': 'Settings',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'language': 'Language',
      'history': 'History',
      'calculate': 'Calculate',
      'clear': 'Clear',
      'save': 'Save',
      'delete': 'Delete',
      'no_history': 'No calculation history',
      'loan_amount': 'Loan Amount',
      'interest_rate': 'Interest Rate',
      'tenure': 'Tenure',
      'emi': 'EMI',
      'total_payment': 'Total Payment',
      'total_interest': 'Total Interest',
      'principal': 'Principal',
      // Home Screen
      'cibil_score_check': 'CIBIL Score Check',
      'check_credit_score': 'Check your credit score instantly ',
      'loan_profile': 'Loans',
      'business_calculator': 'Advance Calculators',
      'tax_calculator': 'Tax Calculator',
      'income_tax_calculator': 'Income Tax Calculator',
      'calculate_tax_liability': 'Calculate your tax liability',
      'house_rent_calculator': 'House Rent Calculator',
      'calculate_house_rent': 'Estimate yearly rent expenses',
      'emi_calculator': 'EMI Calculator',
      'calculate_emi_charts': 'Calculate EMI with charts & schedule',
      // GST Calculator
      'gst_calculator': 'GST Calculator',
      'calculate_gst': 'Calculate GST',
      'add_remove_gst': 'Add or remove GST from amounts',
      'amount': 'Amount',
      'gst_rate': 'GST Rate (%)',
      'add_gst': 'Add GST',
      'remove_gst': 'Remove GST',
      'net_amount': 'Net Amount',
      'gst_amount': 'GST Amount',
      'total_amount': 'Total Amount',
      'amount_breakdown': 'Amount Breakdown',
      // EMI Calculator
      'loan_type': 'Loan Type',
      'home_loan': 'Home Loan',
      'personal_loan': 'Personal Loan',
      'car_loan': 'Car Loan',
      'education_loan': 'Education Loan',
      'business_loan': 'Business Loan',
      'loan_tenure': 'Loan Tenure',
      'years': 'Years',
      'months': 'Months',
      'emi_display_frequency': 'EMI Display Frequency',
      'monthly': 'Monthly',
      'quarterly': 'Quarterly',
      'yearly': 'Yearly',
      'enable_prepayment': 'Enable Prepayment/Part Payment',
      'prepayment_amount': 'Prepayment Amount (₹)',
      'prepayment_month': 'Prepayment Month',
      'enter_loan_amount': 'Enter loan amount',
      'enter_interest_rate': 'Enter interest rate',
      'enter_tenure': 'Enter tenure',
      'enter_prepayment_amount': 'Enter prepayment amount',
      'enter_month_number': 'Enter month number',
      'calculate_emi': 'Calculate EMI',
      'calculation_results': 'Calculation Results',
      'monthly_emi': 'Monthly EMI',
      'quarterly_emi': 'Quarterly EMI',
      'yearly_emi': 'Yearly EMI',
      'principal_vs_interest': 'Principal vs Interest',
      'yearly_payment_breakdown': 'Yearly Payment Breakdown',
      'outstanding_balance': 'Outstanding Balance Over Time',
      'amortization_schedule': 'Amortization Schedule',
      'month': 'Month',
      'balance': 'Balance',
      'emi_calculation_results': 'EMI Calculation Results',
      'detailed_breakdown': 'Detailed breakdown and charts',
      'export_pdf': 'Export as PDF',
      'share_results': 'Share Results',
      // Settings
      'app_settings': 'App Settings',
      'customize_experience': 'Customize your app experience',
      'profile_theme': 'Profile & Theme',
      'theme_mode': 'Theme Mode',
      'choose_theme': 'Choose light or dark mode',
      'select_language': 'Select Language',
      'choose_language': 'Choose your preferred language',
      'english': 'English',
      'hindi': 'हिंदी (Hindi)',
      'app_information': 'App Information',
      'app_version': 'App Version',
      // Common
      'close': 'Close',
      'cancel': 'Cancel',
      'ok': 'OK',
      'yes': 'Yes',
      'no': 'No',
      'please_enter_valid': 'Please enter valid values',
      'calculation_deleted': 'Calculation deleted',
      'history_cleared': 'History cleared',
      'clear_history': 'Clear History',
      'delete_all_calculations': 'Are you sure you want to delete all calculations?',
    },
    'hi': {
      'app_name': 'Loan Sathi',
      'home': 'होम',
      'profile': 'प्रोफ़ाइल',
      'settings': 'सेटिंग्स',
      'dark_mode': 'डार्क मोड',
      'light_mode': 'लाइट मोड',
      'language': 'भाषा',
      'history': 'इतिहास',
      'calculate': 'गणना करें',
      'clear': 'साफ करें',
      'save': 'सहेजें',
      'delete': 'हटाएं',
      'no_history': 'कोई गणना इतिहास नहीं',
      'loan_amount': 'ऋण राशि',
      'interest_rate': 'ब्याज दर',
      'tenure': 'अवधि',
      'emi': 'ईएमआई',
      'total_payment': 'कुल भुगतान',
      'total_interest': 'कुल ब्याज',
      'principal': 'मूलधन',
      // Home Screen
      'cibil_score_check': 'CIBIL स्कोर जांच',
      'check_credit_score': 'अपना क्रेडिट स्कोर तुरंत और मुफ्त में जांचें।',
      'loan_profile': 'तत्काल ऋण',
      'business_calculator': 'उन्नत कैलकुलेटर',
      'tax_calculator': 'टैक्स कैलकुलेटर',
      'income_tax_calculator': 'आयकर कैलकुलेटर',
      'calculate_tax_liability': 'अपनी कर देनदारी की गणना करें',
      'house_rent_calculator': 'मकान किराया कैलकुलेटर',
      'calculate_house_rent': 'वार्षिक किराया व्यय का अनुमान लगाएं',
      'emi_calculator': 'ईएमआई कैलकुलेटर',
      'calculate_emi_charts': 'चार्ट और अनुसूची के साथ ईएमआई की गणना करें',
      // GST Calculator
      'gst_calculator': 'GST कैलकुलेटर',
      'calculate_gst': 'GST की गणना करें',
      'add_remove_gst': 'राशि में GST जोड़ें या हटाएं',
      'amount': 'राशि',
      'gst_rate': 'GST दर (%)',
      'add_gst': 'GST जोड़ें',
      'remove_gst': 'GST हटाएं',
      'net_amount': 'शुद्ध राशि',
      'gst_amount': 'GST राशि',
      'total_amount': 'कुल राशि',
      'amount_breakdown': 'राशि विवरण',
      // EMI Calculator
      'loan_type': 'ऋण प्रकार',
      'home_loan': 'होम लोन',
      'personal_loan': 'पर्सनल लोन',
      'car_loan': 'कार लोन',
      'education_loan': 'शिक्षा ऋण',
      'business_loan': 'व्यापार ऋण',
      'loan_tenure': 'ऋण अवधि',
      'years': 'वर्ष',
      'months': 'महीने',
      'emi_display_frequency': 'ईएमआई प्रदर्शन आवृत्ति',
      'monthly': 'मासिक',
      'quarterly': 'त्रैमासिक',
      'yearly': 'वार्षिक',
      'enable_prepayment': 'पूर्व भुगतान/आंशिक भुगतान सक्षम करें',
      'prepayment_amount': 'पूर्व भुगतान राशि (₹)',
      'prepayment_month': 'पूर्व भुगतान महीना',
      'enter_loan_amount': 'ऋण राशि दर्ज करें',
      'enter_interest_rate': 'ब्याज दर दर्ज करें',
      'enter_tenure': 'अवधि दर्ज करें',
      'enter_prepayment_amount': 'पूर्व भुगतान राशि दर्ज करें',
      'enter_month_number': 'महीना संख्या दर्ज करें',
      'calculate_emi': 'ईएमआई की गणना करें',
      'calculation_results': 'गणना परिणाम',
      'monthly_emi': 'मासिक ईएमआई',
      'quarterly_emi': 'त्रैमासिक ईएमआई',
      'yearly_emi': 'वार्षिक ईएमआई',
      'principal_vs_interest': 'मूलधन बनाम ब्याज',
      'yearly_payment_breakdown': 'वार्षिक भुगतान विवरण',
      'outstanding_balance': 'समय के साथ बकाया शेष',
      'amortization_schedule': 'ऋण परिशोधन अनुसूची',
      'month': 'महीना',
      'balance': 'शेष',
      'emi_calculation_results': 'ईएमआई गणना परिणाम',
      'detailed_breakdown': 'विस्तृत विवरण और चार्ट',
      'export_pdf': 'PDF के रूप में निर्यात करें',
      'share_results': 'परिणाम साझा करें',
      // Settings
      'app_settings': 'ऐप सेटिंग्स',
      'customize_experience': 'अपने ऐप अनुभव को अनुकूलित करें',
      'profile_theme': 'प्रोफ़ाइल और थीम',
      'theme_mode': 'थीम मोड',
      'choose_theme': 'लाइट या डार्क मोड चुनें',
      'select_language': 'भाषा चुनें',
      'choose_language': 'अपनी पसंदीदा भाषा चुनें',
      'english': 'English',
      'hindi': 'हिंदी (Hindi)',
      'app_information': 'ऐप जानकारी',
      'app_version': 'ऐप संस्करण',
      // Common
      'close': 'बंद करें',
      'cancel': 'रद्द करें',
      'ok': 'ठीक है',
      'yes': 'हाँ',
      'no': 'नहीं',
      'please_enter_valid': 'कृपया मान्य मान दर्ज करें',
      'calculation_deleted': 'गणना हटाई गई',
      'history_cleared': 'इतिहास साफ कर दिया गया',
      'clear_history': 'इतिहास साफ करें',
      'delete_all_calculations': 'क्या आप वाकई सभी गणनाएं हटाना चाहते हैं?',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? 
           _localizedValues['en']?[key] ?? key;
  }

  String get appName => translate('app_name');
  String get home => translate('home');
  String get profile => translate('profile');
  String get settings => translate('settings');
  String get darkMode => translate('dark_mode');
  String get lightMode => translate('light_mode');
  String get language => translate('language');
  String get history => translate('history');
  String get calculate => translate('calculate');
  String get clear => translate('clear');
  String get save => translate('save');
  String get delete => translate('delete');
  String get noHistory => translate('no_history');
  String get loanAmount => translate('loan_amount');
  String get interestRate => translate('interest_rate');
  String get tenure => translate('tenure');
  String get emi => translate('emi');
  String get totalPayment => translate('total_payment');
  String get totalInterest => translate('total_interest');
  String get principal => translate('principal');
  
  // Home Screen
  String get cibilScoreCheck => translate('cibil_score_check');
  String get checkCreditScore => translate('check_credit_score');
  String get loanProfile => translate('loan_profile');
  String get businessCalculator => translate('business_calculator');
  String get taxCalculator => translate('tax_calculator');
  String get incomeTaxCalculator => translate('income_tax_calculator');
  String get calculateTaxLiability => translate('calculate_tax_liability');
  String get houseRentCalculator => translate('house_rent_calculator');
  String get calculateHouseRent => translate('calculate_house_rent');
  String get emiCalculator => translate('emi_calculator');
  String get calculateEmiCharts => translate('calculate_emi_charts');
  
  // GST Calculator
  String get gstCalculator => translate('gst_calculator');
  String get calculateGst => translate('calculate_gst');
  String get addRemoveGst => translate('add_remove_gst');
  String get amount => translate('amount');
  String get gstRate => translate('gst_rate');
  String get addGst => translate('add_gst');
  String get removeGst => translate('remove_gst');
  String get netAmount => translate('net_amount');
  String get gstAmount => translate('gst_amount');
  String get totalAmount => translate('total_amount');
  String get amountBreakdown => translate('amount_breakdown');
  
  // EMI Calculator
  String get loanType => translate('loan_type');
  String get homeLoan => translate('home_loan');
  String get personalLoan => translate('personal_loan');
  String get carLoan => translate('car_loan');
  String get educationLoan => translate('education_loan');
  String get businessLoan => translate('business_loan');
  String get loanTenure => translate('loan_tenure');
  String get years => translate('years');
  String get months => translate('months');
  String get emiDisplayFrequency => translate('emi_display_frequency');
  String get monthly => translate('monthly');
  String get quarterly => translate('quarterly');
  String get yearly => translate('yearly');
  String get enablePrepayment => translate('enable_prepayment');
  String get prepaymentAmount => translate('prepayment_amount');
  String get prepaymentMonth => translate('prepayment_month');
  String get enterLoanAmount => translate('enter_loan_amount');
  String get enterInterestRate => translate('enter_interest_rate');
  String get enterTenure => translate('enter_tenure');
  String get enterPrepaymentAmount => translate('enter_prepayment_amount');
  String get enterMonthNumber => translate('enter_month_number');
  String get calculateEmi => translate('calculate_emi');
  String get calculationResults => translate('calculation_results');
  String get monthlyEmi => translate('monthly_emi');
  String get quarterlyEmi => translate('quarterly_emi');
  String get yearlyEmi => translate('yearly_emi');
  String get principalVsInterest => translate('principal_vs_interest');
  String get yearlyPaymentBreakdown => translate('yearly_payment_breakdown');
  String get outstandingBalance => translate('outstanding_balance');
  String get amortizationSchedule => translate('amortization_schedule');
  String get month => translate('month');
  String get balance => translate('balance');
  String get emiCalculationResults => translate('emi_calculation_results');
  String get detailedBreakdown => translate('detailed_breakdown');
  String get exportPdf => translate('export_pdf');
  String get shareResults => translate('share_results');
  
  // Settings
  String get appSettings => translate('app_settings');
  String get customizeExperience => translate('customize_experience');
  String get profileTheme => translate('profile_theme');
  String get themeMode => translate('theme_mode');
  String get chooseTheme => translate('choose_theme');
  String get selectLanguage => translate('select_language');
  String get chooseLanguage => translate('choose_language');
  String get english => translate('english');
  String get hindi => translate('hindi');
  String get appInformation => translate('app_information');
  String get appVersion => translate('app_version');
  
  // Common
  String get close => translate('close');
  String get cancel => translate('cancel');
  String get ok => translate('ok');
  String get yes => translate('yes');
  String get no => translate('no');
  String get pleaseEnterValid => translate('please_enter_valid');
  String get calculationDeleted => translate('calculation_deleted');
  String get historyCleared => translate('history_cleared');
  String get clearHistory => translate('clear_history');
  String get deleteAllCalculations => translate('delete_all_calculations');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'hi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

