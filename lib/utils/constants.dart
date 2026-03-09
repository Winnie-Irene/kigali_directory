const List<String> kCategories = [
  'All',
  'Hospital',
  'Police Station',
  'Library',
  'Restaurant',
  'Café',
  'Park',
  'Tourist Attraction',
  'Utility Office',
  'Other',
];

const Map<String, dynamic> kCategoryIcons = {
  'Hospital':           {'icon': 0xe3f4, 'color': 0xFFFF6B6B},   // local_hospital
  'Police Station':     {'icon': 0xe8e8, 'color': 0xFF4ECDC4},   // local_police
  'Library':            {'icon': 0xe54c, 'color': 0xFFFFE66D},   // local_library
  'Restaurant':         {'icon': 0xe56c, 'color': 0xFFFF8C42},   // restaurant
  'Café':               {'icon': 0xe541, 'color': 0xFFB8860B},   // local_cafe
  'Park':               {'icon': 0xe014, 'color': 0xFF6BCB77},   // park
  'Tourist Attraction': {'icon': 0xe53b, 'color': 0xFFDA77FF},   // attractions
  'Utility Office':     {'icon': 0xe8f9, 'color': 0xFF74B9FF},   // business_center
  'Other':              {'icon': 0xe0c8, 'color': 0xFF8892B0},   // place
};