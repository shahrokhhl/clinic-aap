import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../config/modules_config.dart';
import '../theme/app_theme.dart';

IconData _iconFor(String name) {
  const map = {
    'chart-pie': FontAwesomeIcons.chartPie,
    'file-invoice': FontAwesomeIcons.fileInvoice,
    'folder-user': FontAwesomeIcons.folderOpen,
    'hospital': FontAwesomeIcons.hospital,
    'stethoscope': FontAwesomeIcons.stethoscope,
    'note-sticky': FontAwesomeIcons.noteSticky,
    'tooth': FontAwesomeIcons.tooth,
    'shield-heart': FontAwesomeIcons.shieldHeart,
    'money-bill-transfer': FontAwesomeIcons.moneyBillTransfer,
    'sack-dollar': FontAwesomeIcons.sackDollar,
    'building-columns': FontAwesomeIcons.buildingColumns,
    'hand-holding-dollar': FontAwesomeIcons.handHoldingDollar,
    'file-invoice-dollar': FontAwesomeIcons.fileInvoiceDollar,
    'gear': FontAwesomeIcons.gear,
    'user-doctor': FontAwesomeIcons.userDoctor,
    'user-tie': FontAwesomeIcons.userTie,
    'users-gear': FontAwesomeIcons.usersGear,
  };
  return map[name] ?? FontAwesomeIcons.circle;
}

class AppSidebar extends StatelessWidget {
  final String selectedKey;
  final ValueChanged<String> onSelect;
  final bool collapsed;

  const AppSidebar({
    super.key,
    required this.selectedKey,
    required this.onSelect,
    this.collapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: collapsed ? 76 : 264,
      color: AppColors.sidebar,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(FontAwesomeIcons.notesMedical, color: Colors.white, size: 18),
                  ),
                  if (!collapsed) ...[
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'کلینیک نوراژ',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (final group in navGroups) ...[
                    if (!collapsed)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 16, 10, 6),
                        child: Text(
                          group.title,
                          style: const TextStyle(
                            color: Color(0xFF8B87B0),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    for (final item in group.items) _NavTile(
                      item: item,
                      selected: selectedKey == item.key,
                      collapsed: collapsed,
                      onTap: () => onSelect(item.key),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final NavItem item;
  final bool selected;
  final bool collapsed;
  final VoidCallback onTap;

  const _NavTile({
    required this.item,
    required this.selected,
    required this.collapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: selected ? AppColors.sidebarActive : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                FaIcon(
                  _iconFor(item.icon),
                  size: 16,
                  color: selected ? Colors.white : const Color(0xFFB4B0D6),
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? Colors.white : const Color(0xFFD3D0EA),
                        fontSize: 13.5,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
