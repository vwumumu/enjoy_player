/// Resolve media kind from filename extension.
library;

import 'package:path/path.dart' as p;

/// Video extensions **without** leading dot (for `FilePicker.allowedExtensions`).
const kFilePickerLocalVideoExtensions = <String>[
  'mp4',
  'webm',
  'mkv',
  'mov',
  'avi',
  'm4v',
  'ogv',
];

/// Audio extensions **without** leading dot (for `FilePicker.allowedExtensions`).
const kFilePickerLocalAudioExtensions = <String>[
  'mp3',
  'm4a',
  'aac',
  'wav',
  'flac',
  'ogg',
  'opus',
  'oga',
];

/// All importable local audio/video extensions for the library import picker.
const kFilePickerLocalImportExtensions = <String>[
  ...kFilePickerLocalVideoExtensions,
  ...kFilePickerLocalAudioExtensions,
];

bool _hasPickerExt(String fileName, List<String> pickerExts) {
  final ext = p.extension(fileName).toLowerCase();
  if (ext.length < 2) return false;
  return pickerExts.contains(ext.substring(1));
}

bool isVideoFileName(String fileName) {
  return _hasPickerExt(fileName, kFilePickerLocalVideoExtensions);
}

bool isAudioFileName(String fileName) {
  return _hasPickerExt(fileName, kFilePickerLocalAudioExtensions);
}

/// True when [fileName] has an extension we import and play as local media.
bool isImportableLocalMediaFileName(String fileName) {
  return isVideoFileName(fileName) || isAudioFileName(fileName);
}
