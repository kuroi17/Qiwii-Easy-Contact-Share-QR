import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

const navy = Color(0xFF17243A);
const teal = Color(0xFF0E8C86);
const mint = Color(0xFFDDF3ED);
const ivory = Color(0xFFF8F7F3);
const slate = Color(0xFF667085);
const border = Color(0xFFE8E7E2);
const success = Color(0xFF2F7D5A);
const amber = Color(0xFFC98222);

class Contact {
  const Contact({
    required this.id,
    required this.name,
    required this.phone,
    required this.initials,
  });
  final String id;
  final String name;
  final String phone;
  final String initials;
}

const demoContacts = [
  Contact(id: '1', name: 'Maya Chen', phone: '+1 415 555 0198', initials: 'MC'),
  Contact(
    id: '2',
    name: 'Jordan Rivera',
    phone: '+1 415 555 0142',
    initials: 'JR',
  ),
  Contact(
    id: '3',
    name: 'Amara Okafor',
    phone: '+1 628 555 0116',
    initials: 'AO',
  ),
  Contact(
    id: '4',
    name: 'Theo Martin',
    phone: '+1 510 555 0164',
    initials: 'TM',
  ),
  Contact(
    id: '5',
    name: 'Nina Patel',
    phone: '+1 650 555 0137',
    initials: 'NP',
  ),
  Contact(id: '6', name: 'Liam Park', phone: '+1 408 555 0121', initials: 'LP'),
];

void main() => runApp(const ContactQrApp());

class ContactQrApp extends StatelessWidget {
  const ContactQrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ContactQR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: ivory,
        colorScheme: ColorScheme.fromSeed(seedColor: teal),
      ),
      home: const HomeScreen(),
    );
  }
}

class Shell extends StatelessWidget {
  const Shell({super.key, required this.child, this.dark = false});
  final Widget child;
  final bool dark;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: dark ? navy : ivory,
    body: SafeArea(child: child),
  );
}

class Header extends StatelessWidget {
  const Header({super.key, required this.title, this.light = false});
  final String title;
  final bool light;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back_ios_new,
          size: 18,
          color: light ? Colors.white : navy,
        ),
      ),
      Expanded(
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: light ? Colors.white : navy,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
      const SizedBox(width: 48),
    ],
  );
}

class CardBox extends StatelessWidget {
  const CardBox({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: border),
    ),
    child: child,
  );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
    child: SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon ?? Icons.arrow_forward),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: navy,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    ),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Shell(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: navy,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.contact_page, color: Colors.white),
              ),
              const SizedBox(width: 10),
              const Text(
                'ContactQR',
                style: TextStyle(
                  color: navy,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 62),
          const Text(
            'PRIVATE BY DESIGN',
            style: TextStyle(
              color: teal,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Move the right contacts, not your whole address book.',
            style: TextStyle(
              color: navy,
              fontSize: 35,
              height: 1.14,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.1,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Select a few people, show a QR code, and let the receiver choose what to save.',
            style: TextStyle(color: slate, fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 38),
          ActionTile(
            icon: Icons.north_east,
            color: navy,
            title: 'Send contacts',
            subtitle: 'Choose who to share',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SendScreen()),
            ),
          ),
          const SizedBox(height: 12),
          ActionTile(
            icon: Icons.qr_code_scanner,
            color: teal,
            title: 'Receive contacts',
            subtitle: 'Scan a sender’s QR code',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScannerScreen()),
            ),
          ),
          const SizedBox(height: 145),
          CardBox(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.shield, color: teal),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No accounts. No cloud.',
                        style: TextStyle(
                          color: navy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Your contacts stay between the two devices.',
                        style: TextStyle(color: slate, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class ActionTile extends StatelessWidget {
  const ActionTile({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: CardBox(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(color: slate, fontSize: 14),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: slate),
        ],
      ),
    ),
  );
}

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});
  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final search = TextEditingController();
  final selected = <String>{'1', '2', '3'};

  List<Contact> get filtered => demoContacts
      .where(
        (c) => '${c.name} ${c.phone}'.toLowerCase().contains(
          search.text.toLowerCase(),
        ),
      )
      .toList();

  @override
  Widget build(BuildContext context) => Shell(
    child: Column(
      children: [
        const Header(title: 'Send contacts'),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Choose people to share',
                  style: TextStyle(
                    color: navy,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Only the contacts you select will be offered.',
                  style: TextStyle(color: slate, fontSize: 15),
                ),
                const SizedBox(height: 20),
                SearchBox(
                  controller: search,
                  onChanged: (_) => setState(() {}),
                  hint: 'Search contacts',
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${selected.length} selected',
                      style: const TextStyle(
                        color: slate,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(
                        () => selected.length == filtered.length
                            ? selected.clear()
                            : selected.addAll(filtered.map((c) => c.id)),
                      ),
                      child: Text(
                        selected.length == filtered.length
                            ? 'Clear all'
                            : 'Select all',
                        style: const TextStyle(
                          color: teal,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final c = filtered[index];
                      return ContactRow(
                        contact: c,
                        selected: selected.contains(c.id),
                        onTap: () => setState(
                          () => selected.contains(c.id)
                              ? selected.remove(c.id)
                              : selected.add(c.id),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        PrimaryButton(
          label: 'Continue',
          icon: Icons.arrow_forward,
          onPressed: () {
            if (selected.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Select at least one contact.')),
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReviewScreen(ids: selected.toList()),
              ),
            );
          },
        ),
      ],
    ),
  );
}

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key, required this.ids});
  final List<String> ids;

  @override
  Widget build(BuildContext context) {
    final chosen = demoContacts.where((c) => ids.contains(c.id)).toList();
    return Shell(
      child: Column(
        children: [
          const Header(title: 'Review selection'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  const Icon(Icons.verified_user, color: teal, size: 34),
                  const SizedBox(height: 18),
                  const Text(
                    'Ready to share',
                    style: TextStyle(
                      color: navy,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${chosen.length} contacts will be offered to the receiver.',
                    style: const TextStyle(color: slate, fontSize: 15),
                  ),
                  const SizedBox(height: 26),
                  CardBox(
                    child: Column(
                      children: chosen
                          .map(
                            (c) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 17,
                                    backgroundColor: mint,
                                    child: Text(
                                      c.initials,
                                      style: const TextStyle(
                                        color: teal,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      c.name,
                                      style: const TextStyle(
                                        color: navy,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.check_circle,
                                    color: teal,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          PrimaryButton(
            label: 'Generate transfer QR',
            icon: Icons.qr_code_2,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => QrScreen(count: chosen.length)),
            ),
          ),
        ],
      ),
    );
  }
}

class QrScreen extends StatelessWidget {
  const QrScreen({super.key, required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Shell(
      child: Column(
        children: [
          const Header(title: 'Transfer'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  const StatusPill(),
                  const SizedBox(height: 20),
                  const Text(
                    'Show this code',
                    style: TextStyle(
                      color: navy,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ask the receiver to scan this QR code with ContactQR.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: slate, fontSize: 15),
                  ),
                  const SizedBox(height: 28),
                  CardBox(
                    child: Column(
                      children: [
                        QrImageView(
                          data: 'contactqr://session/demo-$count',
                          size: 220,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          '$count contacts • expires in 10 minutes',
                          style: const TextStyle(color: slate, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, size: 8, color: teal),
                      SizedBox(width: 8),
                      Text(
                        'Waiting for receiver…',
                        style: TextStyle(color: slate, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text(
              'Cancel transfer',
              style: TextStyle(color: slate, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Shell(
      dark: true,
      child: Column(
        children: [
          const Header(title: 'Receive contacts', light: true),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    'Scan the sender’s code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Align the QR code inside the frame. Nothing is saved automatically.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFB9C2D1),
                      fontSize: 15,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReceivedScreen()),
                    ),
                    child: Container(
                      height: 310,
                      decoration: BoxDecoration(
                        color: const Color(0xFF25334C),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFF4E5C73)),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.qr_code_2,
                          size: 86,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Tap the frame to simulate a successful scan',
                    style: TextStyle(color: Color(0xFFB9C2D1), fontSize: 12),
                  ),
                  const Spacer(),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.flash_on, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('Flash', style: TextStyle(color: Colors.white)),
                      SizedBox(width: 36),
                      Icon(Icons.lock, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Private session',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReceivedScreen extends StatefulWidget {
  const ReceivedScreen({super.key});
  @override
  State<ReceivedScreen> createState() => _ReceivedScreenState();
}

class _ReceivedScreenState extends State<ReceivedScreen> {
  final search = TextEditingController();
  final selected = <String>{'1', '2', '3', '4', '5', '6'};

  List<Contact> get filtered => demoContacts
      .where(
        (c) => '${c.name} ${c.phone}'.toLowerCase().contains(
          search.text.toLowerCase(),
        ),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    return Shell(
      child: Column(
        children: [
          const Header(title: 'Received contacts'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'Review before saving',
                    style: TextStyle(
                      color: navy,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The sender offered 6 contacts. You decide what gets added.',
                    style: TextStyle(color: slate, fontSize: 15),
                  ),
                  const SizedBox(height: 20),
                  SearchBox(
                    controller: search,
                    onChanged: (_) => setState(() {}),
                    hint: 'Search received contacts',
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${selected.length} selected',
                        style: const TextStyle(
                          color: slate,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(
                          () => selected.isEmpty
                              ? selected.addAll(filtered.map((c) => c.id))
                              : selected.clear(),
                        ),
                        child: const Text(
                          'Select / clear',
                          style: TextStyle(
                            color: teal,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, index) {
                        final c = filtered[index];
                        return ContactRow(
                          contact: c,
                          selected: selected.contains(c.id),
                          onTap: () => setState(
                            () => selected.contains(c.id)
                                ? selected.remove(c.id)
                                : selected.add(c.id),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          PrimaryButton(
            label: 'Save selected contacts',
            icon: Icons.save_alt,
            onPressed: () {
              if (selected.isEmpty) return;
              showModalBottomSheet(
                context: context,
                backgroundColor: ivory,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                ),
                builder: (_) => SaveSheet(count: selected.length),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SaveSheet extends StatelessWidget {
  const SaveSheet({super.key, required this.count});
  final int count;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(22, 14, 22, 30),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFCCD0D5),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Save contacts?',
          style: TextStyle(
            color: navy,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '$count contacts will be added to your device. Existing contacts will never be overwritten.',
          style: const TextStyle(color: slate, fontSize: 15, height: 1.45),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => ResultScreen(count: count)),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: navy,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),
            ),
            child: const Text(
              'Save contacts',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        Center(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: slate, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    ),
  );
}

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.count});
  final int count;

  @override
  Widget build(BuildContext context) => Shell(
    child: Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 65, 20, 20),
            child: Column(
              children: [
                const Icon(Icons.check_circle, color: success, size: 72),
                const SizedBox(height: 22),
                const Text(
                  'Transfer complete',
                  style: TextStyle(
                    color: navy,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your selected contacts are ready on this device.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: slate, fontSize: 15),
                ),
                const SizedBox(height: 36),
                CardBox(
                  child: Column(
                    children: [
                      SummaryRow(
                        label: 'Saved',
                        value: '$count contacts',
                        color: success,
                      ),
                      const Divider(color: border),
                      const SummaryRow(
                        label: 'Skipped',
                        value: '0 contacts',
                        color: amber,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: mint,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    'Nothing was overwritten. You can safely repeat a transfer anytime.',
                    style: TextStyle(color: navy, fontSize: 13, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        PrimaryButton(
          label: 'Done',
          onPressed: () =>
              Navigator.popUntil(context, (route) => route.isFirst),
        ),
      ],
    ),
  );
}

class SummaryRow extends StatelessWidget {
  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: slate, fontSize: 15)),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class SearchBox extends StatelessWidget {
  const SearchBox({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.hint,
  });
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hint;
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      hintStyle: const TextStyle(color: slate),
      prefixIcon: const Icon(Icons.search, color: slate),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 0),
    ),
  );
}

class ContactRow extends StatelessWidget {
  const ContactRow({
    super.key,
    required this.contact,
    required this.selected,
    required this.onTap,
  });
  final Contact contact;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(15),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: mint,
            child: Text(
              contact.initials,
              style: const TextStyle(
                color: teal,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    color: navy,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  contact.phone,
                  style: const TextStyle(color: slate, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? teal : Colors.transparent,
              border: Border.all(
                color: selected ? teal : const Color(0xFFC7CBD3),
                width: 1.5,
              ),
            ),
            child: selected
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
        ],
      ),
    ),
  );
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: mint,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(color: teal, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        const Text(
          'READY TO CONNECT',
          style: TextStyle(
            color: teal,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: .7,
          ),
        ),
      ],
    ),
  );
}
