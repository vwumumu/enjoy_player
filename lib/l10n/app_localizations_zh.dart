// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Enjoy 播放器';

  @override
  String get libraryTitle => '资料库';

  @override
  String get homeTitle => '首页';

  @override
  String get homeRecentMedia => '最近媒体';

  @override
  String get homeEmptyTitle => '暂无最近媒体';

  @override
  String get homeEmptyHint => '导入媒体或将文件拖放到此处开始。';

  @override
  String get libraryTabAudio => '音频';

  @override
  String get libraryTabVideo => '视频';

  @override
  String get libraryEmptyAudioTitle => '未找到任何音频';

  @override
  String get libraryEmptyAudioHint => '你的资料库中没有任何音频内容。';

  @override
  String get libraryEmptyVideoTitle => '未找到任何视频';

  @override
  String get libraryEmptyVideoHint => '你的资料库中没有任何视频内容。';

  @override
  String get actionOpenFiles => '打开文件';

  @override
  String get actionImport => '导入';

  @override
  String get importFromFile => '从文件…';

  @override
  String get importFromYoutube => '从 YouTube 链接…';

  @override
  String get youtubeImportTitle => '导入 YouTube 视频';

  @override
  String get youtubeImportHint => '粘贴 YouTube 链接或视频 ID';

  @override
  String get youtubeImportInvalid => '无法识别有效的 YouTube 视频 ID。';

  @override
  String get youtubeImporting => '正在添加视频…';

  @override
  String get youtubeBadge => 'YouTube';

  @override
  String get youtubeLoginTooltip => 'YouTube 账号';

  @override
  String get youtubeLoginClose => '关闭';

  @override
  String get youtubeLoginScreenTitle => 'YouTube 登录';

  @override
  String get youtubeLogout => '退出登录（清除 Cookie）';

  @override
  String get searchHint => '搜索';

  @override
  String get transportRepeat => '循环';

  @override
  String get transportFullscreen => '全屏';

  @override
  String get transportExitFullscreen => '退出全屏';

  @override
  String get transportMore => '更多';

  @override
  String get transportCollapse => '收起播放器';

  @override
  String get transportExpand => '展开播放器';

  @override
  String get settingsTitle => '设置';

  @override
  String get importMedia => '导入媒体';

  @override
  String get importingMedia => '正在导入媒体…';

  @override
  String get importMediaFailed => '无法导入此文件。';

  @override
  String get noMediaYet => '暂无媒体';

  @override
  String get tapImportToAdd => '从工具栏导入音频或视频。';

  @override
  String get navMainLabel => '主导航';

  @override
  String get miniPlayerMediaVideo => '视频';

  @override
  String get miniPlayerMediaAudio => '音频';

  @override
  String get retry => '重试';

  @override
  String get settingsSectionAppearance => '外观';

  @override
  String get settingsAppearanceSubtitle => '主题跟随系统设置。';

  @override
  String get settingsSectionAbout => '关于';

  @override
  String get settingsAboutSubtitle => 'Enjoy 播放器 — 本地字幕与跟读练习。';

  @override
  String get settingsThemeRowTitle => '主题';

  @override
  String get settingsThemeDarkLocked => '跟随系统外观。';

  @override
  String get settingsThemeSystem => '系统';

  @override
  String get settingsThemeLight => '浅色';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get play => '播放';

  @override
  String get pause => '暂停';

  @override
  String get previousLine => '上一句';

  @override
  String get nextLine => '下一句';

  @override
  String get replayLine => '重播本句';

  @override
  String get echoMode => '回声模式';

  @override
  String get exitEchoMode => '退出回声模式';

  @override
  String get transcript => '字幕稿';

  @override
  String get transcriptNowReading => '正在朗读';

  @override
  String get playerTranscriptResizeHint => '拖动以调整字幕稿面板大小';

  @override
  String get importSubtitle => '导入字幕';

  @override
  String get noTranscript => '无字幕稿';

  @override
  String get importSrtOrVtt => '导入 .srt 或 .vtt 文件。';

  @override
  String get miniPlayerOpen => '打开播放器';

  @override
  String get loading => '加载中…';

  @override
  String get error => '错误';

  @override
  String get playerOpenGenericError => '无法打开此项目。';

  @override
  String playbackRateTimes(String rate) {
    return '$rate 倍';
  }

  @override
  String get speed => '速度';

  @override
  String get volume => '音量';

  @override
  String get transportMute => '静音';

  @override
  String get transportUnmute => '取消静音';

  @override
  String get repeatNone => '关闭循环';

  @override
  String get repeatSegment => '循环片段';

  @override
  String get settingsPlaceholder => '播放器偏好将显示在此处。';

  @override
  String get subtitles => '字幕';

  @override
  String get subtitlesPrimary => '主字幕';

  @override
  String get subtitlesTranslation => '翻译（可选）';

  @override
  String get subtitlesNone => '无';

  @override
  String get subtitlesImportFile => '导入字幕文件…';

  @override
  String get subtitlesDeleteTrack => '删除轨道';

  @override
  String get importSubtitleSuccess => '字幕已导入';

  @override
  String get noTranscriptHint =>
      '打开媒体时云端字幕会在后台加载（每项在刷新前仅一次）。本地视频请使用提取或添加字幕（.srt/.vtt）。';

  @override
  String get transcriptEmptyExtract => '提取';

  @override
  String get transcriptEmptyAddSubtitle => '添加字幕';

  @override
  String get subtitlesExtractEmbedded => '提取内嵌字幕';

  @override
  String get subtitlesRefreshCloud => '从云端刷新字幕稿';

  @override
  String get subtitlesImportLanguageTitle => '字幕语言';

  @override
  String get subtitlesImportLanguageHint => 'BCP-47 代码（如 en、zh-TW）。未知请填 und。';

  @override
  String get subtitlesProviderOfficial => '官方';

  @override
  String get subtitlesProviderAuto => '自动';

  @override
  String get subtitlesProviderAi => 'AI';

  @override
  String get subtitlesProviderUser => '用户';

  @override
  String get subtitlesExtractNoTracks =>
      '此文件中无内嵌字幕轨道（仅有视频与音频）。若有单独的 .srt 或 .vtt，请使用导入文件。';

  @override
  String subtitlesExtractedCount(int count) {
    return '已提取 $count 条字幕轨道。';
  }

  @override
  String get subtitlesRefreshDone => '已从云端更新字幕稿。';

  @override
  String get subtitlesNoPlayableUri => '无法解析此项目的可播放文件。';

  @override
  String get expandEchoBackward => '向后扩展回声';

  @override
  String get expandEchoForward => '向前扩展回声';

  @override
  String get shrinkEchoBackward => '向后收缩回声';

  @override
  String get shrinkEchoForward => '向前收缩回声';

  @override
  String get shadowReadingTitle => '跟读';

  @override
  String get shadowReadingHint => '跟读本段并练习口语。录制你的声音并与参考音高对比。';

  @override
  String get shadowReadingReferenceSnippet => '参考';

  @override
  String get pitchContourTitle => '音高曲线';

  @override
  String get pitchContourError => '无法分析本段的音高。';

  @override
  String get pitchContourWaveform => '波形';

  @override
  String get pitchContourReference => '参考音高';

  @override
  String get pitchContourUser => '你的音高';

  @override
  String get pitchContourAnalyzing => '正在分析音高…';

  @override
  String get shadowRecordingExisting => '已保存的录音';

  @override
  String get shadowRecordingEmpty => '本段尚无录音。';

  @override
  String get shadowRecordingTake => '录音';

  @override
  String get shadowRecordingPlay => '播放';

  @override
  String get shadowRecordingPause => '暂停';

  @override
  String get shadowRecordingChooseTake => '切换录音';

  @override
  String get shadowRecordingDelete => '删除';

  @override
  String get shadowRecordingDeleteConfirmTitle => '删除此条录音？';

  @override
  String shadowRecordingDeleteConfirmMessage(String takeLabel) {
    return '将永久删除 $takeLabel，无法撤销。';
  }

  @override
  String get shadowRecordingRecord => '录音';

  @override
  String get shadowRecordingStop => '停止';

  @override
  String get shadowRecordingMicDenied => '需要麦克风权限才能录音。';

  @override
  String shadowRecordingSaveFailed(String reason) {
    return '无法保存录音：$reason';
  }

  @override
  String get settingsSectionRecording => '录音';

  @override
  String get settingsSectionRecordingHint => '跟读录音所使用的麦克风。';

  @override
  String get settingsRecordingMicTitle => '麦克风';

  @override
  String settingsRecordingMicAuto(String label) {
    return '自动 · $label';
  }

  @override
  String get settingsRecordingMicAutoNoDevice => '自动 · 系统默认';

  @override
  String get settingsRecordingMicEmpty => '未检测到麦克风';

  @override
  String get settingsRecordingMicAutoOption => '自动（跳过虚拟麦克风）';

  @override
  String get settingsRecordingMicDialogTitle => '选择麦克风';

  @override
  String get shadowRecordingSilentWarning => '未检测到麦克风信号。请打开「设置 → 录音」选择其他麦克风。';

  @override
  String get shadowRecordingPlaybackFailed => '无法播放此条录音。';

  @override
  String shadowRecordingOverTarget(String seconds) {
    return '超出目标 +$seconds 秒';
  }

  @override
  String get hotkeysTitle => '键盘快捷键';

  @override
  String get hotkeysHintFooter => '按 Shift+/（?）打开此列表。';

  @override
  String get hotkeysCustomizedBadge => '已自定义';

  @override
  String get hotkeysSectionKeyboard => '键盘快捷键';

  @override
  String get hotkeysResetBinding => '重置';

  @override
  String get hotkeysResetAll => '重置全部快捷键';

  @override
  String get hotkeysCaptureTitle => '按下新快捷键';

  @override
  String get hotkeysCaptureHint => '按下组合键。Esc 取消。';

  @override
  String get hotkeysConflictError => '该快捷键已被使用。';

  @override
  String get hotkeysScopeGlobal => '全局';

  @override
  String get hotkeysScopePlayer => '播放器';

  @override
  String get hotkeysScopeLibrary => '资料库';

  @override
  String get hotkeysScopeModal => '弹窗';

  @override
  String get hotkeysDescHelp => '显示键盘快捷键';

  @override
  String get hotkeysDescSearch => '打开搜索';

  @override
  String get hotkeysDescSettings => '打开设置';

  @override
  String get hotkeysDescTogglePlay => '播放 / 暂停';

  @override
  String get hotkeysDescToggleExpand => '切换播放器展开/收起';

  @override
  String get hotkeysDescToggleFullscreen => '切换全屏';

  @override
  String get hotkeysDescPrevLine => '播放上一句';

  @override
  String get hotkeysDescNextLine => '播放下一句';

  @override
  String get hotkeysDescReplayLine => '重播当前句';

  @override
  String get hotkeysDescToggleEchoMode => '切换回声模式';

  @override
  String get hotkeysDescToggleDictationMode => '切换听写模式';

  @override
  String get hotkeysDescToggleRecording => '开始/停止录音';

  @override
  String get hotkeysDescToggleAssessment => '显示/隐藏发音评测';

  @override
  String get hotkeysDescTogglePitchContour => '显示/隐藏音高曲线';

  @override
  String get hotkeysDescPlayRecording => '播放/暂停录音';

  @override
  String get hotkeysDescSlowDown => '减慢播放速度';

  @override
  String get hotkeysDescSpeedUp => '加快播放速度';

  @override
  String get hotkeysDescExpandEchoBackward => '向后扩展回声区域';

  @override
  String get hotkeysDescExpandEchoForward => '向前扩展回声区域';

  @override
  String get hotkeysDescShrinkEchoBackward => '向后收缩回声区域';

  @override
  String get hotkeysDescShrinkEchoForward => '向前收缩回声区域';

  @override
  String get hotkeysDescLibrarySearch => '聚焦搜索框';

  @override
  String get hotkeysDescCloseModal => '关闭弹窗';

  @override
  String get hotkeysStubSearch => '搜索功能尚未提供。';

  @override
  String get hotkeysStubDictation => '听写模式尚未提供。';

  @override
  String get assessmentTitle => '发音评测';

  @override
  String get assessmentDescription => '为你的朗读提供详细评分。';

  @override
  String get assessmentRun => '运行发音评测';

  @override
  String get assessmentView => '查看发音评测';

  @override
  String get assessmentReassess => '重新评测';

  @override
  String get assessmentOverallScore => '总分';

  @override
  String get assessmentAccuracy => '准确度';

  @override
  String get assessmentCompleteness => '完整度';

  @override
  String get assessmentFluency => '流利度';

  @override
  String get assessmentProsody => '韵律';

  @override
  String get assessmentPronunciationAnalysis => '发音分析';

  @override
  String get assessmentAccuracyScore => '准确度分数';

  @override
  String get assessmentSyllables => '音节';

  @override
  String get assessmentPhonemes => '音素';

  @override
  String get assessmentNoRecording => '录音文件缺失或为空。';

  @override
  String assessmentRunFailed(String reason) {
    return '无法运行评测：$reason';
  }

  @override
  String get assessmentErrorTypeOmission => '遗漏';

  @override
  String get assessmentErrorTypeInsertion => '插入';

  @override
  String get assessmentErrorTypeMispronunciation => '发音错误';

  @override
  String get assessmentErrorTypeUnexpectedBreak => '意外停顿';

  @override
  String get assessmentErrorTypeMissingBreak => '缺少停顿';

  @override
  String get assessmentErrorTypeMonotone => '单调';

  @override
  String get assessmentErrorTypeCorrect => '正确';

  @override
  String get assessmentErrorExplOmission => '预期应有此词但未检测到。';

  @override
  String get assessmentErrorExplInsertion => '检测到参考中不存在的额外词语。';

  @override
  String get assessmentErrorExplMispronunciation => '此词发音可能不正确。';

  @override
  String get assessmentErrorExplUnexpectedBreak => '在此词前检测到意外停顿。';

  @override
  String get assessmentErrorExplMissingBreak => '在此词前未检测到应有的停顿。';

  @override
  String get assessmentErrorExplMonotone => '音高变化低于预期。';

  @override
  String get assessmentErrorExplCorrect => '此词未发现问题。';

  @override
  String get assessmentWebUnsupported => 'Web 上暂不支持发音评测。';

  @override
  String get assessmentEmptyReference => '参考文本为空。';

  @override
  String get assessmentInvalidStored => '无法读取已保存的评测数据。';

  @override
  String get authSignInTitle => '登录 Enjoy';

  @override
  String get authSignInSubtitle => '应用内将打开安全登录页。完成步骤后我们会自动检测登录结果。';

  @override
  String get authSignInCta => '继续';

  @override
  String get authWaitingForApproval => '正在完成登录…';

  @override
  String get authCancel => '取消';

  @override
  String get authSignedInSuccess => '登录成功';

  @override
  String get authReloadSignInPage => '重新加载登录页';

  @override
  String get authOpenInSystemBrowser => '在系统浏览器中打开';

  @override
  String get authSignOut => '退出登录';

  @override
  String get profileTitle => '个人资料';

  @override
  String get profileFieldName => '姓名';

  @override
  String get profileFieldEmail => '邮箱';

  @override
  String get profileFieldGoal => '每日目标（分钟）';

  @override
  String get profileFieldLearningLanguage => '学习语言';

  @override
  String get profileFieldNativeLanguage => '母语';

  @override
  String get profileFieldRequired => '必填';

  @override
  String get profileSave => '保存';

  @override
  String get profileSaveSuccess => '资料已保存';

  @override
  String get profileSubscriptionFree => '免费';

  @override
  String get profileSubscriptionPro => '专业版';

  @override
  String profileBalance(String value) {
    return '余额：$value';
  }

  @override
  String get profileStatLibraryTitle => '资料库';

  @override
  String get profileStatLibrarySubtitle => '保存在本机的项目数';

  @override
  String get profileStatEchoTitle => '回声练习次数';

  @override
  String get profileStatEchoSubtitle => '本地记录的练习行数';

  @override
  String get profileStatRecordTitle => '已录音';

  @override
  String get profileStatRecordSubtitle => '跟读练习分钟数';

  @override
  String get settingsSectionAccount => '账号';

  @override
  String get settingsSectionAccountHint => '个人资料、订阅与退出登录';

  @override
  String get settingsSectionDataMigrationHint => '登录后迁移访客数据';

  @override
  String get settingsSectionSyncHint => '上传队列、离线状态与手动同步';

  @override
  String get settingsSectionAppearanceLanguageHint => '主题密度、字幕稿字体与区域设置';

  @override
  String get hotkeysSectionKeyboardHint => '查看并自定义快捷键';

  @override
  String get settingsSectionAdvancedHint => 'API 地址与实验性开关';

  @override
  String get settingsSectionDeveloperHint => '诊断与内部工具';

  @override
  String get settingsSectionAboutHint => '版本、许可与链接';

  @override
  String get settingsSectionSync => '云端同步';

  @override
  String get settingsSectionDataMigration => '本地数据';

  @override
  String get syncSettingsTileTitle => '同步状态';

  @override
  String get syncSettingsTileSubtitleSignedOut => '登录后可同步资料库与录音';

  @override
  String get syncSettingsTileSubtitleUpToDate => '已是最新';

  @override
  String syncSettingsTileSubtitleCounts(int retryable, int failed) {
    return '$retryable 项等待中 · $failed 项失败';
  }

  @override
  String get syncScreenTitle => '同步状态';

  @override
  String get syncScreenLastSyncLabel => '上次成功同步';

  @override
  String get syncScreenLastSyncNever => '从未';

  @override
  String get syncScreenStatRetryable => '等待上传';

  @override
  String get syncScreenStatFailed => '永久失败';

  @override
  String get syncScreenSyncNow => '立即同步';

  @override
  String get syncScreenRetryFailed => '重试失败项';

  @override
  String get syncScreenSignedOutBody => '使用 Enjoy 账号登录以在设备间同步元数据。';

  @override
  String get syncScreenGoSignIn => '登录';

  @override
  String get syncPendingRekeyLabel => '导入待关联账号';

  @override
  String get syncPendingRekeyHint => '这些项目在退出登录状态下添加。登录后将关联到你的账号并排队上传。';

  @override
  String get cloudScreenTitle => '云端';

  @override
  String get cloudTabAudio => '音频';

  @override
  String get cloudTabVideo => '视频';

  @override
  String get cloudSignedOutBody => '登录后可浏览保存到 Enjoy 账号的媒体。';

  @override
  String get cloudAddToLibrary => '添加到资料库';

  @override
  String get cloudAlreadyInLibrary => '已在资料库中';

  @override
  String get cloudAddedToLibrary => '已添加到本地资料库。';

  @override
  String get cloudEmpty => '此列表为空。';

  @override
  String get cloudHasMediaUrlHint => '打开时从已保存的 URL 流式播放。';

  @override
  String get cloudNoMediaUrlHint => '无远程文件 URL — 打开此项目时请在播放器中使用「定位文件」。';

  @override
  String get cloudRefreshTooltip => '刷新此标签页';

  @override
  String get cloudAddToLibraryTooltip => '添加到资料库';

  @override
  String get cloudEmptyAudioTitle => '暂无云端音频';

  @override
  String get cloudEmptyAudioSubtitle => '登录后保存的项目将显示在此处。';

  @override
  String get cloudEmptyVideoTitle => '暂无云端视频';

  @override
  String get cloudEmptyVideoSubtitle => '登录后保存的项目将显示在此处。';

  @override
  String get syncSnackSuccess => '同步已成功完成。';

  @override
  String syncSnackIssues(int synced, int failed) {
    return '同步结束：$synced 项成功，$failed 项失败。';
  }

  @override
  String get syncQueueDetails => '队列详情';

  @override
  String get syncQueueEmpty => '队列为空。';

  @override
  String get settingsSectionAdvanced => '高级';

  @override
  String get settingsApiBaseUrl => 'API 基础地址';

  @override
  String get settingsApiBaseUrlHint => '示例：https://enjoy.bot';

  @override
  String get settingsApiBaseUrlSave => '保存 API 地址';

  @override
  String get settingsAiApiBaseUrl => 'AI API 基础地址';

  @override
  String get settingsAiApiBaseUrlHint => '示例：https://worker.enjoy.bot';

  @override
  String get settingsAiApiBaseUrlSave => '保存 AI API 地址';

  @override
  String get settingsAccountSignedOut => '未登录';

  @override
  String get settingsAccountOpenProfile => '打开个人资料';

  @override
  String get settingsAccountSignIn => '登录';

  @override
  String get errorNetwork => '网络错误';

  @override
  String get errorUnauthorized => '会话已过期 — 请重新登录';

  @override
  String get communityActivity => '社区动态';

  @override
  String get communityToday => '今日社区';

  @override
  String get homeRecordingsToday => '录音';

  @override
  String get homePracticeTime => '练习时长';

  @override
  String get homeActiveLearners => '活跃学习者';

  @override
  String homePeopleLearning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 人正在学习',
      one: '$count 人正在学习',
    );
    return '$_temp0';
  }

  @override
  String get homeNoActiveUsers => '暂无活跃用户';

  @override
  String get homeTodaysGoal => '今日目标';

  @override
  String get homeMinutes => '分钟';

  @override
  String get homeCompleted => '已完成';

  @override
  String get homeGoalCompleted => '目标完成！太棒了！';

  @override
  String get homeGoalAlmostThere => '快完成了！继续加油！';

  @override
  String get homeGoalHalfway => '已经完成一半！你可以的！';

  @override
  String get homeGoalGoodStart => '不错的开始！坚持练习！';

  @override
  String get homeGoalJustStarted => '刚刚开始！每一分钟都很重要！';

  @override
  String get homeGoalStartNow => '现在开始练习吧！';

  @override
  String get mediaLocateTitle => '定位媒体文件';

  @override
  String get mediaLocateBody => '此项目是在其他设备上添加的。请在本机选择同一文件。我们会通过安全指纹校验是否与资料库匹配。';

  @override
  String get mediaLocateChooseFile => '选择文件';

  @override
  String get mediaLocateHashMismatch => '该文件与此项目不匹配。请确认选择了正确文件。';

  @override
  String mediaLocateExpectedSize(String sizeLabel) {
    return '预期大小：$sizeLabel';
  }

  @override
  String get mediaLocateSizeUnknown => '预期大小：未知';

  @override
  String get migrationBannerTitle => '迁移本地数据';

  @override
  String get migrationBannerBody => '检测到你本地保存了媒体与学习记录。是否迁移到你的账号？';

  @override
  String get migrationBannerActionMove => '迁移数据';

  @override
  String get migrationBannerActionDismiss => '暂不';

  @override
  String get settingsMigrationTitle => '迁移本地数据';

  @override
  String get settingsMigrationSubtitle => '将访客媒体与记录迁移到当前账号';

  @override
  String get migrationSuccess => '数据迁移成功';

  @override
  String get migrationMigrationFailed => '无法迁移数据，请稍后重试。';

  @override
  String get libraryDeleteMediaTitle => '从资料库删除？';

  @override
  String libraryDeleteMediaMessage(String title) {
    return '从本机移除「$title」。此操作无法撤销。';
  }

  @override
  String get libraryDeleteMediaTooltip => '从资料库删除';

  @override
  String get libraryMediaDeleted => '已从资料库移除。';

  @override
  String get libraryDeleteMediaFailed => '无法移除此项目。';

  @override
  String get settingsSectionDeveloper => '开发者';

  @override
  String get settingsAiPlaygroundTileTitle => 'AI 试验台';

  @override
  String get settingsAiPlaygroundTileSubtitle => '调用 ASR、聊天、翻译与词典 API';

  @override
  String get aiPlaygroundTitle => 'AI 试验台';

  @override
  String get aiPlaygroundIntro =>
      '使用已保存的基础地址与访问令牌调用 Enjoy API。Flutter 上尚未接入 TTS；登录后发音评测通过原生插件使用 Azure Speech。';

  @override
  String get aiPlaygroundPickAudio => '选择音频文件';

  @override
  String get aiPlaygroundTranscribe => '转写';

  @override
  String get aiPlaygroundChatSystem => '系统（可选）';

  @override
  String get aiPlaygroundChatUser => '用户消息';

  @override
  String get aiPlaygroundSendChat => '发送聊天';

  @override
  String get aiPlaygroundTranslateSource => '源语言';

  @override
  String get aiPlaygroundTranslateTarget => '目标语言';

  @override
  String get aiPlaygroundTranslateText => '待翻译文本';

  @override
  String get aiPlaygroundTranslate => '翻译';

  @override
  String get aiPlaygroundDictWord => '单词';

  @override
  String get aiPlaygroundDictSource => '源语言';

  @override
  String get aiPlaygroundDictTarget => '目标语言';

  @override
  String get aiPlaygroundDictLookup => '词典查询';

  @override
  String get aiPlaygroundAssessmentReference => '参考文本（你所说的内容）';

  @override
  String get aiPlaygroundAssessmentLanguage => '语言（如 en、en-US）';

  @override
  String get aiPlaygroundAssess => '运行发音评测';

  @override
  String get aiPlaygroundAssessmentTtsNote =>
      '本版本暂不提供 TTS（Azure Speech 集成进行中）。';

  @override
  String get aiPlaygroundOutput => '输出';

  @override
  String get aiPlaygroundClearOutput => '清空输出';

  @override
  String get aiPlaygroundSectionAsr => '语音识别';

  @override
  String get aiPlaygroundSectionChat => '聊天';

  @override
  String get aiPlaygroundSectionTranslation => '翻译';

  @override
  String get aiPlaygroundSectionDictionary => '词典';

  @override
  String get aiPlaygroundSectionTtsAssessment => 'TTS / 评测';

  @override
  String get youtubePasteFromClipboard => '粘贴';

  @override
  String get settingsSubtitle => '按你的学习方式调整 Enjoy。';

  @override
  String get settingsSectionAppearanceLanguage => '外观与语言';

  @override
  String get settingsAppearanceTheme => '主题';

  @override
  String get settingsAppearanceThemeValue => '深色 · 影院风';

  @override
  String get settingsAppearanceDisplayLanguage => '显示语言';

  @override
  String get settingsAppearanceLearningLanguage => '学习语言';

  @override
  String get settingsAppearanceNativeLanguage => '母语';

  @override
  String get settingsAppearanceSyncedFromProfile => '与账号个人资料同步';

  @override
  String get settingsKeyboardOpenCheatsheet => '打开快捷键速查';

  @override
  String get settingsKeyboardOpenCheatsheetSubtitle => '浏览并自定义所有快捷键';

  @override
  String hotkeysHelpSubtitle(String key) {
    return '随时按 $key 打开此列表。';
  }

  @override
  String get hotkeysHelpSearchHint => '搜索快捷键';

  @override
  String get hotkeysHelpEmpty => '无匹配的快捷键';

  @override
  String get hotkeysHelpCustomize => '在设置中自定义';

  @override
  String hotkeysSettingsSubtitle(String key) {
    return '点按一行即可修改。随时按 $key。';
  }

  @override
  String get hotkeysFilterHint => '筛选快捷键';

  @override
  String get hotkeysResetTooltip => '重置此快捷键';

  @override
  String get hotkeysEditTooltip => '更改快捷键';

  @override
  String get settingsAboutMadeWithCare => '为语言学习者用心打造。';
}

/// The translations for Chinese, as used in China (`zh_CN`).
class AppLocalizationsZhCn extends AppLocalizationsZh {
  AppLocalizationsZhCn() : super('zh_CN');

  @override
  String get appTitle => 'Enjoy 播放器';

  @override
  String get libraryTitle => '资料库';

  @override
  String get homeTitle => '首页';

  @override
  String get homeRecentMedia => '最近媒体';

  @override
  String get homeEmptyTitle => '暂无最近媒体';

  @override
  String get homeEmptyHint => '导入媒体或将文件拖放到此处开始。';

  @override
  String get libraryTabAudio => '音频';

  @override
  String get libraryTabVideo => '视频';

  @override
  String get libraryEmptyAudioTitle => '未找到任何音频';

  @override
  String get libraryEmptyAudioHint => '你的资料库中没有任何音频内容。';

  @override
  String get libraryEmptyVideoTitle => '未找到任何视频';

  @override
  String get libraryEmptyVideoHint => '你的资料库中没有任何视频内容。';

  @override
  String get actionOpenFiles => '打开文件';

  @override
  String get actionImport => '导入';

  @override
  String get importFromFile => '从文件…';

  @override
  String get importFromYoutube => '从 YouTube 链接…';

  @override
  String get youtubeImportTitle => '导入 YouTube 视频';

  @override
  String get youtubeImportHint => '粘贴 YouTube 链接或视频 ID';

  @override
  String get youtubeImportInvalid => '无法识别有效的 YouTube 视频 ID。';

  @override
  String get youtubeImporting => '正在添加视频…';

  @override
  String get youtubeBadge => 'YouTube';

  @override
  String get youtubeLoginTooltip => 'YouTube 账号';

  @override
  String get youtubeLoginClose => '关闭';

  @override
  String get youtubeLoginScreenTitle => 'YouTube 登录';

  @override
  String get youtubeLogout => '退出登录（清除 Cookie）';

  @override
  String get searchHint => '搜索';

  @override
  String get transportRepeat => '循环';

  @override
  String get transportFullscreen => '全屏';

  @override
  String get transportExitFullscreen => '退出全屏';

  @override
  String get transportMore => '更多';

  @override
  String get transportCollapse => '收起播放器';

  @override
  String get transportExpand => '展开播放器';

  @override
  String get settingsTitle => '设置';

  @override
  String get importMedia => '导入媒体';

  @override
  String get importingMedia => '正在导入媒体…';

  @override
  String get importMediaFailed => '无法导入此文件。';

  @override
  String get noMediaYet => '暂无媒体';

  @override
  String get tapImportToAdd => '从工具栏导入音频或视频。';

  @override
  String get navMainLabel => '主导航';

  @override
  String get miniPlayerMediaVideo => '视频';

  @override
  String get miniPlayerMediaAudio => '音频';

  @override
  String get retry => '重试';

  @override
  String get settingsSectionAppearance => '外观';

  @override
  String get settingsAppearanceSubtitle => '主题跟随系统设置。';

  @override
  String get settingsSectionAbout => '关于';

  @override
  String get settingsAboutSubtitle => 'Enjoy 播放器 — 本地字幕与跟读练习。';

  @override
  String get settingsThemeRowTitle => '主题';

  @override
  String get settingsThemeDarkLocked => '跟随系统外观。';

  @override
  String get settingsThemeSystem => '系统';

  @override
  String get settingsThemeLight => '浅色';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get play => '播放';

  @override
  String get pause => '暂停';

  @override
  String get previousLine => '上一句';

  @override
  String get nextLine => '下一句';

  @override
  String get replayLine => '重播本句';

  @override
  String get echoMode => '回声模式';

  @override
  String get exitEchoMode => '退出回声模式';

  @override
  String get transcript => '字幕稿';

  @override
  String get transcriptNowReading => '正在朗读';

  @override
  String get playerTranscriptResizeHint => '拖动以调整字幕稿面板大小';

  @override
  String get importSubtitle => '导入字幕';

  @override
  String get noTranscript => '无字幕稿';

  @override
  String get importSrtOrVtt => '导入 .srt 或 .vtt 文件。';

  @override
  String get miniPlayerOpen => '打开播放器';

  @override
  String get loading => '加载中…';

  @override
  String get error => '错误';

  @override
  String get playerOpenGenericError => '无法打开此项目。';

  @override
  String playbackRateTimes(String rate) {
    return '$rate 倍';
  }

  @override
  String get speed => '速度';

  @override
  String get volume => '音量';

  @override
  String get transportMute => '静音';

  @override
  String get transportUnmute => '取消静音';

  @override
  String get repeatNone => '关闭循环';

  @override
  String get repeatSegment => '循环片段';

  @override
  String get settingsPlaceholder => '播放器偏好将显示在此处。';

  @override
  String get subtitles => '字幕';

  @override
  String get subtitlesPrimary => '主字幕';

  @override
  String get subtitlesTranslation => '翻译（可选）';

  @override
  String get subtitlesNone => '无';

  @override
  String get subtitlesImportFile => '导入字幕文件…';

  @override
  String get subtitlesDeleteTrack => '删除轨道';

  @override
  String get importSubtitleSuccess => '字幕已导入';

  @override
  String get noTranscriptHint =>
      '打开媒体时云端字幕会在后台加载（每项在刷新前仅一次）。本地视频请使用提取或添加字幕（.srt/.vtt）。';

  @override
  String get transcriptEmptyExtract => '提取';

  @override
  String get transcriptEmptyAddSubtitle => '添加字幕';

  @override
  String get subtitlesExtractEmbedded => '提取内嵌字幕';

  @override
  String get subtitlesRefreshCloud => '从云端刷新字幕稿';

  @override
  String get subtitlesImportLanguageTitle => '字幕语言';

  @override
  String get subtitlesImportLanguageHint => 'BCP-47 代码（如 en、zh-TW）。未知请填 und。';

  @override
  String get subtitlesProviderOfficial => '官方';

  @override
  String get subtitlesProviderAuto => '自动';

  @override
  String get subtitlesProviderAi => 'AI';

  @override
  String get subtitlesProviderUser => '用户';

  @override
  String get subtitlesExtractNoTracks =>
      '此文件中无内嵌字幕轨道（仅有视频与音频）。若有单独的 .srt 或 .vtt，请使用导入文件。';

  @override
  String subtitlesExtractedCount(int count) {
    return '已提取 $count 条字幕轨道。';
  }

  @override
  String get subtitlesRefreshDone => '已从云端更新字幕稿。';

  @override
  String get subtitlesNoPlayableUri => '无法解析此项目的可播放文件。';

  @override
  String get expandEchoBackward => '向后扩展回声';

  @override
  String get expandEchoForward => '向前扩展回声';

  @override
  String get shrinkEchoBackward => '向后收缩回声';

  @override
  String get shrinkEchoForward => '向前收缩回声';

  @override
  String get shadowReadingTitle => '跟读';

  @override
  String get shadowReadingHint => '跟读本段并练习口语。录制你的声音并与参考音高对比。';

  @override
  String get shadowReadingReferenceSnippet => '参考';

  @override
  String get pitchContourTitle => '音高曲线';

  @override
  String get pitchContourError => '无法分析本段的音高。';

  @override
  String get pitchContourWaveform => '波形';

  @override
  String get pitchContourReference => '参考音高';

  @override
  String get pitchContourUser => '你的音高';

  @override
  String get pitchContourAnalyzing => '正在分析音高…';

  @override
  String get shadowRecordingExisting => '已保存的录音';

  @override
  String get shadowRecordingEmpty => '本段尚无录音。';

  @override
  String get shadowRecordingTake => '录音';

  @override
  String get shadowRecordingPlay => '播放';

  @override
  String get shadowRecordingPause => '暂停';

  @override
  String get shadowRecordingChooseTake => '切换录音';

  @override
  String get shadowRecordingDelete => '删除';

  @override
  String get shadowRecordingDeleteConfirmTitle => '删除此条录音？';

  @override
  String shadowRecordingDeleteConfirmMessage(String takeLabel) {
    return '将永久删除 $takeLabel，无法撤销。';
  }

  @override
  String get shadowRecordingRecord => '录音';

  @override
  String get shadowRecordingStop => '停止';

  @override
  String get shadowRecordingMicDenied => '需要麦克风权限才能录音。';

  @override
  String shadowRecordingSaveFailed(String reason) {
    return '无法保存录音：$reason';
  }

  @override
  String get settingsSectionRecording => '录音';

  @override
  String get settingsSectionRecordingHint => '跟读录音所使用的麦克风。';

  @override
  String get settingsRecordingMicTitle => '麦克风';

  @override
  String settingsRecordingMicAuto(String label) {
    return '自动 · $label';
  }

  @override
  String get settingsRecordingMicAutoNoDevice => '自动 · 系统默认';

  @override
  String get settingsRecordingMicEmpty => '未检测到麦克风';

  @override
  String get settingsRecordingMicAutoOption => '自动（跳过虚拟麦克风）';

  @override
  String get settingsRecordingMicDialogTitle => '选择麦克风';

  @override
  String get shadowRecordingSilentWarning => '未检测到麦克风信号。请打开「设置 → 录音」选择其他麦克风。';

  @override
  String get shadowRecordingPlaybackFailed => '无法播放此条录音。';

  @override
  String shadowRecordingOverTarget(String seconds) {
    return '超出目标 +$seconds 秒';
  }

  @override
  String get hotkeysTitle => '键盘快捷键';

  @override
  String get hotkeysHintFooter => '按 Shift+/（?）打开此列表。';

  @override
  String get hotkeysCustomizedBadge => '已自定义';

  @override
  String get hotkeysSectionKeyboard => '键盘快捷键';

  @override
  String get hotkeysResetBinding => '重置';

  @override
  String get hotkeysResetAll => '重置全部快捷键';

  @override
  String get hotkeysCaptureTitle => '按下新快捷键';

  @override
  String get hotkeysCaptureHint => '按下组合键。Esc 取消。';

  @override
  String get hotkeysConflictError => '该快捷键已被使用。';

  @override
  String get hotkeysScopeGlobal => '全局';

  @override
  String get hotkeysScopePlayer => '播放器';

  @override
  String get hotkeysScopeLibrary => '资料库';

  @override
  String get hotkeysScopeModal => '弹窗';

  @override
  String get hotkeysDescHelp => '显示键盘快捷键';

  @override
  String get hotkeysDescSearch => '打开搜索';

  @override
  String get hotkeysDescSettings => '打开设置';

  @override
  String get hotkeysDescTogglePlay => '播放 / 暂停';

  @override
  String get hotkeysDescToggleExpand => '切换播放器展开/收起';

  @override
  String get hotkeysDescToggleFullscreen => '切换全屏';

  @override
  String get hotkeysDescPrevLine => '播放上一句';

  @override
  String get hotkeysDescNextLine => '播放下一句';

  @override
  String get hotkeysDescReplayLine => '重播当前句';

  @override
  String get hotkeysDescToggleEchoMode => '切换回声模式';

  @override
  String get hotkeysDescToggleDictationMode => '切换听写模式';

  @override
  String get hotkeysDescToggleRecording => '开始/停止录音';

  @override
  String get hotkeysDescToggleAssessment => '显示/隐藏发音评测';

  @override
  String get hotkeysDescTogglePitchContour => '显示/隐藏音高曲线';

  @override
  String get hotkeysDescPlayRecording => '播放/暂停录音';

  @override
  String get hotkeysDescSlowDown => '减慢播放速度';

  @override
  String get hotkeysDescSpeedUp => '加快播放速度';

  @override
  String get hotkeysDescExpandEchoBackward => '向后扩展回声区域';

  @override
  String get hotkeysDescExpandEchoForward => '向前扩展回声区域';

  @override
  String get hotkeysDescShrinkEchoBackward => '向后收缩回声区域';

  @override
  String get hotkeysDescShrinkEchoForward => '向前收缩回声区域';

  @override
  String get hotkeysDescLibrarySearch => '聚焦搜索框';

  @override
  String get hotkeysDescCloseModal => '关闭弹窗';

  @override
  String get hotkeysStubSearch => '搜索功能尚未提供。';

  @override
  String get hotkeysStubDictation => '听写模式尚未提供。';

  @override
  String get assessmentTitle => '发音评测';

  @override
  String get assessmentDescription => '为你的朗读提供详细评分。';

  @override
  String get assessmentRun => '运行发音评测';

  @override
  String get assessmentView => '查看发音评测';

  @override
  String get assessmentReassess => '重新评测';

  @override
  String get assessmentOverallScore => '总分';

  @override
  String get assessmentAccuracy => '准确度';

  @override
  String get assessmentCompleteness => '完整度';

  @override
  String get assessmentFluency => '流利度';

  @override
  String get assessmentProsody => '韵律';

  @override
  String get assessmentPronunciationAnalysis => '发音分析';

  @override
  String get assessmentAccuracyScore => '准确度分数';

  @override
  String get assessmentSyllables => '音节';

  @override
  String get assessmentPhonemes => '音素';

  @override
  String get assessmentNoRecording => '录音文件缺失或为空。';

  @override
  String assessmentRunFailed(String reason) {
    return '无法运行评测：$reason';
  }

  @override
  String get assessmentErrorTypeOmission => '遗漏';

  @override
  String get assessmentErrorTypeInsertion => '插入';

  @override
  String get assessmentErrorTypeMispronunciation => '发音错误';

  @override
  String get assessmentErrorTypeUnexpectedBreak => '意外停顿';

  @override
  String get assessmentErrorTypeMissingBreak => '缺少停顿';

  @override
  String get assessmentErrorTypeMonotone => '单调';

  @override
  String get assessmentErrorTypeCorrect => '正确';

  @override
  String get assessmentErrorExplOmission => '预期应有此词但未检测到。';

  @override
  String get assessmentErrorExplInsertion => '检测到参考中不存在的额外词语。';

  @override
  String get assessmentErrorExplMispronunciation => '此词发音可能不正确。';

  @override
  String get assessmentErrorExplUnexpectedBreak => '在此词前检测到意外停顿。';

  @override
  String get assessmentErrorExplMissingBreak => '在此词前未检测到应有的停顿。';

  @override
  String get assessmentErrorExplMonotone => '音高变化低于预期。';

  @override
  String get assessmentErrorExplCorrect => '此词未发现问题。';

  @override
  String get assessmentWebUnsupported => 'Web 上暂不支持发音评测。';

  @override
  String get assessmentEmptyReference => '参考文本为空。';

  @override
  String get assessmentInvalidStored => '无法读取已保存的评测数据。';

  @override
  String get authSignInTitle => '登录 Enjoy';

  @override
  String get authSignInSubtitle => '应用内将打开安全登录页。完成步骤后我们会自动检测登录结果。';

  @override
  String get authSignInCta => '继续';

  @override
  String get authWaitingForApproval => '正在完成登录…';

  @override
  String get authCancel => '取消';

  @override
  String get authSignedInSuccess => '登录成功';

  @override
  String get authReloadSignInPage => '重新加载登录页';

  @override
  String get authOpenInSystemBrowser => '在系统浏览器中打开';

  @override
  String get authSignOut => '退出登录';

  @override
  String get profileTitle => '个人资料';

  @override
  String get profileFieldName => '姓名';

  @override
  String get profileFieldEmail => '邮箱';

  @override
  String get profileFieldGoal => '每日目标（分钟）';

  @override
  String get profileFieldLearningLanguage => '学习语言';

  @override
  String get profileFieldNativeLanguage => '母语';

  @override
  String get profileFieldRequired => '必填';

  @override
  String get profileSave => '保存';

  @override
  String get profileSaveSuccess => '资料已保存';

  @override
  String get profileSubscriptionFree => '免费';

  @override
  String get profileSubscriptionPro => '专业版';

  @override
  String profileBalance(String value) {
    return '余额：$value';
  }

  @override
  String get profileStatLibraryTitle => '资料库';

  @override
  String get profileStatLibrarySubtitle => '保存在本机的项目数';

  @override
  String get profileStatEchoTitle => '回声练习次数';

  @override
  String get profileStatEchoSubtitle => '本地记录的练习行数';

  @override
  String get profileStatRecordTitle => '已录音';

  @override
  String get profileStatRecordSubtitle => '跟读练习分钟数';

  @override
  String get settingsSectionAccount => '账号';

  @override
  String get settingsSectionAccountHint => '个人资料、订阅与退出登录';

  @override
  String get settingsSectionDataMigrationHint => '登录后迁移访客数据';

  @override
  String get settingsSectionSyncHint => '上传队列、离线状态与手动同步';

  @override
  String get settingsSectionAppearanceLanguageHint => '主题密度、字幕稿字体与区域设置';

  @override
  String get hotkeysSectionKeyboardHint => '查看并自定义快捷键';

  @override
  String get settingsSectionAdvancedHint => 'API 地址与实验性开关';

  @override
  String get settingsSectionDeveloperHint => '诊断与内部工具';

  @override
  String get settingsSectionAboutHint => '版本、许可与链接';

  @override
  String get settingsSectionSync => '云端同步';

  @override
  String get settingsSectionDataMigration => '本地数据';

  @override
  String get syncSettingsTileTitle => '同步状态';

  @override
  String get syncSettingsTileSubtitleSignedOut => '登录后可同步资料库与录音';

  @override
  String get syncSettingsTileSubtitleUpToDate => '已是最新';

  @override
  String syncSettingsTileSubtitleCounts(int retryable, int failed) {
    return '$retryable 项等待中 · $failed 项失败';
  }

  @override
  String get syncScreenTitle => '同步状态';

  @override
  String get syncScreenLastSyncLabel => '上次成功同步';

  @override
  String get syncScreenLastSyncNever => '从未';

  @override
  String get syncScreenStatRetryable => '等待上传';

  @override
  String get syncScreenStatFailed => '永久失败';

  @override
  String get syncScreenSyncNow => '立即同步';

  @override
  String get syncScreenRetryFailed => '重试失败项';

  @override
  String get syncScreenSignedOutBody => '使用 Enjoy 账号登录以在设备间同步元数据。';

  @override
  String get syncScreenGoSignIn => '登录';

  @override
  String get syncPendingRekeyLabel => '导入待关联账号';

  @override
  String get syncPendingRekeyHint => '这些项目在退出登录状态下添加。登录后将关联到你的账号并排队上传。';

  @override
  String get cloudScreenTitle => '云端';

  @override
  String get cloudTabAudio => '音频';

  @override
  String get cloudTabVideo => '视频';

  @override
  String get cloudSignedOutBody => '登录后可浏览保存到 Enjoy 账号的媒体。';

  @override
  String get cloudAddToLibrary => '添加到资料库';

  @override
  String get cloudAlreadyInLibrary => '已在资料库中';

  @override
  String get cloudAddedToLibrary => '已添加到本地资料库。';

  @override
  String get cloudEmpty => '此列表为空。';

  @override
  String get cloudHasMediaUrlHint => '打开时从已保存的 URL 流式播放。';

  @override
  String get cloudNoMediaUrlHint => '无远程文件 URL — 打开此项目时请在播放器中使用「定位文件」。';

  @override
  String get cloudRefreshTooltip => '刷新此标签页';

  @override
  String get cloudAddToLibraryTooltip => '添加到资料库';

  @override
  String get cloudEmptyAudioTitle => '暂无云端音频';

  @override
  String get cloudEmptyAudioSubtitle => '登录后保存的项目将显示在此处。';

  @override
  String get cloudEmptyVideoTitle => '暂无云端视频';

  @override
  String get cloudEmptyVideoSubtitle => '登录后保存的项目将显示在此处。';

  @override
  String get syncSnackSuccess => '同步已成功完成。';

  @override
  String syncSnackIssues(int synced, int failed) {
    return '同步结束：$synced 项成功，$failed 项失败。';
  }

  @override
  String get syncQueueDetails => '队列详情';

  @override
  String get syncQueueEmpty => '队列为空。';

  @override
  String get settingsSectionAdvanced => '高级';

  @override
  String get settingsApiBaseUrl => 'API 基础地址';

  @override
  String get settingsApiBaseUrlHint => '示例：https://enjoy.bot';

  @override
  String get settingsApiBaseUrlSave => '保存 API 地址';

  @override
  String get settingsAiApiBaseUrl => 'AI API 基础地址';

  @override
  String get settingsAiApiBaseUrlHint => '示例：https://worker.enjoy.bot';

  @override
  String get settingsAiApiBaseUrlSave => '保存 AI API 地址';

  @override
  String get settingsAccountSignedOut => '未登录';

  @override
  String get settingsAccountOpenProfile => '打开个人资料';

  @override
  String get settingsAccountSignIn => '登录';

  @override
  String get errorNetwork => '网络错误';

  @override
  String get errorUnauthorized => '会话已过期 — 请重新登录';

  @override
  String get communityActivity => '社区动态';

  @override
  String get communityToday => '今日社区';

  @override
  String get homeRecordingsToday => '录音';

  @override
  String get homePracticeTime => '练习时长';

  @override
  String get homeActiveLearners => '活跃学习者';

  @override
  String homePeopleLearning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 人正在学习',
      one: '$count 人正在学习',
    );
    return '$_temp0';
  }

  @override
  String get homeNoActiveUsers => '暂无活跃用户';

  @override
  String get homeTodaysGoal => '今日目标';

  @override
  String get homeMinutes => '分钟';

  @override
  String get homeCompleted => '已完成';

  @override
  String get homeGoalCompleted => '目标完成！太棒了！';

  @override
  String get homeGoalAlmostThere => '快完成了！继续加油！';

  @override
  String get homeGoalHalfway => '已经完成一半！你可以的！';

  @override
  String get homeGoalGoodStart => '不错的开始！坚持练习！';

  @override
  String get homeGoalJustStarted => '刚刚开始！每一分钟都很重要！';

  @override
  String get homeGoalStartNow => '现在开始练习吧！';

  @override
  String get mediaLocateTitle => '定位媒体文件';

  @override
  String get mediaLocateBody => '此项目是在其他设备上添加的。请在本机选择同一文件。我们会通过安全指纹校验是否与资料库匹配。';

  @override
  String get mediaLocateChooseFile => '选择文件';

  @override
  String get mediaLocateHashMismatch => '该文件与此项目不匹配。请确认选择了正确文件。';

  @override
  String mediaLocateExpectedSize(String sizeLabel) {
    return '预期大小：$sizeLabel';
  }

  @override
  String get mediaLocateSizeUnknown => '预期大小：未知';

  @override
  String get migrationBannerTitle => '迁移本地数据';

  @override
  String get migrationBannerBody => '检测到你本地保存了媒体与学习记录。是否迁移到你的账号？';

  @override
  String get migrationBannerActionMove => '迁移数据';

  @override
  String get migrationBannerActionDismiss => '暂不';

  @override
  String get settingsMigrationTitle => '迁移本地数据';

  @override
  String get settingsMigrationSubtitle => '将访客媒体与记录迁移到当前账号';

  @override
  String get migrationSuccess => '数据迁移成功';

  @override
  String get migrationMigrationFailed => '无法迁移数据，请稍后重试。';

  @override
  String get libraryDeleteMediaTitle => '从资料库删除？';

  @override
  String libraryDeleteMediaMessage(String title) {
    return '从本机移除「$title」。此操作无法撤销。';
  }

  @override
  String get libraryDeleteMediaTooltip => '从资料库删除';

  @override
  String get libraryMediaDeleted => '已从资料库移除。';

  @override
  String get libraryDeleteMediaFailed => '无法移除此项目。';

  @override
  String get settingsSectionDeveloper => '开发者';

  @override
  String get settingsAiPlaygroundTileTitle => 'AI 试验台';

  @override
  String get settingsAiPlaygroundTileSubtitle => '调用 ASR、聊天、翻译与词典 API';

  @override
  String get aiPlaygroundTitle => 'AI 试验台';

  @override
  String get aiPlaygroundIntro =>
      '使用已保存的基础地址与访问令牌调用 Enjoy API。Flutter 上尚未接入 TTS；登录后发音评测通过原生插件使用 Azure Speech。';

  @override
  String get aiPlaygroundPickAudio => '选择音频文件';

  @override
  String get aiPlaygroundTranscribe => '转写';

  @override
  String get aiPlaygroundChatSystem => '系统（可选）';

  @override
  String get aiPlaygroundChatUser => '用户消息';

  @override
  String get aiPlaygroundSendChat => '发送聊天';

  @override
  String get aiPlaygroundTranslateSource => '源语言';

  @override
  String get aiPlaygroundTranslateTarget => '目标语言';

  @override
  String get aiPlaygroundTranslateText => '待翻译文本';

  @override
  String get aiPlaygroundTranslate => '翻译';

  @override
  String get aiPlaygroundDictWord => '单词';

  @override
  String get aiPlaygroundDictSource => '源语言';

  @override
  String get aiPlaygroundDictTarget => '目标语言';

  @override
  String get aiPlaygroundDictLookup => '词典查询';

  @override
  String get aiPlaygroundAssessmentReference => '参考文本（你所说的内容）';

  @override
  String get aiPlaygroundAssessmentLanguage => '语言（如 en、en-US）';

  @override
  String get aiPlaygroundAssess => '运行发音评测';

  @override
  String get aiPlaygroundAssessmentTtsNote =>
      '本版本暂不提供 TTS（Azure Speech 集成进行中）。';

  @override
  String get aiPlaygroundOutput => '输出';

  @override
  String get aiPlaygroundClearOutput => '清空输出';

  @override
  String get aiPlaygroundSectionAsr => '语音识别';

  @override
  String get aiPlaygroundSectionChat => '聊天';

  @override
  String get aiPlaygroundSectionTranslation => '翻译';

  @override
  String get aiPlaygroundSectionDictionary => '词典';

  @override
  String get aiPlaygroundSectionTtsAssessment => 'TTS / 评测';

  @override
  String get youtubePasteFromClipboard => '粘贴';

  @override
  String get settingsSubtitle => '按你的学习方式调整 Enjoy。';

  @override
  String get settingsSectionAppearanceLanguage => '外观与语言';

  @override
  String get settingsAppearanceTheme => '主题';

  @override
  String get settingsAppearanceThemeValue => '深色 · 影院风';

  @override
  String get settingsAppearanceDisplayLanguage => '显示语言';

  @override
  String get settingsAppearanceLearningLanguage => '学习语言';

  @override
  String get settingsAppearanceNativeLanguage => '母语';

  @override
  String get settingsAppearanceSyncedFromProfile => '与账号个人资料同步';

  @override
  String get settingsKeyboardOpenCheatsheet => '打开快捷键速查';

  @override
  String get settingsKeyboardOpenCheatsheetSubtitle => '浏览并自定义所有快捷键';

  @override
  String hotkeysHelpSubtitle(String key) {
    return '随时按 $key 打开此列表。';
  }

  @override
  String get hotkeysHelpSearchHint => '搜索快捷键';

  @override
  String get hotkeysHelpEmpty => '无匹配的快捷键';

  @override
  String get hotkeysHelpCustomize => '在设置中自定义';

  @override
  String hotkeysSettingsSubtitle(String key) {
    return '点按一行即可修改。随时按 $key。';
  }

  @override
  String get hotkeysFilterHint => '筛选快捷键';

  @override
  String get hotkeysResetTooltip => '重置此快捷键';

  @override
  String get hotkeysEditTooltip => '更改快捷键';

  @override
  String get settingsAboutMadeWithCare => '为语言学习者用心打造。';
}
