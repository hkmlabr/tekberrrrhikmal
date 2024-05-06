import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController nimController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  late dynamic db = null;
  List<Map<String, Object?>> mahasiswa = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setupDatabase();
  }

  void setupDatabase() async {
    final database = openDatabase(
      join(await getDatabasesPath(), 'mahasiswa_db.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE mahasiswa(id INTEGER PRIMARY KEY, nama TEXT, nim TEXT)',
        );
      },
      version: 1,
    );
    db = await database;

    retrieve();
  }

  void save() async {
    await db.insert(
      'mahasiswa',
      {"nama": namaController.text, "nim": nimController.text},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    retrieve();
  }

  void retrieve() async {
    final List<Map<String, Object?>> mahasiswa = await db.query('mahasiswa');
    setState(() {
      this.mahasiswa = mahasiswa;
    });
  }

  void deleteRow(id) async {
    await db.delete(
      'mahasiswa',
      // Use a `where` clause to delete a specific dog.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
    retrieve();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Input Data Mahasiswa")),
      body: Container(
        padding: EdgeInsets.all(20),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            TextField(
              controller: nimController,
              decoration: const InputDecoration(
                label: Text("NIM"),
              ),
            ),
            TextField(
              controller: namaController,
              decoration: const InputDecoration(
                label: Text("Nama Mahasiswa"),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                save();
              },
              child: Text("Simpan Data Mahasiswa"),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(
                        label: Text('Nama'),
                      ),
                      DataColumn(
                        label: Text('Nim'),
                      ),
                      DataColumn(
                        label: Text('Action'),
                      ),
                    ],
                    rows: mahasiswa
                        .map(
                          (e) => DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  e['nim'].toString(),
                                ),
                              ),
                              DataCell(
                                Text(
                                  e['nama'].toString(),
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  onPressed: () {
                                    deleteRow(e['id']);
                                  },
                                  icon: Icon(Icons.delete),
                                ),
                              )
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
