import 'package:chaos_wheel_party_game/models/prompt_models.dart';

class PromptRepository {
  PromptRepository() : _prompts = _buildPrompts();

  final List<ContentPrompt> _prompts;

  List<ContentPrompt> get allPrompts => List.unmodifiable(_prompts);

  List<ContentPrompt> find({
    required PromptType type,
    required PromptVibeMode mode,
    required int playerCount,
    required bool premiumUnlocked,
  }) {
    return _prompts
        .where((prompt) {
          return prompt.type == type &&
              prompt.mode == mode &&
              prompt.minPlayers <= playerCount &&
              (!prompt.isPremium || premiumUnlocked);
        })
        .toList(growable: false);
  }
}

List<ContentPrompt> _buildPrompts() {
  final prompts = <ContentPrompt>[];

  void addSet({
    required PromptVibeMode mode,
    required PromptType type,
    required List<String> texts,
    required List<String> tags,
    required bool isPremium,
  }) {
    for (var index = 0; index < texts.length; index++) {
      prompts.add(
        ContentPrompt(
          id: '${type.name}_${mode.name}_${(index + 1).toString().padLeft(3, '0')}',
          type: type,
          mode: mode,
          level: mode == PromptVibeMode.evil
              ? 3
              : index < 16
              ? 1
              : index < 34
              ? 2
              : 3,
          text: texts[index],
          tags: tags,
          minPlayers: index % 5 == 0 ? 4 : 3,
          isPremium: isPremium,
          intensityLabel: _intensityLabelFor(mode, index),
          requiresDrinkingAllowed: _requiresDrinkingAllowed(texts[index]),
          requiresExtremeAllowed:
              mode == PromptVibeMode.evil ||
              (mode == PromptVibeMode.unhinged && index >= 34),
        ),
      );
    }
  }

  addSet(
    mode: PromptVibeMode.cozy,
    type: PromptType.truth,
    tags: const ['safe', 'funny', 'friends'],
    isPremium: false,
    texts: _cozyTruth,
  );
  addSet(
    mode: PromptVibeMode.cozy,
    type: PromptType.dare,
    tags: const ['safe', 'silly', 'warmup'],
    isPremium: false,
    texts: _cozyDare,
  );
  addSet(
    mode: PromptVibeMode.spicy,
    type: PromptType.truth,
    tags: const ['flirty', 'social', 'awkward'],
    isPremium: false,
    texts: _spicyTruth,
  );
  addSet(
    mode: PromptVibeMode.spicy,
    type: PromptType.dare,
    tags: const ['party', 'risky', 'social'],
    isPremium: false,
    texts: _spicyDare,
  );
  addSet(
    mode: PromptVibeMode.unhinged,
    type: PromptType.truth,
    tags: const ['chaos', 'late-night', 'exposing'],
    isPremium: false,
    texts: _unhingedTruth,
  );
  addSet(
    mode: PromptVibeMode.unhinged,
    type: PromptType.dare,
    tags: const ['chaos', 'embarrassing', 'loud'],
    isPremium: false,
    texts: _unhingedDare,
  );
  addSet(
    mode: PromptVibeMode.evil,
    type: PromptType.truth,
    tags: const ['premium', 'cursed', 'social'],
    isPremium: true,
    texts: _evilTruth,
  );
  addSet(
    mode: PromptVibeMode.evil,
    type: PromptType.dare,
    tags: const ['premium', 'cursed', 'chaos'],
    isPremium: true,
    texts: _evilDare,
  );

  return prompts;
}

String _intensityLabelFor(PromptVibeMode mode, int index) {
  if (mode == PromptVibeMode.evil) {
    return 'HIGH TENSION';
  }
  if (index >= 34) {
    return mode == PromptVibeMode.cozy ? 'RISKY' : 'CHAOTIC';
  }
  if (index >= 16) {
    return mode == PromptVibeMode.cozy ? 'SAFE' : 'RISKY';
  }
  return mode == PromptVibeMode.cozy ? 'SAFE' : 'HIGH TENSION';
}

bool _requiresDrinkingAllowed(String text) {
  final lower = text.toLowerCase();
  return lower.contains('shot') ||
      lower.contains('drink') ||
      lower.contains('drinking') ||
      lower.contains('alcohol');
}

// ─── COZY TRUTH (50) ──────────────────────────────────────────────────────────
const _cozyTruth = [
  'What is your most embarrassing moment from this year?',
  'Who here do you think would survive a zombie apocalypse?',
  'What is the most embarrassing text you have accidentally sent to the wrong person?',
  'Who here do you think would make the best parent?',
  'What is the worst haircut or style phase you went through?',
  'Who here do you think is secretly the most competitive?',
  'What is the most embarrassing thing your parents have ever caught you doing?',
  'Who here do you think gives the best hugs?',
  'What is one habit you have that you hope nobody has noticed?',
  'Who here would you want on your side in an argument?',
  'What is the funniest thing that has happened to you this year?',
  'Who here do you think would plan the best party?',
  'What is your most embarrassing childhood memory?',
  'Who here do you trust the most with a secret?',
  'What is the silliest reason you have cried at a movie or show?',
  'Who here would make the best travel companion?',
  'What is a lie you told your parents that actually worked?',
  'Who here do you think is secretly the funniest person in the room?',
  'What is the most embarrassing thing you have ever posted and then deleted?',
  'Who here do you think looks the most trustworthy but is actually chaotic?',
  'What is the worst excuse you have used to cancel plans?',
  'Who here would you call if you needed help hiding something embarrassing?',
  'What is your most embarrassing autocorrect failure?',
  'Who here do you think would be the calmest person in a crisis?',
  'What is a food opinion you would actually defend in public?',
  'Who here do you think has changed the most since you first met them?',
  'What is the most ridiculous reason you have been late somewhere?',
  'Who here would you trust to choose your outfit for an important event?',
  'What is the funniest thing you believed as a child that turned out to be wrong?',
  'Who here do you think has the most interesting past?',
  'What is the most childish thing you still secretly do?',
  'Who here would you most want to be stranded with on a deserted island?',
  'What is a compliment you received that you still think about?',
  'Who here do you think would make the best roommate?',
  'What is the worst rumor that has ever been spread about you?',
  'Who here do you think would accidentally go viral for something embarrassing?',
  'What is your most embarrassing moment in front of someone you were trying to impress?',
  'Who here do you think is the most genuinely kind person in the room?',
  'What is something you pretend to understand but actually have no idea about?',
  'Who here would you want giving a speech at your wedding?',
  'What is the most ridiculous thing you have done out of boredom?',
  'Who here do you think would be the most fun at 3 AM?',
  'What is the most embarrassing search in your browser history?',
  'Who here do you think would be the best in a high-pressure situation?',
  'What is the most awkward greeting situation you have been in?',
  'Who here do you think has the best life advice?',
  'What is your most embarrassing cooking disaster?',
  'Who here do you think would be the last person you expected to be best friends with?',
  'What is one thing you would be genuinely embarrassed if the group found out?',
  'Who here do you think would survive longest without social media?',
];

// ─── COZY DARE (50) ──────────────────────────────────────────────────────────
const _cozyDare = [
  'Compliment every single person in this room with one genuine thing.',
  'Show the last photo in your camera roll that you are comfortable sharing.',
  'Do your best impression of someone in this room without saying their name.',
  'Give the person on your left a genuine compliment about their appearance.',
  'Call someone not in the room and tell them they are your favorite person right now.',
  'Let the group choose a new nickname for you for the rest of the game.',
  'Show everyone your most recent Google search.',
  'Let someone in this room read your last three messages on your lock screen.',
  'Speak in an accent chosen by the group for the next two rounds.',
  'Do your best impression of a teacher or boss you have had.',
  'Share the most embarrassing photo of yourself that is more than three years old.',
  'Tell the most embarrassing story from your school years in under sixty seconds.',
  'Do your best runway walk across the room while everyone watches silently.',
  'Describe your dream partner without using any physical traits.',
  'Show your most used app and let the group judge for thirty seconds.',
  'Describe the last person you had a crush on using only three adjectives.',
  'Tell everyone in the room one thing you genuinely admire about them.',
  'Let the group guess your most embarrassing secret and react without denying anything.',
  'Call your mom or dad and tell them you miss them right now.',
  'Show the oldest photo saved on your phone.',
  'Let someone in this room rename one of your contacts.',
  'Do your most convincing impression of a news anchor reading a dramatic headline.',
  'Let someone read your most recent voice note out loud to the group.',
  'Read the last message you sent out loud without hiding the name.',
  'Let the group pick someone you must take a selfie with right now.',
  'Send a voice note to your best friend saying "we need to talk seriously" and then immediately send another saying it was a game.',
  'Give a sixty-second speech about why you are the group most valuable player.',
  'Let the group decide who you must swap phones with for thirty seconds.',
  'Sing the chorus of the last song you were embarrassed to be caught listening to.',
  'Tell the group the most embarrassing lie you have ever told and how it ended.',
  'Show the most recent screenshot on your phone if it is safe.',
  'Act out how you would react if you ran into your ex completely unexpectedly.',
  'Let someone in the room change your ringtone for the next hour.',
  'Do your best impression of someone famous using only body language.',
  'Let the group choose one person in this room you must say something honest to.',
  'Show the last five photos in your gallery without skipping any.',
  'Let someone scroll through your Spotify or music listening history.',
  'Read out loud the last article or video title you looked at.',
  'Give a dramatic reading of the most recent notification on your phone.',
  'Let the group choose who has to be your assigned partner for the next round.',
  'Describe yourself as a character from a TV show and let the group guess which.',
  'Let someone pick a random number in your contacts and read out the name without calling.',
  'Tell the group what your lock screen is and why.',
  'Let the group decide what embarrassing true fact about you gets shared.',
  'Do your best fake cry for exactly ten seconds.',
  'Let someone here post a story on your behalf using a photo they choose.',
  'Act out your most embarrassing memory without using words.',
  'Let the group choose one app on your phone to see your activity in.',
  'Give a heartfelt apology to an inanimate object of your choice.',
  'Let the group pick who you must give your full, undivided attention to for two minutes.',
];

// ─── SPICY TRUTH (50) ──────────────────────────────────────────────────────────
const _spicyTruth = [
  'Who here do you find the most physically attractive?',
  'If you could go on a date with anyone in this room, who would you choose?',
  'Have you ever had romantic feelings for someone in this group?',
  'Who here gives you butterflies when they look at you?',
  'Who in this room do you think would be the most exciting to date?',
  'Have you ever flirted with someone in this group without them realizing?',
  'Who here would you most want to be stuck in a hotel room with overnight?',
  'Who here do you think kisses the best?',
  'What is the most attractive thing anyone has ever done or said to you?',
  'Who here would you swipe right on immediately if you saw them on a dating app?',
  'What is the boldest move you have ever made to get someone attention?',
  'Who here do you think has the most chemistry with someone else in the room?',
  'What is your most embarrassing confession about your romantic life?',
  'Who here would be the hardest to say no to if they asked you on a date?',
  'What is one physical feature you noticed about someone in this room immediately?',
  'Who here do you think would be the most passionate partner?',
  'What is the most forward thing anyone has ever said or done to you?',
  'Who here would you take on a vacation just the two of you?',
  'Have you ever had a dream about someone in this group?',
  'Who here would you want to slow dance with right now?',
  'What is the craziest thing you have ever done for someone you liked?',
  'Who in this room have you thought about in a romantic way at any point?',
  'What is the most nervous you have ever been around someone you were attracted to?',
  'Who here would be the most unforgettable to lose?',
  'What is your most embarrassing moment on a date?',
  'Who here do you think would be the most loyal partner in a relationship?',
  'What is the longest you talked to someone before finally admitting you liked them?',
  'Who here has the most attractive voice?',
  'What is one thing about your love life you have never confessed to anyone in this room?',
  'Who here would you choose if you had to kiss one person right now?',
  'What was the most exciting kiss you have ever experienced?',
  'Who here would you bring home to meet your family before anyone else?',
  'What is the most obvious hint you have ever dropped that nobody picked up?',
  'Who here would you call if you just got your heart broken?',
  'What is the most romantic thing you have ever done for someone?',
  'Who here do you think secretly likes someone else in this room?',
  'What is the most embarrassing thing you have ever done to impress someone?',
  'Who here has said something to you that you still think about when you are alone?',
  'What is one thing you find irresistible that you are slightly embarrassed about?',
  'Who here would you most regret never telling how you actually feel?',
  'What is your worst flirting story?',
  'Who here do you think would make the biggest effort in a relationship?',
  'What is the most romantic fantasy you have but rarely admit?',
  'Who here would you choose for a completely honest, late night conversation?',
  'What physical detail about someone here did you notice before anything else?',
  'Who here do you think gives off the most dangerous relationship energy?',
  'What is the worst rejection you have ever experienced?',
  'Who here do you think is the best-looking person you personally know?',
  'What is the most honest thing you would say to the person you find most attractive here?',
  'Who here would you consider pursuing if your situation in life were completely different?',
];

// ─── SPICY DARE (50) ──────────────────────────────────────────────────────────
const _spicyDare = [
  'Tell the person you find most attractive in this room one genuine thing you like about them.',
  'Give your number to someone in this room whose number you do not currently have.',
  'Whisper something honest and flattering to the person you find most attractive here.',
  'Ask someone in this room if you can hold their hand for thirty seconds.',
  'Wink at someone in the room and hold eye contact until they look away first.',
  'Tell the person opposite you one thing about them that would make someone fall for them.',
  'Sit as close as possible to the person you would most want to date for this round.',
  'Tell someone here the one thing about them you find most physically attractive.',
  'Give the person on your right a slow, genuine compliment while looking them in the eyes.',
  'Ask the most attractive person here what their type is and listen without interrupting.',
  'Tell someone in the room what you would do on a perfect first date with them.',
  'Send a "thinking of you" message right now to the person you last had feelings for.',
  'Let the group choose who you must give your most charming smile to and hold it.',
  'Tell the group your biggest turn-on without softening it.',
  'Ask someone in this room if they find you attractive and accept their completely honest answer.',
  'Hold the hand of the person on your left for the next sixty seconds.',
  'Let the group decide who you must compliment three times in a row without laughing.',
  'Tell the person you like most in this room one thing you have been keeping to yourself.',
  'Read a flirty but honest message to someone in this room that the group writes for you.',
  'Tell someone here one sentence that would genuinely work as a pickup line on you.',
  'Send a single emoji chosen by the group to the last person you had feelings for.',
  'Let someone here draw a small heart on your hand.',
  'Describe your ideal date out loud and let the group guess who in the room fits best.',
  'Let the group pick one person you must maintain eye contact with for thirty full seconds.',
  'Tell the group which two people here have the most obvious chemistry.',
  'Send "hey stranger" to someone you have not spoken to in a very long time.',
  'Ask someone in this room what they would do if you asked them out right now.',
  'Let the group pick who you must give your full, dedicated attention to for the next three minutes.',
  'Tell someone in this room one thing you have noticed about them that you kept to yourself until now.',
  'Send "I was just thinking about you" to someone outside this room with no explanation.',
  'Give someone here a genuine compliment that makes them slightly uncomfortable from honesty.',
  'Let someone here ask you one personal question you must answer completely honestly.',
  'Tell the person you trust most here what you honestly think about someone in the room.',
  'Ask the person you are most curious about here one question you have always wanted to ask.',
  'Let the group choose who in this room you must say "you are dangerous to be around" to.',
  'Give the most attractive person here a compliment that is slightly too specific to be generic.',
  'Tell someone here why they would be hard to forget.',
  'Let someone in this room pick a song to dedicate to someone else here.',
  'Send "can we talk soon" to someone you have been meaning to reconnect with.',
  'Tell the group honestly who here you would most want to get to know better.',
  'Let the group decide who you must ask "what do you actually think of me" to right now.',
  'Describe the most attractive version of yourself without being modest.',
  'Tell someone here one honest reason you would or would not date them.',
  'Let the group pick who you must get a photo with, with your arm around them.',
  'Tell the room which one person here you would choose for a secret weekend trip.',
  'Ask someone in this room to describe you in three completely honest words.',
  'Let the person you find most interesting here ask you one thing they have always wondered.',
  'Tell someone here one thing you find genuinely irresistible about them.',
  'Send "I heard a song that reminded me of you" to the last person you liked.',
  'Let the group decide the most honest thing you must say to the person sitting closest to you.',
];

// ─── UNHINGED TRUTH (40) ──────────────────────────────────────────────────────
const _unhingedTruth = [
  'Have you ever sent a message to the completely wrong person and what did it say?',
  'Who here do you think is actually in love with someone else in this room?',
  'What is the most embarrassing thing you have ever done for an ex?',
  'Who here would you take home tonight if nothing had any consequences?',
  'What is the most toxic behavior you have been guilty of in a relationship?',
  'Who here do you think has the most drama in their current love life?',
  'What is the worst thing you have said about someone in this room when they were not present?',
  'Have you ever ghosted someone and immediately regretted it badly?',
  'Who here do you secretly find more attractive now than when you first met them?',
  'What is the most reckless thing you have done for someone you were attracted to?',
  'Who here would you least want to see your full browsing history?',
  'What is the most embarrassing thing you have done while drunk?',
  'Who here do you think has feelings for someone in this room right now tonight?',
  'What is your most embarrassing confession about your physical life?',
  'Who here would you trust least in a situation that required total loyalty?',
  'What is the wildest or most unexpected place you have ever hooked up?',
  'Who here do you think would be the worst partner to have in a serious relationship?',
  'What is the most you have ever spent or changed for someone who did not deserve it?',
  'Who here do you think has the biggest secret from the rest of this group?',
  'What is something you have done drunk that you would genuinely never admit sober?',
  'Who here do you think secretly wants to pursue someone in this room?',
  'What is the most private thing someone has accidentally found on your phone?',
  'Who here do you think would be the most jealous partner in a relationship?',
  'What is the worst breakup you have caused or been responsible for?',
  'Who here do you have the most unresolved tension with right now?',
  'What is one thing you did in a past relationship that you genuinely still regret?',
  'Who here do you think would say "I love you" first and mean it the least?',
  'What is the most embarrassing thing you have done to get someone attention?',
  'Who here looks the most innocent but is absolutely not?',
  'What is the most honest thing you could say about your own behavior in relationships?',
  'Who here do you think is secretly the wildest when they are comfortable?',
  'What is something someone in this room said to you that you cannot stop thinking about?',
  'Who here do you have the most unfinished business with, in any way?',
  'What is a thing you have done to someone in this room that they do not know about?',
  'Who here would you choose to spend a week in a cabin with, completely off the grid?',
  'What is your most honest and potentially uncomfortable opinion about your own love life?',
  'Who here do you think would fight the hardest for someone they cared about?',
  'What is the most embarrassing thing you have ever confessed to a crush?',
  'Who here do you think would make the most unforgettable ex?',
  'What is the realest and most honest thing you could tell this group about yourself right now?',
];

// ─── UNHINGED DARE (40) ──────────────────────────────────────────────────────
const _unhingedDare = [
  'Text your most recent ex "I keep thinking about something you said" and leave it at that.',
  'Call someone you have not spoken to in over a month and say "I have been thinking about you."',
  'Let the group pick someone from your contacts you must text "are you up?" to right now.',
  'Show the group the most embarrassing photo in your camera roll that involves another person.',
  'Read out loud the last message you drafted but never actually sent.',
  'Let someone in this room scroll through your Instagram or WhatsApp DMs for twenty seconds.',
  'Call your most recent ex and put it on speaker for exactly ten seconds.',
  'Post an embarrassing photo chosen by the group to your story for fifteen minutes.',
  'Text the last person you rejected or who rejected you with just "hey."',
  'Let someone here pick one person you must call and tell them you owe them an apology.',
  'Let the group see your current screen time report without hiding any apps.',
  'Send "we need to talk" to a random contact chosen by the group and then immediately follow up.',
  'Let the group choose which two people here must swap phones for two full minutes.',
  'Text someone who has been persistently trying to get your attention with "okay, tell me more."',
  'Let the group pick someone you must call and sing them one line of a song live.',
  'Show the last five photos in your camera roll without hiding or skipping any.',
  'Let someone here read the last conversation in your most used messaging app.',
  'Send a voice note saying "I thought about you more than I should have today" to someone.',
  'Give the person across from you a two-minute back massage if they fully agree.',
  'Tell the most embarrassing story about your love life to the entire group with full details.',
  'Let the group choose who you must give a genuine, unironic slow hug to right now.',
  'Take a video of yourself doing your most embarrassing dance and send it to one contact.',
  'Let someone here ask you any single question and you must answer completely honestly.',
  'Text "I dreamed about you" to someone chosen by the group.',
  'Let someone here scroll through your Spotify listening history for thirty seconds.',
  'Call a random contact you rarely talk to and have a thirty-second completely genuine conversation.',
  'Let the group choose someone here to tell you the most honest thing they think about you.',
  'Send "is that offer still open?" to someone from your past without explaining to the group.',
  'Let someone in the room post one photo to your story entirely on your behalf.',
  'Text the person you have been avoiding most recently with "are we actually okay?"',
  'Let the group read the first message in your oldest currently active text thread.',
  'Give the most attractive person here a compliment that is specifically too honest.',
  'Let the group pick someone you must whisper one deeply genuine thing to.',
  'Call your closest friend and tell them you have been keeping a specific secret from them.',
  'Text someone you used to like "I heard a song today and could not stop thinking of you."',
  'Let the group choose the most honest thing you must say and say it completely seriously.',
  'Send "confession: I used to have real feelings for you" to someone the group picks.',
  'Show the group your most recent sent voice note and let them hear it.',
  'Let the group decide the most personal true fact about you that must be shared right now.',
  'Text the person you trust most here "I need to tell you something important" and then actually do.',
];

// ─── EVIL TRUTH (36) ──────────────────────────────────────────────────────────
const _evilTruth = [
  'Who here would you pursue right now if everyone in this room consented and nothing was off-limits?',
  'Have you ever had genuine romantic feelings for someone in this group that you never admitted?',
  'Who here do you think would be the most devastating person to fall in love with?',
  'Have you ever been physically attracted to someone in this room and said absolutely nothing?',
  'Who here could genuinely destroy your peace with a single text?',
  'What is the most honest thing you have thought about someone in this room that you would never say to them?',
  'Who here do you think secretly wants to pursue someone in this group but is holding back?',
  'What is the most painful truth about your past that only one person knows and is not in this room?',
  'Who here has said or done something that you still think about when you are completely alone?',
  'Have you ever faked feelings for someone just to keep them around?',
  'Who here would you choose if you had to be in a completely secret relationship with one person?',
  'What is the worst thing you have ever done to someone who trusted you fully?',
  'Who in this room do you think has the most potential to actually break your heart?',
  'What is the most selfish thing you have done in a relationship and never apologized for?',
  'Who here would you most regret never being honest with about how you actually feel?',
  'What is something you have done to someone in this room that they do not currently know about?',
  'Who here do you think is the most genuinely dangerous person to let yourself get close to?',
  'Have you ever been in love with two people at the exact same time?',
  'Who here would you tell your absolute biggest secret to if you had to choose one person right now?',
  'What is the most honest thing you could confess about how you actually feel about someone in this group?',
  'Who here do you think is truly impossible to get over once they are gone?',
  'What is the most honest reason you have ever ended a relationship?',
  'Who here hides the most about who they actually are when they are comfortable?',
  'What is something someone here has done that hurt you more than they will ever know?',
  'Who here would you call at your absolute most vulnerable moment?',
  'What is the most honest thing you feel about the person sitting physically closest to you?',
  'Who here do you think secretly has the strongest feelings for someone in this room?',
  'Have you ever done something to deliberately ruin your own relationship?',
  'Who here would you pick if you could spend one completely honest evening with anyone in the room?',
  'What is the most genuine thing you have never said out loud about your own love life?',
  'Who here do you think deserves much more honesty from the people around them?',
  'What is the single most honest confession you have been holding back from everyone in this room?',
  'Who here would you choose for one night of complete honesty with no consequences?',
  'What is a truth about someone in this room that you have been sitting on and never shared?',
  'Who here do you think will remember tonight the longest and for what reason?',
  'What is the most you have ever wanted someone in this room and never acted on it?',
];

// ─── EVIL DARE (36) ──────────────────────────────────────────────────────────
const _evilDare = [
  'Text your ex right now: "I still think about that one time. You know which one."',
  'Call someone you have genuine unresolved feelings for and tell them, without mentioning it is a game.',
  'Let the group pick someone here you must privately tell one true thing you have never told them.',
  'Send your most recent ex a voice note saying "I lied when I said I was completely over it."',
  'Let someone here read the last message you deleted before sending it.',
  'Call the person you have been actively avoiding and have an honest thirty-second conversation.',
  'Text "I think I made a mistake letting you go" to someone from your past the group picks.',
  'Let the group pick someone here you must kiss or agree on an alternative consequence together.',
  'Tell the person you find most attractive in this room exactly what you find attractive about them.',
  'Send "can we actually start over?" to someone you have history with.',
  'Let someone here ask you the most personal question they want answered and answer it completely.',
  'Text "I wish things between us had gone completely differently" to someone.',
  'Let the group choose who here you must hold hands with for the rest of this entire round.',
  'Call your most recent situationship and tell them you genuinely thought about them today.',
  'Let the group decide who you must sit directly next to and ask "do you actually like me?"',
  'Tell the person across from you the one thing about them you find the hardest to resist.',
  'Let the group choose one person you must maintain a complete, unbroken stare with for one full minute.',
  'Text someone "I never told you this but I think you are genuinely incredible."',
  'Let the group pick someone you must give a long, slow, completely genuine hug to.',
  'Tell the most attractive person here in full detail what you would actually do on a date with them.',
  'Let someone here ask you one question you have been dreading and answer it truthfully.',
  'Send the person you liked most recently "I wish I had been more honest with you from the start."',
  'Let the group decide which two people here must share fifteen seconds completely alone together.',
  'Tell someone in this room one honest thing about how you feel that you have been sitting on.',
  'Text "I think about you more than you know" to someone chosen entirely by the group.',
  'Let someone here read your last five sent messages without you closing anything.',
  'Tell the person you like most in this room one thing you would do differently given another chance.',
  'Let the group choose who you must ask out loud "what do you actually, honestly think of me?"',
  'Send your ex right now: "you were right about me. I know that now."',
  'Let someone in this room ask you the one question they have genuinely always wanted to know.',
  'Tell the group which single person here you would most regret losing from your life entirely.',
  'Let the group pick who you must call and tell them you have genuinely been thinking about them.',
  'Send "I should have said this a long time ago" followed by something completely honest to someone.',
  'Let someone here choose one photo from your gallery to show to the whole group.',
  'Tell the person you find most interesting here one thing you have always wanted to say to them.',
  'Let the group decide what truth you must share about how you actually feel about someone in this room.',
];
