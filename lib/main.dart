import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(TaniAIApp());
}

class TaniAIApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaniAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        cardTheme: CardTheme(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.green.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: CropRecommendationPage(),
    );
  }
}

class TanamanDetail {
  final String? nama;
  final String? deskripsi;
  final String? manfaat;
  final String? tips;

  TanamanDetail({this.nama, this.deskripsi, this.manfaat, this.tips});

  factory TanamanDetail.fromJson(Map<String, dynamic> json) {
    return TanamanDetail(
      nama: json['nama'],
      deskripsi: json['deskripsi'],
      manfaat: json['manfaat'],
      tips: json['tips'],
    );
  }
}

class CropRecommendationPage extends StatefulWidget {
  @override
  _CropRecommendationPageState createState() => _CropRecommendationPageState();
}

class _CropRecommendationPageState extends State<CropRecommendationPage> {
  final _formKey = GlobalKey<FormState>();
  double N = 0, P = 0, K = 0, temperature = 0, humidity = 0, ph = 0, rainfall = 0;
  String result = "";
  String imageUrl = "";
  TanamanDetail? detailTanaman;
  Map<String, dynamic>? dataTanaman;

  @override
  void initState() {
    super.initState();
    loadTanamanJson();
  }

  Future<void> loadTanamanJson() async {
    String jsonString = await rootBundle.loadString('assets/data_tanaman.json');
    setState(() {
      dataTanaman = jsonDecode(jsonString);
    });
  }

  Future<void> predictCrop() async {
    var url = Uri.parse('https://tani-ai-backend-production-e3c7.up.railway.app/predict');
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "N": N,
        "P": P,
        "K": K,
        "temperature": temperature,
        "humidity": humidity,
        "ph": ph,
        "rainfall": rainfall,
      }),
    );

    var data = jsonDecode(response.body);
    setState(() {
      result = data["rekomendasi"];
      imageUrl = data["gambar"];
      detailTanaman = getTanamanDetail(result);
    });
  }

  TanamanDetail? getTanamanDetail(String rekomendasi) {
    if (dataTanaman == null) return null;
    String key = rekomendasi.toLowerCase();
    if (dataTanaman!.containsKey(key)) {
      return TanamanDetail.fromJson(dataTanaman![key]);
    }
    return null;
  }

  Widget buildNumberField(String label, IconData icon, String hint, Function(String) onSaved) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.green),
          filled: true,
          fillColor: Colors.green.shade50,
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.green.shade200, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.green, width: 2),
          ),
        ),
        keyboardType: TextInputType.number,
        validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
        onSaved: (value) => onSaved(value!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(60)),
              ),
              child: Column(
                children: [
                  Icon(Icons.agriculture, size: 48, color: Colors.white),
                  SizedBox(height: 10),
                  Text("TaniAI",
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text("Rekomendasi Tanaman", style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      "TaniAI adalah aplikasi berbasis AI yang membantu Anda mengetahui tanaman apa yang paling cocok untuk lahan Anda berdasarkan data tanah dan cuaca.",
                      textAlign: TextAlign.left,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            // FORM & HASIL
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 420),
                child: Column(
                  children: [
                    Card(
                      margin: EdgeInsets.only(bottom: 24, top: 32),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(Icons.eco, color: Colors.green, size: 48),
                            SizedBox(height: 8),
                            Text(
                              "Masukkan Data Lahan",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Dapatkan rekomendasi tanaman terbaik untuk lahan Anda menggunakan AI.",
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16),
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  buildNumberField("Nitrogen", Icons.science, "Masukkan nilai Nitrogen (N)", (v) => N = double.parse(v)),
                                  buildNumberField("Fosfor", Icons.science_outlined, "Masukkan nilai Fosfor (P)", (v) => P = double.parse(v)),
                                  buildNumberField("Kalium", Icons.science_rounded, "Masukkan nilai Kalium (K)", (v) => K = double.parse(v)),
                                  buildNumberField("Suhu", Icons.thermostat, "Masukkan suhu lahan (°C)", (v) => temperature = double.parse(v)),
                                  buildNumberField("Kelembapan", Icons.water_drop, "Masukkan kelembapan (%)", (v) => humidity = double.parse(v)),
                                  buildNumberField("pH", Icons.eco, "Masukkan pH tanah", (v) => ph = double.parse(v)),
                                  buildNumberField("Curah Hujan", Icons.cloud, "Masukkan curah hujan (mm)", (v) => rainfall = double.parse(v)),
                                  SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        _formKey.currentState!.save();
                                        predictCrop();
                                      }
                                    },
                                    icon: Icon(Icons.search),
                                    label: Text("Prediksi Tanaman", style: TextStyle(fontSize: 18)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (result.isNotEmpty)
                      Card(
                        color: Colors.white,
                        margin: EdgeInsets.only(bottom: 24, top: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text("Rekomendasi Tanaman",
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                                ),
                              ),
                              SizedBox(height: 10),
                              Center(
                                child: Text(detailTanaman?.nama ?? result,
                                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                                ),
                              ),
                              SizedBox(height: 14),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: imageUrl.isNotEmpty
                                    ? Image.network(imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover)
                                    : Container(
                                        height: 180,
                                        color: Colors.green.shade100,
                                        child: Center(child: Text("Gambar tidak tersedia")),
                                      ),
                              ),
                              if (detailTanaman != null) ...[
                                SizedBox(height: 18),
                                if (detailTanaman!.deskripsi != null)
                                  ListTile(
                                    leading: Icon(Icons.info, color: Colors.green.shade700),
                                    title: Text("Deskripsi", style: TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text(detailTanaman!.deskripsi!),
                                  ),
                                if (detailTanaman!.manfaat != null)
                                  ListTile(
                                    leading: Icon(Icons.emoji_nature, color: Colors.green.shade700),
                                    title: Text("Manfaat", style: TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text(detailTanaman!.manfaat!),
                                  ),
                                if (detailTanaman!.tips != null)
                                  ListTile(
                                    leading: Icon(Icons.tips_and_updates, color: Colors.green.shade700),
                                    title: Text("Tips", style: TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text(detailTanaman!.tips!),
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Footer jika ingin
            Container(
              width: double.infinity,
              color: Colors.grey.shade200,
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "Dibuat oleh IK2C/2025/ALVINA/RAHMA/KecerdasanBuatan",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
