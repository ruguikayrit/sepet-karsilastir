"""Ürün tipi başına market eşleştirme kuralları.

Her kural bir market aramasını tek bir ürün tipine indirger:

* ``term`` — markette aranacak metin
* ``unit`` — ürün adında bulunması gereken gramaj/hacim deseni
* ``must`` — adda geçmesi gereken ifadelerden en az biri
* ``no``   — adda geçmemesi gereken ifadeler

Kural metinleri Türkçe karakterleri katlanmış (ASCII) yazılır; eşleştirme de
katlanmış ürün adı üzerinde yapılır. ``\\b`` ile başlayan ifadeler regex,
kalanlar kelime sınırlı düz metin olarak aranır. Birim deseni ürün adındaki
gramajı katalogdaki gramaja sabitler: 500 g kaşar satırına 400 g ürün giremez.
"""

from __future__ import annotations

RULES: dict[str, dict] = {
    'sut-1l': {
        'term': 'süt',
        'unit': '((?<![\\d.,])1\\s*(lt|l)\\b|(?<![\\d.,])1000\\s*ml\\b|\\b1/1\\b)',
        'must': ['tam yagli', '%3'],
        'no': [
            'sutlu', 'yarim', 'light', 'laktozsuz', 'devam', 'toz', 'kefir',
            'cikolatali', 'kakaolu', 'krema', 'yagsiz', '%1', '%2', '%0',
        ],
    },
    'sut-yarim-1l': {
        'term': 'süt yarım yağlı',
        'unit': '((?<![\\d.,])1\\s*(lt|l)\\b|(?<![\\d.,])1000\\s*ml\\b|\\b1/1\\b)',
        'must': ['yarim yagli', '%1,5', '%1.5'],
        'no': [
            'sutlu', 'toz', 'devam', 'krema', 'laktozsuz', 'tam yagli', '%3',
        ],
    },
    'yumurta-30': {
        'term': 'yumurta',
        'unit': '(?<![\\d.,])30\\s*(lu|li|adet|ad)\\b',
        'must': ['yumurta'],
        'no': ['sivi'],
    },
    'yumurta-15': {
        'term': 'yumurta',
        'unit': '(?<![\\d.,])15\\s*(li|lu|adet|ad)\\b',
        'must': ['yumurta'],
        'no': ['sivi'],
    },
    'peynir-500': {
        'term': 'beyaz peynir',
        'unit': '(?<![\\d.,])500\\s*(gr|g)\\b',
        'must': ['beyaz peynir'],
        'no': ['kasar', 'labne', 'krem', 'tulum', 'suzme', 'lor'],
    },
    'kasar-500': {
        'term': 'kaşar peyniri',
        'unit': '(?<![\\d.,])500\\s*(gr|g)\\b',
        'must': ['kasar'],
        'no': ['dilimli', 'rende'],
    },
    'labne-400': {
        'term': 'labne',
        'unit': '(?<![\\d.,])400\\s*(gr|g)\\b',
        'must': ['labne'],
        'no': [],
    },
    'yogurt-1kg': {
        'term': 'yoğurt',
        'unit': '((?<![\\d.,])1000\\s*(gr|g)\\b|(?<![\\d.,])1\\s*kg\\b)',
        'must': ['yogurt'],
        'no': ['meyveli', 'kefir', 'ayran'],
    },
    'tereyag-500': {
        'term': 'tereyağı',
        'unit': '(?<![\\d.,])500\\s*(gr|g)\\b',
        'must': ['tereyag'],
        'no': ['margarin'],
    },
    'zeytin-500': {
        'term': 'siyah zeytin',
        'unit': '(?<![\\d.,])500\\s*(gr|g)\\b',
        'must': ['zeytin'],
        'no': ['yesil', 'yagi', 'ezme'],
    },
    'recel-380': {
        'term': 'reçel',
        'unit': '(?<![\\d.,])380\\s*(gr|g)\\b',
        'must': ['recel'],
        'no': [],
    },
    'misir-gevregi': {
        'term': 'mısır gevreği',
        'unit': '(?<![\\d.,])450\\s*(gr|g)\\b',
        'must': ['gevre'],
        'no': [],
    },
    'ekmek-tam-bugday': {
        'term': 'tam buğday ekmek',
        'unit': '',
        'must': ['bugday ekmek'],
        'no': ['galeta', 'unu', 'gevrek'],
    },
    'ekmek-beyaz': {
        'term': 'ekmek',
        'unit': '',
        'must': ['ekmek'],
        'no': [
            'bugday', 'galeta', 'gevrek', 'cavdar', 'unu', 'kepek', 'tost',
            'kizar', 'etimek', 'corek', 'kraker',
        ],
    },
    'pirinc-1kg': {
        'term': 'pirinç',
        'unit': '((?<![\\d.,])1000\\s*(gr|g)\\b|(?<![\\d.,])1\\s*kg\\b)',
        'must': ['pirinc'],
        'no': ['pilav', 'unu'],
    },
    'makarna-500': {
        'term': 'spagetti makarna',
        'unit': '(?<![\\d.,])500\\s*(gr|g)\\b',
        'must': ['spagetti', 'spaghetti'],
        'no': [],
    },
    'makarna-penne': {
        'term': 'penne makarna',
        'unit': '(?<![\\d.,])500\\s*(gr|g)\\b',
        'must': ['penne', 'kalem'],
        'no': [],
    },
    'aycicek-1l': {
        'term': 'ayçiçek yağı',
        'unit': '((?<![\\d.,])1\\s*(lt|l)\\b|(?<![\\d.,])1000\\s*ml\\b)',
        'must': ['aycicek'],
        'no': ['misir', 'kanola'],
    },
    'aycicek-5l': {
        'term': 'ayçiçek yağı 5 lt',
        'unit': '(?<![\\d.,])5\\s*(lt|l)\\b',
        'must': ['aycicek'],
        'no': ['al 3 ode', 'al 2 ode', 'kampanya'],
    },
    'zeytinyagi-1l': {
        'term': 'zeytinyağı',
        'unit': '((?<![\\d.,])1\\s*(lt|l)\\b|(?<![\\d.,])1000\\s*ml\\b)',
        'must': ['zeytinyag'],
        'no': [],
    },
    'seker-2kg': {
        'term': 'toz şeker',
        'unit': '((?<![\\d.,])2000\\s*(gr|g)\\b|(?<![\\d.,])2\\s*kg\\b)',
        'must': ['toz seker'],
        'no': ['pudra', 'kup', 'esmer', 'fasulye'],
    },
    'seker-1kg': {
        'term': 'toz şeker',
        'unit': '((?<![\\d.,])1000\\s*(gr|g)\\b|(?<![\\d.,])1\\s*kg\\b)',
        'must': ['toz seker'],
        'no': ['pudra', 'kup', 'esmer', 'fasulye'],
    },
    'un-5kg': {
        'term': 'un 5 kg',
        'unit': '(?<![\\d.,])5\\s*kg\\b',
        'must': ['un'],
        'no': ['pudra'],
    },
    'tuz-500': {
        'term': 'sofra tuzu',
        'unit': '(?<![\\d.,])500\\s*(gr|g)\\b',
        'must': ['tuz'],
        'no': ['kaya', 'sivi', 'himalaya'],
    },
    'mercimek-1kg': {
        'term': 'kırmızı mercimek',
        'unit': '((?<![\\d.,])1000\\s*(gr|g)\\b|(?<![\\d.,])1\\s*kg\\b)',
        'must': ['kirmizi mercimek'],
        'no': ['corba', 'yesil', 'siyah', 'sari'],
    },
    'nohut-1kg': {
        'term': 'nohut',
        'unit': '((?<![\\d.,])1000\\s*(gr|g)\\b|(?<![\\d.,])1\\s*kg\\b)',
        'must': ['nohut'],
        'no': ['leblebi'],
    },
    'bulgur-1kg': {
        'term': 'köftelik bulgur',
        'unit': '((?<![\\d.,])1000\\s*(gr|g)\\b|(?<![\\d.,])1\\s*kg\\b)',
        'must': ['koftelik'],
        'no': ['firik', 'simit', 'pilavlik'],
    },
    'salca-650': {
        'term': 'biber salçası',
        'unit': '(?<![\\d.,])650\\s*(gr|g)\\b',
        'must': ['biber salca'],
        'no': ['aci', 'domates'],
    },
    'ketcap-500': {
        'term': 'ketçap',
        'unit': '(?<![\\d.,])500\\s*(gr|g)\\b',
        'must': ['ketcap'],
        'no': [],
    },
    'mayonez-430': {
        'term': 'mayonez',
        'unit': '(?<![\\d.,])430\\s*(gr|g)\\b',
        'must': ['mayonez'],
        'no': ['ketcap', 'hardal'],
    },
    'ton-2x160': {
        'term': 'ton balığı',
        'unit': '(2\\s*x\\s*160|2\\*160)',
        'must': ['ton'],
        'no': [],
    },
    'konserve-fasulye': {
        'term': 'haşlanmış fasulye',
        'unit': '(?<![\\d.,])800\\s*(gr|g)\\b',
        'must': ['fasulye'],
        'no': [],
    },
    'konserve-misir': {
        'term': 'mısır konservesi',
        'unit': '(3\\s*x\\s*200|3\\*200)',
        'must': ['misir'],
        'no': [],
    },
    'cay-500': {
        'term': 'çay',
        'unit': '(?<![\\d.,])500\\s*(gr|g)\\b',
        'must': ['cay'],
        'no': [
            'bardagi', 'kasigi', 'poset', 'bitki', 'buzlu', 'aromal',
            'bergamot', 'earl', 'yesil',
        ],
    },
    'cay-1000': {
        'term': 'çay 1000 gr',
        'unit': '((?<![\\d.,])1000\\s*(gr|g)\\b|(?<![\\d.,])1\\s*kg\\b)',
        'must': ['cay'],
        'no': ['bardagi', 'kasigi', 'bitki', 'buzlu'],
    },
    'su-5l': {
        'term': 'su 5 lt',
        'unit': '(?<![\\d.,])5\\s*(lt|l)\\b',
        'must': ['\\bsu\\b'],
        'no': ['maden', 'meyve', 'soda', 'kola', 'gazoz', 'sugar'],
    },
    'su-1-5l': {
        'term': 'su 1.5 lt',
        'unit': '(?<![\\d])1[.,]5\\s*(lt|l)\\b',
        'must': ['\\bsu\\b'],
        'no': ['maden', 'meyve', 'soda', 'kola', 'gazoz', 'sugar'],
    },
    'kola-1l': {
        'term': 'kola',
        'unit': '((?<![\\d.,])1\\s*(lt|l)\\b|(?<![\\d.,])1000\\s*ml\\b)',
        'must': ['kola'],
        'no': ['kolali'],
    },
    'kola-2-5l': {
        'term': 'kola 2.5 lt',
        'unit': '(?<![\\d])2[.,]5\\s*(lt|l)\\b',
        'must': ['kola'],
        'no': ['kolali'],
    },
    'ayran-285': {
        'term': 'ayran',
        'unit': '(?<![\\d.,])285\\s*(ml|cc)\\b',
        'must': ['ayran'],
        'no': [],
    },
    'kahve-100': {
        'term': 'türk kahvesi',
        'unit': '(?<![\\d.,])100\\s*(gr|g)\\b',
        'must': ['turk kahvesi'],
        'no': ['filtre', 'granul', 'hazir'],
    },
    'filtre-kahve': {
        'term': 'filtre kahve',
        'unit': '(?<![\\d.,])250\\s*(gr|g)\\b',
        'must': ['filtre'],
        'no': [],
    },
    'meyvesuyu-1l': {
        'term': 'meyve suyu',
        'unit': '((?<![\\d.,])1\\s*(lt|l)\\b|(?<![\\d.,])1000\\s*ml\\b)',
        'must': ['meyve'],
        'no': ['soda', 'gazoz'],
    },
    'maden-6x': {
        'term': 'maden suyu',
        'unit': '(6\\s*x\\s*200|6\\*200)',
        'must': ['maden'],
        'no': [],
    },
    'domates-1kg': {
        'term': 'domates',
        'unit': '\\bkg\\b',
        'must': ['domates'],
        'no': [
            'salca', 'rende', 'kuru', 'pure', 'soslu', 'konserve',
            'dogranmis', 'kokteyl', 'tursu',
        ],
    },
    'patates-1kg': {
        'term': 'patates',
        'unit': '\\bkg\\b',
        'must': ['patates'],
        'no': [
            'cips', 'kizart', 'parmak', 'pure', 'dondurulmus', 'baby',
            'tatli',
        ],
    },
    'muz-1kg': {
        'term': 'muz',
        'unit': '\\bkg\\b',
        'must': ['muz'],
        'no': ['muzlu'],
    },
    'sogan-1kg': {
        'term': 'kuru soğan',
        'unit': '\\bkg\\b',
        'must': ['sogan'],
        'no': ['taze', 'yesil', 'arpacik'],
    },
    'salatalik-1kg': {
        'term': 'salatalık',
        'unit': '\\bkg\\b',
        'must': ['salatalik'],
        'no': ['tursu'],
    },
    'havuc-1kg': {
        'term': 'havuç',
        'unit': '\\bkg\\b',
        'must': ['havuc'],
        'no': ['havuclu', 'rende', 'baby'],
    },
    'biber-1kg': {
        'term': 'çarliston biber',
        'unit': '\\bkg\\b',
        'must': ['carliston'],
        'no': ['salca', 'tursu', 'pul'],
    },
    'patlican-1kg': {
        'term': 'patlıcan',
        'unit': '\\bkg\\b',
        'must': ['patlican'],
        'no': ['kizartma', 'konserve', 'kuru'],
    },
    'kabak-1kg': {
        'term': 'kabak',
        'unit': '\\bkg\\b',
        'must': ['kabak'],
        'no': ['cekirdek', 'tatli', 'bal'],
    },
    'fasulye-1kg': {
        'term': 'taze fasulye',
        'unit': '\\bkg\\b',
        'must': ['fasulye'],
        'no': ['kuru', 'haslan', 'konserve', 'barbunya', 'seker'],
    },
    'sarimsak-250': {
        'term': 'sarımsak',
        'unit': '(?<![\\d.,])250\\s*(gr|g)\\b',
        'must': ['sarimsak'],
        'no': ['toz', 'sos', 'granul'],
    },
    'maydanoz': {
        'term': 'maydanoz',
        'unit': '',
        'must': ['maydanoz'],
        'no': ['tohum', 'kurutulmus'],
    },
    'pilic-butun': {
        'term': 'bütün piliç',
        'unit': '',
        'must': ['butun pilic'],
        'no': [
            'but', 'kanat', 'gogus', 'pirzola', 'baget', 'ciger', 'sosis',
            'sucuk', 'salam', 'fume', 'kokteyl',
        ],
    },
    'pilic-but': {
        'term': 'piliç but',
        'unit': '',
        'must': ['\\bbut\\b'],
        'no': ['pirzola', 'izgara', 'tava', 'baget', 'kanat', 'fume'],
    },
    'tavuk-1kg': {
        'term': 'piliç but pirzola',
        'unit': '',
        'must': ['pirzola'],
        'no': ['fume', 'kuzu', 'dana', 'kivircik', 'koyun'],
    },
    'kofte-500': {
        'term': 'köfte',
        'unit': '(?<![\\d.,])500\\s*(gr|g)\\b',
        'must': ['kofte'],
        'no': ['harc', 'baharat', 'cig kofte', 'seti'],
    },
    'sucuk-250': {
        'term': 'sucuk',
        'unit': '(?<![\\d.,])250\\s*(gr|g)\\b',
        'must': ['sucuk'],
        'no': ['sucuklu'],
    },
    'salam-60': {
        'term': 'salam',
        'unit': '(?<![\\d.,])60\\s*(gr|g)\\b',
        'must': ['salam'],
        'no': [],
    },
    'sosis-190': {
        'term': 'sosis',
        'unit': '(?<![\\d.,])190\\s*(gr|g)\\b',
        'must': ['sosis'],
        'no': [],
    },
    'kiyma-400': {
        'term': 'dana kıyma',
        'unit': '(?<![\\d.,])400\\s*(gr|g)\\b',
        'must': ['kiyma'],
        'no': ['kuzu', 'tavuk', 'pilic', 'hindi'],
    },
    'deterjan-1-5kg': {
        'term': 'toz deterjan',
        'unit': '((?<![\\d])1[.,]5\\s*kg\\b|(?<![\\d.,])1500\\s*(gr|g)\\b)',
        'must': ['deterjan'],
        'no': ['bulasik', 'sivi'],
    },
    'bulasik-1500': {
        'term': 'bulaşık deterjanı',
        'unit': '(?<![\\d.,])1500\\s*ml\\b',
        'must': ['bulasik'],
        'no': ['makine', 'tablet'],
    },
    'yumusatici-1440': {
        'term': 'yumuşatıcı',
        'unit': '(?<![\\d.,])1440\\s*ml\\b',
        'must': ['yumusatici'],
        'no': [],
    },
    'tuvalet-16': {
        'term': 'tuvalet kağıdı',
        'unit': '(?<![\\d.,])16\\s*(li|lu|adet|rulo)\\b',
        'must': ['tuvalet'],
        'no': [],
    },
    'cop-torbasi': {
        'term': 'çöp torbası',
        'unit': '(?<![\\d.,])15\\s*(li|lu|adet)\\b',
        'must': ['cop'],
        'no': ['dondurucu', 'buzdolabi'],
    },
    'sampuan-400': {
        'term': 'şampuan',
        'unit': '(?<![\\d.,])400\\s*ml\\b',
        'must': ['sampuan'],
        'no': ['bebek', 'kopuk'],
    },
    'dis-macunu': {
        'term': 'diş macunu',
        'unit': '(?<![\\d.,])75\\s*ml\\b',
        'must': ['macun'],
        'no': ['cocuk', 'firca'],
    },
    'sabun-4': {
        'term': 'kalıp sabun',
        'unit': '4\\s*(x|\\*)\\s*200\\s*(gr|g)\\b',
        'must': ['sabun'],
        'no': ['sivi', 'arap', 'kopuk'],
    },
    'dus-jeli': {
        'term': 'duş jeli',
        'unit': '(?<![\\d.,])500\\s*ml\\b',
        'must': ['dus jeli'],
        'no': ['sampuan', 'kopuk'],
    },
    'cips-150': {
        'term': 'patates cipsi',
        'unit': '(?<![\\d.,])150\\s*(gr|g)\\b',
        'must': ['cips'],
        'no': [],
    },
    'biskuvi-102': {
        'term': 'bisküvi',
        'unit': '(?<![\\d.,])102\\s*(gr|g)\\b',
        'must': ['biskuvi'],
        'no': [],
    },
    'cikolata-100': {
        'term': 'sütlü çikolata',
        'unit': '(?<![\\d.,])100\\s*(gr|g)\\b',
        'must': ['cikolata'],
        'no': ['sicak', 'sos', 'pul', 'kaplamali'],
    },
    'gofret-350': {
        'term': 'gofret',
        'unit': '(?<![\\d.,])350\\s*(gr|g)\\b',
        'must': ['gofret'],
        'no': [],
    },
    'kek-162': {
        'term': 'kek',
        'unit': '(?<![\\d.,])162\\s*(gr|g)\\b',
        'must': ['kek'],
        'no': ['unu', 'karisim'],
    },
    'kraker-82': {
        'term': 'kraker',
        'unit': '(?<![\\d.,])82\\s*(gr|g)\\b',
        'must': ['kraker'],
        'no': [],
    },
    'findik-ici': {
        'term': 'fındık içi',
        'unit': '(?<![\\d.,])150\\s*(gr|g)\\b',
        'must': ['findik'],
        'no': ['ezme', 'krema', 'cikolata'],
    },
    'dondurma-500': {
        'term': 'dondurma',
        'unit': '(?<![\\d.,])500\\s*ml\\b',
        'must': ['dondurma'],
        'no': ['kulah', 'cubuk'],
    },
    'bebek-bezi': {
        'term': 'bebek bezi',
        'unit': '(?<![\\d.,])40\\s*(li|lu|adet|ad)\\b',
        'must': ['bez'],
        'no': ['islak', 'havlu'],
    },
}
