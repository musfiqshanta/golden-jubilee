import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/registration_controller.dart';

class RegistrationPage extends GetView<RegistrationController> {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'নিবন্ধন ফর্ম',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFD4AF37),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
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
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Demo Data and Test Buttons
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ElevatedButton.icon(
                        //   icon: const Icon(Icons.picture_as_pdf, size: 18),
                        //   label: const Text(
                        //     'ইংরেজি পিডিএফ টেস্ট',
                        //     style: TextStyle(fontSize: 12),
                        //   ),
                        //   style: ElevatedButton.styleFrom(
                        //     backgroundColor: Colors.green.shade100,
                        //     foregroundColor: Colors.black87,
                        //     padding: const EdgeInsets.symmetric(
                        //       horizontal: 12,
                        //       vertical: 8,
                        //     ),
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(8),
                        //     ),
                        //     elevation: 0,
                        //   ),
                        //   onPressed: controller.generateAndOpenInvoice,
                        // ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: ElevatedButton.icon(
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
                            onPressed: controller.fillDemoData,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // ElevatedButton.icon(
                    //   icon: const Icon(Icons.picture_as_pdf, size: 18),
                    //   label: const Text(
                    //     'বাংলা পিডিএফ টেস্ট',
                    //     style: TextStyle(fontSize: 12),
                    //   ),
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.orange.shade100,
                    //     foregroundColor: Colors.black87,
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 12,
                    //       vertical: 8,
                    //     ),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //     elevation: 0,
                    //   ),
                    //  onPressed: controller.testBengaliPdfGeneration,
                    // ),
                    // ElevatedButton.icon(
                    //   icon: const Icon(Icons.picture_as_pdf, size: 18),
                    //   label: const Text(
                    //     'বাংলা পিডিএফ',
                    //     style: TextStyle(fontSize: 12),
                    //   ),
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.deepOrange.shade100,
                    //     foregroundColor: Colors.black87,
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 12,
                    //       vertical: 8,
                    //     ),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //     elevation: 0,
                    //   ),
                    //   onPressed: controller.generateRegistrationPdf,
                    // ),
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
                        Icons.school,
                        size: 50,
                        color: Color(0xFFD4AF37),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'সুবর্ণজয়ন্তী নিবন্ধন',
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
                        '৫০ বছর পূর্তি উদযাপনে আমাদের সাথে যোগ দিন',
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
                    controller: controller.nameController,
                    label: 'পূর্ণ নাম',
                    icon: Icons.person_outline,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'আপনার পূর্ণ নাম লিখুন'
                                : null,
                  ),
                  const SizedBox(height: 15),
                  _textField(
                    controller: controller.fatherNameController,
                    label: 'পিতার নাম',
                    icon: Icons.person_outline,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'আপনার পিতার নাম লিখুন'
                                : null,
                  ),
                  const SizedBox(height: 15),
                  _textField(
                    controller: controller.motherNameController,
                    label: 'মাতার নাম',
                    icon: Icons.person_outline,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'আপনার মাতার নাম লিখুন'
                                : null,
                  ),
                  const SizedBox(height: 15),
                  Obx(
                    () => _dropdownField(
                      label: 'লিঙ্গ',
                      value: controller.selectedGender.value ?? '',
                      items: ['পুরুষ', 'মহিলা', 'অন্যান্য'],
                      onChanged:
                          (value) =>
                              controller.selectedGender.value = value ?? '',
                    ),
                  ),
                  const SizedBox(height: 15),
                  Obx(
                    () => _dateField(
                      label: 'জন্ম তারিখ',
                      value: controller.selectedDateOfBirth.value,
                      onTap: () => controller.selectDateOfBirth(context),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _textField(
                    controller: controller.nationalIdController,
                    label: 'জাতীয় পরিচয়পত্র নম্বর',
                    icon: Icons.badge_outlined,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'আপনার জাতীয় পরিচয়পত্র নম্বর লিখুন'
                                : null,
                  ),
                ]),
                const SizedBox(height: 20),
                // Contact Information Section
                _sectionCard('যোগাযোগের তথ্য (ইংলিশ)', Icons.contact_phone, [
                  _textField(
                    controller: controller.mobileController,
                    label: 'মোবাইল নম্বর',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'আপনার মোবাইল নম্বর লিখুন'
                                : null,
                  ),
                  const SizedBox(height: 15),
                  _textField(
                    controller: controller.emailController,
                    label: 'ইমেইল ঠিকানা',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'আপনার ইমেইল লিখুন';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}',
                      ).hasMatch(value)) {
                        return 'সঠিক ইমেইল লিখুন';
                      }
                      return null;
                    },
                  ),
                ]),
                const SizedBox(height: 20),
                // Address Information Section
                _sectionCard('ঠিকানা', Icons.location_on, [
                  _textField(
                    controller: controller.permanentAddressController,
                    label: 'স্থায়ী ঠিকানা',
                    icon: Icons.home_outlined,
                    maxLines: 3,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'আপনার স্থায়ী ঠিকানা লিখুন'
                                : null,
                  ),
                  const SizedBox(height: 15),
                  _textField(
                    controller: controller.presentAddressController,
                    label: 'বর্তমান ঠিকানা',
                    icon: Icons.home_outlined,
                    maxLines: 3,
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
                  _textField(
                    controller: controller.occupationController,
                    label: 'পেশা',
                    icon: Icons.work_outline,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'আপনার পেশা লিখুন'
                                : null,
                  ),
                  const SizedBox(height: 15),
                  _textField(
                    controller: controller.designationController,
                    label: 'পদবী',
                    icon: Icons.badge_outlined,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'আপনার পদবী লিখুন'
                                : null,
                  ),
                  const SizedBox(height: 15),
                  _textField(
                    controller: controller.workplaceAddressController,
                    label: 'কর্মস্থলের ঠিকানা',
                    icon: Icons.business_outlined,
                    maxLines: 3,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'আপনার কর্মস্থলের ঠিকানা লিখুন'
                                : null,
                  ),
                ]),
                const SizedBox(height: 20),
                // Personal Details Section
                _sectionCard('ব্যক্তিগত বিবরণ', Icons.info, [
                  Obx(
                    () => _dropdownField(
                      label: 'জাতীয়তা',
                      value: controller.selectedNationality.value ?? '',
                      items: controller.nationalities,
                      onChanged:
                          (value) =>
                              controller.selectedNationality.value =
                                  value ?? '',
                    ),
                  ),
                  const SizedBox(height: 15),
                  Obx(
                    () => _dropdownField(
                      label: 'ধর্ম',
                      value: controller.selectedReligion.value ?? '',
                      items: controller.religions,
                      onChanged:
                          (value) =>
                              controller.selectedReligion.value = value ?? '',
                    ),
                  ),
                ]),
                const SizedBox(height: 20),
                // Academic Information Section
                _sectionCard('শিক্ষাগত তথ্য', Icons.school, [
                  Obx(
                    () => Row(
                      children: [
                        Checkbox(
                          value: controller.isRunningStudent.value,
                          onChanged:
                              (val) =>
                                  controller.isRunningStudent.value =
                                      val ?? false,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'বর্তমানে অধ্যয়নরত',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Obx(
                    () =>
                        controller.isRunningStudent.value
                            ? Row(
                              children: [
                                Expanded(
                                  child: _dropdownField(
                                    label: 'শেষ শ্রেণি',
                                    value:
                                        controller.selectedFinalClass.value ??
                                        '',
                                    items: controller.finalClasses,
                                    onChanged:
                                        (value) =>
                                            controller
                                                .selectedFinalClass
                                                .value = value ?? '',
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: _dropdownField(
                                    label: 'বছর',
                                    value: controller.selectedYear.value ?? '',
                                    items: controller.years,
                                    onChanged:
                                        (value) =>
                                            controller.selectedYear.value =
                                                value ?? '',
                                  ),
                                ),
                              ],
                            )
                            : _dropdownField(
                              label: 'এসএসসি পাশের বছর',
                              value:
                                  controller.selectedSscPassingYear.value ?? '',
                              items: controller.sscPassingYears,
                              onChanged:
                                  (value) =>
                                      controller.selectedSscPassingYear.value =
                                          value ?? '',
                            ),
                  ),
                ]),
                const SizedBox(height: 20),
                // Family Participation Section
                _sectionCard(
                  'পরিবারের অংশগ্রহণ (সর্বোচ্চ ২ জন)',
                  Icons.family_restroom,
                  [
                    Obx(
                      () => Row(
                        children: [
                          Expanded(
                            child: _customNumberField(
                              label: 'অংশগ্রহণকারী স্বামী/স্ত্রী',
                              value: controller.spouseCount.value,
                              max: 4,
                              onChanged:
                                  (value) =>
                                      controller.spouseCount.value = value,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _customNumberField(
                              label: 'সন্তান',
                              value: controller.childCount.value,
                              max: 3,
                              onChanged:
                                  (value) =>
                                      controller.childCount.value = value,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // T-shirt Size Dropdown
                _sectionCard('টি-শার্টের সাইজ', Icons.checkroom, [
                  Obx(
                    () => DropdownButtonFormField<String>(
                      value:
                          (controller.selectedTshirtSize.value == null ||
                                  controller.selectedTshirtSize.value == '' ||
                                  !controller.tshirtSizes.contains(
                                    controller.selectedTshirtSize.value,
                                  ))
                              ? null
                              : controller.selectedTshirtSize.value,
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
                          controller.tshirtSizes
                              .map(
                                (size) => DropdownMenuItem<String>(
                                  value: size,
                                  child: Text(size),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (value) =>
                              controller.selectedTshirtSize.value = value ?? '',
                      validator:
                          (value) =>
                              value == null
                                  ? 'টি-শার্ট সাইজ নির্বাচন করুন'
                                  : null,
                    ),
                  ),
                ]),
                const SizedBox(height: 20),
                // Total Amount Card
                _sectionCard('মোট জমার পরিমাণ', Icons.attach_money, [
                  Obx(
                    () => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        _buildTotalAmountText(controller),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B6914),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: const Color(0xFFFFF3E0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(
                        color: Color(0xFFFF9800),
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
                          Icon(Icons.info_outline, color: Color(0xFFFF9800)),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'নিবন্ধন ফি ব্যাচ প্রতিনিধি বরাবর জমা দিতে হবে।',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFFBF360C),
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
                // Photo Upload Section
                _sectionCard('ছবি আপলোড', Icons.camera_alt, [
                  Obx(
                    () => GestureDetector(
                      onTap: controller.pickPhoto,
                      child: Container(
                        width: double.infinity,
                        height: 220,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                controller.photoError.value != null
                                    ? Colors.red
                                    : const Color(0xFFD4AF37),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[100],
                        ),
                        child:
                            (controller.selectedPhoto.value != null &&
                                    controller.selectedPhoto.value!.bytes !=
                                        null)
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    controller.selectedPhoto.value!.bytes!,
                                    fit: BoxFit.contain,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                )
                                : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add_a_photo,
                                      size: 40,
                                      color: Color(0xFFD4AF37),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'ছবি আপলোড করুন',
                                      style: TextStyle(
                                        color: Color(0xFFD4AF37),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'সর্বোচ্চ সাইজ: ৩ এমবি',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    ),
                  ),
                  Obx(
                    () =>
                        controller.photoError.value != null
                            ? Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                controller.photoError.value!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            )
                            : const SizedBox(),
                  ),
                  Obx(
                    () =>
                        (controller.selectedPhoto.value != null)
                            ? Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'File: ${controller.selectedPhoto.value!.name}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    'Size: ${(controller.selectedPhoto.value!.size / 1024).toStringAsFixed(1)} KB',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : const SizedBox(),
                  ),
                ]),
                const SizedBox(height: 30),
                // Submit Button
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (controller.formKey.currentState!.validate() &&
                          controller.selectedTshirtSize.value != null &&
                          controller.selectedPhoto.value != null) {
                        await controller.saveRegistration();
                      } else if (controller.selectedTshirtSize.value == null) {
                        Get.snackbar(
                          'ত্রুটি',
                          'টি-শার্ট সাইজ নির্বাচন করুন',
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                      } else if (controller.selectedPhoto.value == null) {
                        controller.photoError.value =
                            'ছবি আপলোড করা বাধ্যতামূলক';
                        Get.snackbar(
                          'ত্রুটি',
                          'ছবি আপলোড করা বাধ্যতামূলক',
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'নিবন্ধন জমা দিন',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B6914),
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
  }) {
    return TextFormField(
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
          items
              .map(
                (item) =>
                    DropdownMenuItem<String>(value: item, child: Text(item)),
              )
              .toList(),
      onChanged: onChanged,
      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFD4AF37)),
    );
  }

  Widget _dateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
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
      ),
    );
  }

  Widget _customNumberField({
    required String label,
    required int value,
    required int max,
    required void Function(int) onChanged,
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
              onPressed: value < max ? () => onChanged(value + 1) : null,
              icon: const Icon(Icons.add_circle_outline),
              color: const Color(0xFFD4AF37),
            ),
          ],
        ),
      ],
    );
  }

  String _buildTotalAmountText(RegistrationController controller) {
    final int baseFee = controller.isRunningStudent.value ? 700 : 1200;
    final int guestCount =
        controller.spouseCount.value + controller.childCount.value;
    final int guestFee = guestCount * 500;
    final int total = baseFee + guestFee;
    String details =
        controller.isRunningStudent.value
            ? 'বর্তমানে অধ্যয়নরত: 700 টাকা'
            : 'প্রাক্তন শিক্ষার্থী: 1200 টাকা';
    details += '\nপরিবারের সদস্য ($guestCount জন): $guestFee টাকা';
    details += '\n-----------------------------';
    details += '\nমোট: $total টাকা';
    return details;
  }
}
