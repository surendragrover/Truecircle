import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'services/otp_service.dart';
import '../core/permission_manager.dart';
import '../core/app_config.dart';
import '../home/home_page.dart';

class PhoneVerificationPage extends StatefulWidget {
  final bool returnResult; // if true, Navigator.pop(true) on success
  const PhoneVerificationPage({super.key, this.returnResult = false});

  @override
  State<PhoneVerificationPage> createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  final _phoneCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  bool _busy = false;
  String? _error;
  String? _selectedCountry; // ISO 3166-1 alpha-2

  Future<void> _verify() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final code = _codeCtrl.text.trim();
      final otp = OtpService.create();
      final ok = await otp.verifyCode(code);
      if (!ok) {
        final msg = PermissionManager.isSampleMode || AppConfig.useOfflineOtp
            ? 'Enter 000000 to continue.'
            : 'Invalid code. OTP via Firebase is disabled in this build.';
        setState(() => _error = msg);
        return;
      }
      // Persist the user's phone locally (privacy-first; no upload)
      final box = await Hive.openBox('app_prefs');
      final cc =
          (_selectedCountry ??
                  (Localizations.localeOf(context).countryCode ?? 'US'))
              .toUpperCase();
      final dial = _dialCodeFor(cc).replaceAll(RegExp(r'[^0-9+]'), '').trim();
      String num = _phoneCtrl.text.trim().replaceAll(RegExp(r'[^0-9+]'), '');
      if (!num.startsWith('+')) {
        num = dial + num;
      }
      await box.put('user_phone', num);
      await box.put('user_phone_cc', cc);
      await box.put('phone_verified', true);
      if (!mounted) return;
      if (widget.returnResult) {
        Navigator.of(context).pop(true);
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize selected country from locale (fallback to US if null)
    // We'll update this via picker as needed.
    // Do not block UI; this is synchronous.
    _selectedCountry = null; // defer to build for first resolve
    // Prefill phone field with current locale dial code once UI is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cc = (Localizations.localeOf(context).countryCode ?? 'US')
          .toUpperCase();
      final dial = _dialCodeFor(cc).trim();
      if (_phoneCtrl.text.isEmpty) {
        _phoneCtrl.text = dial;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hint = Theme.of(context).hintColor;
    final cc =
        (_selectedCountry ??
                (Localizations.localeOf(context).countryCode ?? 'US'))
            .toUpperCase();
    final dial = _dialCodeFor(cc);
    final flag = _flagEmoji(cc);
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Image.asset('assets/images/truecircle_logo.png', height: 24),
        ),
        titleSpacing: 0,
        title: const Text('Phone verification'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'For privacy, no SMS is sent or auto‑read. Your phone is kept on this device to personalize your experience.',
                style: TextStyle(color: hint),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone number',
                  hintText: '${dial}XXXXXXXXXX',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: Center(child: Text('$flag $dial')),
                  ),
                  suffixIcon: IconButton(
                    tooltip: 'Change country code',
                    icon: const Icon(Icons.flag_outlined),
                    onPressed: _busy ? null : () => _openCountryPicker(cc),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _codeCtrl,
                keyboardType: TextInputType.number,
                onSubmitted: (_) => _busy ? null : _verify(),
                decoration: const InputDecoration(
                  labelText: 'Enter code',
                  hintText: '000000',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _busy ? null : _verify,
                  icon: _busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.verified_outlined),
                  label: const Text('Verify and continue'),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter 000000 to continue. No SMS is sent or auto‑read.',
                style: TextStyle(color: hint),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openCountryPicker(String currentCc) async {
    final entries = _countryDial.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    String filter = '';
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: StatefulBuilder(
            builder: (ctx, setSt) {
              final list = entries.where((e) {
                if (filter.isEmpty) return true;
                final cc = e.key;
                final dial = e.value;
                return cc.toLowerCase().contains(filter.toLowerCase()) ||
                    dial.contains(filter);
              }).toList();
              return Padding(
                padding: EdgeInsets.only(
                  left: 12,
                  right: 12,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 12,
                  top: 8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search by code or dial (e.g., IN or +91)',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => setSt(() => filter = v),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: list.length,
                        itemBuilder: (ctx, i) {
                          final e = list[i];
                          final code = e.key;
                          final dial = e.value;
                          final flag = _flagEmoji(code);
                          return ListTile(
                            leading: Text(
                              flag,
                              style: const TextStyle(fontSize: 20),
                            ),
                            title: Text('$code  ($dial)'),
                            trailing: code == currentCc
                                ? Icon(
                                    Icons.check,
                                    color: Theme.of(ctx).colorScheme.primary,
                                  )
                                : null,
                            onTap: () => Navigator.of(ctx).pop(code),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (selected != null && mounted) {
      final oldDial = _dialCodeFor(currentCc).trim();
      final newDial = _dialCodeFor(selected).trim();
      setState(() {
        _selectedCountry = selected;
        // If user hasn't typed a full number yet (or started with a dial), update prefix
        if (_phoneCtrl.text.isEmpty || _phoneCtrl.text.trim().startsWith('+')) {
          _phoneCtrl.text = newDial;
        } else if (_phoneCtrl.text.trim().startsWith(oldDial)) {
          _phoneCtrl.text = _phoneCtrl.text.replaceFirst(oldDial, newDial);
        }
      });
    }
  }
}

// Complete ISO 3166-1 alpha-2 -> dial code map (flattened; NANP territories map to +1)
const Map<String, String> _countryDial = {
  'AD': '+376',
  'AE': '+971',
  'AF': '+93',
  'AG': '+1',
  'AI': '+1',
  'AL': '+355',
  'AM': '+374',
  'AO': '+244',
  'AR': '+54',
  'AS': '+1',
  'AT': '+43',
  'AU': '+61',
  'AW': '+297',
  'AX': '+358',
  'AZ': '+994',
  'BA': '+387',
  'BB': '+1',
  'BD': '+880',
  'BE': '+32',
  'BF': '+226',
  'BG': '+359',
  'BH': '+973',
  'BI': '+257',
  'BJ': '+229',
  'BL': '+590',
  'BM': '+1',
  'BN': '+673',
  'BO': '+591',
  'BQ': '+599',
  'BR': '+55',
  'BS': '+1',
  'BT': '+975',
  'BV': '+47',
  'BW': '+267',
  'BY': '+375',
  'BZ': '+501',
  'CA': '+1',
  'CC': '+61',
  'CD': '+243',
  'CF': '+236',
  'CG': '+242',
  'CH': '+41',
  'CI': '+225',
  'CK': '+682',
  'CL': '+56',
  'CM': '+237',
  'CN': '+86',
  'CO': '+57',
  'CR': '+506',
  'CU': '+53',
  'CV': '+238',
  'CW': '+599',
  'CX': '+61',
  'CY': '+357',
  'CZ': '+420',
  'DE': '+49',
  'DJ': '+253',
  'DK': '+45',
  'DM': '+1',
  'DO': '+1',
  'DZ': '+213',
  'EC': '+593',
  'EE': '+372',
  'EG': '+20',
  'EH': '+212',
  'ER': '+291',
  'ES': '+34',
  'ET': '+251',
  'FI': '+358',
  'FJ': '+679',
  'FK': '+500',
  'FM': '+691',
  'FO': '+298',
  'FR': '+33',
  'GA': '+241',
  'GB': '+44',
  'GD': '+1',
  'GE': '+995',
  'GF': '+594',
  'GG': '+44',
  'GH': '+233',
  'GI': '+350',
  'GL': '+299',
  'GM': '+220',
  'GN': '+224',
  'GP': '+590',
  'GQ': '+240',
  'GR': '+30',
  'GS': '+500',
  'GT': '+502',
  'GU': '+1',
  'GW': '+245',
  'GY': '+592',
  'HK': '+852',
  'HM': '+61',
  'HN': '+504',
  'HR': '+385',
  'HT': '+509',
  'HU': '+36',
  'ID': '+62',
  'IE': '+353',
  'IL': '+972',
  'IM': '+44',
  'IN': '+91',
  'IO': '+246',
  'IQ': '+964',
  'IR': '+98',
  'IS': '+354',
  'IT': '+39',
  'JE': '+44',
  'JM': '+1',
  'JO': '+962',
  'JP': '+81',
  'KE': '+254',
  'KG': '+996',
  'KH': '+855',
  'KI': '+686',
  'KM': '+269',
  'KN': '+1',
  'KP': '+850',
  'KR': '+82',
  'KW': '+965',
  'KY': '+1',
  'KZ': '+7',
  'LA': '+856',
  'LB': '+961',
  'LC': '+1',
  'LI': '+423',
  'LK': '+94',
  'LR': '+231',
  'LS': '+266',
  'LT': '+370',
  'LU': '+352',
  'LV': '+371',
  'LY': '+218',
  'MA': '+212',
  'MC': '+377',
  'MD': '+373',
  'ME': '+382',
  'MF': '+590',
  'MG': '+261',
  'MH': '+692',
  'MK': '+389',
  'ML': '+223',
  'MM': '+95',
  'MN': '+976',
  'MO': '+853',
  'MP': '+1',
  'MQ': '+596',
  'MR': '+222',
  'MS': '+1',
  'MT': '+356',
  'MU': '+230',
  'MV': '+960',
  'MW': '+265',
  'MX': '+52',
  'MY': '+60',
  'MZ': '+258',
  'NA': '+264',
  'NC': '+687',
  'NE': '+227',
  'NF': '+672',
  'NG': '+234',
  'NI': '+505',
  'NL': '+31',
  'NO': '+47',
  'NP': '+977',
  'NR': '+674',
  'NU': '+683',
  'NZ': '+64',
  'OM': '+968',
  'PA': '+507',
  'PE': '+51',
  'PF': '+689',
  'PG': '+675',
  'PH': '+63',
  'PK': '+92',
  'PL': '+48',
  'PM': '+508',
  'PN': '+64',
  'PR': '+1',
  'PS': '+970',
  'PT': '+351',
  'PW': '+680',
  'PY': '+595',
  'QA': '+974',
  'RE': '+262',
  'RO': '+40',
  'RS': '+381',
  'RU': '+7',
  'RW': '+250',
  'SA': '+966',
  'SB': '+677',
  'SC': '+248',
  'SD': '+249',
  'SE': '+46',
  'SG': '+65',
  'SH': '+290',
  'SI': '+386',
  'SJ': '+47',
  'SK': '+421',
  'SL': '+232',
  'SM': '+378',
  'SN': '+221',
  'SO': '+252',
  'SR': '+597',
  'SS': '+211',
  'ST': '+239',
  'SV': '+503',
  'SX': '+1',
  'SY': '+963',
  'SZ': '+268',
  'TC': '+1',
  'TD': '+235',
  'TF': '+262',
  'TG': '+228',
  'TH': '+66',
  'TJ': '+992',
  'TK': '+690',
  'TL': '+670',
  'TM': '+993',
  'TN': '+216',
  'TO': '+676',
  'TR': '+90',
  'TT': '+1',
  'TV': '+688',
  'TW': '+886',
  'TZ': '+255',
  'UA': '+380',
  'UG': '+256',
  'UM': '+1',
  'US': '+1',
  'UY': '+598',
  'UZ': '+998',
  'VA': '+39',
  'VC': '+1',
  'VE': '+58',
  'VG': '+1',
  'VI': '+1',
  'VN': '+84',
  'VU': '+678',
  'WF': '+681',
  'WS': '+685',
  'YE': '+967',
  'YT': '+262',
  'ZA': '+27',
  'ZM': '+260',
  'ZW': '+263',
};

String _flagEmoji(String countryCode) {
  // Convert country code letters to Regional Indicator Symbol letters
  // e.g., 'IN' -> 🇮🇳
  if (countryCode.length != 2) return '🌐';
  final int base = 0x1F1E6; // Regional Indicator Symbol Letter A
  final upper = countryCode.toUpperCase();
  final codeUnits = upper.codeUnits
      .map((c) => base + (c - 0x41))
      .toList(growable: false);
  return String.fromCharCodes(codeUnits);
}

String _dialCodeFor(String countryCode) {
  final cc = countryCode.toUpperCase();
  final dial = _countryDial[cc] ?? '+1';
  return '$dial ';
}
