import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/registration_controller.dart';
import 'registration_page.dart';

class TabbedRegistrationPage extends GetView<RegistrationController> {
  const TabbedRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'নিবন্ধন ফর্ম',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFFD4AF37),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [Tab(icon: Icon(Icons.flash_on), text: 'দ্রুত নিবন্ধন')],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFD4AF37), Colors.white],
            ),
          ),
          child: const TabBarView(children: [QuickRegistrationTab()]),
        ),
      ),
    );
  }
}

class QuickRegistrationTab extends GetView<RegistrationController> {
  const QuickRegistrationTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize default values when the tab is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.resetForQuickRegistration();
    });
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                    Icons.flash_on,
                    size: 50,
                    color: Color(0xFFD4AF37),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'দ্রুত নিবন্ধন',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B6914),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'কেবল প্রয়োজনীয় তথ্য দিয়ে দ্রুত নিবন্ধন করুন',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: const Text(
                      'দ্রুত নিবন্ধনের জন্য কেবল ৪টি তথ্য প্রয়োজন।',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick Registration Form
            _sectionCard('দ্রুত নিবন্ধন ফর্ম', Icons.person, [
              _textField(
                controller: controller.nameController,
                label: 'পূর্ণ নাম *',
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
                controller: controller.mobileController,
                label: 'মোবাইল নম্বর *',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                hintText: 'ইংরেজিতে মোবাইল নম্বর লিখুন (উদাহরণ: 01XXXXXXXXX)',
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'আপনার মোবাইল নম্বর লিখুন'
                            : null,
              ),
              const SizedBox(height: 15),

              // Current Studying Checkbox
              Obx(
                () => Row(
                  children: [
                    Checkbox(
                      value: controller.isRunningStudent.value,
                      onChanged: (val) {
                        controller.isRunningStudent.value = val ?? false;
                        // Reset still studying when running student is unchecked
                        if (!(val ?? false)) {
                          controller.isStillStudying.value = false;
                        }
                        // Reset dropdown values when switching
                        controller.selectedFinalClass.value = '';
                        controller.selectedSscPassingYear.value = 'None';
                      },
                      activeColor: const Color(0xFFD4AF37),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'বর্তমানে অধ্যয়নরত (ছাত্র/ছাত্রী)',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // Batch/Class Selection
              Obx(
                () => _dropdownField(
                  label:
                      controller.isRunningStudent.value
                          ? 'বর্তমান শ্রেণি *'
                          : 'এসএসসি পাশের বছর *',
                  value:
                      controller.isRunningStudent.value
                          ? (controller.selectedFinalClass.value.isEmpty
                              ? null
                              : controller.selectedFinalClass.value)
                          : (controller.selectedSscPassingYear.value.isEmpty ||
                                  controller.selectedSscPassingYear.value ==
                                      'None'
                              ? null
                              : controller.selectedSscPassingYear.value),
                  items:
                      controller.isRunningStudent.value
                          ? controller.finalClasses
                          : controller.sscPassingYears,
                  onChanged: (value) {
                    if (controller.isRunningStudent.value) {
                      controller.selectedFinalClass.value = value ?? '';
                    } else {
                      controller.selectedSscPassingYear.value = value ?? 'None';
                    }
                  },
                  validator: (value) {
                    final currentValue =
                        controller.isRunningStudent.value
                            ? controller.selectedFinalClass.value
                            : controller.selectedSscPassingYear.value;
                    return currentValue.isEmpty || currentValue == 'None'
                        ? 'ব্যাচ/শ্রেণি নির্বাচন করুন'
                        : null;
                  },
                ),
              ),
              const SizedBox(height: 15),
              Obx(
                () => _dateField(
                  label: 'জন্ম তারিখ *',
                  value: controller.selectedDateOfBirth.value,
                  onTap: () => controller.selectDateOfBirth(context),
                  validator: (value) {
                    return controller.selectedDateOfBirth.value == null
                        ? 'জন্ম তারিখ নির্বাচন করুন'
                        : null;
                  },
                ),
              ),
            ]),

            const SizedBox(height: 20),

            // Family Participation Section
            _sectionCard('পরিবার/অতিথী অংশগ্রহণ', Icons.family_restroom, [
              Obx(
                () => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _customNumberField(
                            label: 'স্বামী/স্ত্রী/সন্তান',
                            value: controller.spouseCount.value,
                            maxValue: 3,
                            onChanged: (value) {
                              // Ensure total guests don't exceed 3
                              final currentChildCount =
                                  controller.childCount.value;
                              final newTotal = value + currentChildCount;
                              if (newTotal <= 3) {
                                controller.spouseCount.value = value;
                                controller.updateGuestDetails();
                              } else {
                                // Show warning if total would exceed 3
                                Get.snackbar(
                                  'সতর্কতা',
                                  'মোট অতিথির সংখ্যা ৩ জনের বেশি হতে পারবে না',
                                  backgroundColor: Colors.orange,
                                  colorText: Colors.white,
                                  duration: const Duration(seconds: 2),
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _customNumberField(
                            label: 'অন্যান্য আতিথী',
                            value: controller.childCount.value,
                            maxValue: 3,
                            onChanged: (value) {
                              // Ensure total guests don't exceed 3
                              final currentSpouseCount =
                                  controller.spouseCount.value;
                              final newTotal = currentSpouseCount + value;
                              if (newTotal <= 3) {
                                controller.childCount.value = value;
                                controller.updateGuestDetails();
                              } else {
                                // Show warning if total would exceed 3
                                Get.snackbar(
                                  'সতর্কতা',
                                  'মোট অতিথির সংখ্যা ৩ জনের বেশি হতে পারবে না',
                                  backgroundColor: Colors.orange,
                                  colorText: Colors.white,
                                  duration: const Duration(seconds: 2),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Guest Details Input Fields
                    Obx(() {
                      final totalGuests =
                          controller.spouseCount.value +
                          controller.childCount.value;
                      if (totalGuests == 0) return const SizedBox.shrink();

                      return Column(
                        children: [
                          const Text(
                            'অতিথির বিবরণ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B6914),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...List.generate(totalGuests, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      key: ValueKey('guest_name_$index'),
                                      controller:
                                          index <
                                                  controller
                                                      .guestNameControllers
                                                      .length
                                              ? controller
                                                  .guestNameControllers[index]
                                              : null,
                                      onChanged: (value) {
                                        // Debug: Print guest name change
                                        print(
                                          '🔍 Guest name change: index=$index, value="$value", current controllers length=${controller.guestNameControllers.length}',
                                        );

                                        // Ensure the guestNames list is properly sized
                                        while (controller.guestNames.length <=
                                            index) {
                                          controller.guestNames.add('');
                                        }

                                        controller.guestNames[index] = value;

                                        print(
                                          '🔍 After update: names length=${controller.guestNames.length}, value at index=$index="${controller.guestNames[index]}"',
                                        );
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'অতিথি ${index + 1} এর নাম',
                                        hintText:
                                            index <
                                                        controller
                                                            .guestNames
                                                            .length &&
                                                    controller
                                                        .guestNames[index]
                                                        .isNotEmpty
                                                ? controller.guestNames[index]
                                                : 'অতিথির নাম লিখুন',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        labelText: 'সম্পর্ক',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                      ),
                                      value:
                                          index <
                                                  controller
                                                      .guestRelationships
                                                      .length
                                              ? controller
                                                  .guestRelationships[index]
                                              : 'স্বামী',
                                      items:
                                          controller.guestRelationshipOptions
                                              .map((relationship) {
                                                return DropdownMenuItem<String>(
                                                  value: relationship,
                                                  child: Text(relationship),
                                                );
                                              })
                                              .toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          // Ensure the guestRelationships list is properly sized
                                          while (controller
                                                  .guestRelationships
                                                  .length <=
                                              index) {
                                            controller.guestRelationships.add(
                                              'স্বামী',
                                            );
                                          }
                                          controller.guestRelationships[index] =
                                              value;
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      );
                    }),

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
                      child: const Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Color(0xFFD4AF37),
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'প্রতি অতিথির জন্য ৫০০ টাকা অতিরিক্ত ফি',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF8B6914),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]),

            const SizedBox(height: 20),

            // Total Amount Card
            _sectionCard('মোট জমার পরিমাণ', Icons.attach_money, [
              Obx(
                () => Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        _buildTotalAmountText(controller),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B6914),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: const Color(0xFFE8F5E8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.green,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'ফি কাঠামো',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• বর্তমানে অধ্যয়নরত: ৫০০ টাকা\n• প্রাক্তন শিক্ষার্থী (২০১৯-২০২৬): ৭০০ টাকা\n• প্রাক্তন শিক্ষার্থী (অন্যান্য): ১২০০ টাকা\n• প্রতি অতিথি: ৫০০ টাকা\n• অনলাইন লেনদেন ফি: ২.৫%',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
            ]),

            const SizedBox(height: 20),

            // Update Details Note
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.green.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'নিবন্ধনের পর তথ্য আপডেট করুন',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'নিবন্ধন সম্পন্ন হওয়ার পর আপনি "নিবন্ধন যাচাই করুন" সেকশনে গিয়ে আপনার সব তথ্য আপডেট করতে পারবেন।',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    '• ব্যাচ এবং মোবাইল নম্বর দিয়ে আপনার নিবন্ধন খুঁজুন\n• "আপডেট করুন" বাটনে ক্লিক করে সব তথ্য সম্পাদনা করুন',
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Register Button
            Obx(
              () => ElevatedButton(
                onPressed:
                    controller.isLoading.value
                        ? null
                        : () => _launchQuickRegistration(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                ),
                child:
                    controller.isLoading.value
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          'দ্রুত নিবন্ধন করুন',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchQuickRegistration() async {
    // Fill demo data for quick registration
    controller.fillQuickRegistrationDemoData();

    // Launch payment with quick registration flag
    await controller.launchRegistrationPayment(isQuickRegistration: true);
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8B6914),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: const Color(0xFFD4AF37)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8B6914),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: (value?.isEmpty ?? true) ? null : value,
          items:
              items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    String? Function(DateTime?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8B6914),
          ),
        ),
        const SizedBox(height: 8),
        FormField<DateTime>(
          validator: validator,
          builder: (FormFieldState<DateTime> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: state.hasError ? Colors.red : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade50,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Color(0xFFD4AF37),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          value != null
                              ? '${value.day}/${value.month}/${value.year}'
                              : 'জন্ম তারিখ নির্বাচন করুন',
                          style: TextStyle(
                            color: value != null ? Colors.black87 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      state.errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8B6914),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              onPressed: value > 0 ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove),
              style: IconButton.styleFrom(
                backgroundColor:
                    value > 0 ? const Color(0xFFD4AF37) : Colors.grey.shade300,
                foregroundColor: value > 0 ? Colors.white : Colors.grey,
                shape: const CircleBorder(),
              ),
            ),
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed:
                  (maxValue == null || value < maxValue)
                      ? () => onChanged(value + 1)
                      : null,
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor:
                    (maxValue == null || value < maxValue)
                        ? const Color(0xFFD4AF37)
                        : Colors.grey.shade300,
                foregroundColor:
                    (maxValue == null || value < maxValue)
                        ? Colors.white
                        : Colors.grey,
                shape: const CircleBorder(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _buildTotalAmountText(RegistrationController controller) {
    // Determine base fee based on student type and passing year
    int baseFee;
    String feeDescription;

    if (controller.isRunningStudent.value) {
      baseFee = 500; // Running students now pay 500
      feeDescription = 'বর্তমানে অধ্যয়নরত: 500 টাকা';
    } else {
      // For old students, check if they passed between 2019-2026
      final passingYear = controller.selectedSscPassingYear.value;
      if (passingYear != 'None') {
        final year = int.tryParse(passingYear);
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

    final int guestCount =
        controller.spouseCount.value + controller.childCount.value;
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
}

class FullDetailsTab extends StatelessWidget {
  const FullDetailsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const RegistrationPage();
  }
}
