import 'package:app_1/presentation/screens/main_app/profile/verification/cubits/verification_state.dart';
import 'package:app_1/presentation/screens/main_app/profile/verification/screens/verify_account_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_1/presentation/screens/main_app/profile/verification/cubits/verification_cubit.dart';
import 'package:app_1/core/theme/app_theme.dart';

class RequestVerificationScreen extends StatelessWidget {
  const RequestVerificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VerificationCubit(
        verificationRepository: context.read(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('تفعيل الحساب'),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppTheme.primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _RequestVerificationContent(),
      ),
    );
  }
}

class _RequestVerificationContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VerificationCubit, VerificationState>(
      listener: (context, state) {
        if (state is VerificationRequested) {
          // الانتقال إلى شاشة إدخال الرمز
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyAccountScreen(),
            ),
          );
        } else if (state is VerificationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              
              // أيقونة التحقق
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_outlined,
                  size: 60,
                  color: AppTheme.primaryColor,
                ),
              ),
              
              SizedBox(height: 30),
              
              // العنوان
              Text(
                'تفعيل حسابك',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              
              SizedBox(height: 16),
              
              // الوصف
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'تفعيل حسابك يمنحك مزايا حصرية ويحسن من ظهورك في المجتمع. سنرسل رمز تحقق مكون من 6 أرقام إلى بريدك الإلكتروني.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.6,
                  ),
                ),
              ),
              
              SizedBox(height: 40),
              
              // فوائد التفعيل
              _buildBenefitsList(),
              
              Spacer(),
              
              // زر طلب الرمز
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: state is VerificationLoading
                      ? null
                      : () {
                          context.read<VerificationCubit>().requestVerification();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: state is VerificationLoading
                      ? CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'إرسال رمز التحقق',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              
            
            ],
          ),
        );
      },
    );
  }

  Widget _buildBenefitsList() {
    final benefits = [
      {'icon': Icons.star_border, 'text': 'ترقية الرتبة إلى المستوى التالي'},
      {'icon': Icons.visibility, 'text': 'تحسين ظهورك في المجتمع'},
      {'icon': Icons.verified_user, 'text': 'حساب موثوق وجدير بالثقة'},
      {'icon': Icons.bolt, 'text': 'مزايا حصرية للمستخدمين الموثقين'},
    ];

    return Column(
      children: benefits.map((benefit) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  benefit['icon'] as IconData,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  benefit['text'] as String,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}