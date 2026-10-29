import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../models/visitor.dart';
import '../providers/visitor_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'visitor_details.dart';

class VisitorForm extends StatefulWidget {
  final Visitor? visitor;
  const VisitorForm({super.key, this.visitor});

  @override
  State<VisitorForm> createState() => _VisitorFormState();
}

class _VisitorFormState extends State<VisitorForm> {
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final purposeCtrl = TextEditingController();

  late String visitorType;
  late String project;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final v = widget.visitor;
    nameCtrl.text = v?.name ?? '';
    phoneCtrl.text = v?.mobile ?? '';
    emailCtrl.text = v?.email ?? '';
    purposeCtrl.text = v?.purpose ?? '';

    visitorType = AppConstants.visitorTypes.contains(v?.visitorType)
        ? v!.visitorType
        : AppConstants.visitorTypes.first;

    project = AppConstants.projects.contains(v?.project)
        ? v!.project
        : AppConstants.projects.first;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    purposeCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final v = Visitor(
      id: widget.visitor?.id ?? '',
      name: nameCtrl.text.trim(),
      mobile: phoneCtrl.text.trim(),
      email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
      visitorType: visitorType,
      project: project,
      purpose: purposeCtrl.text.trim(),
      status: widget.visitor?.status ?? VisitorStatus.registered.label,
      checkInTime: widget.visitor?.checkInTime,
      checkOutTime: widget.visitor?.checkOutTime,
      createdAt: widget.visitor?.createdAt ?? DateTime.now().toUtc().toIso8601String(),
    );

    final provider = context.read<VisitorProvider>();

    try {
      if (widget.visitor != null) {
        await provider.updateVisitor(v);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Visitor updated successfully!'),
              backgroundColor: Color(0xFF16A34A),
            ),
          );
          Navigator.pop(context, v);
        }
      } else {
        final created = await provider.addVisitor(v);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Visitor registered successfully!'),
              backgroundColor: Color(0xFF16A34A),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => VisitorDetails(visitor: created),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.visitor != null;
    final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Visitor Pass' : 'New Visitor Pass'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              controller: nameCtrl,
              label: 'Visitor Name *',
              hint: 'e.g. Rahul Sharma',
              prefixIcon: Icons.person_outline,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Visitor name is required';
                return null;
              },
            ),
            const SizedBox(height: 14),

            CustomTextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              label: 'Mobile Number * (10 Digits)',
              hint: '10-digit mobile number',
              prefixIcon: Icons.phone_android_outlined,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (v) {
                if (v == null || v.trim().length != 10) {
                  return 'Enter a valid 10-digit mobile number';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            CustomTextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              label: 'Email (Optional)',
              hint: 'e.g. rahul@example.com',
              prefixIcon: Icons.email_outlined,
              validator: (val) {
                if (val == null || val.trim().isEmpty) return null;
                return emailRegex.hasMatch(val.trim()) ? null : 'Enter a valid email address';
              },
            ),
            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              initialValue: visitorType,
              decoration: InputDecoration(
                labelText: 'Visitor Type',
                prefixIcon: const Icon(Icons.badge_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: AppConstants.visitorTypes
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => visitorType = v!),
            ),
            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              initialValue: project,
              decoration: InputDecoration(
                labelText: 'Project Site',
                prefixIcon: const Icon(Icons.business_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: AppConstants.projects
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => project = v!),
            ),
            const SizedBox(height: 14),

            CustomTextField(
              controller: purposeCtrl,
              label: 'Purpose of Visit *',
              hint: 'e.g. Property Inspection / Meeting',
              prefixIcon: Icons.description_outlined,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Purpose of visit is required';
                return null;
              },
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('CANCEL'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: isEdit ? 'SAVE CHANGES' : 'GENERATE PASS',
                    icon: isEdit ? Icons.save_outlined : Icons.qr_code,
                    isLoading: _isSubmitting,
                    onPressed: _save,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
