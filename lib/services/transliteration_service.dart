/// Offline transliteration service for map/room labels.
/// Labels are phonetically transliterated (not semantically translated).
/// Example: "Pharmacy" → "ಫಾರ್ಮಸಿ" (Kannada phonetic), NOT "ಔಷಧಾಲಯ" (meaning).
class TransliterationService {
  TransliterationService._();
  static final TransliterationService instance = TransliterationService._();

  /// Master transliteration map.
  /// Key: English label key (from JSON node.label), Value: {langCode: transliterated text}
  static const Map<String, Map<String, String>> _map = {
    // ── Ground Floor ──
    'main_entrance': {
      'en': 'Main Entrance',
      'kn': 'ಮೇನ್ ಎಂಟ್ರೆನ್ಸ್',
      'hi': 'मेन एंट्रेंस',
      'ta': 'மெயின் என்ட்ரன்ஸ்',
      'te': 'మెయిన్ ఎంట్రన్స్',
    },
    'pharmacy': {
      'en': 'Pharmacy',
      'kn': 'ಫಾರ್ಮಸಿ',
      'hi': 'फार्मेसी',
      'ta': 'பார்மசி',
      'te': 'ఫార్మసీ',
    },
    'canteen': {
      'en': 'Canteen',
      'kn': 'ಕ್ಯಾಂಟೀನ್',
      'hi': 'कैंटीन',
      'ta': 'கேன்டீன்',
      'te': 'క్యాంటీన్',
    },
    'reception_a': {
      'en': 'Reception A',
      'kn': 'ರಿಸೆಪ್ಷನ್ A',
      'hi': 'रिसेप्शन A',
      'ta': 'ரிசப்ஷன் A',
      'te': 'రిసెప్షన్ A',
    },
    'reception_b': {
      'en': 'Reception B',
      'kn': 'ರಿಸೆಪ್ಷನ್ B',
      'hi': 'रिसेप्शन B',
      'ta': 'ரிசப்ஷன் B',
      'te': 'రిసెప్షన్ B',
    },
    'billing': {
      'en': 'Billing',
      'kn': 'ಬಿಲ್ಲಿಂಗ್',
      'hi': 'बिलिंग',
      'ta': 'பில்லிங்',
      'te': 'బిల్లింగ్',
    },
    'waiting_area': {
      'en': 'Waiting Area',
      'kn': 'ವೇಟಿಂಗ್ ಏರಿಯಾ',
      'hi': 'वेटिंग एरिया',
      'ta': 'வெய்ட்டிங் ஏரியா',
      'te': 'వెయిటింగ్ ఏరియా',
    },
    'ultrasonic': {
      'en': 'Ultrasonic',
      'kn': 'ಅಲ್ಟ್ರಾಸೋನಿಕ್',
      'hi': 'अल्ट्रासोनिक',
      'ta': 'அல்ட்ராசோனிக்',
      'te': 'అల్ట్రాసోనిక్',
    },
    'x_ray': {
      'en': 'X-Ray',
      'kn': 'ಎಕ್ಸ್-ರೇ',
      'hi': 'एक्स-रे',
      'ta': 'எக்ஸ்-ரே',
      'te': 'ఎక్స్-రే',
    },
    'mri': {
      'en': 'MRI',
      'kn': 'MRI',
      'hi': 'MRI',
      'ta': 'MRI',
      'te': 'MRI',
    },
    'sample_collection': {
      'en': 'Sample Collection',
      'kn': 'ಸ್ಯಾಂಪಲ್ ಕಲೆಕ್ಷನ್',
      'hi': 'सैंपल कलेक्शन',
      'ta': 'சாம்பிள் கலெக்ஷன்',
      'te': 'శాంపిల్ కలెక్షన్',
    },

    // ── OPDs ──
    'obg_opd': {
      'en': 'OBG OPD',
      'kn': 'OBG OPD',
      'hi': 'OBG OPD',
      'ta': 'OBG OPD',
      'te': 'OBG OPD',
    },
    'surgery_opd': {
      'en': 'Surgery OPD',
      'kn': 'ಸರ್ಜರಿ OPD',
      'hi': 'सर्जरी OPD',
      'ta': 'சர்ஜரி OPD',
      'te': 'సర్జరీ OPD',
    },
    'medicine_opd': {
      'en': 'Medicine OPD',
      'kn': 'ಮೆಡಿಸಿನ್ OPD',
      'hi': 'मेडिसिन OPD',
      'ta': 'மெடிசின் OPD',
      'te': 'మెడిసిన్ OPD',
    },
    'dental_opd': {
      'en': 'Dental OPD',
      'kn': 'ಡೆಂಟಲ್ OPD',
      'hi': 'डेंटल OPD',
      'ta': 'டெண்டல் OPD',
      'te': 'డెంటల్ OPD',
    },
    'ortho_opd': {
      'en': 'Ortho OPD',
      'kn': 'ಆರ್ಥೋ OPD',
      'hi': 'ऑर्थो OPD',
      'ta': 'ஆர்த்தோ OPD',
      'te': 'ఆర్థో OPD',
    },
    'pea_opd': {
      'en': 'PEA OPD',
      'kn': 'PEA OPD',
      'hi': 'PEA OPD',
      'ta': 'PEA OPD',
      'te': 'PEA OPD',
    },
    'ent_opd': {
      'en': 'ENT OPD',
      'kn': 'ENT OPD',
      'hi': 'ENT OPD',
      'ta': 'ENT OPD',
      'te': 'ENT OPD',
    },
    'dermatology_opd': {
      'en': 'Dermatology OPD',
      'kn': 'ಡರ್ಮಟಾಲಜಿ OPD',
      'hi': 'डर्मेटोलॉजी OPD',
      'ta': 'டெர்மட்டாலஜி OPD',
      'te': 'డెర్మటాలజీ OPD',
    },
    'psyciatry_opd': {
      'en': 'Psychiatry OPD',
      'kn': 'ಸೈಕಿಯಾಟ್ರಿ OPD',
      'hi': 'साइकियाट्री OPD',
      'ta': 'சைக்கியாட்ரி OPD',
      'te': 'సైకియాట్రీ OPD',
    },
    'opthamology_opd': {
      'en': 'Ophthalmology OPD',
      'kn': 'ಆಫ್ತಾಲ್ಮಾಲಜಿ OPD',
      'hi': 'ऑफ्थैल्मोलॉजी OPD',
      'ta': 'ஆப்தால்மாலஜி OPD',
      'te': 'ఆఫ్తాల్మాలజీ OPD',
    },

    // ── Vertical Transport ──
    'lift_1': {
      'en': 'Lift 1',
      'kn': 'ಲಿಫ್ಟ್ 1',
      'hi': 'लिफ्ट 1',
      'ta': 'லிஃப்ட் 1',
      'te': 'లిఫ్ట్ 1',
    },
    'lift_2': {
      'en': 'Lift 2',
      'kn': 'ಲಿಫ್ಟ್ 2',
      'hi': 'लिफ्ट 2',
      'ta': 'லிஃப்ட் 2',
      'te': 'లిఫ్ట్ 2',
    },
    'lift_3': {
      'en': 'Lift 3',
      'kn': 'ಲಿಫ್ಟ್ 3',
      'hi': 'लिफ्ट 3',
      'ta': 'லிஃப்ட் 3',
      'te': 'లిఫ్ట్ 3',
    },
    'stairs_1': {
      'en': 'Stairs 1',
      'kn': 'ಸ್ಟೇರ್ಸ್ 1',
      'hi': 'स्टेयर्स 1',
      'ta': 'ஸ்டேர்ஸ் 1',
      'te': 'స్టేర్స్ 1',
    },
    'stairs_2': {
      'en': 'Stairs 2',
      'kn': 'ಸ್ಟೇರ್ಸ್ 2',
      'hi': 'स्टेयर्स 2',
      'ta': 'ஸ்டேர்ஸ் 2',
      'te': 'స్టేర్స్ 2',
    },
    'ramp': {
      'en': 'Ramp',
      'kn': 'ರ್ಯಾಂಪ್',
      'hi': 'रैंप',
      'ta': 'ராம்ப்',
      'te': 'ర్యాంప్',
    },

    // ── Toilets ──
    'toilet_female': {
      'en': 'Toilet (Female)',
      'kn': 'ಟಾಯ್ಲೆಟ್ (ಫೀಮೇಲ್)',
      'hi': 'टॉयलेट (फीमेल)',
      'ta': 'டாய்லெட் (ஃபீமேல்)',
      'te': 'టాయిలెట్ (ఫీమేల్)',
    },
    'toilet_male': {
      'en': 'Toilet (Male)',
      'kn': 'ಟಾಯ್ಲೆಟ್ (ಮೇಲ್)',
      'hi': 'टॉयलेट (मेल)',
      'ta': 'டாய்லெட் (மேல்)',
      'te': 'టాయిలెట్ (మేల్)',
    },

    // ── Wards ──
    'post_natal_ward': {
      'en': 'Post Natal Ward',
      'kn': 'ಪೋಸ್ಟ್ ನೇಟಲ್ ವಾರ್ಡ್',
      'hi': 'पोस्ट नेटल वॉर्ड',
      'ta': 'போஸ்ட் நேட்டல் வார்ட்',
      'te': 'పోస్ట్ నేటల్ వార్డ్',
    },
    'paediatric_ward': {
      'en': 'Paediatric Ward',
      'kn': 'ಪೀಡಿಯಾಟ್ರಿಕ್ ವಾರ್ಡ್',
      'hi': 'पीडियाट्रिक वॉर्ड',
      'ta': 'பீடியாட்ரிக் வார்ட்',
      'te': 'పీడియాట్రిక్ వార్డ్',
    },
    'gynaecology_ward': {
      'en': 'Gynaecology Ward',
      'kn': 'ಗೈನಕಾಲಜಿ ವಾರ್ಡ್',
      'hi': 'गाइनेकोलॉजी वॉर्ड',
      'ta': 'கைனகாலஜி வார்ட்',
      'te': 'గైనకాలజీ వార్డ్',
    },
    'antenatal_ward': {
      'en': 'Antenatal Ward',
      'kn': 'ಆಂಟಿನೇಟಲ್ ವಾರ್ಡ್',
      'hi': 'एंटीनेटल वॉर्ड',
      'ta': 'ஆண்ட்டிநேட்டல் வார்ட்',
      'te': 'ఆంటీనేటల్ వార్డ్',
    },
    'opthamology_ward_male': {
      'en': 'Ophthalmology Ward (Male)',
      'kn': 'ಆಫ್ತಾಲ್ಮಾಲಜಿ ವಾರ್ಡ್ (ಮೇಲ್)',
      'hi': 'ऑफ्थैल्मोलॉजी वॉर्ड (मेल)',
      'ta': 'ஆப்தால்மாலஜி வார்ட் (மேல்)',
      'te': 'ఆఫ్తాల్మాలజీ వార్డ్ (మేల్)',
    },
    'opthamology_ward_female': {
      'en': 'Ophthalmology Ward (Female)',
      'kn': 'ಆಫ್ತಾಲ್ಮಾಲಜಿ ವಾರ್ಡ್ (ಫೀಮೇಲ್)',
      'hi': 'ऑफ्थैल्मोलॉजी वॉर्ड (फीमेल)',
      'ta': 'ஆப்தால்மாலஜி வார்ட் (ஃபீமேல்)',
      'te': 'ఆఫ్తాల్మాలజీ వార్డ్ (ఫీమేల్)',
    },
    'dvl_ward': {
      'en': 'DVL Ward',
      'kn': 'DVL ವಾರ್ಡ್',
      'hi': 'DVL वॉर्ड',
      'ta': 'DVL வார்ட்',
      'te': 'DVL వార్డ్',
    },
    'psycology_ward': {
      'en': 'Psychology Ward',
      'kn': 'ಸೈಕಾಲಜಿ ವಾರ್ಡ್',
      'hi': 'साइकोलॉजी वॉर्ड',
      'ta': 'சைக்காலஜி வார்ட்',
      'te': 'సైకాలజీ వార్డ్',
    },
    'post_op_female_ward': {
      'en': 'Post-Op Female Ward',
      'kn': 'ಪೋಸ್ಟ್-ಆಪ್ ಫೀಮೇಲ್ ವಾರ್ಡ್',
      'hi': 'पोस्ट-ऑप फीमेल वॉर्ड',
      'ta': 'போஸ்ட்-ஆப் ஃபீமேல் வார்ட்',
      'te': 'పోస్ట్-ఆప్ ఫీమేల్ వార్డ్',
    },
    'post_op_male_ward': {
      'en': 'Post-Op Male Ward',
      'kn': 'ಪೋಸ್ಟ್-ಆಪ್ ಮೇಲ್ ವಾರ್ಡ್',
      'hi': 'पोस्ट-ऑप मेल वॉर्ड',
      'ta': 'போஸ்ட்-ஆப் மேல் வார்ட்',
      'te': 'పోస్ట్-ఆప్ మేల్ వార్డ్',
    },

    // ── Departments & Facilities ──
    'department_of_obg': {
      'en': 'Department of OBG',
      'kn': 'ಡಿಪಾರ್ಟ್‌ಮೆಂಟ್ ಆಫ್ OBG',
      'hi': 'डिपार्टमेंट ऑफ OBG',
      'ta': 'டிபார்ட்மெண்ட் ஆஃப் OBG',
      'te': 'డిపార్ట్‌మెంట్ ఆఫ్ OBG',
    },
    'admin_office': {
      'en': 'Admin Office',
      'kn': 'ಅಡ್ಮಿನ್ ಆಫೀಸ್',
      'hi': 'एडमिन ऑफिस',
      'ta': 'அட்மின் ஆபீஸ்',
      'te': 'అడ్మిన్ ఆఫీస్',
    },
    'opthamology_ot_complex': {
      'en': 'Ophthalmology OT Complex',
      'kn': 'ಆಫ್ತಾಲ್ಮಾಲಜಿ OT ಕಾಂಪ್ಲೆಕ್ಸ್',
      'hi': 'ऑफ्थैल्मोलॉजी OT कॉम्प्लेक्स',
      'ta': 'ஆப்தால்மாலஜி OT காம்ப்ளெக்ஸ்',
      'te': 'ఆఫ్తాల్మాలజీ OT కాంప్లెక్స్',
    },
    'central_laboratory_blood_center_ictc': {
      'en': 'Central Lab, Blood Center, ICTC',
      'kn': 'ಸೆಂಟ್ರಲ್ ಲ್ಯಾಬ್, ಬ್ಲಡ್ ಸೆಂಟರ್, ICTC',
      'hi': 'सेंट्रल लैब, ब्लड सेंटर, ICTC',
      'ta': 'சென்ட்ரல் லேப், ப்ளட் சென்டர், ICTC',
      'te': 'సెంట్రల్ ల్యాబ్, బ్లడ్ సెంటర్, ICTC',
    },
    'icu': {
      'en': 'ICU',
      'kn': 'ICU',
      'hi': 'ICU',
      'ta': 'ICU',
      'te': 'ICU',
    },
    'ot': {
      'en': 'OT',
      'kn': 'OT',
      'hi': 'OT',
      'ta': 'OT',
      'te': 'OT',
    },
    'ot_waiting_area': {
      'en': 'OT Waiting Area',
      'kn': 'OT ವೇಟಿಂಗ್ ಏರಿಯಾ',
      'hi': 'OT वेटिंग एरिया',
      'ta': 'OT வெய்ட்டிங் ஏரியா',
      'te': 'OT వెయిటింగ్ ఏరియా',
    },
    'f1_n86': {
      'en': 'Room F1-86',
      'kn': 'ರೂಮ್ F1-86',
      'hi': 'रूम F1-86',
      'ta': 'ரூம் F1-86',
      'te': 'రూమ్ F1-86',
    },
    'rect118': {
      'en': 'Room 118',
      'kn': 'ರೂಮ್ 118',
      'hi': 'रूम 118',
      'ta': 'ரூம் 118',
      'te': 'రూమ్ 118',
    },
  };

  /// Returns the transliterated label for a given label key and language.
  /// Falls back to English, then to the raw key if not found.
  String transliterate(String labelKey, String langCode) {
    final normalizedKey = labelKey.toLowerCase().replaceAll(' ', '_');
    final entry = _map[normalizedKey];
    if (entry == null) {
      // Unknown label — return key formatted as title case
      return labelKey.replaceAll('_', ' ').split(' ').map((w) =>
        w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}'
      ).join(' ');
    }
    return entry[langCode] ?? entry['en'] ?? labelKey;
  }

  /// Check if a label key exists in the transliteration map.
  bool hasLabel(String labelKey) => _map.containsKey(labelKey.toLowerCase().replaceAll(' ', '_'));

  /// Returns all known label keys.
  Iterable<String> get allLabelKeys => _map.keys;
}
