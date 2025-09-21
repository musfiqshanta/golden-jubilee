import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/counter_service.dart';

class AdminRegistrationScreen extends StatefulWidget {
  const AdminRegistrationScreen({super.key});

  @override
  State<AdminRegistrationScreen> createState() =>
      _AdminRegistrationScreenState();
}

class _AdminRegistrationScreenState extends State<AdminRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers - exactly matching the registration controller
  final _nameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _permanentAddressController = TextEditingController();
  final _presentAddressController = TextEditingController();
  final _occupationController = TextEditingController();
  final _designationController = TextEditingController();
  final _workplaceAddressController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _finalClassController = TextEditingController();
  final _sscPassingYearController = TextEditingController();
  final _spouseCountController = TextEditingController();
  final _childCountController = TextEditingController();
  final _parentCountController = TextEditingController();
  final _totalPayableController = TextEditingController();
  final _paymentReferenceController = TextEditingController();
  final _bankTranIdController = TextEditingController();
  final _cardTypeController = TextEditingController();

  // Reactive fields - exactly matching the registration controller
  String _selectedGender = 'পুরুষ';
  String _selectedReligion = 'ইসলাম';
  String _selectedNationality = 'বাংলাদেশী';
  String _selectedFinalClass = '';
  String _selectedYear = '2024';
  String _selectedSscPassingYear = 'None';
  DateTime? _selectedDateOfBirth;
  int _spouseCount = 0;
  int _childCount = 0;
  int _parentCount = 0;

  // Guest details - names and relationships
  List<String> _guestNames = [];
  List<String> _guestRelationships = [];

  String? _selectedTshirtSize;
  String _selectedBloodGroup = '';
  bool _isRunningStudent = false;
  bool _isStillStudying = false;
  bool _isLoading = false;
  String _paymentStatus = 'approved';
  String _paymentMethod = 'manual';

  // Dropdown lists - exactly matching the registration controller
  final List<String> _genders = ['পুরুষ', 'মহিলা', 'অন্যান্য'];
  final List<String> _tshirtSizes = ['S', 'M', 'L', 'XL', 'XXL'];
  final List<String> _religions = [
    'ইসলাম',
    'হিন্দু',
    'খ্রিস্টান',
    'বৌদ্ধ',
    'অন্যান্য',
  ];
  final List<String> _nationalities = ['বাংলাদেশী', 'অন্যান্য'];
  final List<String> _bloodGroups = [
    'জানি না / জানা নেই',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];
  final List<String> _finalClasses = [
    '৬ষ্ঠ শ্রেণি',
    '৭ম শ্রেণি',
    '৮ম শ্রেণি',
    '৯ম শ্রেণি',
    '১০ম শ্রেণি',
  ];
  final List<String> _years = [
    '1972',
    '1973',
    '1974',
    '1975',
    '1976',
    '1977',
    '1978',
    '1979',
    '1980',
    '1981',
    '1982',
    '1983',
    '1984',
    '1985',
    '1986',
    '1987',
    '1988',
    '1989',
    '1990',
    '1991',
    '1992',
    '1993',
    '1994',
    '1995',
    '1996',
    '1997',
    '1998',
    '1999',
    '2000',
    '2001',
    '2002',
    '2003',
    '2004',
    '2005',
    '2006',
    '2007',
    '2008',
    '2009',
    '2010',
    '2011',
    '2012',
    '2013',
    '2014',
    '2015',
    '2016',
    '2017',
    '2018',
    '2019',
    '2020',
    '2021',
    '2022',
    '2023',
    '2024',
    '2025',
    '2026',
  ];

  // Guest relationship options
  final List<String> _guestRelationshipOptions = [
    'স্বামী',
    'স্ত্রী',
    'সন্তান',
    'পিতা',
    'মাতা',
    'ভাই',
    'বোন',
    'অন্যান্য',
  ];
  final List<String> _sscPassingYears = [
    '1972',
    '1973',
    '1974',
    '1975',
    '1976',
    '1977',
    '1978',
    '1979',
    '1980',
    '1981',
    '1982',
    '1983',
    '1984',
    '1985',
    '1986',
    '1987',
    '1988',
    '1989',
    '1990',
    '1991',
    '1992',
    '1993',
    '1994',
    '1995',
    '1996',
    '1997',
    '1998',
    '1999',
    '2000',
    '2001',
    '2002',
    '2003',
    '2004',
    '2005',
    '2006',
    '2007',
    '2008',
    '2009',
    '2010',
    '2011',
    '2012',
    '2013',
    '2014',
    '2015',
    '2016',
    '2017',
    '2018',
    '2019',
    '2020',
    '2021',
    '2022',
    '2023',
    '2024',
    '2025',
    '2026',
  ];

  @override
  void initState() {
    super.initState();
    _updateGuestDetails();
    _updateTotalPayable();
  }

  void _updateGuestDetails() {
    final totalGuests = _spouseCount + _childCount;

    // Ensure guest names and relationships lists are the right size
    while (_guestNames.length < totalGuests) {
      _guestNames.add('');
    }
    while (_guestRelationships.length < totalGuests) {
      _guestRelationships.add('স্বামী');
    }

    // Remove excess entries
    if (_guestNames.length > totalGuests) {
      _guestNames = _guestNames.take(totalGuests).toList();
    }
    if (_guestRelationships.length > totalGuests) {
      _guestRelationships = _guestRelationships.take(totalGuests).toList();
    }

    setState(() {});
  }

  void _updateTotalPayable() {
    final total = _calculateTotalPayable();
    _totalPayableController.text = total.toString();
  }

  void _fillDemoData() {
    // Clear form first
    _clearForm();

    // Fill personal information
    _nameController.text = 'আবুল কালাম আজাদ';
    _fatherNameController.text = 'মোঃ আব্দুল হামিদ';
    _motherNameController.text = 'রোকসানা বেগম';
    _selectedGender = 'পুরুষ';
    _selectedBloodGroup = 'A+';
    _selectedDateOfBirth = DateTime(1995, 6, 15);

    // Fill contact information
    _mobileController.text = '01712345678';
    _emailController.text = 'akalam.azad@example.com';

    // Fill address information
    _permanentAddressController.text =
        'গ্রাম: শাহবাগ, ডাকঘর: শাহবাগ, উপজেলা: সদর, জেলা: ঢাকা';
    _presentAddressController.text =
        'বাড়ি নং: ১২৩, রোড নং: ৪৫, ধানমন্ডি, ঢাকা-১২০৫';

    // Fill professional information
    _occupationController.text = 'সফটওয়্যার ইঞ্জিনিয়ার';
    _designationController.text = 'সিনিয়র ডেভেলপার';
    _workplaceAddressController.text = 'টেকনোলজি পার্ক, ঢাকা';

    // Fill personal details
    _selectedNationality = 'বাংলাদেশী';
    _selectedReligion = 'ইসলাম';

    // Fill academic information
    _isRunningStudent = false;
    _selectedSscPassingYear = '2012';

    // Fill family information
    _spouseCount = 1;
    _childCount = 1;
    _parentCount = 2;
    _updateGuestDetails();

    // Fill guest details
    if (_guestNames.isNotEmpty) {
      _guestNames[0] = 'ফাতেমা খাতুন';
      _guestRelationships[0] = 'স্ত্রী';
    }
    if (_guestNames.length > 1) {
      _guestNames[1] = 'রহমান';
      _guestRelationships[1] = 'সন্তান';
    }

    // Fill t-shirt size
    _selectedTshirtSize = 'L';

    // Fill payment information
    _paymentStatus = 'approved';
    _paymentMethod = 'online';
    _bankTranIdController.text = '2509201018220det8bZh9NIoKRq';
    _cardTypeController.text = 'BKASH-BKash';
    _paymentReferenceController.text = 'REF-2024-001';

    // Update total payable
    _updateTotalPayable();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ডেমো ডাটা সফলভাবে পূরণ করা হয়েছে'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  int _calculateTotalPayable() {
    // Calculate base fee based on student type and passing year (matching actual registration)
    int baseFee;
    if (_isRunningStudent) {
      baseFee = 500; // Running students pay 500
    } else {
      // For old students, check if they passed between 2019-2026
      if (_selectedSscPassingYear != 'None' &&
          _selectedSscPassingYear.isNotEmpty) {
        final year = int.tryParse(_selectedSscPassingYear);
        if (year != null && year >= 2019 && year <= 2026) {
          baseFee = 700; // Old students who passed 2019-2026 pay 700
        } else {
          baseFee = 1200; // Other old students pay 1200
        }
      } else {
        baseFee = 1200; // Default for old students
      }
    }

    final int guestCount = _spouseCount + _childCount;
    final int guestFee = guestCount * 500; // Each guest costs 500
    final int totalPayable = baseFee + guestFee;

    return totalPayable;
  }

  String _buildTotalAmountText() {
    // Determine base fee based on student type and passing year
    int baseFee;
    String feeDescription;

    if (_isRunningStudent) {
      baseFee = 500; // Running students now pay 500
      feeDescription = 'বর্তমানে অধ্যয়নরত: 500 টাকা';
    } else {
      // For old students, check if they passed between 2019-2026
      if (_selectedSscPassingYear != 'None' &&
          _selectedSscPassingYear.isNotEmpty) {
        final year = int.tryParse(_selectedSscPassingYear);
        if (year != null && year >= 2019 && year <= 2026) {
          baseFee = 700; // Old students who passed 2019-2026 pay 700
          feeDescription = 'প্রাক্তন শিক্ষার্থী (২০১৯-২০২৬): 700 টাকা';
        } else {
          baseFee = 1200; // Other old students pay 1200
          feeDescription = 'প্রাক্তন শিক্ষার্থী: 1200 টাকা';
        }
      } else {
        baseFee = 1200; // Default for old students
        feeDescription = 'প্রাক্তন শিক্ষার্থী: 1200 টাকা';
      }
    }

    final int guestCount = _spouseCount + _childCount;
    final int guestFee = guestCount * 500;
    final int subtotal = baseFee + guestFee;

    // Calculate 2.5% transaction fee
    final int transactionFee = (subtotal * 0.025).round();
    final int total = subtotal + transactionFee;

    String details = feeDescription;
    details += '\nপরিবারের সদস্য ($guestCount জন): $guestFee টাকা';
    details += '\n-----------------------------';
    details += '\nউপমোট: $subtotal টাকা';
    details += '\nঅনলাইন লেনদেন ফি (২.৫%): $transactionFee টাকা';
    details += '\n-----------------------------';
    details += '\nমোট: $total টাকা';
    return details;
  }

  Future<void> _saveRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Admin registrations always save to production collections
    // regardless of the current environment setting

    if (_selectedTshirtSize == null || _selectedTshirtSize!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('টি-শার্ট সাইজ নির্বাচন করুন'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate academic information
    if (_isRunningStudent) {
      if (_selectedFinalClass.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('শেষ শ্রেণি নির্বাচন করুন'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else {
      if (_selectedSscPassingYear == 'None' ||
          _selectedSscPassingYear.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('এসএসসি পাশের বছর নির্বাচন করুন'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Validate payment data based on payment method
    if (_paymentMethod == 'manual') {
      if (_paymentReferenceController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('রেফারেন্স নাম/নম্বর লিখুন'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else if (_paymentMethod == 'online') {
      if (_bankTranIdController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ব্যাংক ট্রানজেকশন আইডি লিখুন'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_cardTypeController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('কার্ড/পেমেন্ট টাইপ লিখুন'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_paymentReferenceController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('পেমেন্ট রেফারেন্স লিখুন'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final phone = _mobileController.text.trim();
      final batch =
          _isRunningStudent ? _selectedFinalClass : _selectedSscPassingYear;

      // Check if phone number already exists in the same batch
      // Admin registrations always use production collections
      try {
        final existingDoc =
            await FirebaseFirestore.instance
                .collection('batches') // Always use production collection
                .doc(batch)
                .collection('registrations') // Always use production collection
                .doc(phone)
                .get();

        if (existingDoc.exists) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'এই মোবাইল নম্বরটি ইতিমধ্যে এই ব্যাচে নিবন্ধিত হয়েছে। অনুগ্রহ করে অন্য নম্বর ব্যবহার করুন।',
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),
              ),
            );
          }
          return;
        }
      } catch (e) {
        print('Error checking existing registration: $e');
      }

      // Calculate total payable amount (matching actual registration logic)
      final int totalPayable = _calculateTotalPayable();

      final registrationData = {
        'name': _nameController.text.trim(),
        'fatherName': _fatherNameController.text.trim(),
        'motherName': _motherNameController.text.trim(),
        'gender': _selectedGender,
        'bloodGroup': _selectedBloodGroup,
        'dateOfBirth': _selectedDateOfBirth?.toIso8601String(),
        'nationalId': _nationalIdController.text.trim(),
        'mobile': phone,
        'email': _emailController.text.trim(),
        'permanentAddress': _permanentAddressController.text.trim(),
        'presentAddress': _presentAddressController.text.trim(),
        'occupation': _occupationController.text.trim(),
        'designation': _designationController.text.trim(),
        'workplaceAddress': _workplaceAddressController.text.trim(),
        'nationality': _selectedNationality,
        'religion': _selectedReligion,
        'finalClass': _selectedFinalClass,
        'year': _selectedYear,
        'sscPassingYear': _selectedSscPassingYear,
        'isRunningStudent': _isRunningStudent,
        'isStillStudying': _isStillStudying,
        'spouseCount': _spouseCount,
        'childCount': _childCount,
        'parentCount': _parentCount,
        'tshirtSize': _selectedTshirtSize,
        'batch': batch,
        'registrationTimestamp': now.toIso8601String(),
        'registrationDate': now.toIso8601String(),
        'registration_date': now.toIso8601String(),
        'totalPayable': totalPayable,
        'paymentStatus': _paymentStatus,
        'paymentMethod': _paymentMethod,
        'paymentDate':
            _paymentStatus == 'approved' ? now.toIso8601String() : null,
        'payment_date':
            _paymentStatus == 'approved' ? now.toIso8601String() : null,
        'paymentData': {
          'amount': totalPayable.toString(),
          'bank_tran_id': _bankTranIdController.text.trim(),
          'card_type': _cardTypeController.text.trim(),
          'reference': _paymentReferenceController.text.trim(),
        },
        'guestNames': _guestNames,
        'guestRelationships': _guestRelationships,
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Save to Firebase using the same structure as regular registration
      // Admin registrations always use production collections
      await FirebaseFirestore.instance
          .collection('batches') // Always use production collection
          .doc(batch)
          .collection('registrations') // Always use production collection
          .doc(phone)
          .set(registrationData);

      // Update counters
      try {
        final counterService = CounterService();
        await counterService.incrementTotalRegistrations();
        final guestCount = _spouseCount + _childCount;
        if (guestCount > 0) {
          await counterService.updateTotalGuests(guestCount);
        }
      } catch (e) {
        print('Warning: Failed to update counters: $e');
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User "${_nameController.text}" registered successfully!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Clear form
        _clearForm();
      }

      print('✅ Admin registration saved successfully: ${_nameController.text}');
    } catch (e) {
      print('Error saving admin registration: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving registration: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearForm() {
    // Clear all text controllers
    _nameController.clear();
    _fatherNameController.clear();
    _motherNameController.clear();
    _nationalIdController.clear();
    _mobileController.clear();
    _emailController.clear();
    _permanentAddressController.clear();
    _presentAddressController.clear();
    _occupationController.clear();
    _designationController.clear();
    _workplaceAddressController.clear();
    _finalClassController.clear();
    _sscPassingYearController.clear();
    _spouseCountController.clear();
    _childCountController.clear();
    _parentCountController.clear();
    _totalPayableController.clear();
    _paymentReferenceController.clear();
    _bankTranIdController.clear();
    _cardTypeController.clear();

    // Reset selection variables
    _selectedGender = 'পুরুষ';
    _selectedBloodGroup = '';
    _selectedNationality = 'বাংলাদেশী';
    _selectedReligion = 'ইসলাম';
    _selectedTshirtSize = null;
    _selectedYear = '2024';
    _selectedFinalClass = '';
    _selectedSscPassingYear = 'None';
    _paymentStatus = 'approved';
    _paymentMethod = 'manual';
    _isRunningStudent = false;
    _isStillStudying = false;
    _selectedDateOfBirth = null;
    _spouseCount = 0;
    _childCount = 0;
    _parentCount = 0;

    // Clear guest details
    _guestNames.clear();
    _guestRelationships.clear();

    _updateGuestDetails();
    _updateTotalPayable();
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD4AF37),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'এডমিন নিবন্ধন ফর্ম',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFD4AF37),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _clearForm,
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear Form',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD4AF37), Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Demo Data Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.auto_fix_high, size: 18),
                      label: const Text(
                        'ডেমো ডাটা পূরণ করুন',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey.shade100,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _fillDemoData,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.admin_panel_settings,
                        size: 50,
                        color: Color(0xFFD4AF37),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'এডমিন নিবন্ধন',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B6914),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'জাহাজমারা উচ্চ বিদ্যালয়',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B6914),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'এডমিন দ্বারা নতুন ব্যবহারকারী নিবন্ধন করুন',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Personal Information Section
                _sectionCard('ব্যক্তিগত তথ্য', Icons.person, [
                  _textField(
                    controller: _nameController,
                    label: 'পূর্ণ নাম',
                    icon: Icons.person_outline,
                    hintText: 'বাংলায় আপনার পূর্ণ নাম লিখুন',
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'আপনার পূর্ণ নাম লিখুন'
                                : null,
                  ),
                  const SizedBox(height: 15),
                  _textField(
                    controller: _fatherNameController,
                    label: 'পিতার নাম',
                    icon: Icons.person_outline,
                    hintText: 'বাংলায় আপনার পিতার নাম লিখুন',
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'আপনার পিতার নাম লিখুন'
                                : null,
                  ),
                  const SizedBox(height: 15),
                  _textField(
                    controller: _motherNameController,
                    label: 'মাতার নাম',
                    icon: Icons.person_outline,
                    hintText: 'বাংলায় আপনার মাতার নাম লিখুন',
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'আপনার মাতার নাম লিখুন'
                                : null,
                  ),
                  const SizedBox(height: 15),
                  _dropdownField(
                    label: 'লিঙ্গ',
                    value: _selectedGender,
                    items: _genders,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value ?? 'পুরুষ';
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  _dropdownField(
                    label: 'রক্তের গ্রুপ',
                    value: _selectedBloodGroup,
                    items: _bloodGroups,
                    onChanged: (value) {
                      setState(() {
                        _selectedBloodGroup = value ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  _dateField(
                    label: 'জন্ম তারিখ',
                    value: _selectedDateOfBirth,
                    onTap: () => _selectDateOfBirth(),
                  ),
                  const SizedBox(height: 15),
                  _textField(
                    controller: _nationalIdController,
                    label: 'জাতীয় পরিচয়পত্র নম্বর (ঐচ্ছিক)',
                    icon: Icons.badge_outlined,
                    hintText: 'ইংরেজিতে জাতীয় পরিচয়পত্র নম্বর লিখুন (ঐচ্ছিক)',
                    validator: (value) => null, // Optional field
                  ),
                ]),
                const SizedBox(height: 20),
                // Contact Information Section
                _sectionCard('যোগাযোগের তথ্য', Icons.contact_phone, [
                  _textField(
                    controller: _mobileController,
                    label: 'মোবাইল নম্বর',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    hintText:
                        'ইংরেজিতে মোবাইল নম্বর লিখুন (উদাহরণ: 01XXXXXXXXX)',
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'আপনার মোবাইল নম্বর লিখুন'
                                : null,
                  ),
                  const SizedBox(height: 15),
                  _textField(
                    controller: _emailController,
                    label: 'ইমেইল ঠিকানা (ঐচ্ছিক)',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    hintText: 'ইংরেজিতে ইমেইল ঠিকানা লিখুন (ঐচ্ছিক)',
                    validator: (value) {
                      // Optional field - only validate if provided
                      if (value != null && value.isNotEmpty) {
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}',
                        ).hasMatch(value)) {
                          return 'সঠিক ইমেইল লিখুন';
                        }
                      }
                      return null;
                    },
                  ),
                ]),
                const SizedBox(height: 20),
                // Address Information Section
                _sectionCard('ঠিকানা', Icons.location_on, [
                  _textField(
                    controller: _permanentAddressController,
                    label: 'স্থায়ী ঠিকানা',
                    icon: Icons.home_outlined,
                    maxLines: 3,
                    hintText: 'বাংলায় আপনার স্থায়ী ঠিকানা লিখুন',
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'আপনার স্থায়ী ঠিকানা লিখুন'
                                : null,
                  ),
                  const SizedBox(height: 15),
                  _textField(
                    controller: _presentAddressController,
                    label: 'বর্তমান ঠিকানা',
                    icon: Icons.home_outlined,
                    maxLines: 3,
                    hintText: 'বাংলায় আপনার বর্তমান ঠিকানা লিখুন',
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'আপনার বর্তমান ঠিকানা লিখুন'
                                : null,
                  ),
                ]),
                const SizedBox(height: 20),
                // Professional Information Section
                _sectionCard('পেশাগত তথ্য', Icons.work, [
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'পেশাগত তথ্য ঐচ্ছিক। আপনি যদি বর্তমানে কর্মরত না হন তবে এই তথ্যগুলি খালি রাখতে পারেন।',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _textField(
                    controller: _occupationController,
                    label: 'পেশা (ঐচ্ছিক)',
                    icon: Icons.work_outline,
                    hintText: 'বাংলায় আপনার পেশা লিখুন (ঐচ্ছিক)',
                    validator: (value) => null, // Always optional
                  ),
                  const SizedBox(height: 15),
                  _textField(
                    controller: _designationController,
                    label: 'পদবী (ঐচ্ছিক)',
                    icon: Icons.badge_outlined,
                    hintText: 'বাংলায় আপনার পদবী লিখুন (ঐচ্ছিক)',
                    validator: (value) => null, // Always optional
                  ),
                  const SizedBox(height: 15),
                  _textField(
                    controller: _workplaceAddressController,
                    label: 'কর্মস্থলের ঠিকানা (ঐচ্ছিক)',
                    icon: Icons.business_outlined,
                    maxLines: 3,
                    hintText: 'বাংলায় আপনার কর্মস্থলের ঠিকানা লিখুন (ঐচ্ছিক)',
                    validator: (value) => null, // Always optional
                  ),
                ]),
                const SizedBox(height: 20),
                // Personal Details Section
                _sectionCard('ব্যক্তিগত বিবরণ', Icons.info, [
                  _dropdownField(
                    label: 'জাতীয়তা',
                    value: _selectedNationality,
                    items: _nationalities,
                    onChanged: (value) {
                      setState(() {
                        _selectedNationality = value ?? 'বাংলাদেশী';
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  _dropdownField(
                    label: 'ধর্ম',
                    value: _selectedReligion,
                    items: _religions,
                    onChanged: (value) {
                      setState(() {
                        _selectedReligion = value ?? 'ইসলাম';
                      });
                    },
                  ),
                ]),
                const SizedBox(height: 20),
                // Academic Information Section
                _sectionCard('শিক্ষাগত তথ্য', Icons.school, [
                  Row(
                    children: [
                      Checkbox(
                        value: _isRunningStudent,
                        onChanged: (val) {
                          setState(() {
                            _isRunningStudent = val ?? false;
                            // Reset still studying when running student is unchecked
                            if (!(val ?? false)) {
                              _isStillStudying = false;
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'বর্তমানে অধ্যয়নরত (ছাত্র/ছাত্রী)',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _isRunningStudent
                      ? Row(
                        children: [
                          Expanded(
                            child: _dropdownField(
                              label: 'শেষ শ্রেণি',
                              value: _selectedFinalClass,
                              items: _finalClasses,
                              onChanged: (value) {
                                setState(() {
                                  _selectedFinalClass = value ?? '';
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _dropdownField(
                              label: 'বছর',
                              value: _selectedYear,
                              items: _years,
                              onChanged: (value) {
                                setState(() {
                                  _selectedYear = value ?? '';
                                });
                              },
                            ),
                          ),
                        ],
                      )
                      : _dropdownField(
                        label: 'এসএসসি পাশের বছর',
                        value: _selectedSscPassingYear,
                        items: _sscPassingYears,
                        onChanged: (value) {
                          setState(() {
                            _selectedSscPassingYear = value ?? '';
                            _updateTotalPayable();
                          });
                        },
                      ),
                ]),
                const SizedBox(height: 20),
                // Family Participation Section
                _sectionCard('পরিবার/অতিথী অংশগ্রহণ ', Icons.family_restroom, [
                  Row(
                    children: [
                      Expanded(
                        child: _customNumberField(
                          label: 'স্বামী/স্ত্রী/সন্তান',
                          value: _spouseCount,
                          maxValue: 3,
                          onChanged: (value) {
                            // Ensure total guests don't exceed 3
                            final newTotal = value + _childCount;
                            if (newTotal <= 3) {
                              setState(() {
                                _spouseCount = value;
                                _updateGuestDetails();
                                _updateTotalPayable();
                              });
                            } else {
                              // Show warning if total would exceed 3
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'মোট অতিথির সংখ্যা ৩ জনের বেশি হতে পারবে না',
                                  ),
                                  backgroundColor: Colors.orange,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _customNumberField(
                          label: 'অন্যান্য আতিথী',
                          value: _childCount,
                          maxValue: 3,
                          onChanged: (value) {
                            // Ensure total guests don't exceed 3
                            final newTotal = _spouseCount + value;
                            if (newTotal <= 3) {
                              setState(() {
                                _childCount = value;
                                _updateGuestDetails();
                                _updateTotalPayable();
                              });
                            } else {
                              // Show warning if total would exceed 3
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'মোট অতিথির সংখ্যা ৩ জনের বেশি হতে পারবে না',
                                  ),
                                  backgroundColor: Colors.orange,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // Guest Details Input Fields
                  if (_spouseCount + _childCount > 0) ...[
                    Text(
                      'অতিথির বিবরণ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B6914),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(_spouseCount + _childCount, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'অতিথি ${index + 1} এর নাম',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                onChanged: (value) {
                                  if (index < _guestNames.length) {
                                    _guestNames[index] = value;
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'সম্পর্ক',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                value:
                                    index < _guestRelationships.length
                                        ? _guestRelationships[index]
                                        : 'স্বামী',
                                items:
                                    _guestRelationshipOptions.map((
                                      relationship,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: relationship,
                                        child: Text(relationship),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  if (value != null &&
                                      index < _guestRelationships.length) {
                                    _guestRelationships[index] = value;
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: const Color(0xFFD4AF37),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'মোট অতিথি: ${_spouseCount + _childCount} জন (সর্বোচ্চ ৩ জন)',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8B6914),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 20),
                // T-shirt Size Dropdown
                _sectionCard('টি-শার্টের সাইজ', Icons.checkroom, [
                  DropdownButtonFormField<String>(
                    value:
                        (_selectedTshirtSize == null ||
                                _selectedTshirtSize!.isEmpty ||
                                !_tshirtSizes.contains(_selectedTshirtSize))
                            ? null
                            : _selectedTshirtSize,
                    decoration: InputDecoration(
                      labelText: 'টি-শার্ট সাইজ নির্বাচন করুন',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFD4AF37),
                          width: 2,
                        ),
                      ),
                    ),
                    items:
                        _tshirtSizes.map((size) {
                          return DropdownMenuItem<String>(
                            value: size,
                            child: Text(size),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTshirtSize = value ?? '';
                      });
                    },
                    validator:
                        (value) =>
                            value == null
                                ? 'টি-শার্ট সাইজ নির্বাচন করুন'
                                : null,
                  ),
                ]),
                const SizedBox(height: 20),
                // Total Amount Card
                _sectionCard('মোট জমার পরিমাণ', Icons.attach_money, [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _buildTotalAmountText(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B6914),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: const Color(0xFFE8F5E8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(
                        color: Color(0xFF4CAF50),
                        width: 1.5,
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.payment, color: Color(0xFF4CAF50)),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'এডমিন দ্বারা নিবন্ধন করা হয়েছে - পেমেন্ট অনুমোদিত',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 20),
                // Admin Payment Information Section
                _sectionCard('এডমিন পেমেন্ট তথ্য', Icons.admin_panel_settings, [
                  Row(
                    children: [
                      Expanded(
                        child: _dropdownField(
                          label: 'পেমেন্ট স্ট্যাটাস',
                          value: _paymentStatus,
                          items: ['approved', 'pending', 'rejected'],
                          onChanged: (value) {
                            setState(() {
                              _paymentStatus = value ?? 'approved';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _dropdownField(
                          label: 'পেমেন্ট পদ্ধতি',
                          value: _paymentMethod,
                          items: ['manual', 'online'],
                          onChanged: (value) {
                            setState(() {
                              _paymentMethod = value ?? 'manual';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // Conditional payment data fields based on payment method
                  if (_paymentMethod == 'manual') ...[
                    _textField(
                      controller: _paymentReferenceController,
                      label: 'রেফারেন্স নাম/নম্বর',
                      icon: Icons.receipt_long,
                      hintText:
                          'ম্যানুয়াল পেমেন্টের রেফারেন্স নাম বা নম্বর লিখুন',
                      validator: (value) {
                        if (_paymentMethod == 'manual' &&
                            (value == null || value.trim().isEmpty)) {
                          return 'রেফারেন্স নাম/নম্বর লিখুন';
                        }
                        return null;
                      },
                    ),
                  ] else if (_paymentMethod == 'online') ...[
                    Row(
                      children: [
                        Expanded(
                          child: _textField(
                            controller: _bankTranIdController,
                            label: 'ব্যাংক ট্রানজেকশন আইডি',
                            icon: Icons.account_balance,
                            hintText: 'ব্যাংক ট্রানজেকশন আইডি লিখুন',
                            validator: (value) {
                              if (_paymentMethod == 'online' &&
                                  (value == null || value.trim().isEmpty)) {
                                return 'ব্যাংক ট্রানজেকশন আইডি লিখুন';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _textField(
                            controller: _cardTypeController,
                            label: 'কার্ড/পেমেন্ট টাইপ',
                            icon: Icons.credit_card,
                            hintText: 'যেমন: BKASH-BKash, VISA, MasterCard',
                            validator: (value) {
                              if (_paymentMethod == 'online' &&
                                  (value == null || value.trim().isEmpty)) {
                                return 'কার্ড/পেমেন্ট টাইপ লিখুন';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _textField(
                      controller: _paymentReferenceController,
                      label: 'পেমেন্ট রেফারেন্স',
                      icon: Icons.receipt_long,
                      hintText: 'অনলাইন পেমেন্টের রেফারেন্স লিখুন',
                      validator: (value) {
                        if (_paymentMethod == 'online' &&
                            (value == null || value.trim().isEmpty)) {
                          return 'পেমেন্ট রেফারেন্স লিখুন';
                        }
                        return null;
                      },
                    ),
                  ],
                ]),
                const SizedBox(height: 30),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _clearForm,
                        icon: const Icon(Icons.clear),
                        label: const Text('ফর্ম সাফ করুন'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _saveRegistration,
                        icon:
                            _isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Icon(Icons.save),
                        label: Text(
                          _isLoading
                              ? 'সংরক্ষণ হচ্ছে...'
                              : 'নিবন্ধন সম্পন্ন করুন',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFD4AF37), size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B6914),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: const Color(0xFFD4AF37)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
            ),
          ),
        ),
        if (hintText != null) ...[
          const SizedBox(height: 5),
          Text(
            hintText,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.orange,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _dropdownField({
    required String label,
    required String value,
    required List<String> items,
    void Function(String?)? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: (value.isEmpty || !items.contains(value)) ? null : value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
        ),
      ),
      items:
          items.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
      onChanged: onChanged,
      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFD4AF37)),
    );
  }

  Widget _dateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFFD4AF37)),
            const SizedBox(width: 12),
            Text(
              value != null
                  ? '${value.day}/${value.month}/${value.year}'
                  : 'জন্ম তারিখ নির্বাচন করুন',
              style: TextStyle(
                color: value != null ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customNumberField({
    required String label,
    required int value,
    required void Function(int) onChanged,
    int? maxValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF8B6914),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              onPressed: value > 0 ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove_circle_outline),
              color: const Color(0xFFD4AF37),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD4AF37)),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B6914),
                ),
              ),
            ),
            IconButton(
              onPressed:
                  maxValue != null && value >= maxValue
                      ? null
                      : () => onChanged(value + 1),
              icon: const Icon(Icons.add_circle_outline),
              color:
                  maxValue != null && value >= maxValue
                      ? Colors.grey
                      : const Color(0xFFD4AF37),
            ),
          ],
        ),
        if (maxValue != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'সর্বোচ্চ: $maxValue জন',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _nationalIdController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _permanentAddressController.dispose();
    _presentAddressController.dispose();
    _occupationController.dispose();
    _designationController.dispose();
    _workplaceAddressController.dispose();
    _finalClassController.dispose();
    _sscPassingYearController.dispose();
    _spouseCountController.dispose();
    _childCountController.dispose();
    _parentCountController.dispose();
    _totalPayableController.dispose();
    _paymentReferenceController.dispose();
    _bankTranIdController.dispose();
    _cardTypeController.dispose();
    super.dispose();
  }
}
