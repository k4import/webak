import 'package:flutter/material.dart';
import 'package:webak/core/theme/app_theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المساعدة'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle('كيفية استخدام التطبيق'),
          _buildHelpCard(
            'إضافة مهمة جديدة',
            'اضغط على زر + في الشاشة الرئيسية لإضافة مهمة جديدة. قم بإدخال عنوان المهمة والوصف والموعد النهائي ثم اضغط على حفظ.',
            Icons.add_task,
          ),
          _buildHelpCard(
            'تعديل مهمة',
            'اضغط على المهمة التي تريد تعديلها، ثم قم بتعديل البيانات المطلوبة واضغط على حفظ.',
            Icons.edit,
          ),
          _buildHelpCard(
            'حذف مهمة',
            'اسحب المهمة من اليمين إلى اليسار لحذفها، أو اضغط على المهمة ثم اضغط على زر الحذف.',
            Icons.delete,
          ),
          _buildHelpCard(
            'تصفية المهام',
            'استخدم خيارات التصفية في أعلى الشاشة لعرض المهام حسب الحالة (قيد التنفيذ، مكتملة، متأخرة).',
            Icons.filter_list,
          ),
          
          const SizedBox(height: 24),
          _buildSectionTitle('الأسئلة الشائعة'),
          _buildFAQItem(
            'كيف يمكنني تغيير كلمة المرور؟',
            'يمكنك تغيير كلمة المرور من خلال الذهاب إلى الإعدادات > الحساب > تغيير كلمة المرور.',
          ),
          _buildFAQItem(
            'هل يمكنني استخدام التطبيق بدون اتصال بالإنترنت؟',
            'نعم، يمكنك استخدام التطبيق بدون اتصال بالإنترنت، لكن لن تتمكن من مزامنة البيانات مع الخادم حتى تتصل بالإنترنت مرة أخرى.',
          ),
          _buildFAQItem(
            'كيف يمكنني استعادة حسابي إذا نسيت كلمة المرور؟',
            'يمكنك استعادة حسابك من خلال الضغط على "نسيت كلمة المرور" في شاشة تسجيل الدخول واتباع التعليمات.',
          ),
          _buildFAQItem(
            'هل يمكنني مشاركة المهام مع الآخرين؟',
            'حالياً، لا يدعم التطبيق مشاركة المهام مع المستخدمين الآخرين، لكن هذه الميزة قيد التطوير وستتوفر قريباً.',
          ),
          
          const SizedBox(height: 24),
          _buildSectionTitle('الدعم الفني'),
          _buildContactCard(),
          
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: () {
                _showTutorial(context);
              },
              child: const Text('عرض الدليل التفصيلي'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppTheme.primary,
        ),
      ),
    );
  }

  Widget _buildHelpCard(String title, String description, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            answer,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تواصل معنا',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildContactItem(Icons.email, 'البريد الإلكتروني', 'support@webak.com'),
            const SizedBox(height: 8),
            _buildContactItem(Icons.phone, 'الهاتف', '+966 123 456 789'),
            const SizedBox(height: 8),
            _buildContactItem(Icons.language, 'الموقع الإلكتروني', 'www.webak.com'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(value),
      ],
    );
  }

  void _showTutorial(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الدليل التفصيلي'),
        content: const Text(
          'سيتم تنفيذ هذه الميزة قريباً. ستتضمن دليلاً تفصيلياً خطوة بخطوة لاستخدام جميع ميزات التطبيق.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}