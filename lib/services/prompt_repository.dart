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

const _cozyTruth = [
  'What is your most embarrassing school memory?',
  'Who here would survive a zombie apocalypse?',
  'What is your biggest green flag?',
  'What nickname would you secretly enjoy having?',
  'Who here gives the best first impression?',
  'What is the weirdest comfort food you love?',
  'What harmless thing makes you irrationally angry?',
  'Who here would be the best roommate?',
  'What song would expose your music taste instantly?',
  'What is a tiny win you still brag about?',
  'Who here would make the best reality show narrator?',
  'What is your most useless talent?',
  'What movie scene still lives in your head?',
  'Who here would be the calmest in a crisis?',
  'What is your most random childhood fear?',
  'What is one thing you pretend to understand?',
  'Who here has the strongest main character energy?',
  'What is the most wholesome lie you have told?',
  'What app do you open without thinking?',
  'Who here would plan the best vacation?',
  'What is a habit you picked up from your family?',
  'What is the funniest thing you believed as a kid?',
  'Who here would win a low-stakes debate?',
  'What compliment do you remember too clearly?',
  'What is your most dramatic minor inconvenience?',
  'Who here is secretly the most competitive?',
  'What is your comfort show?',
  'What is a food opinion you will defend?',
  'Who here would be best at babysitting?',
  'What is your most chaotic shopping habit?',
  'What is a small thing that instantly improves your day?',
  'Who here would be the best game show host?',
  'What is your most innocent guilty pleasure?',
  'What is your worst harmless impulse buy?',
  'Who here would be most trusted with a secret?',
  'What is a compliment you wish people gave you more?',
  'What is the funniest reason you have been late?',
  'Who here would be best in a cooking show?',
  'What is your most specific pet peeve?',
  'What is a childhood snack you still miss?',
  'Who here would accidentally become famous?',
  'What is the most awkward greeting you have done?',
  'What is one trend you never understood?',
  'Who here would make the best teacher?',
  'What is your safest controversial opinion?',
  'What is the worst haircut phase you survived?',
  'Who here would be best at cheering someone up?',
  'What is a secret talent no one asks for?',
  'What is the funniest thing in your search history?',
  'Who here would survive without their phone longest?',
];

const _cozyDare = [
  'Do your best fake movie trailer voice.',
  'Compliment three people in the room.',
  'Tell a two-sentence story using a random accent.',
  'Let the group choose your new nickname for one round.',
  'Act like a confused tourist for 20 seconds.',
  'Do a dramatic slow clap for yourself.',
  'Make the group laugh without using words.',
  'Pose like a cereal box mascot.',
  'Give a tiny motivational speech to your drink.',
  'Swap seats with the person you know least.',
  'Do your best celebrity walk across the room.',
  'Invent a handshake with the person on your left.',
  'Describe your day like a sports commentator.',
  'Let someone choose an emoji that represents you.',
  'Speak in rhymes until your next turn.',
  'Act out your favorite animal for 15 seconds.',
  'Give someone a fake award and explain it.',
  'Make a dramatic apology to an object nearby.',
  'Do your best robot dance for 10 seconds.',
  'Let the group pick a theme song for you.',
  'Talk like a villain explaining a harmless plan.',
  'Say the alphabet with maximum confidence backwards attempt.',
  'Create a slogan for the group.',
  'Pretend you are hosting a cooking show for 20 seconds.',
  'Give the person opposite you a fake horoscope.',
  'Do a runway walk with whatever is in your hand.',
  'Speak only in questions for one minute.',
  'Make up a conspiracy theory about the room.',
  'Let the group choose your pose for a photo.',
  'Do an overly dramatic weather report.',
  'Invent a new dance move and name it.',
  'Try to sell your shoe like a luxury product.',
  'Give a toast to the most random object nearby.',
  'Do your best victory celebration.',
  'Let the person on your right ask one safe question.',
  'Narrate your next action like a documentary.',
  'Make a serious face while everyone tries to make you laugh.',
  'Pretend to be a bouncer for 20 seconds.',
  'Give your phone case a personality review.',
  'Do a fake acceptance speech.',
  'Let the group rename your next selfie.',
  'Speak like a pirate until someone laughs.',
  'Create a group chant in 10 seconds.',
  'Act like you just won a tiny lottery.',
  'Give a dramatic reading of the last notification you can show.',
  'Do a silent commercial for your favorite snack.',
  'Let the group pick your hand gesture for this round.',
  'Explain your outfit like a fashion critic.',
  'Do your best suspense movie gasp.',
  'Give someone a wholesome dare for later.',
];

const _spicyTruth = [
  'Who here would you trust least with your secrets?',
  'Who here would you kiss if there were no consequences?',
  'What is your biggest red flag?',
  'Who here gives the strongest flirt energy?',
  'What is the most toxic thing you have done?',
  'Who here would you text at 2 AM?',
  'What is your most questionable dating opinion?',
  'Who here looks like they have the most secrets?',
  'What is a DM you regret sending?',
  'Who here would be the hardest to get over?',
  'What is your type, but be painfully specific.',
  'Who here would be dangerous to date?',
  'What is your biggest relationship ick?',
  'Who here has the best voice?',
  'What is your most unserious crush story?',
  'Who here would you choose for a fake date?',
  'What is the boldest move you have made?',
  'Who here seems most likely to ghost someone?',
  'What is one thing you find attractive but rarely admit?',
  'Who here would you want on your side in drama?',
  'What is a compliment that would instantly work on you?',
  'Who here has the most mysterious aura?',
  'What is your worst flirting habit?',
  'Who here would win a breakup?',
  'What is a green flag you secretly require?',
  'Who here would be most fun to take to a party?',
  'What is your most chaotic talking stage story?',
  'Who here seems like they know how to lie well?',
  'What is your biggest jealousy trigger?',
  'Who here would you trust to choose your date outfit?',
  'What is one romantic thing you pretend not to like?',
  'Who here would be the best wingperson?',
  'What is your most dramatic crush confession?',
  'Who here would be easiest to fall for?',
  'What is a message you would never want read aloud?',
  'Who here would survive a situationship best?',
  'What is your most suspicious saved contact name?',
  'Who here gives the most ex energy?',
  'What is your dating app dealbreaker?',
  'Who here would make the best couple with you as a joke?',
  'What is a truth about your standards?',
  'Who here would be most likely to start drama accidentally?',
  'What is your most embarrassing romantic memory?',
  'Who here would you pick for a secret alliance?',
  'What is a red flag you have ignored before?',
  'Who here has the best smile?',
  'What is a risky text you almost sent?',
  'Who here would be most likely to leave someone on read?',
  'What is your biggest soft spot?',
  'Who here would you call if your crush replied?',
];

const _spicyDare = [
  'Let the group write a flirty but safe text you do not have to send.',
  'Give your best dramatic eye contact to someone for 5 seconds.',
  'Rank three harmless date ideas from best to worst.',
  'Let someone pick a new contact name for your crush.',
  'Read your last emoji-only message if it is safe to show.',
  'Give a fake dating profile intro for yourself.',
  'Whisper a harmless secret to the person on your left.',
  'Let the group name the red flag you give off most.',
  'Do your best slow-motion entrance.',
  'Send a compliment to someone in the room.',
  'Let the group pick who has the best flirt face.',
  'Act out how you react when your crush texts back.',
  'Tell someone here what makes them dangerous to date.',
  'Describe your type without using physical traits.',
  'Let someone choose a risky DM you can send or refuse.',
  'Do a dramatic breakup monologue to an object.',
  'Give your best wink attempt.',
  'Let the group vote who you would survive a date with.',
  'Say a pickup line chosen by the group.',
  'Pose like your dating profile photo.',
  'Tell someone here why they would be trouble in a relationship.',
  'Give a toast to your worst talking stage.',
  'Let the group choose who you should avoid texting tonight.',
  'Act like you just got left on read.',
  'Read the first safe sentence from your notes app.',
  'Let the group guess your most obvious crush type.',
  'Admit the last thing that made you jealous.',
  'Describe someone here as a movie genre.',
  'Let the person opposite ask one spicy but safe question.',
  'Make a fake apology to your exes.',
  'Show your caught-flirting reaction to the room.',
  'Let the group give you a dating slogan.',
  'Name one person here as your party bodyguard.',
  'Pretend to receive a dramatic confession.',
  'Give someone a sincere compliment with no jokes.',
  'Let the group choose who has main character date energy.',
  'Name one standard you break when you like someone.',
  'Explain your last crush using only three words.',
  'Let someone choose the red flag you must defend.',
  'Do a dramatic hair flip or equivalent move.',
  'Read a safe notification in a romantic voice.',
  'Let the group decide who you would probably text after midnight.',
  'Act like you are trying to look cool and failing.',
  'Give a compliment to the person with the least eye contact.',
  'Let the group choose a harmless dare for your crush energy.',
  'Say your best “we need to talk” line.',
  'Reveal one rumor about your love life you would hate spreading.',
  'Do a dramatic stare into the distance.',
  'Let the room rate your flirting from 1 to dangerous.',
  'Tell one person here what would make them hard to resist.',
];

const _unhingedTruth = [
  'What is the most embarrassing thing your phone could reveal?',
  'Who here would you not trust with your unlocked phone?',
  'What is your most chaotic saved screenshot?',
  'Who here is most likely to start a group chat argument?',
  'What is the pettiest reason you judged someone?',
  'Who here would be the worst person to share a secret with?',
  'What is the weirdest thing you have done out of boredom?',
  'Who here would fold first under pressure?',
  'What is your most suspicious recent search?',
  'Who here would survive internet cancellation best?',
  'What is something you deleted for a reason?',
  'Who here has the most villain potential?',
  'What is your most unhinged impulse?',
  'Who here would lie best with a straight face?',
  'What is the most dramatic thing you have overreacted to?',
  'Who here is secretly the biggest menace?',
  'What is your most cursed food combination?',
  'Who here would accidentally expose everyone?',
  'What is the worst excuse you have used?',
  'Who here would be most dangerous with fame?',
  'What is your most chaotic group chat role?',
  'Who here would you never let plan your birthday?',
  'What is the dumbest thing you were confident about?',
  'Who here gives “knows too much” energy?',
  'What is one thing you pretend did not happen?',
  'Who here would make the worst alibi?',
  'What is your most embarrassing camera roll category?',
  'Who here would get caught first in a prank?',
  'What is your most dramatic unfollow story?',
  'Who here would be the funniest enemy?',
  'What is your most unhinged note to self?',
  'Who here would cause chaos for entertainment?',
  'What is the most awkward thing you have overheard?',
  'Who here is most likely to disappear at a party?',
  'What is a secret opinion you know will annoy people?',
  'Who here would be worst in a group project?',
  'What is your most chaotic purchase?',
  'Who here looks innocent but is not?',
  'What is your most ridiculous lie?',
  'Who here would you least want reading your drafts?',
];

const _unhingedDare = [
  'Show the group your most recent safe photo.',
  'Let the group choose a harmless post caption for you.',
  'Read a safe note from your notes app dramatically.',
  'Let someone scroll your emojis for 5 seconds.',
  'Do your most dramatic fake apology.',
  'Let the group rename you for two rounds.',
  'Act out your villain origin story.',
  'Show your last three used emojis.',
  'Let the group choose a fake scandal for you.',
  'Give a courtroom defense for your worst habit.',
  'Let someone choose your next lock screen vibe.',
  'Do a dramatic reenactment of getting exposed.',
  'Read a safe text in your most guilty voice.',
  'Let the group create your warning label.',
  'Pretend you are being interviewed after chaos.',
  'Show your most chaotic safe screenshot if you want, or take a shot.',
  'Let the group vote your most suspicious trait.',
  'Give a roast of yourself.',
  'Act like your phone just betrayed you.',
  'Let the room choose your fake FBI file title.',
  'Do an acceptance speech for “messiest energy.”',
  'Let someone pick a safe truth for you to answer.',
  'Say your last safe search like it is a confession.',
  'Give your best “I can explain” face.',
  'Let the group invent your secret double life.',
  'Read a safe notification like breaking news.',
  'Do a dramatic exit and come back immediately.',
  'Let the group decide who you owe an apology to.',
  'Act like you just saw your ex in public.',
  'Let someone choose your fake villain catchphrase.',
  'Show your most used app category if you want, or take a shot.',
  'Give a one-minute TED Talk on your worst habit.',
  'Let the group decide your chaos ranking.',
  'Pretend to expose yourself, then reveal something harmless.',
  'Do a dramatic phone call with no phone.',
  'Let the room write your fake tabloid headline.',
  'Act like you are hiding a very dumb secret.',
  'Let someone pick your next reaction face.',
  'Give a warning speech about dating you.',
  'Say “I regret nothing” with full confidence.',
];

const _evilTruth = [
  'Who here would hurt you the most if they rejected you?',
  'Which person here gives the biggest fake personality vibe?',
  'Who here would your ex be most jealous of?',
  'Who in this room do you trust the least with a secret?',
  'If you had to secretly date one person here for a year, who would it be?',
  'Who here would be the worst person to catch feelings for?',
  'Which two people here would create the most toxic relationship?',
  'Who here hides their real personality best?',
  'Which person here would you least want seeing your private messages?',
  'Who here has the most dangerous charm?',
  'Who here would you never admit you were jealous of?',
  'Who here could ruin your peace with one text?',
  'Which player would be the hardest to get over?',
  'Who here acts the most innocent but knows exactly what they are doing?',
  'Who here would you trust the least in a messy group chat?',
  'Who here would expose someone by accident?',
  'What is the biggest red flag you ignored because you liked someone?',
  'Who here gives the most mixed signals?',
  'Who here would you avoid if you were trying to make good decisions?',
  'What is one thing you still regret not saying?',
  'Who here would be dangerous to fall for?',
  'Which player do you think has the most hidden drama?',
  'Who here would you not want as an enemy?',
  'Who here would you choose if nobody could judge you?',
  'What is the most honest thing you have not said out loud tonight?',
  'Who here do you think notices more than they admit?',
  'Which person here could make you act out of character?',
  'Who here would be the most trouble in a secret relationship?',
  'What opinion about someone here are you scared to say?',
  'Who here do you think is secretly hard to impress?',
  'Who here would you never let read your old messages?',
  'Who here has the strongest main-character energy for the wrong reasons?',
  'Which player would you trust with a secret, but not with your feelings?',
  'Who here do you think could start drama without trying?',
  'What is a truth about your love life that would change the room?',
  'Who here would you pick for one night of chaos and regret?',
];

const _evilDare = [
  'Send "I almost texted you tonight" to someone.',
  'Let the room choose someone who can ask you one question you must answer honestly.',
  'Call someone and say "I need relationship advice", then hang up.',
  'DM the hottest person in your camera roll with only "interesting".',
  'Let the room pick a contact you must react to with a heart.',
  'Read your last deleted text draft if you have one, or your last unsent message.',
  'Let someone in the room write your next story caption.',
  'Give a sincere compliment to the person you find most attractive here.',
  'Let the group choose one person you must message.',
  'Say who in the room would be the hardest to ignore for a week.',
  'Let the group choose a safe message you send to someone you recently texted.',
  'Give your phone to one player for 30 seconds while they choose one safe photo to show.',
  'Let the room choose who you must sit next to for the next round.',
  'Send "we need to talk" to a friend, then immediately say it was a game.',
  'Let someone ask you one brutal but safe question.',
  'Let the room vote who you should avoid flirting with.',
  'Read your last safe notification like it is evidence.',
  'Give a public apology to the group for your worst vibe.',
  'Let the group choose your next DM opening line.',
  'Tell one player why they are trouble.',
  'Let the room decide who you owe an honest answer to.',
  'Make eye contact with the person you would least want to argue with for 10 seconds.',
  'Let the group rank your flirting style in one word.',
  'Send a harmless voice note saying "I have a confession" to someone.',
  'Let one player choose your contact name for them for the rest of the night.',
  'Tell the room who you would trust least with your phone unlocked.',
  'Let the group choose a photo you can safely show for five seconds.',
  'Give the most dangerous player here a warning label.',
  'Let someone choose one question from your notes or reminders that you must explain.',
  'Say one name in the room and one reason they should scare people.',
  'Let the room choose a player you must protect for the next round.',
  'Text a close friend "I need your honest opinion about me" and read their first reply.',
  'Let the group choose the person you must compliment without making it awkward.',
  'Read the last message you sent, with names hidden if needed.',
  'Let one player rewrite your bio for the next five minutes.',
  'Tell someone here "you are dangerous" and explain why.',
];
