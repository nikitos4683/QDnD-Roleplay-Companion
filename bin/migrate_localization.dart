import 'dart:io';
import 'dart:convert';

// STATIC DICTIONARY FOR CORE TERMS
final Map<String, String> coreTerms = {
  // Classes
  'Barbarian': 'Варвар',
  'Bard': 'Бард',
  'Cleric': 'Жрец',
  'Druid': 'Друид',
  'Fighter': 'Воин',
  'Monk': 'Монах',
  'Paladin': 'Паладин',
  'Ranger': 'Следопыт',
  'Rogue': 'Плут',
  'Sorcerer': 'Чародей',
  'Warlock': 'Колдун',
  'Wizard': 'Волшебник',
  
  // Races
  'Human': 'Человек',
  'Elf': 'Эльф',
  'Dwarf': 'Дварф',
  'Halfling': 'Полурослик',
  'Dragonborn': 'Драконорожденный',
  'Gnome': 'Гном',
  'Half-Elf': 'Полуэльф',
  'Half-Orc': 'Полуорк',
  'Tiefling': 'Тифлинг',

  // Skills
  'Athletics': 'Атлетика',
  'Acrobatics': 'Акробатика',
  'Sleight of Hand': 'Ловкость рук',
  'Stealth': 'Скрытность',
  'Arcana': 'Магия',
  'History': 'История',
  'Investigation': 'Анализ',
  'Nature': 'Природа',
  'Religion': 'Религия',
  'Animal Handling': 'Уход за животными',
  'Insight': 'Проницательность',
  'Medicine': 'Медицина',
  'Perception': 'Восприятие',
  'Survival': 'Выживание',
  'Deception': 'Обман',
  'Intimidation': 'Запугивание',
  'Performance': 'Выступление',
  'Persuasion': 'Убеждение',

  // Abilities
  'Strength': 'Сила',
  'Dexterity': 'Ловкость',
  'Constitution': 'Телосложение',
  'Intelligence': 'Интеллект',
  'Wisdom': 'Мудрость',
  'Charisma': 'Харизма',

  // Item Types
  'weapon': 'Оружие',
  'armor': 'Доспех',
  'consumable': 'Расходник',
  'tool': 'Инструмент',
  'gear': 'Снаряжение',
  'treasure': 'Сокровище',

  // Item Rarities
  'common': 'Обычный',
  'uncommon': 'Необычный',
  'rare': 'Редкий',
  'veryRare': 'Очень редкий',
  'legendary': 'Легендарный',
  'artifact': 'Артефакт',
  
  // Damage Types
  'slashing': 'Рубящий',
  'piercing': 'Колющий',
  'bludgeoning': 'Дробящий',
  'acid': 'Кислота',
  'cold': 'Холод',
  'fire': 'Огонь',
  'force': 'Силовой',
  'lightning': 'Молния',
  'necrotic': 'Некротический',
  'poison': 'Яд',
  'psychic': 'Психический',
  'radiant': 'Излучение',
  'thunder': 'Звук',
};

void main() {
  print('🚀 Starting localization migration...');
  
  final dataDir = Directory('assets/data');
  if (!dataDir.existsSync()) {
    print('❌ Data directory not found!');
    return;
  }

  final files = dataDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.json'));

  for (final file in files) {
    processFile(file);
  }

  print('✅ Migration complete!');
}

void processFile(File file) {
  print('📄 Processing ${file.path}...');
  try {
    final content = file.readAsStringSync();
    final dynamic jsonContent = jsonDecode(content);

    bool modified = false;

    if (jsonContent is List) {
      // List of items/features
      for (var item in jsonContent) {
        if (migrateItem(item)) modified = true;
      }
    } else if (jsonContent is Map<String, dynamic>) {
      // Single object (Class, Race)
      if (migrateObject(jsonContent)) modified = true;
    }

    if (modified) {
      const encoder = JsonEncoder.withIndent('  ');
      file.writeAsStringSync(encoder.convert(jsonContent));
      print('  💾 Saved updates to ${file.path}');
    } else {
      print('  Actions: No changes needed.');
    }
  } catch (e) {
    print('  ❌ Error processing file: $e');
  }
}

bool migrateItem(Map<String, dynamic> item) {
  bool changed = false;

  // 1. Migrate Name
  if (item.containsKey('nameEn')) {
    if (!item.containsKey('nameRu') || item['nameRu'] == null || item['nameRu'] == '') {
      final enName = item['nameEn'].toString();
      // Try dictionary match first
      String? translation = coreTerms[enName];
      
      // If not found, try partial match for known patterns (e.g. "Potion of Healing")
      translation ??= enName;

      item['nameRu'] = translation;
      changed = true;
    }
  }

  // 2. Migrate Description
  if (item.containsKey('descriptionEn')) {
    if (!item.containsKey('descriptionRu') || item['descriptionRu'] == null || item['descriptionRu'] == '') {
      item['descriptionRu'] = item['descriptionEn']; // Fallback copy
      changed = true;
    }
  }

  return changed;
}

bool migrateObject(Map<String, dynamic> obj) {
  bool changed = false;

  // Class/Race Data usually has "name": {"en": "...", "ru": "..."} structure
  if (obj.containsKey('name') && obj['name'] is Map) {
    final nameMap = obj['name'] as Map<String, dynamic>;
    if (!nameMap.containsKey('ru') || nameMap['ru'] == '') {
      final enName = nameMap['en'] ?? obj['id'];
      nameMap['ru'] = coreTerms[enName] ?? enName;
      changed = true;
    }
  }

  if (obj.containsKey('description') && obj['description'] is Map) {
    final descMap = obj['description'] as Map<String, dynamic>;
    if (!descMap.containsKey('ru') || descMap['ru'] == '') {
      descMap['ru'] = descMap['en'] ?? '';
      changed = true;
    }
  }
  
  // Recursively check for subclasses or sub-features
  if (obj.containsKey('subclasses') && obj['subclasses'] is List) {
     for (var sub in obj['subclasses']) {
       if (migrateObject(sub)) changed = true;
     }
  }

  return changed;
}
