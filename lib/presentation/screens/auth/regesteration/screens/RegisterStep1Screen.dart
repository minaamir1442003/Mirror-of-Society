import 'package:app_1/presentation/providers/language_provider.dart';
import 'package:app_1/presentation/screens/auth/regesteration/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/RegisterData.dart';

class RegisterStep1Screen extends StatefulWidget {
  const RegisterStep1Screen({Key? key}) : super(key: key);

  @override
  _RegisterStep1ScreenState createState() => _RegisterStep1ScreenState();
}

class _RegisterStep1ScreenState extends State<RegisterStep1Screen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _goToNextStep(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final registerData = RegisterData(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: '',
        password: '',
      );
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterStep2Screen(registerData: registerData),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = context.read<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          langProvider.isArabic ? 'المرحلة 1: المعلومات الشخصية' : 'Step 1: Personal Information',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    langProvider.isArabic ? '1 من 4' : '1 of 4',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 0.25,
                    backgroundColor: Colors.grey[200],
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    langProvider.isArabic ? 'المعلومات الشخصية' : 'Personal Information',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: langProvider.isArabic ? 'الاسم الأول' : 'First Name',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return langProvider.isArabic
                            ? 'يرجى إدخال الاسم الأول'
                            : 'Please enter first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: langProvider.isArabic ? 'الاسم الأخير' : 'Last Name',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return langProvider.isArabic
                            ? 'يرجى إدخال الاسم الأخير'
                            : 'Please enter last name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _goToNextStep(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        langProvider.isArabic ? 'التالي' : 'Next',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}