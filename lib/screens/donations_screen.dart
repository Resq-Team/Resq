import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';

class DonationsScreen extends StatefulWidget {
  const DonationsScreen({super.key});

  @override
  State<DonationsScreen> createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> {
  int _donationType = 0; // 0: Money, 1: Items
  final TextEditingController _amountController = TextEditingController(text: '2500');
  final TextEditingController _itemsController = TextEditingController();
  final TextEditingController _donorNameController = TextEditingController();

  String _selectedPurpose = 'Flood Relief';
  String _selectedPaymentMethod = 'Credit / Debit Card';
  bool _isProcessing = false;

  final List<String> _purposes = [
    'Flood Relief',
    'Emergency Medical Supplies',
    'Community Kitchen Rations',
    'Shelter Bedding & Blankets',
    'Children Welfare Fund',
  ];

  final List<String> _paymentMethods = [
    'Credit / Debit Card',
    'Bank Direct Transfer',
    'eZ Cash / mCash Mobile',
    'Google Pay / Apple Pay',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _itemsController.dispose();
    _donorNameController.dispose();
    super.dispose();
  }

  // Firestore එකට Donation Data Save කිරීමේ Method එක
  Future<void> _submitDonation() async {
    // Validation Checks
    if (_donationType == 0) {
      if (_amountController.text.trim().isEmpty ||
          double.tryParse(_amountController.text.trim()) == null ||
          double.parse(_amountController.text.trim()) <= 0) {
        _showSnackBar('Please enter a valid amount');
        return;
      }
    } else {
      if (_itemsController.text.trim().isEmpty) {
        _showSnackBar('Please enter item details and quantity');
        return;
      }
    }

    setState(() => _isProcessing = true);

    try {
      final String donorName = _donorNameController.text.trim().isEmpty
          ? 'Anonymous Donor'
          : _donorNameController.text.trim();

      // Firestore හි 'donations' collection එකට Record එක එකතු කිරීම
      await FirebaseFirestore.instance.collection('donations').add({
        'type': _donationType == 0 ? 'Money' : 'Items',
        'amount': _donationType == 0 ? double.tryParse(_amountController.text.trim()) ?? 0.0 : 0.0,
        'itemDetails': _donationType == 1 ? _itemsController.text.trim() : '',
        'purpose': _selectedPurpose,
        'paymentMethod': _donationType == 0 ? _selectedPaymentMethod : 'N/A (Physical Items)',
        'donorName': donorName,
        'status': 'Completed',
        'transactionId': 'TXN_${DateTime.now().millisecondsSinceEpoch}',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // Success Dialog එක පෙන්වීම
      _showSuccessDialog();

    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to save donation: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.emergencyRedLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.volunteer_activism_rounded,
                    color: AppColors.emergencyRed,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Donation Received!',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _donationType == 0
                      ? 'Thank you for contributing LKR ${_amountController.text} towards $_selectedPurpose. Record has been saved.'
                      : 'Thank you for donating items towards $_selectedPurpose. Our team will contact you soon.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Dialog එක Close කිරීම
                    Navigator.pop(context); // Screen එකෙන් Back යාම
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emergencyRed,
                    minimumSize: const Size(double.infinity, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Done',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Make a Donation',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Segmented Toggle: Money vs Items
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _donationType = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _donationType == 0 ? AppColors.emergencyRed : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Money',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _donationType == 0 ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _donationType = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _donationType == 1 ? AppColors.emergencyRed : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Items',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _donationType == 1 ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Donor Name Field (Optional)
            Text(
              'Your Name (Optional)',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _donorNameController,
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Leave blank to donate anonymously',
                hintStyle: GoogleFonts.poppins(fontSize: 12, color: AppColors.textLight),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (_donationType == 0) ...[
              // Amount (LKR)
              Text(
                'Amount (LKR)',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  prefixText: 'LKR  ',
                  prefixStyle: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryNavy,
                  ),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Quick Amount Chips
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['500', '1000', '2500', '5000'].map((amt) {
                  return GestureDetector(
                    onTap: () => setState(() => _amountController.text = amt),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _amountController.text == amt
                              ? AppColors.emergencyRed
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        'LKR $amt',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: _amountController.text == amt
                              ? AppColors.emergencyRed
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ] else ...[
              // Items Donation form
              Text(
                'Item Description & Quantity',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _itemsController,
                maxLines: 3,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'e.g. 50 packs of dry rations, 20 blankets...',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Purpose Dropdown
            Text(
              'Purpose',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPurpose,
                  isExpanded: true,
                  items: _purposes.map((p) {
                    return DropdownMenuItem<String>(
                      value: p,
                      child: Text(p, style: GoogleFonts.poppins(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedPurpose = val);
                  },
                ),
              ),
            ),

            if (_donationType == 0) ...[
              const SizedBox(height: 20),
              // Payment Method Dropdown
              Text(
                'Payment Method',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPaymentMethod,
                    isExpanded: true,
                    items: _paymentMethods.map((m) {
                      return DropdownMenuItem<String>(
                        value: m,
                        child: Text(m, style: GoogleFonts.poppins(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedPaymentMethod = val);
                    },
                  ),
                ),
              ),
            ],

            const SizedBox(height: 36),

            // Donate Now Button
            ElevatedButton(
              onPressed: _isProcessing ? null : _submitDonation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emergencyRed,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text(
                      'Donate Now',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),

            const SizedBox(height: 18),

            // Thank you for your support
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite, color: AppColors.emergencyRed, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Thank you for your support!',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.emergencyRed,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}