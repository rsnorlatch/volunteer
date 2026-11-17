import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:volunteer/controllers/facility_controller.dart';
import 'package:volunteer/data/models/facility.dart';
import 'package:volunteer/shared/constants/app_colors.dart';
import 'package:volunteer/shared/widgets/common_widgets.dart';
import 'package:volunteer/shared/widgets/primary_button.dart';
import 'package:volunteer/shared/widgets/sub_page_scaffold.dart';

class FacilitySearchPage extends StatefulWidget {
  const FacilitySearchPage({super.key});

  @override
  State<FacilitySearchPage> createState() => _FacilitySearchPageState();
}

class _FacilitySearchPageState extends State<FacilitySearchPage> {
  static const _groups = ['Semua', 'A+', 'B+', 'O+', 'AB+'];

  final _ctrl = Get.find<FacilityController>();
  final _name = TextEditingController();
  final _area = TextEditingController();
  String _group = 'Semua';
  late List<Facility> _results = _ctrl.search();

  @override
  void dispose() {
    _name.dispose();
    _area.dispose();
    super.dispose();
  }

  void _apply() {
    setState(() {
      _results =
          _ctrl.search(name: _name.text, group: _group, area: _area.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SubPageScaffold(
      title: 'Cari fasilitas darah',
      subtitle: 'Temukan fasilitas berdasarkan nama dan golongan darah.',
      children: [
        AppSearchField(hint: 'Nama fasilitas / instansi', controller: _name),
        const SizedBox(height: 18),
        const Text('Golongan darah',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final g in _groups)
              AppChoicePill(
                label: g,
                selected: _group == g,
                white: true,
                onTap: () => setState(() => _group = g),
              ),
          ],
        ),
        const SizedBox(height: 18),
        const Text('Lokasi',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        AppSearchField(
          hint: 'Kota / kecamatan / alamat',
          controller: _area,
          icon: Icons.my_location,
        ),
        const SizedBox(height: 18),
        PrimaryButton(text: 'Terapkan filter', onPressed: _apply),
        const SizedBox(height: 26),
        const Text('Hasil pencarian',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        if (_results.isEmpty)
          const EmptyState(
            icon: Icons.search_off_rounded,
            title: 'Fasilitas tidak ditemukan',
            message: 'Coba ubah filter pencarian.',
          )
        else
          for (final f in _results)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f.name,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 6),
                          Text('${f.address.split(',').first} • ${f.note}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusPill(
                      f.isOpen ? 'Buka' : 'Tutup',
                      tone: f.isOpen ? PillTone.success : PillTone.danger,
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
