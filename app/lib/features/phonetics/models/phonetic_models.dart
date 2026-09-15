import 'dart:math' as math;

enum PhonemeCategory {
  shortVowel,
  longVowel,
  diphthong,
  plosive,
  fricative,
  affricate,
  nasal,
  approximant,
}

enum VoicingType {
  voiced,
  unvoiced,
  vowel,
}

class PhonemeInfo {
  final String symbol; // IPA e.g. "ɪ", "iː", "θ", "v"
  final String arpaKey; // e.g. "IH", "IY", "TH", "V"
  final String name;
  final PhonemeCategory category;
  final VoicingType voicing;
  final String exampleWord;
  final String exampleIpa;
  final String spanishTrapDescription;
  final String articulationTip;
  final double l1SpanishDifficultyPrior; // 0.0 (easy for Spanish) to 1.0 (very hard)

  const PhonemeInfo({
    required this.symbol,
    required this.arpaKey,
    required this.name,
    required this.category,
    required this.voicing,
    required this.exampleWord,
    required this.exampleIpa,
    required this.spanishTrapDescription,
    required this.articulationTip,
    this.l1SpanishDifficultyPrior = 0.5,
  });
}

class MinimalPairItem {
  final String wordA;
  final String ipaA;
  final String phonemeA;
  final String wordB;
  final String ipaB;
  final String phonemeB;
  final String contrastTitle;
  final String l1Explanation;

  const MinimalPairItem({
    required this.wordA,
    required this.ipaA,
    required this.phonemeA,
    required this.wordB,
    required this.ipaB,
    required this.phonemeB,
    required this.contrastTitle,
    required this.l1Explanation,
  });
}

class PhoneticTaxonomy {
  static const List<PhonemeInfo> all44Phonemes = [
    // ── 1. SHORT VOWELS ──
    PhonemeInfo(
      symbol: 'ɪ',
      arpaKey: 'IH',
      name: 'Short I (Near-close near-front)',
      category: PhonemeCategory.shortVowel,
      voicing: VoicingType.vowel,
      exampleWord: 'ship',
      exampleIpa: '/ʃɪp/',
      spanishTrapDescription: 'El español no tiene este sonido. Se tiende a pronunciar como /i/ tensa ("sheep").',
      articulationTip: 'Relaja la lengua y los labios. Es más breve, abierta y relajada que la "i" española.',
      l1SpanishDifficultyPrior: 0.85,
    ),
    PhonemeInfo(
      symbol: 'e',
      arpaKey: 'EH',
      name: 'Short E (Open-mid front)',
      category: PhonemeCategory.shortVowel,
      voicing: VoicingType.vowel,
      exampleWord: 'bed',
      exampleIpa: '/bed/',
      spanishTrapDescription: 'Similar a la "e" española pero ligeramente más abierta.',
      articulationTip: 'Abre un poco más la mandíbula sin tensar la garganta.',
      l1SpanishDifficultyPrior: 0.3,
    ),
    PhonemeInfo(
      symbol: 'æ',
      arpaKey: 'AE',
      name: 'Ash / Flat A (Near-open front)',
      category: PhonemeCategory.shortVowel,
      voicing: VoicingType.vowel,
      exampleWord: 'cat',
      exampleIpa: '/kæt/',
      spanishTrapDescription: 'No existe en español. Se suele confundir con "a" o "e".',
      articulationTip: 'Baja la mandíbula como para decir "a" pero estira las comisuras de los labios hacia los lados como para "e".',
      l1SpanishDifficultyPrior: 0.9,
    ),
    PhonemeInfo(
      symbol: 'ʌ',
      arpaKey: 'AH',
      name: 'Strut / Wedge (Open-mid back unrounded)',
      category: PhonemeCategory.shortVowel,
      voicing: VoicingType.vowel,
      exampleWord: 'cup',
      exampleIpa: '/kʌp/',
      spanishTrapDescription: 'Sonido gutural relajado. Se suele sustituir por "o" o "u" española.',
      articulationTip: 'Sonido corto en el centro de la boca, con mandíbula relajada y sin redondear los labios.',
      l1SpanishDifficultyPrior: 0.8,
    ),
    PhonemeInfo(
      symbol: 'ʊ',
      arpaKey: 'UH',
      name: 'Short U / Foot (Near-close near-back)',
      category: PhonemeCategory.shortVowel,
      voicing: VoicingType.vowel,
      exampleWord: 'good',
      exampleIpa: '/ɡʊd/',
      spanishTrapDescription: 'Suele confundirse con la "u" tensa y larga de "food".',
      articulationTip: 'Relaja los labios y no los redondees en exceso; sonido corto.',
      l1SpanishDifficultyPrior: 0.75,
    ),
    PhonemeInfo(
      symbol: 'ɒ',
      arpaKey: 'AA',
      name: 'Short O / Lot (Open back rounded)',
      category: PhonemeCategory.shortVowel,
      voicing: VoicingType.vowel,
      exampleWord: 'hot',
      exampleIpa: '/hɒt/',
      spanishTrapDescription: 'Más abierta que la "o" española.',
      articulationTip: 'Abre bien la boca en posición ovalada.',
      l1SpanishDifficultyPrior: 0.5,
    ),
    PhonemeInfo(
      symbol: 'ə',
      arpaKey: 'AH',
      name: 'Schwa (Mid central neutral)',
      category: PhonemeCategory.shortVowel,
      voicing: VoicingType.vowel,
      exampleWord: 'teacher',
      exampleIpa: '/ˈtiːtʃər/',
      spanishTrapDescription: 'El sonido más común en inglés. En español no existe la reducción vocálica átona.',
      articulationTip: 'No hagas ningún esfuerzo: boca y lengua completamente neutras.',
      l1SpanishDifficultyPrior: 0.95,
    ),

    // ── 2. LONG VOWELS ──
    PhonemeInfo(
      symbol: 'iː',
      arpaKey: 'IY',
      name: 'Long EE (Close front)',
      category: PhonemeCategory.longVowel,
      voicing: VoicingType.vowel,
      exampleWord: 'sheep',
      exampleIpa: '/ʃiːp/',
      spanishTrapDescription: 'Similar a la "i" española pero más tensa y con mayor duración.',
      articulationTip: 'Sonríe con los labios tensos y prolonga el sonido.',
      l1SpanishDifficultyPrior: 0.4,
    ),
    PhonemeInfo(
      symbol: 'ɑː',
      arpaKey: 'AA',
      name: 'Long AH (Open back unrounded)',
      category: PhonemeCategory.longVowel,
      voicing: VoicingType.vowel,
      exampleWord: 'father',
      exampleIpa: '/ˈfɑːðər/',
      spanishTrapDescription: 'Vocal "a" profunda desde la parte posterior de la garganta.',
      articulationTip: 'Baja la lengua y relaja la mandíbula como en el médico.',
      l1SpanishDifficultyPrior: 0.45,
    ),
    PhonemeInfo(
      symbol: 'ɔː',
      arpaKey: 'AO',
      name: 'Long AW / Thought',
      category: PhonemeCategory.longVowel,
      voicing: VoicingType.vowel,
      exampleWord: 'door',
      exampleIpa: '/dɔːr/',
      spanishTrapDescription: 'O larga y redonda en posición posterior.',
      articulationTip: 'Redondea los labios y mantén la lengua atrás.',
      l1SpanishDifficultyPrior: 0.55,
    ),
    PhonemeInfo(
      symbol: 'uː',
      arpaKey: 'UW',
      name: 'Long OO / Goose',
      category: PhonemeCategory.longVowel,
      voicing: VoicingType.vowel,
      exampleWord: 'food',
      exampleIpa: '/fuːd/',
      spanishTrapDescription: 'Similar a la "u" española pero más tensa y alargada.',
      articulationTip: 'Redondea bien los labios y tensa la parte trasera de la lengua.',
      l1SpanishDifficultyPrior: 0.4,
    ),
    PhonemeInfo(
      symbol: 'ɜː',
      arpaKey: 'ER',
      name: 'Nurse / Long Bird vowel',
      category: PhonemeCategory.longVowel,
      voicing: VoicingType.vowel,
      exampleWord: 'bird',
      exampleIpa: '/bɜːrd/',
      spanishTrapDescription: 'Se tiende a pronunciar la vocal ortográfica ("i", "u", "e") en vez del sonido neutro largo.',
      articulationTip: 'Labios neutros y lengua en el centro sin tocar ningún diente.',
      l1SpanishDifficultyPrior: 0.85,
    ),

    // ── 3. DIPHTHONGS ──
    PhonemeInfo(
      symbol: 'eɪ',
      arpaKey: 'EY',
      name: 'Face Diphthong',
      category: PhonemeCategory.diphthong,
      voicing: VoicingType.vowel,
      exampleWord: 'day',
      exampleIpa: '/deɪ/',
      spanishTrapDescription: 'Deslizamiento suave de "e" a "i".',
      articulationTip: 'Empieza en /e/ y desliza rápidamente hacia /ɪ/.',
      l1SpanishDifficultyPrior: 0.35,
    ),
    PhonemeInfo(
      symbol: 'aɪ',
      arpaKey: 'AY',
      name: 'Price Diphthong',
      category: PhonemeCategory.diphthong,
      voicing: VoicingType.vowel,
      exampleWord: 'fly',
      exampleIpa: '/flaɪ/',
      spanishTrapDescription: 'Deslizamiento de "a" a "i".',
      articulationTip: 'Desliza de /a/ abierta a /ɪ/.',
      l1SpanishDifficultyPrior: 0.25,
    ),
    PhonemeInfo(
      symbol: 'ɔɪ',
      arpaKey: 'OY',
      name: 'Choice Diphthong',
      category: PhonemeCategory.diphthong,
      voicing: VoicingType.vowel,
      exampleWord: 'boy',
      exampleIpa: '/bɔɪ/',
      spanishTrapDescription: 'Similar al diptongo español "oy".',
      articulationTip: 'Comienza en /ɔ/ y termina en /ɪ/.',
      l1SpanishDifficultyPrior: 0.2,
    ),
    PhonemeInfo(
      symbol: 'aʊ',
      arpaKey: 'AW',
      name: 'Mouth Diphthong',
      category: PhonemeCategory.diphthong,
      voicing: VoicingType.vowel,
      exampleWord: 'now',
      exampleIpa: '/naʊ/',
      spanishTrapDescription: 'Deslizamiento de "a" a "u".',
      articulationTip: 'Empieza con boca abierta y redondea los labios al final.',
      l1SpanishDifficultyPrior: 0.3,
    ),
    PhonemeInfo(
      symbol: 'əʊ',
      arpaKey: 'OW',
      name: 'Goat Diphthong',
      category: PhonemeCategory.diphthong,
      voicing: VoicingType.vowel,
      exampleWord: 'home',
      exampleIpa: '/həʊm/',
      spanishTrapDescription: 'Se suele pronunciar como "o" pura española en vez de diptongo que arranca en schwa.',
      articulationTip: 'Arranca en neutro /ə/ y redondea suavemente a /ʊ/.',
      l1SpanishDifficultyPrior: 0.7,
    ),
    PhonemeInfo(
      symbol: 'ɪə',
      arpaKey: 'IH',
      name: 'Near Diphthong',
      category: PhonemeCategory.diphthong,
      voicing: VoicingType.vowel,
      exampleWord: 'here',
      exampleIpa: '/hɪər/',
      spanishTrapDescription: 'Deslizamiento de "i" relajada a schwa.',
      articulationTip: 'Desliza de /ɪ/ a la relajación total de /ə/.',
      l1SpanishDifficultyPrior: 0.6,
    ),
    PhonemeInfo(
      symbol: 'eə',
      arpaKey: 'EH',
      name: 'Square Diphthong',
      category: PhonemeCategory.diphthong,
      voicing: VoicingType.vowel,
      exampleWord: 'wear',
      exampleIpa: '/weər/',
      spanishTrapDescription: 'Deslizamiento de "e" a schwa.',
      articulationTip: 'Desliza de /e/ a /ə/.',
      l1SpanishDifficultyPrior: 0.55,
    ),
    PhonemeInfo(
      symbol: 'ʊə',
      arpaKey: 'UH',
      name: 'Cure Diphthong',
      category: PhonemeCategory.diphthong,
      voicing: VoicingType.vowel,
      exampleWord: 'tour',
      exampleIpa: '/tʊər/',
      spanishTrapDescription: 'Deslizamiento de "u" relajada a schwa.',
      articulationTip: 'Desliza de /ʊ/ a /ə/.',
      l1SpanishDifficultyPrior: 0.65,
    ),

    // ── 4. CONSONANTS: PLOSIVES ──
    PhonemeInfo(
      symbol: 'p',
      arpaKey: 'P',
      name: 'Unvoiced Bilabial Plosive',
      category: PhonemeCategory.plosive,
      voicing: VoicingType.unvoiced,
      exampleWord: 'pen',
      exampleIpa: '/pen/',
      spanishTrapDescription: 'En inglés es aspirada a principio de palabra (/pʰ/), liberando un golpe de aire.',
      articulationTip: 'Suelta una pequeña ráfaga de aire que apague una vela.',
      l1SpanishDifficultyPrior: 0.5,
    ),
    PhonemeInfo(
      symbol: 'b',
      arpaKey: 'B',
      name: 'Voiced Bilabial Plosive',
      category: PhonemeCategory.plosive,
      voicing: VoicingType.voiced,
      exampleWord: 'bad',
      exampleIpa: '/bæd/',
      spanishTrapDescription: 'En español suele fricativizarse entre vocales; en inglés siempre cierra completamente los labios.',
      articulationTip: 'Junta los labios firmemente y haz vibrar las cuerdas vocales.',
      l1SpanishDifficultyPrior: 0.45,
    ),
    PhonemeInfo(
      symbol: 't',
      arpaKey: 'T',
      name: 'Unvoiced Alveolar Plosive',
      category: PhonemeCategory.plosive,
      voicing: VoicingType.unvoiced,
      exampleWord: 'tea',
      exampleIpa: '/tiː/',
      spanishTrapDescription: 'En español es dental (toca los dientes). En inglés la lengua toca la cresta alveolar (encías superiores) y es aspirada.',
      articulationTip: 'Pon la punta de la lengua en el paladar detrás de los dientes, no sobre los dientes.',
      l1SpanishDifficultyPrior: 0.6,
    ),
    PhonemeInfo(
      symbol: 'd',
      arpaKey: 'D',
      name: 'Voiced Alveolar Plosive',
      category: PhonemeCategory.plosive,
      voicing: VoicingType.voiced,
      exampleWord: 'did',
      exampleIpa: '/dɪd/',
      spanishTrapDescription: 'Alveolar con contacto firme; en posición final a menudo se omite en español.',
      articulationTip: 'Golpea la cresta alveolar y mantén la vibración.',
      l1SpanishDifficultyPrior: 0.65,
    ),
    PhonemeInfo(
      symbol: 'k',
      arpaKey: 'K',
      name: 'Unvoiced Velar Plosive',
      category: PhonemeCategory.plosive,
      voicing: VoicingType.unvoiced,
      exampleWord: 'cat',
      exampleIpa: '/kæt/',
      spanishTrapDescription: 'Aspirada en posición inicial.',
      articulationTip: 'Bloquea el aire en la garganta y suelta con ráfaga de aire.',
      l1SpanishDifficultyPrior: 0.4,
    ),
    PhonemeInfo(
      symbol: 'ɡ',
      arpaKey: 'G',
      name: 'Voiced Velar Plosive',
      category: PhonemeCategory.plosive,
      voicing: VoicingType.voiced,
      exampleWord: 'go',
      exampleIpa: '/ɡəʊ/',
      spanishTrapDescription: 'Contacto oclusivo velar firme.',
      articulationTip: 'Haz vibrar las cuerdas con la parte posterior de la lengua contra el velo.',
      l1SpanishDifficultyPrior: 0.35,
    ),

    // ── 5. CONSONANTS: FRICATIVES ──
    PhonemeInfo(
      symbol: 'f',
      arpaKey: 'F',
      name: 'Unvoiced Labiodental Fricative',
      category: PhonemeCategory.fricative,
      voicing: VoicingType.unvoiced,
      exampleWord: 'fall',
      exampleIpa: '/fɔːl/',
      spanishTrapDescription: 'Igual que en español.',
      articulationTip: 'Dientes superiores sobre el labio inferior.',
      l1SpanishDifficultyPrior: 0.1,
    ),
    PhonemeInfo(
      symbol: 'v',
      arpaKey: 'V',
      name: 'Voiced Labiodental Fricative',
      category: PhonemeCategory.fricative,
      voicing: VoicingType.voiced,
      exampleWord: 'voice',
      exampleIpa: '/vɔɪs/',
      spanishTrapDescription: 'Gran trampa: en español no hay diferencia entre "b" y "v". Se suele pronunciar como /b/.',
      articulationTip: 'Dientes superiores sobre labio inferior + vibración sonora continua.',
      l1SpanishDifficultyPrior: 0.95,
    ),
    PhonemeInfo(
      symbol: 'θ',
      arpaKey: 'TH',
      name: 'Unvoiced Dental Fricative (Soft TH)',
      category: PhonemeCategory.fricative,
      voicing: VoicingType.unvoiced,
      exampleWord: 'think',
      exampleIpa: '/θɪŋk/',
      spanishTrapDescription: 'Similar a la "z" de España, pero en hispanoamérica se suele sustituir por /s/ ("sink").',
      articulationTip: 'Coloca la punta de la lengua entre los dientes y sopla sin vibración.',
      l1SpanishDifficultyPrior: 0.8,
    ),
    PhonemeInfo(
      symbol: 'ð',
      arpaKey: 'DH',
      name: 'Voiced Dental Fricative (Hard TH)',
      category: PhonemeCategory.fricative,
      voicing: VoicingType.voiced,
      exampleWord: 'this',
      exampleIpa: '/ðɪs/',
      spanishTrapDescription: 'Similar a la "d" entre vocales en español ("lado"), pero se suele endurecer erróneamente a /d/ al inicio de palabra.',
      articulationTip: 'Lengua entre los dientes + haz vibrar las cuerdas vocales ("zzz").',
      l1SpanishDifficultyPrior: 0.85,
    ),
    PhonemeInfo(
      symbol: 's',
      arpaKey: 'S',
      name: 'Unvoiced Alveolar Fricative',
      category: PhonemeCategory.fricative,
      voicing: VoicingType.unvoiced,
      exampleWord: 'see',
      exampleIpa: '/siː/',
      spanishTrapDescription: 'Trampa del grupo inicial "s-": los hispanohablantes tienden a añadir una "e" de apoyo ("eschool", "espeak").',
      articulationTip: 'Empieza con un silbido limpio sin emitir ninguna vocal previa.',
      l1SpanishDifficultyPrior: 0.9,
    ),
    PhonemeInfo(
      symbol: 'z',
      arpaKey: 'Z',
      name: 'Voiced Alveolar Fricative',
      category: PhonemeCategory.fricative,
      voicing: VoicingType.voiced,
      exampleWord: 'zoo',
      exampleIpa: '/zuː/',
      spanishTrapDescription: 'En español no existe la "s" sonora. Se suele ensordecer a /s/ ("Sue" vs "zoo", "eyes" vs "ice").',
      articulationTip: 'Haz el sonido de una abeja o mosca zumbando ("zzzz").',
      l1SpanishDifficultyPrior: 0.9,
    ),
    PhonemeInfo(
      symbol: 'ʃ',
      arpaKey: 'SH',
      name: 'Unvoiced Postalveolar Fricative (SH)',
      category: PhonemeCategory.fricative,
      voicing: VoicingType.unvoiced,
      exampleWord: 'she',
      exampleIpa: '/ʃiː/',
      spanishTrapDescription: 'No existe en la mayoría de dialectos españoles. Se suele sustituir por /tʃ/ ("ch").',
      articulationTip: 'Sonido de mandar a callar ("shhh"), continuo y sin el golpe inicial de "ch".',
      l1SpanishDifficultyPrior: 0.8,
    ),
    PhonemeInfo(
      symbol: 'ʒ',
      arpaKey: 'ZH',
      name: 'Voiced Postalveolar Fricative (Measure)',
      category: PhonemeCategory.fricative,
      voicing: VoicingType.voiced,
      exampleWord: 'vision',
      exampleIpa: '/ˈvɪʒ.ən/',
      spanishTrapDescription: 'Sonido "sh" sonoro (como la "j" en francés).',
      articulationTip: 'Haz "shhh" mientras haces vibrar las cuerdas vocales.',
      l1SpanishDifficultyPrior: 0.85,
    ),
    PhonemeInfo(
      symbol: 'h',
      arpaKey: 'HH',
      name: 'Unvoiced Glottal Fricative',
      category: PhonemeCategory.fricative,
      voicing: VoicingType.unvoiced,
      exampleWord: 'hat',
      exampleIpa: '/hæt/',
      spanishTrapDescription: 'En español la "j" es velar y rasposa (/x/). La "h" inglesa es una exhalación suave en la garganta.',
      articulationTip: 'Exhala aire cálido como empañando un espejo con el aliento.',
      l1SpanishDifficultyPrior: 0.7,
    ),

    // ── 6. CONSONANTS: AFFRICATES ──
    PhonemeInfo(
      symbol: 'tʃ',
      arpaKey: 'CH',
      name: 'Unvoiced Postalveolar Affricate (CH)',
      category: PhonemeCategory.affricate,
      voicing: VoicingType.unvoiced,
      exampleWord: 'chair',
      exampleIpa: '/tʃeər/',
      spanishTrapDescription: 'Similar a la "ch" española.',
      articulationTip: 'Bloqueo alveolar seguido de liberación rápida en fricativa.',
      l1SpanishDifficultyPrior: 0.2,
    ),
    PhonemeInfo(
      symbol: 'dʒ',
      arpaKey: 'JH',
      name: 'Voiced Postalveolar Affricate (J / G)',
      category: PhonemeCategory.affricate,
      voicing: VoicingType.voiced,
      exampleWord: 'job',
      exampleIpa: '/dʒɒb/',
      spanishTrapDescription: 'En español no existe la "ch" sonora. Se tiende a pronunciar como "y" (/j/) o "ch".',
      articulationTip: 'Di "ch" haciendo vibrar fuertemente las cuerdas vocales desde el inicio.',
      l1SpanishDifficultyPrior: 0.85,
    ),

    // ── 7. CONSONANTS: NASALS ──
    PhonemeInfo(
      symbol: 'm',
      arpaKey: 'M',
      name: 'Bilabial Nasal',
      category: PhonemeCategory.nasal,
      voicing: VoicingType.voiced,
      exampleWord: 'man',
      exampleIpa: '/mæn/',
      spanishTrapDescription: 'Igual que en español.',
      articulationTip: 'Labios juntos, aire por la nariz.',
      l1SpanishDifficultyPrior: 0.1,
    ),
    PhonemeInfo(
      symbol: 'n',
      arpaKey: 'N',
      name: 'Alveolar Nasal',
      category: PhonemeCategory.nasal,
      voicing: VoicingType.voiced,
      exampleWord: 'now',
      exampleIpa: '/naʊ/',
      spanishTrapDescription: 'Igual que en español.',
      articulationTip: 'Lengua en cresta alveolar, aire por la nariz.',
      l1SpanishDifficultyPrior: 0.1,
    ),
    PhonemeInfo(
      symbol: 'ŋ',
      arpaKey: 'NG',
      name: 'Velar Nasal (Sing)',
      category: PhonemeCategory.nasal,
      voicing: VoicingType.voiced,
      exampleWord: 'sing',
      exampleIpa: '/sɪŋ/',
      spanishTrapDescription: 'En español final suele añadirse una "g" o "k" audible (/sɪŋɡ/ o /sɪŋk/). En inglés es nasal pura sin soltar oclusión.',
      articulationTip: 'Dorso de la lengua contra el velo sin soltar aire por la boca.',
      l1SpanishDifficultyPrior: 0.75,
    ),

    // ── 8. CONSONANTS: APPROXIMANTS / LIQUIDS / GLIDES ──
    PhonemeInfo(
      symbol: 'l',
      arpaKey: 'L',
      name: 'Alveolar Lateral (Clear and Dark L)',
      category: PhonemeCategory.approximant,
      voicing: VoicingType.voiced,
      exampleWord: 'light / milk',
      exampleIpa: '/laɪt/',
      spanishTrapDescription: 'La "Dark L" ([ɫ]) a final de sílaba retrae el dorso de la lengua ("milk", "feel"), ausente en español.',
      articulationTip: 'A final de palabra, levanta la parte trasera de la lengua hacia el velo.',
      l1SpanishDifficultyPrior: 0.75,
    ),
    PhonemeInfo(
      symbol: 'r',
      arpaKey: 'R',
      name: 'Post-alveolar Approximant',
      category: PhonemeCategory.approximant,
      voicing: VoicingType.voiced,
      exampleWord: 'red',
      exampleIpa: '/red/',
      spanishTrapDescription: 'La "r" inglesa NUNCA vibra ni golpea el paladar como la "r" española (/ɾ/ o /r/).',
      articulationTip: 'Retrae la lengua hacia atrás sin que la punta toque ninguna parte del paladar.',
      l1SpanishDifficultyPrior: 0.85,
    ),
    PhonemeInfo(
      symbol: 'w',
      arpaKey: 'W',
      name: 'Voiced Labio-velar Approximant',
      category: PhonemeCategory.approximant,
      voicing: VoicingType.voiced,
      exampleWord: 'wet',
      exampleIpa: '/wet/',
      spanishTrapDescription: 'Suele añadirse un sonido "g" de apoyo erróneo ("guet" en vez de "wet").',
      articulationTip: 'Redondea los labios suavemente como para silbar sin meter sonido de garganta.',
      l1SpanishDifficultyPrior: 0.6,
    ),
    PhonemeInfo(
      symbol: 'j',
      arpaKey: 'Y',
      name: 'Palatal Approximant (Y)',
      category: PhonemeCategory.approximant,
      voicing: VoicingType.voiced,
      exampleWord: 'yes',
      exampleIpa: '/jes/',
      spanishTrapDescription: 'Aproximante suave, no fricativa ni africada como la "y"/"ll" de algunos dialectos.',
      articulationTip: 'Desliza suavemente desde una posición de /i/ sin contacto brusco.',
      l1SpanishDifficultyPrior: 0.45,
    ),
  ];

  static const List<MinimalPairItem> minimalPairs = [
    // ── /ɪ/ vs /iː/ ──
    MinimalPairItem(
      wordA: 'ship', ipaA: '/ʃɪp/', phonemeA: 'ɪ',
      wordB: 'sheep', ipaB: '/ʃiːp/', phonemeB: 'iː',
      contrastTitle: '/ɪ/ vs /iː/ (Ship vs Sheep)',
      l1Explanation: '/ɪ/ es corta y relajada; /iː/ es tensa, larga y sonriente.',
    ),
    MinimalPairItem(
      wordA: 'fit', ipaA: '/fɪt/', phonemeA: 'ɪ',
      wordB: 'feet', ipaB: '/fiːt/', phonemeB: 'iː',
      contrastTitle: '/ɪ/ vs /iː/ (Fit vs Feet)',
      l1Explanation: '/ɪ/ es corta y relajada; /iː/ es tensa y larga.',
    ),
    MinimalPairItem(
      wordA: 'hit', ipaA: '/hɪt/', phonemeA: 'ɪ',
      wordB: 'heat', ipaB: '/hiːt/', phonemeB: 'iː',
      contrastTitle: '/ɪ/ vs /iː/ (Hit vs Heat)',
      l1Explanation: 'Contraste crucial para evitar malentendidos en contexto técnico.',
    ),
    MinimalPairItem(
      wordA: 'live', ipaA: '/lɪv/', phonemeA: 'ɪ',
      wordB: 'leave', ipaB: '/liːv/', phonemeB: 'iː',
      contrastTitle: '/ɪ/ vs /iː/ (Live vs Leave)',
      l1Explanation: 'Live usa vocal relajada /ɪ/; Leave usa vocal larga /iː/.',
    ),
    MinimalPairItem(
      wordA: 'bitch', ipaA: '/bɪtʃ/', phonemeA: 'ɪ',
      wordB: 'beach', ipaB: '/biːtʃ/', phonemeB: 'iː',
      contrastTitle: '/ɪ/ vs /iː/ (Bitch vs Beach)',
      l1Explanation: '¡Cuidado! Decir /iː/ largo en Beach previene decir una palabra malsonante.',
    ),

    // ── /v/ vs /b/ ──
    MinimalPairItem(
      wordA: 'very', ipaA: '/ˈver.i/', phonemeA: 'v',
      wordB: 'berry', ipaB: '/ˈber.i/', phonemeB: 'b',
      contrastTitle: '/v/ vs /b/ (Very vs Berry)',
      l1Explanation: '/v/ es labiodental (dientes en labio); /b/ es bilabial (labios juntos).',
    ),
    MinimalPairItem(
      wordA: 'vote', ipaA: '/vəʊt/', phonemeA: 'v',
      wordB: 'boat', ipaB: '/bəʊt/', phonemeB: 'b',
      contrastTitle: '/v/ vs /b/ (Vote vs Boat)',
      l1Explanation: 'En español no se distingue; en inglés cambia por completo el significado.',
    ),
    MinimalPairItem(
      wordA: 'vest', ipaA: '/vest/', phonemeA: 'v',
      wordB: 'best', ipaB: '/best/', phonemeB: 'b',
      contrastTitle: '/v/ vs /b/ (Vest vs Best)',
      l1Explanation: 'Siente la vibración de los dientes superiores en el labio inferior para /v/.',
    ),

    // ── /θ/ vs /s/ ──
    MinimalPairItem(
      wordA: 'think', ipaA: '/θɪŋk/', phonemeA: 'θ',
      wordB: 'sink', ipaB: '/sɪŋk/', phonemeB: 's',
      contrastTitle: '/θ/ vs /s/ (Think vs Sink)',
      l1Explanation: '/θ/ requiere sacar la punta de la lengua; /s/ mantiene la lengua tras los dientes.',
    ),
    MinimalPairItem(
      wordA: 'thick', ipaA: '/θɪk/', phonemeA: 'θ',
      wordB: 'sick', ipaB: '/sɪk/', phonemeB: 's',
      contrastTitle: '/θ/ vs /s/ (Thick vs Sick)',
      l1Explanation: 'Evita sustituir la "th" por "s" en contextos profesionales.',
    ),

    // ── /s/ vs /z/ ──
    MinimalPairItem(
      wordA: 'ice', ipaA: '/aɪs/', phonemeA: 's',
      wordB: 'eyes', ipaB: '/aɪz/', phonemeB: 'z',
      contrastTitle: '/s/ vs /z/ (Ice vs Eyes)',
      l1Explanation: '/s/ es sorda (sin vibración); /z/ es sonora (zumbido de abeja).',
    ),
    MinimalPairItem(
      wordA: 'price', ipaA: '/praɪs/', phonemeA: 's',
      wordB: 'prize', ipaB: '/praɪz/', phonemeB: 'z',
      contrastTitle: '/s/ vs /z/ (Price vs Prize)',
      l1Explanation: 'El zumbido en /z/ distingue el precio del premio.',
    ),

    // ── /ʃ/ vs /tʃ/ ──
    MinimalPairItem(
      wordA: 'share', ipaA: '/ʃeər/', phonemeA: 'ʃ',
      wordB: 'chair', ipaB: '/tʃeər/', phonemeB: 'tʃ',
      contrastTitle: '/ʃ/ vs /tʃ/ (Share vs Chair)',
      l1Explanation: '/ʃ/ es continuo ("shhh"); /tʃ/ tiene un golpe oclusivo inicial ("ch").',
    ),
    MinimalPairItem(
      wordA: 'sheet', ipaA: '/ʃiːt/', phonemeA: 'ʃ',
      wordB: 'cheat', ipaB: '/tʃiːt/', phonemeB: 'tʃ',
      contrastTitle: '/ʃ/ vs /tʃ/ (Sheet vs Cheat)',
      l1Explanation: 'Suaviza el sonido para evitar decir "cheat" cuando quieres decir "sheet".',
    ),

    // ── /æ/ vs /ʌ/ ──
    MinimalPairItem(
      wordA: 'cat', ipaA: '/kæt/', phonemeA: 'æ',
      wordB: 'cut', ipaB: '/kʌt/', phonemeB: 'ʌ',
      contrastTitle: '/æ/ vs /ʌ/ (Cat vs Cut)',
      l1Explanation: '/æ/ estira las comisuras de los labios; /ʌ/ es una vocal corta relajada en el centro.',
    ),
    MinimalPairItem(
      wordA: 'bat', ipaA: '/bæt/', phonemeA: 'æ',
      wordB: 'but', ipaB: '/bʌt/', phonemeB: 'ʌ',
      contrastTitle: '/æ/ vs /ʌ/ (Bat vs But)',
      l1Explanation: 'Diferencia entre el bate/murciélago y la conjunción "pero".',
    ),
  ];

  static PhonemeInfo? findPhoneme(String sym) {
    final clean = sym.trim().toLowerCase();
    for (final p in all44Phonemes) {
      if (p.symbol.toLowerCase() == clean || p.arpaKey.toLowerCase() == clean) {
        return p;
      }
    }
    return null;
  }
}

/// Signal Detection Theory: Sensibilidad perceptual d' (d-prime)
class SignalDetectionDPrime {
  /// Calcula d' a partir de Hits, Total Targets, False Alarms y Total Distractors
  /// d' = Z(H) - Z(FA)
  static double calculate({
    required int hits,
    required int totalTargets,
    required int falseAlarms,
    required int totalDistractors,
  }) {
    if (totalTargets <= 0 || totalDistractors <= 0) return 0.0;

    // Corrección de Hautus para proporciones extremas (evita infinitos)
    final double hAdj = (hits + 0.5) / (totalTargets + 1.0);
    final double faAdj = (falseAlarms + 0.5) / (totalDistractors + 1.0);

    final double zH = _probit(hAdj);
    final double zFa = _probit(faAdj);

    return zH - zFa;
  }

  /// Aproximación racional de Beasley-Springer-Moro / Abramowitz-Stegun para la función Probit (Z-score)
  static double _probit(double p) {
    if (p <= 0.0) return -4.0;
    if (p >= 1.0) return 4.0;

    // Aproximación estándar de probit
    final double q = p - 0.5;
    if (q.abs() <= 0.42) {
      final double r = q * q;
      return q * (((-25.44106049637 * r + 41.39119773534) * r - 18.61500062529) * r + 2.50662823884) /
          ((((3.13082909833 * r - 21.06224101826) * r + 23.08336743743) * r - 8.47351093090) * r + 1.0);
    }

    double r = p < 0.5 ? p : 1.0 - p;
    r = math.sqrt(-math.log(r));
    double val = (((2.32121276858 * r + 4.87882458012) * r - 0.05523974465) * r - 0.247453500) /
        ((((0.000398064794 * r + 0.033612652) * r + 0.39518049) * r + 1.0) * r);

    return p < 0.5 ? -val : val;
  }
}
