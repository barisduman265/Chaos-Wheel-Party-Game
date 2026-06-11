import 'package:chaos_wheel/models/prompt_models.dart';

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
// Truth = confess / admit / reveal.
const _cozyTruth = [
  'Confess the most embarrassing thing that happened to you this year.',
  'Admit which person here you would actually call in an emergency.',
  'Confess the most embarrassing text you have sent to the wrong person.',
  'Reveal a childish habit you still secretly have.',
  'Admit the worst style phase you ever went through.',
  'Confess who in this room you are secretly most competitive with.',
  'Confess the most embarrassing thing a family member has caught you doing.',
  'Admit which person here gives the best hugs.',
  'Confess one habit you hope nobody here has noticed.',
  'Reveal the funniest thing that happened to you this year.',
  'Admit the silliest reason you have ever cried.',
  'Confess a lie you told your parents that completely worked.',
  'Reveal your most embarrassing childhood memory.',
  'Admit who in this room you trust most with a secret.',
  'Confess the most embarrassing thing you have ever posted and deleted.',
  'Reveal the worst excuse you have used to cancel plans.',
  'Confess your most embarrassing autocorrect fail.',
  'Admit a food opinion you would actually defend in public.',
  'Confess the most ridiculous reason you were ever late.',
  'Reveal the funniest thing you believed as a child.',
  'Confess the most childish thing you still secretly do.',
  'Admit a compliment you received that you still think about.',
  'Confess the worst rumor that was ever spread about you.',
  'Reveal your most embarrassing moment in front of a crush.',
  'Confess something you pretend to understand but really do not.',
  'Admit the most ridiculous thing you have done out of boredom.',
  'Confess the most embarrassing thing in your search history.',
  'Reveal the most awkward greeting you have ever fumbled.',
  'Confess your worst cooking disaster.',
  'Admit one thing you would be mortified for this group to find out.',
  'Confess who here you would want beside you in a zombie apocalypse.',
  'Reveal the most embarrassing nickname you have ever had.',
  'Confess the pettiest thing you have ever stayed mad about.',
  'Admit the last time you cried and why.',
  'Confess the most embarrassing thing on your phone right now.',
  'Reveal a secret talent nobody here knows about.',
  'Confess the dumbest argument you have ever won.',
  'Admit which person here you would pick to plan your birthday.',
  'Confess the most embarrassing thing you did to look cool.',
  'Reveal the worst gift you have ever given someone.',
  'Confess a small lie you have told everyone in this room.',
  'Admit the most embarrassing song saved on your playlist.',
  'Confess the weirdest thing you find genuinely comforting.',
  'Reveal the most embarrassing thing you have done while home alone.',
  'Confess who here you would trust to pick your outfit for a big day.',
  'Admit the most useless skill you are weirdly proud of.',
  'Confess the most embarrassing thing you have done for free food.',
  'Reveal the longest you have ever gone without showering.',
  'Confess one thing you have never told anyone in this room.',
  'Admit the most embarrassing thing you did this week.',
];

// ─── COZY DARE (50) ──────────────────────────────────────────────────────────
// Dare = do it (action).
const _cozyDare = [
  'Compliment every person in this room out loud, one genuine thing each.',
  'Show the last photo in your camera roll that you are comfortable sharing.',
  'Do your best impression of someone in this room until they guess it is them.',
  'Speak in an accent the group picks for the next two rounds.',
  'Do your best runway walk across the room while everyone watches.',
  'Let the group give you a nickname for the rest of the game.',
  'Show everyone the most recent photo you took.',
  'Do your best fake cry for ten full seconds.',
  'Call someone not in the room and tell them they are your favorite person right now.',
  'Do an impression of a teacher or boss you have had.',
  'Show your most used app and let the group judge it for thirty seconds.',
  'Act out your morning routine in fast motion.',
  'Do your most dramatic news-anchor voice reading the last thing you texted.',
  'Let someone in this room rename one of your contacts.',
  'Sing the chorus of the last song you listened to.',
  'Let the group pick someone you must take a selfie with right now.',
  'Give a sixty-second speech on why you are the group MVP.',
  'Swap phones with the person on your left for thirty seconds.',
  'Show the oldest photo saved on your phone.',
  'Do your best impression of a famous person using only body language.',
  'Read the last message you sent out loud, name included.',
  'Let someone read your most recent voice note to the group.',
  'Do a dramatic reading of your latest phone notification.',
  'Let the group choose one app to scroll your activity in.',
  'Balance something on your head and walk across the room.',
  'Strike your best catwalk pose and hold it for ten seconds.',
  'Let someone draw a tiny doodle on the back of your hand.',
  'Act out your most embarrassing memory without using any words.',
  'Show your screen time report without hiding anything.',
  'Let the group pick a contact whose name you must read aloud.',
  'Do thirty seconds of your worst dancing with full commitment.',
  'Let someone here change your ringtone for the next hour.',
  'Talk only in a whisper for the next two rounds.',
  'Show the last five photos in your gallery without skipping any.',
  'Do your best impression of how you look the moment you wake up.',
  'Let the group pick a word you cannot say for the next three rounds.',
  'Give a heartfelt apology to an object of your choice.',
  'Let someone scroll your music history for thirty seconds.',
  'Act out a movie scene and let the group guess it.',
  'Do your best slow-motion victory celebration across the room.',
  'Let the group choose your assigned partner for the next round.',
  'Hold a plank until your next turn comes around.',
  'Let someone read the last article or video title you opened.',
  'Do an impression of the person on your right.',
  'Let the group decide an embarrassing true fact you must share.',
  'Wear something on your head chosen by the group for two rounds.',
  'Let someone post a story for you using a photo they pick.',
  'Do your best impression of a baby learning to walk.',
  'High-five every person here and say one nice thing to each.',
  'Let the group give you a dramatic backstory you must act out.',
];

// ─── SPICY TRUTH (50) ──────────────────────────────────────────────────────────
// Truth = confess / admit / reveal. Flirty register.
const _spicyTruth = [
  'Confess who in this room you find the most physically attractive.',
  'Admit if you have ever had feelings for someone in this group.',
  'Confess who here gives you butterflies.',
  'Reveal the most attractive thing someone has ever done to you.',
  'Confess who here you would swipe right on instantly.',
  'Admit the boldest move you have ever made to get someone\'s attention.',
  'Confess your most embarrassing romantic moment.',
  'Reveal one physical feature you noticed about someone here immediately.',
  'Confess who here you would be most tempted to date.',
  'Admit if you have ever flirted with someone in this group without them realizing.',
  'Confess the craziest thing you have done for someone you liked.',
  'Reveal who here you think kisses the best.',
  'Confess the most forward thing anyone has ever said to you.',
  'Admit who here you would slow dance with right now.',
  'Confess who here would be the hardest for you to say no to.',
  'Reveal the most nervous you have ever been around a crush.',
  'Confess one thing about your love life you have never told this room.',
  'Admit who here has the most attractive voice.',
  'Confess your worst flirting fail.',
  'Reveal the most romantic thing you have ever done for someone.',
  'Confess who here you have thought about in a romantic way.',
  'Admit the longest you waited before telling someone you liked them.',
  'Confess who here you would bring home to meet your family first.',
  'Reveal the most obvious hint you dropped that nobody ever caught.',
  'Confess the worst rejection you have ever experienced.',
  'Admit who here you think secretly likes someone in this room.',
  'Confess the most embarrassing thing you have done to impress someone.',
  'Reveal one thing you find irresistible that you are slightly embarrassed about.',
  'Confess who here you would most regret never telling how you feel.',
  'Admit the most romantic fantasy you rarely say out loud.',
  'Confess what physical detail you notice about people first.',
  'Reveal who here gives off the most dangerous flirt energy.',
  'Confess who here you would pick for a late-night honest talk.',
  'Admit the most exciting kiss you have ever had.',
  'Confess one honest thing you would say to the most attractive person here.',
  'Reveal who here you would secretly date if your life were different.',
  'Confess the cheesiest pickup line that would actually work on you.',
  'Admit who here you have caught yourself staring at.',
  'Confess the most you have ever changed yourself for a crush.',
  'Reveal your biggest turn-on without softening it.',
  'Confess who here you would kiss if you had to pick one person right now.',
  'Admit the most honest thing about your dating life.',
  'Confess the most desperate thing you have done to get noticed.',
  'Reveal who here you think would be the most passionate partner.',
  'Confess a crush you had that nobody ever found out about.',
  'Admit which person here would be your "in another life" choice.',
  'Confess the last time someone made your heart race.',
  'Reveal the personality trait you find most attractive.',
  'Confess who here you would trust with your phone fully unlocked.',
  'Admit the one thing you find genuinely irresistible in a person.',
];

// ─── SPICY DARE (50) ──────────────────────────────────────────────────────────
// Dare = do it (action). Flirty register.
const _spicyDare = [
  'Give the most attractive person here a genuine compliment to their face.',
  'Hold eye contact with someone across the room until one of you laughs.',
  'Sit as close as possible to the person you would most want to date this round.',
  'Hold hands with the person on your left for sixty seconds.',
  'Wink at someone and hold it until they react.',
  'Whisper something flattering to the most attractive person here.',
  'Let someone here draw a small heart on the back of your hand.',
  'Give the person on your right a slow compliment while looking them in the eyes.',
  'Take a photo with your arm around the person the group picks.',
  'Flash your most charming smile at one person and hold it for ten seconds.',
  'Slow dance with someone for fifteen seconds with no music.',
  'Let the group pick someone you must keep eye contact with for thirty seconds.',
  'Send a single flirty emoji the group picks to your last crush.',
  'Give someone here a two-minute shoulder massage if they agree.',
  'Sit back-to-back with the person the group chooses for a full round.',
  'Let someone whisper a dare into your ear and act on it.',
  'Try your best flirty pickup line on the person across from you.',
  'Let the group pick who you must give a piggyback ride across the room.',
  'Feed the person next to you one snack if they are willing.',
  'Let someone pick a song and dedicate it out loud to someone in the room.',
  'Rest your head on the shoulder of the person the group picks for one round.',
  'Give a genuine compliment designed to make someone blush.',
  'Let the person on your right style your hair however they want.',
  'Take a "just met a stranger" photo with the most attractive person here.',
  'Trace a word on someone\'s back and have them guess it.',
  'Let the group choose two people who must link arms for the next round.',
  'Send "I was just thinking about you" to your last crush right now.',
  'Do a dramatic love-confession monologue to a person the group picks.',
  'Sit on the floor in front of someone here while you compliment them.',
  'Give the person across from you your full attention for two minutes.',
  'Let the group pick someone you must hug for fifteen seconds.',
  'Whisper your biggest turn-on to the person beside you.',
  'Let someone scroll your last three photos without you closing anything.',
  'Hold the hand of the person you find most attractive while you answer a question.',
  'Do a slow runway walk toward the person the group picks and pose.',
  'Let the group decide who you must boop on the nose.',
  'Lock pinkies with the person on your left for the next two rounds.',
  'Give someone here a compliment so specific it could not be generic.',
  'Let the most attractive person here ask you one question you must answer.',
  'Pose for a "couple photo" with the person the group chooses.',
  'Let someone draw a tiny pen tattoo on your wrist.',
  'Blow a kiss to someone across the room and keep a straight face.',
  'Let the group pick who you must compliment three times without laughing.',
  'Give your most convincing flirty eyebrow raise to one person.',
  'Whisper something honest and flattering to the person closest to you.',
  'Let someone here pick the next person you must sit beside.',
  'Give the person on your right a slow high-five and hold the grip for ten seconds.',
  'Let the group choose who you must take a goofy couple selfie with.',
  'Hold someone\'s gaze and describe them in three honest words.',
  'Let the person beside you write a flirty word on your palm.',
];

// ─── UNHINGED TRUTH (40) ──────────────────────────────────────────────────────
// Truth = confess / admit / reveal. Chaotic, exposing.
const _unhingedTruth = [
  'Confess the most embarrassing thing you have ever done while drunk.',
  'Admit who here you would take home tonight if there were zero consequences.',
  'Confess the most toxic thing you have ever done in a relationship.',
  'Reveal the wildest place you have ever hooked up.',
  'Confess the worst thing you have said about someone in this room behind their back.',
  'Admit if you have ever ghosted someone and instantly regretted it.',
  'Confess the most reckless thing you have done for someone you wanted.',
  'Reveal the most private thing someone has ever found on your phone.',
  'Confess something you did drunk that you would never admit sober.',
  'Admit who here you secretly find more attractive now than when you first met.',
  'Confess the worst breakup you have ever caused.',
  'Reveal the biggest secret you are keeping from this group.',
  'Confess who here you have the most unresolved tension with.',
  'Admit a thing you did in a past relationship that you still regret.',
  'Confess the most embarrassing thing you have ever done to get attention.',
  'Reveal who here looks the most innocent but absolutely is not.',
  'Confess something a person in this room said that you cannot stop thinking about.',
  'Admit the most you have ever spent on someone who did not deserve it.',
  'Confess who here you would least want to see your browser history.',
  'Reveal the wildest thing on your phone right now.',
  'Confess your most embarrassing confession about your physical life.',
  'Admit who here you think wants to hook up with someone in this room tonight.',
  'Confess the biggest lie you are currently telling someone.',
  'Reveal the messiest situationship you have ever been in.',
  'Confess the most you have ever stalked someone online.',
  'Admit who here would genuinely be the worst person to date.',
  'Confess a secret that could end a friendship if it got out.',
  'Reveal the most chaotic night you have ever had.',
  'Confess who here you would risk a friendship to date.',
  'Admit the pettiest revenge you have ever taken.',
  'Confess the most unhinged text you have ever sent completely sober.',
  'Reveal what you were really doing the last time you lied about where you were.',
  'Confess who here you have had a dream about.',
  'Admit the worst thing you have done that you completely got away with.',
  'Confess the most embarrassing thing you have done for a hookup.',
  'Reveal who in this room you would trust the least.',
  'Confess the realest thing you could say about your love life right now.',
  'Admit the secret you swore you would take to the grave.',
  'Confess who here you have unfinished business with.',
  'Reveal the most honest thing you have been hiding from this group tonight.',
];

// ─── UNHINGED DARE (40) ──────────────────────────────────────────────────────
// Dare = do it (action). Chaotic.
const _unhingedDare = [
  'Text your most recent ex "I keep thinking about something you said" and send it now.',
  'Call someone you have not spoken to in a month and say you have been thinking about them.',
  'Let the group pick a contact you must text "are you up?" to right now.',
  'Show the group the most embarrassing photo in your camera roll that involves another person.',
  'Read out loud the last message you drafted but never sent.',
  'Let someone scroll your DMs for twenty seconds.',
  'Call your most recent ex and put it on speaker for exactly ten seconds.',
  'Post a photo the group picks to your story for fifteen minutes.',
  'Text the last person who rejected you with just "hey."',
  'Let the group see your screen time report with no apps hidden.',
  'Send "we need to talk" to a contact the group picks, then immediately admit it was a dare.',
  'Swap phones with the person across from you for two full minutes.',
  'Let the group pick someone you must call and sing one line to live.',
  'Show the last five photos in your camera roll with no skipping.',
  'Let someone read the last conversation in your most used messaging app.',
  'Send a voice note saying "I thought about you more than I should have today" to someone.',
  'Give the person across from you a two-minute back massage if they agree.',
  'Tell the group your messiest love-life story in full detail.',
  'Take a video of your worst dance and send it to one contact.',
  'Text "I dreamed about you" to someone the group chooses.',
  'Let someone scroll your Spotify history for thirty seconds.',
  'Call a random contact and hold a thirty-second genuine conversation.',
  'Send "is that offer still open?" to someone from your past.',
  'Let someone post one photo to your story entirely on your behalf.',
  'Text the person you have been avoiding "are we actually okay?"',
  'Let the group read the first message in your oldest active chat.',
  'Let the group pick someone you must whisper one brutally honest thing to.',
  'Text someone you used to like "a song reminded me of you today."',
  'Send "confession: I used to have real feelings for you" to a contact the group picks.',
  'Play your most recent sent voice note out loud for the group.',
  'Let someone pick a person you must call and compliment for thirty seconds.',
  'Do a water shot off the table on the count of three.',
  'Let the group choose two people who must swap one item of clothing.',
  'Text your crush something the group writes, word for word.',
  'Let someone here read your search history from the last twenty-four hours.',
  'Send your ex "you were right about me, I know that now."',
  'Let the group pick who you must sit on the lap of for one round.',
  'Reenact the most dramatic argument you have ever had.',
  'Let someone here decide a truth you must confess to the whole group.',
  'Text the person you trust most here "I need to tell you something important" and mean it.',
];

// ─── EVIL TRUTH (36) ──────────────────────────────────────────────────────────
// Premium. Truth = confess / admit / reveal. Genuinely sexual, edgy adult.
const _evilTruth = [
  'Confess the most explicit thing you have ever done that nobody here knows about.',
  'Reveal who in this room you have imagined sleeping with.',
  'Confess your body count out loud, no rounding.',
  'Admit the kinkiest thing you are genuinely into.',
  'Confess who here you would have a one-night stand with, no hesitation.',
  'Reveal the wildest sexual thing you have ever done.',
  'Confess the most inappropriate place you have ever had sex.',
  'Admit who in this room you have had a sexual dream about.',
  'Confess what you are actually like in bed in one honest sentence.',
  'Reveal the last thing you searched that you would never want shown here.',
  'Confess the most recent person you thought about while alone.',
  'Admit the biggest sexual turn-on you have never told anyone.',
  'Confess whether you have ever cheated, and leave it there.',
  'Reveal the most people you have been with in a single week.',
  'Confess who here you would say yes to if they made a move tonight.',
  'Admit the most embarrassing thing that has ever happened to you during sex.',
  'Confess the wildest thing you have ever sent someone.',
  'Reveal the kink you would be too embarrassed to ask a partner for.',
  'Confess who in this room you find the hardest to resist physically.',
  'Admit the last time you hooked up, in the vaguest terms you dare.',
  'Confess the most reckless sexual decision you have ever made.',
  'Reveal whether there is anyone in this room you would sleep with tonight.',
  'Confess your most specific physical type, in detail.',
  'Admit the dirtiest thought you have ever had about someone here.',
  'Confess the wildest age gap or situation you have ever been in.',
  'Reveal the one thing you most want done to you that you never ask for.',
  'Confess whether you have ever been walked in on, and by whom.',
  'Admit how explicit the boldest message in your phone right now is.',
  'Confess who here you would pick for a no-strings night.',
  'Reveal the most adventurous thing on your bucket list, no filter.',
  'Confess the closest you have ever come to hooking up with someone in this group.',
  'Admit how many people in this room you would realistically sleep with.',
  'Confess the most scandalous secret about your sex life.',
  'Reveal what you would do to the most attractive person here if no one would ever know.',
  'Confess the riskiest place you have ever wanted to do it.',
  'Admit the one thing about your sex life you would never want this group to know, then say it.',
];

// ─── EVIL DARE (36) ──────────────────────────────────────────────────────────
// Premium. Dare = do it (action). Genuinely sexual, edgy adult.
const _evilDare = [
  'Whisper exactly what you would do to the most attractive person here into their ear.',
  'Give the person the group picks a fifteen-second lap dance.',
  'Demonstrate your best move on the person beside you, fully clothed.',
  'Sit on the lap of the person you find most attractive for one full round.',
  'Let the group pick someone you must kiss, or take three shots instead.',
  'Take a body shot off the person the group chooses.',
  'Recreate your signature bedroom face for the group.',
  'Send the most explicit flirty text you dare to the person the group picks.',
  'Let someone here slowly trace one finger from your wrist to your elbow.',
  'Demonstrate how you kiss on the back of your own hand for the group.',
  'Whisper your dirtiest thought to the person on your right.',
  'Let the person you find most attractive feed you a snack from their hand.',
  'Give the group your most convincing moan on command.',
  'Dance as close as you dare with the person the group picks for fifteen seconds.',
  'Let someone bite a snack out of your mouth with both your hands behind your back.',
  'Unbutton one button or remove one accessory chosen by the group.',
  'Act out your favorite position using only your hands for the group.',
  'Let the person beside you leave a fake lipstick kiss mark on your cheek.',
  'Send a voice note of your most suggestive whisper to the person the group picks.',
  'Let the group choose two people who must share a fifteen-second kiss or both take a shot.',
  'Describe out loud, in detail, what you would do on a perfect night with the person across from you.',
  'Let someone blindfold you and guess who is holding your hand.',
  'Press your forehead to the most attractive person here and hold eye contact for thirty seconds.',
  'Do your best seductive crawl across the floor.',
  'Let the person the group picks whisper something filthy in your ear while you keep a straight face.',
  'Remove one item the group names and toss it to the center.',
  'Give the person beside you a slow, lingering hand massage.',
  'Let the group pick someone to sit between your knees for one round.',
  'Recreate the steamiest scene you can think of with a willing partner, fully clothed.',
  'Let someone trail an ice cube along your collarbone.',
  'Whisper the most explicit compliment you can to the person across from you.',
  'Let the most attractive person here decide where you must rest your hand for one round.',
  'Give your most convincing seductive look to one person until they break.',
  'Let the group choose a body part the person beside you must compliment in detail.',
  'Send your last crush a message saying exactly what you have been holding back.',
  'Let the group dare you and the most attractive person here to do one thing together, and you both must agree.',
];
