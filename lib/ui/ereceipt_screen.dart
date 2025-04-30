import 'package:flutter/material.dart';

class EReceiptScreen extends StatelessWidget {
  final List<Map<String, dynamic>> selectedProducts;

  EReceiptScreen({required this.selectedProducts});

  int getTotal() {
  return selectedProducts.fold(0, (sum, item) => sum + (item['harga'] as num).toInt());
}


  String generateReceiptText() {
    StringBuffer buffer = StringBuffer();
    buffer.writeln("E-Receipt");
    buffer.writeln("===============");
    for (var p in selectedProducts) {
      buffer.writeln("${p['nama']} - Rp${p['harga']}");
    }
    buffer.writeln("===============");
    buffer.writeln("Total: Rp${getTotal()}");
    return buffer.toString();
  }

  void shareReceipt(BuildContext context) {
    final receipt = generateReceiptText();

    // NOTE: This doesn't share yet unless you install a package like 'share_plus'
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Share"),
        content: Text("Ini teks e-receipt:\n\n$receipt"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Tutup")),
        ],
      ),
    );

    // Jika suatu saat pakai library:
    // Share.share(receipt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("E-Receipt")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Produk yang Dibeli:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            ...selectedProducts.map((p) => ListTile(
                  title: Text(p['nama']),
                  subtitle: Text("Rp${p['harga']}"),
                )),
            Divider(),
            Text("Total: Rp${getTotal()}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => shareReceipt(context),
                icon: Icon(Icons.share),
                label: Text("Bagikan E-Receipt"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
