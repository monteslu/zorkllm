"DACT2 - Act II. Scene 1: Whitby (Mina). Scene 2: Purfleet and London
(Seward): Renfield, Lucy's decline, the Carfax raid, the box trail,
Piccadilly."

"====================================================================
ACT II STATE"

<GLOBAL WHITBY-NIGHT 0>     ;"0 first day, 1 storm night, 2 morning after,
                             3 second day, 4 sleepwalk night, 5 done"
<GLOBAL STORM-SEEN <>>
<GLOBAL LOG-READ <>>
<GLOBAL RESCUE-DONE <>>
<GLOBAL SHAWL-ON <>>
<GLOBAL SWALES-TALKED <>>
<GLOBAL TOMBSTONE-READ <>>
<GLOBAL SHARD-KEPT <>>

<GLOBAL DAY2 1>             ;"the September day counter in Purfleet"
<GLOBAL NIGHT2 <>>
<GLOBAL TICKS2 0>
<GLOBAL LUCY-STAGE 0>
<GLOBAL LUCY-DEAD <>>
<GLOBAL LUCY-SAVED <>>
<GLOBAL LUCY-RESOLVED <>>
<GLOBAL WINDOW-SHUT <>>
<GLOBAL GARLIC-SASH <>>
<GLOBAL GARLIC-DOOR <>>
<GLOBAL GARLIC-GRATE <>>
<GLOBAL WREATH-ON <>>
<GLOBAL MOTHER-WARNED <>>
<GLOBAL WATCHING <>>
<GLOBAL WOLF-BEAT <>>
<GLOBAL WOLF-REPELLED <>>
<GLOBAL WOLF-WAITED <>>
<GLOBAL GARLIC-BONUS <>>
<GLOBAL BAND-LOOKED <>>
<GLOBAL SHERRY-SMELLED <>>
<GLOBAL RENFIELD-TIER 0>
<GLOBAL SUGAR-GOT <>>
<GLOBAL FLY-CAUGHT <>>
<GLOBAL PHONO-PLAYED <>>
<GLOBAL COUNCIL-DONE <>>
<GLOBAL RAID-OPEN <>>
<GLOBAL CARFAX-OPEN <>>
<GLOBAL LABELS-READ <>>
<GLOBAL RATS-TURNS 0>
<GLOBAL RATS-ROUTED <>>
<GLOBAL CARFAX-WAFERED <>>
<GLOBAL BLOXAM-TOLD <>>
<GLOBAL PICCADILLY-KNOWN <>>
<GLOBAL PICC-OPEN <>>
<GLOBAL PICC-WAFERED <>>
<GLOBAL DEEDS-READ <>>
<GLOBAL PICC-SCENE 0>
<GLOBAL PICC-STRUCK <>>
<GLOBAL PICC-WARDED <>>
<GLOBAL MINA-ATTACKED <>>
<GLOBAL TOMB-NIGHT-DONE <>>
<GLOBAL COFFIN-OPENED <>>
<GLOBAL BLOOFER-WARNED <>>
<GLOBAL STAKING-DONE <>>
<GLOBAL TOMB-UNLOCKED <>>
<GLOBAL WOOD-STAKE-ASKED <>>

"====================================================================
SCENE 1 - WHITBY"

<GLOBAL PARTY-ON <>>

<ROUTINE PARTY-FOLLOW ()
	 <COND (,PARTY-ON
		<MOVE ,VAN-HELSING ,HERE>
		<MOVE ,GODALMING ,HERE>
		<MOVE ,MORRIS ,HERE>
		<FSET ,VAN-HELSING ,NDESCBIT>
		<FSET ,GODALMING ,NDESCBIT>
		<FSET ,MORRIS ,NDESCBIT>)>>

<ROUTINE ACT2-PLAIN-FCN (RARG)
	 <ACT2-COMMON .RARG>>

<ROUTINE ACT2-COMMON (RARG)
	 <COND (<EQUAL? .RARG ,M-ENTER> <PARTY-FOLLOW>)>
	 <COND (<EQUAL? .RARG ,M-BEG>
		<COND (<AND <VERB? WAIT SLEEP> <EQUAL? ,ACT 2>>
		       <WHITBY-ADVANCE>
		       <RTRUE>)
		      (<AND <VERB? WAIT> <EQUAL? ,ACT 3>>
		       <PURFLEET-WAIT>
		       <RTRUE>)
		      (<AND <VERB? SLEEP> <EQUAL? ,ACT 3>>
		       <PURFLEET-WAIT>
		       <RTRUE>)>)>
	 <RFALSE>>

<ROUTINE WHITBY-ADVANCE ()
	 <COND (<EQUAL? ,WHITBY-NIGHT 0>
		<SETG WHITBY-NIGHT 1>
		<STORM-NIGHT>)
	       (<EQUAL? ,WHITBY-NIGHT 1>
		<SETG WHITBY-NIGHT 2>
		<TELL CR
"Ninth of August. Morning, and the sea lying flat and innocent as a
mirror, as if it had done nothing at all in the night. Down at Tate
Hill Pier there is a crowd, and the masts of a ship where no ship
should be." CR>)
	       (<EQUAL? ,WHITBY-NIGHT 2>
		<SETG WHITBY-NIGHT 3>
		<TELL CR
"The day goes by in tea and talk of the wreck. Lucy is restless; twice
you find her at the window, looking east." CR>)
	       (<OR <EQUAL? ,WHITBY-NIGHT 3> <EQUAL? ,WHITBY-NIGHT 4>>
		<SLEEPWALK-NIGHT>)
	       (T
		<TELL
"Time enough has passed here. What remains is a telegram, and it will
not come faster for waiting." CR>)>>

<ROUTINE STORM-NIGHT ()
	 <TELL CR
"Eighth of August. The sun goes down in a bank of cloud the colour of an
old bruise, and by ten the storm is on the town like a hand coming down.
Out of the fog a schooner runs for the harbour under all her sail, and
every soul on the pier holds their breath -- and she takes the sand at
Tate Hill Pier at a leap, and an immense dog bounds up from her hold and
is gone into the dark of the churchyard." CR CR
"They find her helmsman lashed to the wheel, head fallen on his breast,
dead these two days, and a crucifix bound about his hands and the
spokes. The searchlight sweeps the deck and finds nothing else alive."
CR>
	 <SETG STORM-SEEN T>
	 <FCLEAR ,SCHOONER ,INVISIBLE>
	 <FCLEAR ,DEAD-CAPTAIN ,INVISIBLE>
	 <FCLEAR ,CAPTAINS-LOG ,INVISIBLE>
	 <FCLEAR ,CART-TRACKS ,INVISIBLE>>

<ROUTINE SLEEPWALK-NIGHT ()
	 <SETG WHITBY-NIGHT 4>
	 ;"Put her on the seat now, not in the churchyard's M-LOOK: on a
	 revisit the room prints its short form and never runs it."
	 <MOVE ,LUCY ,CHURCHYARD>
	 <FCLEAR ,LUCY ,NDESCBIT>
	 <PUTP ,LUCY ,P?LDESC
"Lucy lies half reclining on the seat, asleep, in her nightdress.">
	 <COND (<EQUAL? ,HERE ,CRESCENT-BEDROOM>
		<TELL CR
"Eleventh of August, three in the morning. You wake because the room is
wrong: the door of the room is open, and Lucy's bed is empty, and her
dress and shoes are where she left them. Out of the window, on the
East Cliff, on her favourite seat above the town, something white
sits, and something long and black bends over it." CR CR
"You take what is at hand and run, and the town is a maze of steps and
sleeping windows, and the two-mile way is longer than any road in your
life." CR>)
	       (T
		<TELL CR
"The night comes down without Lucy in it. You look up at the East Cliff
and there is a white figure on the seat above the town, and something
bending over it, and you run." CR>)>>

<ROUTINE CRESCENT-BEDROOM-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<TELL
"The room you share with Lucy at the Crescent. The window looks over the
harbour to the East Cliff, where the abbey stands against the sky like a
memory. The stairs lead down to the door.">
		<COND (<EQUAL? ,WHITBY-NIGHT 4>
		       <TELL CR
"Lucy's bed is empty, and the covers thrown back, and her dress and
shoes lie where she left them.">)>
		<TELL CR>
		<RTRUE>)
	       (T <ACT2-COMMON .RARG>)>>

<ROUTINE LUCY-BED-W-FCN ()
	 <COND (<VERB? EXAMINE LOOK-INSIDE SEARCH>
		<COND (<EQUAL? ,WHITBY-NIGHT 4>
		       <TELL
"Empty, and the sheets still warm, which is somehow the worst detail of
all." CR>)
		      (T
		       <TELL
"Lucy's bed, beside your own. She has walked in her sleep since she was
a child; her mother locks the doors, and Lucy finds them anyway." CR>)>
		<RTRUE>)
	       (<VERB? THROUGH CLIMB-ON BOARD SLEEP>
		<WHITBY-ADVANCE>
		<RTRUE>)>>

<ROUTINE CRESCENT-WINDOW-FCN ()
	 <COND (<VERB? LOOK-OUT LOOK-INSIDE EXAMINE>
		<COND (<EQUAL? ,WHITBY-NIGHT 4>
		       <TELL
"Across the harbour, on the East Cliff, a half-reclining white figure on
Lucy's favourite seat -- and behind it, bending over it, something long
and black. Then a cloud crosses the moon, and there is only the abbey,
and the wind." CR>)
		      (<EQUAL? ,WHITBY-NIGHT 1>
		       <TELL
"Rain going sideways, and the sea standing up in the harbour mouth like
something trying to get in." CR>)
		      (T
		       <TELL
"Red roofs below, the harbour, the pier with its lighthouse, and beyond
the water the East Cliff with the abbey on it, noble and ruined. The sea
is grey and there is a queer stillness in the air, the kind the
fishermen do not like." CR>)>
		<RTRUE>)
	       (<VERB? OPEN CLOSE>
		<TELL "The sash goes up and down as sashes do." CR>
		<RTRUE>)>>

<ROUTINE SHAWL-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"Your big heavy shawl, the practical one. A girl in a nightdress on a
cliff in August at three in the morning will want it." CR>
		<RTRUE>)
	       (<AND <VERB? PUT PUT-ON HANG> <EQUAL? ,PRSI ,LUCY>>
		<SHAWL-ON-LUCY>
		<RTRUE>)
	       (<AND <VERB? GIVE> <EQUAL? ,PRSI ,LUCY>>
		<SHAWL-ON-LUCY>
		<RTRUE>)>>

<ROUTINE SHAWL-ON-LUCY ()
	 <COND (<NOT <EQUAL? ,HERE ,CHURCHYARD>>
		<TELL "Lucy is not here to be wrapped in it." CR>
		<RTRUE>)
	       (,SHAWL-ON
		<TELL "She is wrapped already." CR>)
	       (T
		<SETG SHAWL-ON T>
		<MOVE ,SHAWL ,LUCY>
		<TELL
"You throw the shawl about her and draw the edges together at her
throat. She is cold as the stone she sits on, and asleep, and her
breath comes in long heavy gasps, as though she were trying to get her
lungs full at every breath. The shawl will not hold itself shut." CR>)>>

<ROUTINE SAFETY-PIN-FCN ()
	 <COND (<AND <VERB? PIN> <NOT ,PRSI>>
		<PIN-THE-SHAWL>
		<RTRUE>)
	       (<AND <VERB? PIN PUT TIE> <EQUAL? ,PRSI ,SHAWL ,LUCY>>
		<PIN-THE-SHAWL>
		<RTRUE>)>>

<ROUTINE PIN-THE-SHAWL ()
	 <COND (<NOT <EQUAL? ,HERE ,CHURCHYARD>>
		<TELL "There is nothing here that wants pinning." CR>
		<RTRUE>)
	       (<NOT ,SHAWL-ON>
		<TELL
"Pin what to what? She wants covering first." CR>
		<RTRUE>)
	       (,RESCUE-DONE
		<TELL "It is pinned." CR>
		<RTRUE>)
	       (T
		<SETG RESCUE-DONE T>
		<MOVE ,SAFETY-PIN ,BANK>
		<AWARD 5>
		<TELL
"You pin the shawl at her throat with the big safety pin, and in your
haste, or your clumsiness, or the dark, you must have pricked her: she
gives a small sound and puts her hand up to her neck, still sleeping.
Afterwards, in the light, there are two little red points on her
throat, and a drop of blood on the band of her nightdress, and you
apologise for that pin a hundred times in a week." CR CR
"Then she wakes, and shivers, and clings to you, and does not know how
she came there. You put your own shoes on her feet, and daub your bare
feet with mud so that no one who meets you will look twice, and take
her home through the grey beginning of the day." CR>
		<RESCUE-COMPLETE>)>>

<ROUTINE RESCUE-COMPLETE ()
	 <SETG WHITBY-NIGHT 5>
	 <MOVE ,LUCY ,BANK>
	 <SETG SHAWL-ON <>>
	 <TELL CR
"Nineteenth of August. A telegram, and then a letter, and the summer
folds up like a deck chair. Jonathan is found -- alive, in a hospital
at Buda-Pesth, brain-fevered, with a journal he begs you never to read
unless you must. You go to him, and you marry him there, and Lucy
writes that she is quite well again, only tired, only a little pale."
CR CR
"-- From the diary of Dr. John Seward, kept in phonograph. Purfleet,
September. --" CR CR
"You are John Seward, doctor of medicine, keeper of a lunatic asylum,
and a man who was refused, kindly, by Lucy Westenra in May. Your
friend Arthur is engaged to her. Your patient Renfield has begun to
keep accounts. And the great house next door, empty these many years,
has been bought by a foreign gentleman." CR CR>
	 <SETG ACT 3>
	 <BANK-ALL>
	 <SETG DAY2 1>
	 <SETG NIGHT2 <>>
	 <SETG TICKS2 0>
	 <MOVE ,VAN-HELSING ,BANK>
	 <SETG HERE ,STUDY>
	 <MOVE ,WINNER ,HERE>
	 <SETG LIT T>
	 <V-FIRST-LOOK>>

<ROUTINE WEST-CLIFF-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<TELL
"The paved walk above the harbour. Below, red roofs piled anyhow like a
picture of Nuremberg, and one long granite pier curving into the sea
with a lighthouse at its elbow. The Crescent door is behind you; the way
down to the drawbridge is east.">
		<COND (<EQUAL? ,WHITBY-NIGHT 4>
		       <TELL CR
"Across the water, on the East Cliff, something white sits on the seat
above the town.">)>
		<TELL CR>
		<RTRUE>)
	       (T <ACT2-COMMON .RARG>)>>

<ROUTINE HARBOUR-G-FCN ()
	 <COND (<VERB? EXAMINE>
		<COND (,STORM-SEEN
		       <TELL
"The harbour, and at Tate Hill Pier the wreck of the schooner lying
over on the sand with her masts raking the sky." CR>)
		      (T
		       <TELL
"The harbour lies between the cliffs like a hand's cupped water: red
roofs, the granite pier, the lighthouse at its elbow, and out beyond,
a sea too flat and too grey for August." CR>)>
		<RTRUE>)>>

<ROUTINE ABBEY-RUIN-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<TELL
"A noble ruin of immense size, all empty windows and broken arches. They
say a white lady shows herself in one of them. The wind talks here, and
the churchyard is north.">
		<COND (,STORM-SEEN
		       <TELL CR
"In the dew of the grass, prints: not a dog's, though they are a dog's
shape. They are too large, and they go toward the churchyard.">)>
		<TELL CR>
		<RTRUE>)
	       (T <ACT2-COMMON .RARG>)>>

<ROUTINE CHURCHYARD-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<TELL
"Tombstones lean over the town where the cliff has fallen away, and
walks and seats thread the graves, and the harbour glitters far below.
Lucy's favourite seat rests on a flat tombstone. The steps go down.">
		<COND (<AND <EQUAL? ,WHITBY-NIGHT 4> <NOT ,RESCUE-DONE>>
		       <TELL CR>
		       <COND (<NOT <IN? ,LUCY ,CHURCHYARD>>
			      <MOVE ,LUCY ,CHURCHYARD>
			      <TELL
"Lucy is half reclining on the seat, her head laid back, and over her
something long and black bends -- and as you cry out it lifts a white
face with red gleaming eyes, and then there is nothing bending over her
at all, and no one on the walk, and the moonlight is only moonlight.">)
			     (T
			      <TELL
"Lucy lies back on the seat, asleep, her lips parted, breathing in long
heavy gasps.">)>)>
		<TELL CR>
		<RTRUE>)
	       (T <ACT2-COMMON .RARG>)>>

<ROUTINE SUICIDE-SEAT-FCN ()
	 <COND (<VERB? READ EXAMINE>
		<COND (<NOT ,TOMBSTONE-READ>
		       <SETG TOMBSTONE-READ T>
		       <AWARD 2>)>
		<TELL
"The seat rests on a flat tombstone. Sacred to the memory of George
Canon, who died in the hope of a glorious resurrection, on the
twenty-ninth of July, eighteen hundred and seventy-three, falling from
the rocks at Kettleness. This tomb was erected by his sorrowing mother
to her dearly beloved son. He was the only son of his mother, and she
was a widow. Mr. Swales will tell you, if you let him, that the young
man threw himself off those rocks to spite her." CR>
		<RTRUE>)
	       (<VERB? SIT-DOWN SIT-ON CLIMB-ON BOARD>
		<TELL
"You sit where Lucy sits, above the whole town, and understand why she
comes." CR>
		<RTRUE>)>>

<ROUTINE SWALES-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"Old Mr. Swales, of Whitby, aged nearly a hundred, with a face knotted
like a tree-root and no patience at all for lies cut in stone." CR>
		<RTRUE>)
	       (<VERB? TELL HELLO>
		<COND (<NOT ,SWALES-TALKED>
		       <SETG SWALES-TALKED T>
		       <AWARD 1>)>
		<TELL
"\"Yabblins! There be a vast o' lies written on them steans. Full o'
lies, and the whole thing only a pack o' vanities. Wheer be they now?\"
He knocks the tombstone with his stick, companionably. \"But I be not
afraid o' dyin', not a bit; on'y I don't want to die if I can help it.
My time is nigh at hand. Death be all that I can be sure of.\" He looks
out at the sea and stops smiling. \"There's something in that wind and
that haze out yonder that sounds, and looks, and tastes, and smells
like death.\"" CR>
		<RTRUE>)>>

<ROUTINE TATE-HILL-PIER-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<COND (,STORM-SEEN
		       <TELL
"A tongue of sand and gravel under the East Cliff. The schooner lies
where she leapt, driven high on the sand with all sail set, her timbers
groaning as the tide leaves her. A track of cart-wheels goes away from
her side up the shore. The steps are south." CR>)
		      (T
		       <TELL
"A tongue of sand and gravel beneath the East Cliff, where the boats
come in. The steps are south. There is nothing here today but gulls and
the smell of tar." CR>)>
		<RTRUE>)
	       (T <ACT2-COMMON .RARG>)>>

<ROUTINE SCHOONER-FCN ()
	 <COND (<VERB? EXAMINE LOOK-INSIDE SEARCH BOARD THROUGH>
		<TELL
"The Demeter, of Varna, run in from the Black Sea with a cargo of silver
sand and fifty great wooden boxes of mould, consigned to a solicitor at
Whitby. Her crew are gone -- all of them, one by one, on the voyage --
and the only thing that came ashore alive went into the churchyard on
four feet." CR>
		<RTRUE>)>>

<ROUTINE DEAD-CAPTAIN-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"He is lashed to the wheel with his own hands bound over the spokes,
and between the palms and the wood is a crucifix, the beads wound round
both wrists. He has been dead two days, and he brought his ship in." CR>
		<RTRUE>)
	       (<VERB? TAKE>
		<COND (<EQUAL? ,PRSO ,DEAD-CAPTAIN>
		       <TELL "Let the dead keep what held the dead safe." CR>)
		      (T
		       <TELL "Let the dead keep what held the dead safe." CR>)>
		<RTRUE>)>>

<ROUTINE CAPTAINS-LOG-FCN ()
	 <COND (<VERB? READ EXAMINE>
		<COND (<NOT ,LOG-READ>
		       <SETG LOG-READ T>
		       <AWARD 3>)>
		<TELL
"The log of the Demeter, out of Varna, in a hand that gets worse.
Sixteenth of July: one of the crew missing. Bulgarin gone, said the
mate, and no man saw him go. Twenty-fourth: another gone; the men are
in a panic and go about two together. Twenty-eighth: four days in hell,
and only five hands left. Second of August: another gone at midnight
between two bells, and the man at the wheel screaming." CR CR
"Third of August: the mate came to me wild-eyed. 'It is here; I know it
now. On the watch last night I saw It, like a man, tall and thin and
ghastly pale.' He went below with a knife, and came up backwards, and
went over the rail rather than stay. I am captain, and it is my duty to
stay by my ship, and I will tie my hands to the wheel, and with them
that which He -- It -- dare not touch. Then whether I be man or
madman, God and the Blessed Virgin shall judge. The log goes on for
one line more: 'If we are wrecked, mayhap this bottle may be found.'"
CR>
		<RTRUE>)>>

<ROUTINE CART-TRACKS-FCN ()
	 <COND (<VERB? EXAMINE FOLLOW>
		<TELL
"Deep wheel-ruts in the sand, going away up the shore. Fifty great
boxes came out of that hold before the customs men had properly waked,
and a carrier from Whitby took them to the railway, and the railway
took them to London. It is all perfectly regular. You will remember
this later, and be sick." CR>
		<RTRUE>)>>

"====================================================================
SCENE 2 - PURFLEET AND LONDON

The Purfleet clock. Days advance by WAIT/SLEEP at night, or by the
dusk tick cap; each dusk runs the Lucy check. ACT is 3 through all of
Act II scene 2 (the journal-header acts and the ACT global do not have
to agree; ACT 1 castle, 2 Whitby, 3 Purfleet, 4 the chase)."

<ROUTINE PURFLEET-WAIT ()
	 <COND (,NIGHT2 <P2-DAWN>)
	       (T <P2-DUSK>)>>

<ROUTINE ACT3-PLAIN-FCN (RARG)
	 <ACT2-COMMON .RARG>>

<ROUTINE I-PURFLEET ()
	 <COND (<NOT <EQUAL? ,ACT 3>> <RFALSE>)>
	 ;"Rooms with their own M-ENTER branches never reach ACT2-COMMON,
	 so the party is re-seated from the clock instead: one place that
	 always runs, every turn, whatever the room does."
	 <PARTY-FOLLOW>
	 <SETG TICKS2 <+ ,TICKS2 1>>
	 <COND (<G? ,TICKS2 40>
		<COND (,NIGHT2 <P2-DAWN>) (T <P2-DUSK>)>
		<RTRUE>)>
	 <RFALSE>>

<ROUTINE P2-DUSK ()
	 <SETG NIGHT2 T>
	 <SETG TICKS2 0>
	 <TELL CR "The light goes off the lawn. Evening." CR>
	 <COND (<AND <NOT ,LUCY-RESOLVED> <G? ,DAY2 1>>
		<LUCY-NIGHT>)
	       (<AND ,MINA-ATTACKED <NOT ,PICC-OPEN>>
		<RRTRUE>)>
	 <RTRUE>>

<ROUTINE RRTRUE () <RTRUE>>

<ROUTINE P2-DAWN ()
	 <SETG NIGHT2 <>>
	 <SETG TICKS2 0>
	 <SETG DAY2 <+ ,DAY2 1>>
	 <SETG WATCHING <>>
	 <SETG WOLF-BEAT <>>
	 <TELL CR "Morning, the ">
	 <P2-DATE>
	 <TELL " of September." CR>
	 <COND (<AND <NOT ,LUCY-RESOLVED> <G? ,DAY2 2>>
		<LUCY-DAWN-REPORT>)>
	 <COND (<AND ,RAID-OPEN <NOT ,MINA-ATTACKED> ,CARFAX-WAFERED>
		<MINA-ATTACK-SCENE>)>
	 <RTRUE>>

<ROUTINE P2-DATE ()
	 <COND (<EQUAL? ,DAY2 1> <TELL "eleventh">)
	       (<EQUAL? ,DAY2 2> <TELL "twelfth">)
	       (<EQUAL? ,DAY2 3> <TELL "thirteenth">)
	       (<EQUAL? ,DAY2 4> <TELL "seventeenth">)
	       (<EQUAL? ,DAY2 5> <TELL "eighteenth">)
	       (<EQUAL? ,DAY2 6> <TELL "nineteenth">)
	       (<EQUAL? ,DAY2 7> <TELL "twentieth">)
	       (T <TELL "thirtieth">)>>

"---- Study, phonograph, brandy, safe ----"

<ROUTINE STUDY-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<TELL
"Your study at the asylum: the phonograph with its wax cylinders, a
locked safe, a case-bottle of brandy, and a window giving on the
grounds. The corridor is east.">
		<COND (<IN? ,VAN-HELSING ,STUDY>
		       <TELL CR
"Van Helsing is here, filling the room the way weather does.">)>
		<TELL CR>
		<RTRUE>)
	       (T <ACT2-COMMON .RARG>)>>

<ROUTINE PHONOGRAPH-FCN ()
	 <COND (<VERB? READ EXAMINE PLAY LISTEN LAMP-ON>
		<COND (<NOT ,PHONO-PLAYED>
		       <SETG PHONO-PLAYED T>
		       <AWARD 1>)>
		<TELL
"The cylinder turns and your own voice comes out of the horn, dry and
tired and honest, and tells you where you stand." CR CR>
		<PHONO-RECAP>
		<RTRUE>)>>

<ROUTINE PHONO-RECAP ()
	 <COND (,LUCY-DEAD
		<TELL
"\"Lucy Westenra is dead, and buried at Kingstead, and something walks
that churchyard at night that the newspapers call the Bloofer Lady.
Van Helsing says the work must be finished before it can be begun.\""
CR>)
	       (,LUCY-SAVED
		<TELL
"\"Lucy Westenra lives, and mends. Van Helsing says: the first gain is
ours. The next is the house next door, and the earth in it.\"" CR>)
	       (T
		<TELL
"\"Miss Westenra is ill at Hillingham and no examination shows why. The
professor's orders, which I set down exactly: the window shut at
sundown; the garlic flowers rubbed on the sash, on the door, on the
fireplace; the wreath about her neck; and someone by her all night.\""
CR>)>
	 <COND (<AND ,LUCY-RESOLVED <NOT ,CARFAX-WAFERED>>
		<TELL CR
"\"Mem.: the boxes of earth. Fifty came from Varna. Twenty-nine are
next door. The rest are somewhere in London, and he is in all of
them.\"" CR>)>
	 <COND (<AND ,CARFAX-WAFERED <NOT ,PICC-WAFERED>>
		<TELL CR
"\"Mem.: twenty-nine sterilised. Twenty-one at large. The carrier
Bloxam knows where nine of them went; there are labels on a bunch of
keys; and Arthur is a lord, which in London is a skeleton key of its
own.\"" CR>)>>

<ROUTINE STUDY-SAFE-FCN ()
	 <COND (<VERB? EXAMINE OPEN LOOK-INSIDE UNLOCK>
		<TELL
"Your safe, and in it the typed copy Mina made of every paper we have:
her journal, Jonathan's, mine, the professor's. She typed it three
times over in manifold, and one copy sleeps here, because the
professor says that he who reads our record must find it whole." CR>
		<RTRUE>)>>

<ROUTINE BRANDY-FCN ()
	 <COND (<VERB? DRINK>
		<TELL
"A doctor's measure, no more, and it does exactly what brandy does: it
makes the next hour possible and the one after worse." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A case-bottle of brandy for the patients, or the doctor, whichever
gives way first." CR>
		<RTRUE>)>>

"---- Renfield ----"

<ROUTINE RENFIELD-CELL-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<TELL
"A bare room smelling of sugar and something older. Flies stitch the
sunbeam, and the window, screwed shut, looks toward the trees of the
neighbouring park. The corridor is south.">
		<COND (<EQUAL? ,RENFIELD-TIER 4>
		       <TELL CR
"The room is empty now, and scrubbed, and it will not stop smelling of
sugar.">)
		      (T
		       <TELL CR
"Renfield is here.">)>
		<TELL CR>
		<RTRUE>)
	       (T <ACT2-COMMON .RARG>)>>

<ROUTINE FLY-FCN ()
	 <COND (<VERB? TAKE CATCH>
		<COND (,FLY-CAUGHT
		       <TELL "You have a fly. One is plenty." CR>)
		      (T
		       <SETG FLY-CAUGHT T>
		       <MOVE ,FLY ,WINNER>
		       <TELL
"You cup your hand over a fat bluebottle on the pane and take it, alive
and indignant, and feel foolish, and keep it anyway." CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A fat blue fly, buzzing in the sunbeam. To you, a fly. To the man in
this room, a life, and one unit of arithmetic." CR>
		<RTRUE>)
	       (<VERB? EAT>
		<TELL
"You are the doctor here. That is precisely the distinction under
discussion." CR>
		<RTRUE>)>>

<ROUTINE RENFIELD-FCN ()
	 <COND (<VERB? EXAMINE>
		<COND (<EQUAL? ,RENFIELD-TIER 4>
		       <TELL
"He lies where they found him, face down on the floor in a pool of
blood, his back broken and the left side of his face crushed. He is
still talking." CR>)
		      (T
		       <TELL
"A big man of sixty, sanguine, morbidly excitable, with periods of
gloom. He is on his knees at the moment, in a sunbeam, adding a column
of figures with his lips moving, and his hands are cupped over
something. He is, in his own account, a zoophagous maniac: he eats
lives." CR>)>
		<RTRUE>)
	       (<AND <VERB? GIVE> <EQUAL? ,PRSO ,FLY>>
		<RENFIELD-GIFT 1>
		<RTRUE>)
	       (<AND <VERB? GIVE> <EQUAL? ,PRSO ,SUGAR>>
		<RENFIELD-GIFT 2>
		<RTRUE>)
	       (<AND <VERB? GIVE> <EQUAL? ,PRSO ,NOTEBOOK>>
		<RENFIELD-GIFT 3>
		<RTRUE>)
	       (<VERB? SHOW>
		<TELL
"He looks at it, and through it, and goes back to his sums." CR>
		<RTRUE>)
	       (<VERB? TELL HELLO>
		<RENFIELD-TALK>
		<RTRUE>)
	       (<VERB? ATTACK SIMPLE-KILL>
		<TELL
"He is a patient, and you are his doctor, and that is the whole of the
argument." CR>
		<RTRUE>)>>

<ROUTINE RENFIELD-GIFT (TIER)
	 <COND (<NOT <EQUAL? .TIER <+ ,RENFIELD-TIER 1>>>
		<COND (<L? .TIER <+ ,RENFIELD-TIER 1>>
		       <TELL
"He has had that of you already, and the account is settled." CR>)
		      (T
		       <TELL
"He takes it and turns it over and hands it back. \"Not yet, doctor.
There is an order to things. You would not have me eat the pudding
first.\"" CR>)>
		<RTRUE>)>
	 <SETG RENFIELD-TIER .TIER>
	 <AWARD 3>
	 <COND (<EQUAL? .TIER 1>
		<MOVE ,FLY ,BANK>
		<TELL
"He takes the fly with enormous delicacy, considers it, and eats it,
and his whole face clears like weather. \"The blood is the life!\" he
says. \"The blood is the life!\" Then, confidentially, as one
professional to another: \"You will see, doctor. I shall not need to
be mad much longer.\" You write it down, and the professor, when he
reads it, will go very quiet." CR>)
	       (<EQUAL? .TIER 2>
		<MOVE ,SUGAR ,BANK>
		<TELL
"He takes the sugar and sets it out on the sill in a careful line, to
bring the flies, to bring the spiders, to bring the sparrows. Then he
leans close, and the madness goes out of his voice altogether. \"He is
at hand. The Master. In the house of the chapel, in his boxes of holy
earth. Count the boxes, doctor -- He counts them.\"" CR>)
	       (T
		<MOVE ,NOTEBOOK ,BANK>
		<TELL
"He takes the little notebook back like a man taking back his own name,
and holds it against his chest. \"Don't keep me here, doctor. You don't
know what you do, keeping me here.\" His eyes are perfectly sane.
\"He can come in only if he is asked. That is the law, and it is the
only law He keeps. The mad and the sleeping ask so easily. I asked.
God forgive me, I asked, for what He promised me.\"" CR>)>>

<ROUTINE RENFIELD-TALK ()
	 <COND (<EQUAL? ,RENFIELD-TIER 4>
		<TELL
"\"It was the fog. He came in on the fog, and I asked Him in, and He
promised me lives -- rats and rats and rats, a great red mass of them
with life in their eyes. And then He took her instead.\" He looks for
you with an eye that will not open. \"I told you, doctor. I did what I
could.\"" CR>
		<RTRUE>)>
	 <COND (<EQUAL? ,RENFIELD-TIER 0>
		<TELL
"\"I don't want to talk to you,\" he says, not unkindly. \"You don't
count for anything now. The Master is at hand.\" He goes back to his
column of figures. He is adding lives, and the sum is himself." CR>)
	       (<EQUAL? ,RENFIELD-TIER 1>
		<TELL
"\"Flies, doctor. Flies eat sugar. Spiders eat flies. Sparrows eat
spiders. And what eats sparrows?\" He waits, politely, for you to work
it out, and when you do not, he loses interest in you." CR>)
	       (<EQUAL? ,RENFIELD-TIER 2>
		<TELL
"\"Count the boxes,\" he says. \"That is all the doctoring wanted.\"
Then, in an entirely different voice, small: \"Take me away, doctor.
Send me away in a strait-waistcoat, chains, a gaol -- only take me out
of this house.\"" CR>)
	       (T
		<TELL
"\"I am a sane man fighting for his soul,\" he says, quite level. \"Hear
me. Hear me!\" And then the fit takes him, and the attendants come, and
you are in the corridor with the door shut and your own diary to
answer to." CR>)>>

<ROUTINE NOTEBOOK-FCN ()
	 <COND (<VERB? READ EXAMINE>
		<TELL
"Columns of little numbers, added and added again, each total carried
forward and squared: flies to spiders, spiders to sparrows, sparrows
to something the page does not name. It is confiscated property, and
it is the most careful piece of work in this building, mine included."
CR>
		<RTRUE>)>>

<ROUTINE SUGAR-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"A twist of white sugar from the kitchen. Currency, in this house." CR>
		<RTRUE>)>>

<ROUTINE CELL-WINDOW-FCN ()
	 <COND (<VERB? EXAMINE LOOK-OUT>
		<TELL
"Screwed shut, and looking east over the wall to the heavy trees of
Carfax. Every patient in this wing looks west. This one looks east."
CR>
		<RTRUE>)
	       (<VERB? OPEN>
		<TELL "Screwed shut, and it stays so." CR>
		<RTRUE>)>>

"---- Guest room, Mina, Jonathan ----"

<ROUTINE GUEST-ROOM-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<TELL
"The room given to Jonathan and Mina: a bed by the window, her
typewriter on the table, his kukri knife on the mantel. A married
couple's tidy courage. The corridor is west.">
		<COND (<IN? ,MINA ,GUEST-ROOM>
		       <TELL CR "Mina is at the typewriter.">)>
		<TELL CR>
		<RTRUE>)
	       (T <ACT2-COMMON .RARG>)>>

<ROUTINE MINA-FCN ()
	 <COND (<VERB? EXAMINE>
		<COND (,MINA-ATTACKED
		       <TELL
"Mina Harker, with the red scar of the Wafer on her white forehead, and
a steadiness about her that shames every man in this house." CR>)
		      (T
		       <TELL
"Mina Harker: she has man's brain, and woman's heart, and a memory for
railway timetables that the professor calls a gift from God and Jonathan
calls the train fiend." CR>)>
		<RTRUE>)
	       (<VERB? TELL HELLO>
		<COND (,MINA-ATTACKED
		       <TELL
"\"Unclean,\" she says, and then, seeing your face: \"No. Not that
voice. I shall not use it again.\" She sets her hand on the typescript.
\"Read me everything. All of it. I will not be shut out to be
protected; that is how he got in.\"" CR>)
		      (T
		       <TELL
"\"I am transcribing,\" she says, \"and when it is all in one order, you
will see the shape of it. That is all any of us can do: put the papers
in order.\"" CR>)>
		<RTRUE>)>>

<ROUTINE JONATHAN-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"Jonathan Harker, solicitor, of Exeter: white-haired at thirty, and
quiet, and no longer troubled by whether he was mad, because the
professor has read his journal and said it is all true." CR>
		<RTRUE>)
	       (<VERB? TELL HELLO>
		<TELL
"\"I know the house,\" he says. \"I did the conveyancing.\" He says it
the way another man would confess a crime. \"When the time comes, I
should like to be the one.\"" CR>
		<RTRUE>)>>

<ROUTINE KUKRI-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"A great Gurkha knife, curved and heavy and beautifully kept.
Jonathan's; he bought it in a shop off the Strand and has never once
explained why." CR>
		<RTRUE>)>>

"---- Grounds, ladder, wall ----"

<ROUTINE ASYLUM-GROUNDS-FCN (RARG)
	 <ACT2-COMMON .RARG>>

<ROUTINE LADDER-FCN ()
	 <COND (<VERB? TAKE MOVE PUSH>
		<COND (,RAID-OPEN
		       <TELL
"The ladder is already against the wall; the party went over it before
you." CR>)
		      (T
		       <TELL
"You could set the garden ladder against the wall -- and be a doctor
climbing into his neighbour's garden at night with no warrant and no
reason he could say aloud. Not yet. Not alone." CR>)>
		<RTRUE>)>>

<ROUTINE GROUNDS-EAST ()
	 <COND (,RAID-OPEN
		<COND (<EQUAL? ,HERE ,ASYLUM-GROUNDS> <RETURN ,CARFAX-LAWN>)
		      (T <RETURN ,ASYLUM-GROUNDS>)>)
	       (<EQUAL? ,HERE ,CARFAX-LAWN> <RETURN ,ASYLUM-GROUNDS>)
	       (T
		<TELL
"The wall is twelve feet if it is an inch, and the far side is another
man's property, and you are a respectable physician. When there are
five of you, and a warrant of another kind, it will be different." CR>
		<RFALSE>)>>

"---- Hillingham and Lucy ----"

<ROUTINE HILLINGHAM-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-ENTER>
		<COND (<AND <EQUAL? ,DAY2 1> <NOT ,COUNCIL-DONE>
			    <NOT ,LUCY-RESOLVED>
			    <NOT <IN? ,VAN-HELSING ,HILLINGHAM>>>
		       <FIRST-HILLINGHAM-SCENE>
		       <RTRUE>)>
		<RFALSE>)
	       (<EQUAL? .RARG ,M-LOOK>
		<TELL
"The Westenra hall: flowers, good furniture, and a stillness that has
learned to listen for a sickroom bell. The road is east; Lucy's room is
up.">
		<COND (<IN? ,VAN-HELSING ,HILLINGHAM>
		       <TELL CR "Van Helsing is here, waiting on you.">)>
		<TELL CR>
		<RTRUE>)
	       (T <ACT2-COMMON .RARG>)>>

<ROUTINE FIRST-HILLINGHAM-SCENE ()
	 <MOVE ,VAN-HELSING ,HILLINGHAM>
	 <MOVE ,LUCY ,LUCYS-ROOM>
	 <MOVE ,GARLIC ,WINNER>
	 <MOVE ,WREATH ,WINNER>
	 ;"The professor issues a crucifix with the flowers: the wolf night
	 is unwinnable without one and it is his first instruction."
	 <MOVE ,CRUCIFIX ,WINNER>
	 <TELL CR
"Van Helsing has come from Amsterdam by the night train because you
wired him, and he has looked at Lucy for three minutes without saying
anything, and now he takes you out onto the landing and shuts the
door." CR CR
"\"Friend John. There is blood gone out of that girl and no wound to
let it out by, and no disease in her to spend it. There must be
transfusion of blood at once, or she die.\" It is done before noon:
Arthur's blood, and Arthur white with pride and terror, and Lucy rosy
for the first time in a week." CR CR
"Then the professor sets a great box on the table and opens it, and the
room fills with a smell like a Dutch kitchen. Garlic flowers, brought
from Haarlem by wire and rail. \"You think I am a mad old man. Perhaps.
Now attend, for I say it once and then I say it every night until you
weary of me. At sundown: the window shut. The flowers rubbed on the
sash, and on the door, and on the fireplace -- every whiff of air that
enter, it must pass the flower. And this wreath about her neck, and she
shall not take it off. And someone by her in the night.\"" CR CR
"He presses a little silver crucifix into your hand as you go, and does
not explain it, and does not smile." CR>>

<ROUTINE MRS-WESTENRA-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"Lucy's mother: a kind, frightened woman with a heart the professor says
will not bear a shock, and which he therefore never tells anything to."
CR>
		<RTRUE>)
	       (<AND <VERB? TELL SHOW GIVE>
		     <OR <EQUAL? ,PRSI ,GARLIC ,WREATH>
			 <EQUAL? ,PRSO ,GARLIC ,WREATH>>>
		<COND (,MOTHER-WARNED
		       <TELL "She has promised, and she keeps promises." CR>)
		      (T
		       <SETG MOTHER-WARNED T>
		       <AWARD 3>
		       <TELL
"You explain, gravely, and without one word of the truth, that the
flowers are medicine: strange, foreign, sovereign, and on no account to
be moved. She looks at you the way she used to look at Lucy's governess.
\"Then they shall stay, doctor, though the room smells like a
public-house cellar. You would not laugh at me if you knew how little
I sleep.\"" CR>)>
		<RTRUE>)
	       (<VERB? TELL HELLO>
		<TELL
"\"She is better this morning, I think. Don't you think she is better?\"
It is not really a question, and you are not really a doctor here, and
you say yes." CR>
		<RTRUE>)>>

<ROUTINE MAIDS-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"Four good maids, who will do anything for Miss Lucy, and who are, at
this moment, very sleepy indeed." CR>
		<RTRUE>)
	       ;"SUGAR is not in scope in this room, so the parser can never
	       bind it as PRSI; any request to the maids yields it. Same for
	       plain TALK TO MAIDS, which is what a player actually types."
	       (<VERB? ASK-FOR TELL HELLO TAKE SEARCH>
		<COND (<NOT ,SUGAR-GOT>
		       <GET-SUGAR>)
		      (T
		       <TELL
"\"Yes, doctor. No, doctor.\" They are frightened, and they are being
brave about it in the servants' hall, where it costs more." CR>)>
		<RTRUE>)>>

<ROUTINE GET-SUGAR ()
	 <COND (,SUGAR-GOT
		<TELL "You have your sugar." CR>)
	       (T
		<SETG SUGAR-GOT T>
		<MOVE ,SUGAR ,WINNER>
		<TELL
"A twist of sugar from the kitchen, and no questions asked, which in a
madhouse is a kind of professional courtesy." CR>)>>

<ROUTINE SHERRY-FCN ()
	 <COND (<VERB? SMELL EXAMINE>
		<COND (<AND <G? ,DAY2 3> <NOT ,SHERRY-SMELLED>>
		       <SETG SHERRY-SMELLED T>
		       <AWARD 2>
		       <TELL
"You take out the stopper and put your nose to it, and stand very still.
Laudanum. Someone has drugged the servants' sherry, and the servants
drank it, and slept, and heard nothing at all in the night. Someone was
in this house who could not be seen to be in it." CR>)
		      (T
		       <TELL
"A decanter of sherry on the sideboard, the household's small evening
kindness to itself." CR>)>
		<RTRUE>)>>

<ROUTINE LUCYS-ROOM-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<TELL
"A pretty bedroom trying to stay one: the bed, the fireplace, and the
window on the shrubbery, its latch bright with use. On the air,
sometimes, a beating of wings.">
		<COND (<IN? ,LUCY ,LUCYS-ROOM>
		       <TELL CR>
		       <LUCY-CONDITION>)>
		<TELL CR>
		<RTRUE>)
	       (<EQUAL? .RARG ,M-END>
		;"The wolf beat is printed at dusk, which is itself inside a
		turn: closing it on that same M-END would end the scene
		before the player ever got to answer it. One full turn of
		grace, then it withdraws."
		<COND (<AND ,WOLF-BEAT <NOT ,WOLF-REPELLED>>
		       <COND (,WOLF-WAITED <WOLF-CLOSES>)
			     (T <SETG WOLF-WAITED T>)>)>
		<RFALSE>)
	       (T <ACT2-COMMON .RARG>)>>

<ROUTINE LUCY-CONDITION ()
	 <COND (,LUCY-SAVED
		<TELL
"Lucy sits up against the pillows with colour in her cheeks and an
appetite, and complains, at length, about the smell of the flowers.">)
	       (<EQUAL? ,LUCY-STAGE 0>
		<TELL
"Lucy lies against the pillows, pale but rosy at the lips, and smiles
at you as though you were the one who wanted nursing.">)
	       (<EQUAL? ,LUCY-STAGE 1>
		<TELL
"Lucy is asleep, and paler than yesterday. Her breathing is heavy, and
her lips are drawn back a little from her teeth in a way you do not
write down in your notes.">)
	       (T
		<TELL
"Lucy lies white as the sheet, and her gums are drawn back from the
teeth so that they look longer and sharper than teeth should, and she
does not wake when you take her wrist.">)>>

<ROUTINE LUCY-FCN ()
	 <COND (<AND <EQUAL? ,ACT 2> <EQUAL? ,HERE ,CHURCHYARD>>
		<RETURN <WHITBY-LUCY-FCN>>)>
	 <COND (<AND <EQUAL? ,ACT 3> <EQUAL? ,HERE ,KINGSTEAD>>
		<RETURN <BLOOFER-FCN>>)>
	 <COND (<VERB? EXAMINE>
		<LUCY-CONDITION>
		<TELL CR>
		<RTRUE>)
	       (<VERB? WATCH WATCH>
		<KEEP-WATCH>
		<RTRUE>)
	       (<AND <VERB? PUT PUT-ON HANG GIVE>
		     <EQUAL? ,PRSO ,WREATH ,GARLIC>>
		<PUT-WREATH>
		<RTRUE>)
	       (<VERB? TELL HELLO>
		<COND (,LUCY-SAVED
		       <TELL
"\"Am I to wear these dreadful flowers for ever, Doctor Seward? Arthur
says I smell like a chophouse.\" She laughs, and the laugh is the
whole reward of your profession." CR>)
		      (<G? ,LUCY-STAGE 1>
		       <TELL
"She half wakes, and her voice is not quite her own: soft, and slow,
and voluptuous, and asking to be kissed. Then it is her own again, and
frightened, and she says: \"Don't let them take the flowers away.\"" CR>)
		      (T
		       <TELL
"\"I am quite well, only tired, and I dream. Do you know, I dream that
I am walking, and then something taps at the window like a great bird,
and then it is morning.\"" CR>)>
		<RTRUE>)>>

<ROUTINE WHITBY-LUCY-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"Lucy, in her nightdress, half reclining on the seat, fast asleep, her
head thrown back and her breath coming in long heavy gasps. There is a
white face and something dark at the edge of your memory of the last
half-minute, and you refuse to look at it." CR>
		<RTRUE>)
	       (<AND <VERB? PUT PUT-ON HANG GIVE> <EQUAL? ,PRSO ,SHAWL>>
		<SHAWL-ON-LUCY>
		<RTRUE>)
	       (<VERB? PIN>
		<PIN-THE-SHAWL>
		<RTRUE>)
	       (<VERB? ALARM TELL HELLO>
		<COND (,RESCUE-DONE
		       <TELL
"She is awake, and shivering, and holding onto you." CR>)
		      (T
		       <TELL
"She does not wake. She is cold, and half naked, and two miles from her
bed, and shaking her is not the first thing wanted." CR>)>
		<RTRUE>)
	       (<VERB? TAKE MOVE>
		<TELL
"You will not carry her two miles down a hundred and ninety-nine steps.
Cover her first." CR>
		<RTRUE>)>>

<ROUTINE PUT-WREATH ()
	 <COND (<NOT <IN? ,LUCY ,LUCYS-ROOM>>
		<TELL "Lucy is not here." CR>
		<RTRUE>)
	       (,WREATH-ON
		<TELL "The wreath is about her neck already." CR>
		<RTRUE>)
	       (T
		<SETG WREATH-ON T>
		<MOVE ,WREATH ,LUCY>
		<TELL
"You lay the wreath of garlic flowers about her neck and close it. She
wrinkles her nose, and then breathes in deeply, and something in her
face lets go. \"Peace in its smell,\" she says, half asleep, and
sleeps like a child." CR>)>>

<ROUTINE LUCY-WINDOW-FCN ()
	 <COND (<VERB? CLOSE LOCK>
		<COND (,WINDOW-SHUT
		       <TELL "It is shut and latched." CR>)
		      (T
		       <SETG WINDOW-SHUT T>
		       <FCLEAR ,LUCY-WINDOW ,OPENBIT>
		       <TELL
"You shut the sash and turn the latch. The room is close at once, and
the close air is the price, and it is a cheap one." CR>)>
		<RTRUE>)
	       (<VERB? OPEN>
		<SETG WINDOW-SHUT <>>
		<FSET ,LUCY-WINDOW ,OPENBIT>
		<TELL
"You open the window. Night air, and the shrubbery, and something
moving in it that is probably the wind." CR>
		<RTRUE>)
	       (<AND <VERB? RUB-ON RUB PUT PUT-ON>
		     <OR <EQUAL? ,PRSO ,GARLIC> <EQUAL? ,PRSI ,GARLIC>>>
		<RUB-GARLIC 1>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A sash window on the shrubbery, its latch worn bright with use.">
		<COND (,GARLIC-SASH
		       <TELL
" The sash and the frame are smeared and stuck with crushed white
blossom, and the whole frame reeks.">)>
		<TELL CR>
		<RTRUE>)
	       (<VERB? LOOK-OUT>
		<TELL
"The shrubbery, black and moving, and above it a piece of moon. Once,
for a moment, two small red points of light at the level of a tall
man's eyes -- and then a bat, or a leaf, or nothing." CR>
		<RTRUE>)>>

<ROUTINE LUCY-DOOR-FCN ()
	 <COND (<AND <VERB? RUB-ON RUB PUT PUT-ON>
		     <OR <EQUAL? ,PRSO ,GARLIC> <EQUAL? ,PRSI ,GARLIC>>>
		<RUB-GARLIC 2>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"The bedroom door, and the jamb of it">
		<COND (,GARLIC-DOOR
		       <TELL ", greasy and white with crushed garlic">)>
		<TELL "." CR>
		<RTRUE>)>>

<ROUTINE FIREPLACE-FCN ()
	 <COND (<AND <VERB? RUB-ON RUB PUT PUT-ON>
		     <OR <EQUAL? ,PRSO ,GARLIC> <EQUAL? ,PRSI ,GARLIC>>>
		<RUB-GARLIC 3>
		<RTRUE>)
	       (<VERB? EXAMINE LOOK-INSIDE SEARCH>
		<TELL
"A small bedroom grate, swept and cold">
		<COND (,GARLIC-GRATE
		       <TELL ", and stopped about with garlic blossom">)>
		<TELL
". A chimney is a door, the professor says, and he says it in the voice
he uses for things he has seen." CR>
		<RTRUE>)>>

<ROUTINE RUB-GARLIC (WHICH)
	 <COND (<NOT <OR <HELD? ,GARLIC> <IN? ,GARLIC ,HERE>>>
		<TELL "You have no garlic." CR>
		<RTRUE>)>
	 <COND (<EQUAL? .WHICH 1>
		<COND (,GARLIC-SASH
		       <TELL "The sash is done, and reeks of it." CR>
		       <RTRUE>)>
		<SETG GARLIC-SASH T>
		<TELL
"You rub the white blossoms along the sash and the frame and into the
joint of the latch, as the professor showed you: so, and so. Every
whiff of air that enters must pass the flower." CR>)
	       (<EQUAL? .WHICH 2>
		<COND (,GARLIC-DOOR
		       <TELL "The door is done." CR>
		       <RTRUE>)>
		<SETG GARLIC-DOOR T>
		<TELL
"You rub the garlic over the door and the jamb and the keyhole, and
feel like a fool, and go on doing it thoroughly, which is the correct
professional response to feeling like a fool." CR>)
	       (T
		<COND (,GARLIC-GRATE
		       <TELL "The fireplace is done." CR>
		       <RTRUE>)>
		<SETG GARLIC-GRATE T>
		<TELL
"You rub the flowers about the grate and lay a handful in the cold ash.
A chimney is a door." CR>)>
	 <COND (<AND ,GARLIC-SASH ,GARLIC-DOOR ,GARLIC-GRATE
		     <NOT ,GARLIC-BONUS>>
		<SETG GARLIC-BONUS T>
		<AWARD 1>
		<TELL
"All three ways are stopped. The room smells like a Dutch kitchen and
is, for tonight, a fortress." CR>)>>

"---- The kit: garlic, wreath, the Host ----"

<ROUTINE GARLIC-FCN ()
	 <COND (<AND <VERB? RUB-ON RUB PUT PUT-ON>
		     <EQUAL? ,PRSI ,LUCY-WINDOW>>
		<RUB-GARLIC 1>
		<RTRUE>)
	       (<AND <VERB? RUB-ON RUB PUT PUT-ON>
		     <EQUAL? ,PRSI ,LUCY-DOOR>>
		<RUB-GARLIC 2>
		<RTRUE>)
	       (<AND <VERB? RUB-ON RUB PUT PUT-ON>
		     <EQUAL? ,PRSI ,FIREPLACE>>
		<RUB-GARLIC 3>
		<RTRUE>)
	       (<AND <VERB? PUT PUT-ON HANG GIVE> <EQUAL? ,PRSI ,LUCY>>
		<PUT-WREATH>
		<RTRUE>)
	       (<AND <VERB? THROW THROW-AT> <WOLF-BEAT-ACTIVE?>>
		<WOLF-REPELLED-NOW>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"White garlic blossom, a great armful of it, sent from Haarlem by wire
and rail and arriving fresher than the fish. The professor treats these
weeds like a pharmacopoeia, and he is right to." CR>
		<RTRUE>)
	       (<VERB? SMELL>
		<TELL
"Garlic, overwhelmingly, and under it something clean and green. Peace
in its smell, Lucy says." CR>
		<RTRUE>)
	       (<VERB? EAT>
		<TELL
"You are not the one who needs protecting from the inside." CR>
		<RTRUE>)>>

<ROUTINE WREATH-FCN ()
	 <COND (<AND <VERB? PUT PUT-ON HANG GIVE> <EQUAL? ,PRSI ,LUCY>>
		<PUT-WREATH>
		<RTRUE>)
	       (<AND <VERB? THROW THROW-AT> <WOLF-BEAT-ACTIVE?>>
		<WOLF-REPELLED-NOW>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A wreath of the garlic flowers, plaited by the professor's own thick
fingers with a delicacy that surprised everybody in the room." CR>
		<RTRUE>)>>

<ROUTINE WAFER-FCN ()
	 <COND (<AND <VERB? PUT PUT-ON>
		     <EQUAL? ,PRSI ,CARFAX-BOXES>>
		<WAFER-CARFAX>
		<RTRUE>)
	       (<AND <VERB? PUT PUT-ON>
		     <EQUAL? ,PRSI ,PICC-BOXES>>
		<WAFER-PICC>
		<RTRUE>)
	       (<AND <VERB? PUT PUT-ON>
		     <EQUAL? ,PRSI ,GREAT-TOMB>>
		<RETURN <GREAT-TOMB-FCN>>)
	       (<AND <VERB? PUT PUT-ON> <EQUAL? ,PRSI ,HOLY-CIRCLE>>
		<DRAW-THE-CIRCLE>
		<RTRUE>)
	       (<AND <VERB? PUT PUT-ON> <EQUAL? ,PRSI ,CHAPEL-DOOR>>
		<SEAL-THE-CASTLE>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A plain envelope, and in it the Host, which the professor has by an
Indulgence from Amsterdam and will not be questioned about. You have
carried a great many things in your coat in your life. Nothing has ever
weighed like this." CR>
		<RTRUE>)
	       (<VERB? EAT DROP THROW BURN>
		<TELL
"No. Whatever you believe on a Sunday, you will not waste that." CR>
		<RTRUE>)>>

<ROUTINE VELVET-BAND-FCN ()
	 <COND (<VERB? EXAMINE MOVE LOOK-UNDER TAKE OPEN>
		<COND (<NOT ,BAND-LOOKED>
		       <SETG BAND-LOOKED T>
		       <AWARD 2>)>
		<TELL
"She wears a black velvet band about her throat, with an old diamond
buckle Arthur gave her; and when you lift it, there on the neck, just
over the jugular, are two little punctures, not healthy-looking, with
no sign of disease, and the edges of them white and worn as though
something had worried at them." CR>
		<RTRUE>)>>

"---- The Lucy night machine ----"

<ROUTINE DEFENCE-COUNT ("AUX" (N 0))
	 <COND (,GARLIC-SASH <SET N <+ .N 1>>)>
	 <COND (,GARLIC-DOOR <SET N <+ .N 1>>)>
	 <COND (,GARLIC-GRATE <SET N <+ .N 1>>)>
	 .N>

<ROUTINE DEFENCES-OK? ()
	 <AND ,WINDOW-SHUT ,WREATH-ON <G? <DEFENCE-COUNT> 1>>>

<GLOBAL WOLF-NIGHT-DONE <>>

<ROUTINE LUCY-NIGHT ()
	 ;"The wolf is the LAST night, and it arrives when the player is
	 ready for it rather than on a fixed date: day four or later, OR
	 any night the player has chosen to keep vigil. Keying it to an
	 exact day made the whole climax depend on having typed exactly
	 the right number of WAITs, which is not a puzzle, only a trap."
	 <COND (<AND <NOT ,WOLF-NIGHT-DONE>
		     <OR <G? ,DAY2 3> ,WATCHING>>
		<SETG WOLF-NIGHT-DONE T>
		<LUCY-NIGHT-WOLF>
		<RTRUE>)>
	 <COND (<AND <EQUAL? ,DAY2 3> <NOT ,MOTHER-WARNED>>
		<TELL CR
"In the small hours Mrs. Westenra looks in on her daughter, and finds
the room stifling and hung with weeds, and does what any loving mother
would: she takes the wreath from Lucy's neck and throws up the window
to let in God's good air. She does it out of love. It is the only door
he needed." CR>
		<SETG WREATH-ON <>>
		<SETG WINDOW-SHUT <>>
		<MOVE ,WREATH ,WINNER>
		<LUCY-DECLINE 1>
		<RTRUE>)>
	 <COND (<DEFENCES-OK?>
		<TELL CR
"The window is shut, the flowers are on the sash, the wreath is at her
throat. Something is at the pane in the night, and finds no way in, and
the dust of the shrubbery path is scuffed in the morning in a shape you
do not care to measure. Lucy sleeps through it all, and wakes better."
CR>)
	       (T
		<LUCY-DECLINE 1>)>>

<ROUTINE LUCY-NIGHT-WOLF ()
	 <COND (<NOT <DEFENCES-OK?>>
		<TELL CR
"The defences are not made, and this is the night he does not knock."
CR>
		<LUCY-DECLINE 2>
		<RTRUE>)
	       (<NOT ,WATCHING>
		<TELL CR
"Somewhere over Hampstead, a wolf is loose from the Zoological
Gardens -- the papers will make a comedy of it in the morning. In the
night, at Hillingham, a great grey head comes through Lucy's window in
a burst of glass, and there is nobody in the room but her mother, whose
heart is not strong, and who dies of the fright with her arms around
her daughter. The flowers are scattered on the floor by a hand that is
not the wolf's, and the window stands open on the night." CR>
		<LUCY-DECLINE 2>
		<RTRUE>)
	       (T
		<SETG WOLF-BEAT T>
		<MOVE ,WOLF ,LUCYS-ROOM>
		<FCLEAR ,WOLF ,INVISIBLE>
		<TELL CR
"Midnight, and you are in the chair by the bed with your eyes open, and
the flapping begins at the pane: soft, insistent, patient, like
something being polite. Then the whole window bursts inward in a storm
of glass and a great gaunt grey head is in the room, red-eyed, filling
the broken frame, and Lucy sits up with a cry. It does not come in. It
is looking at you, and waiting for something -- for a scream, for a
faint, for an invitation." CR>)>>

<ROUTINE WOLF-BEAT-ACTIVE? ()
	 <AND ,WOLF-BEAT <NOT ,WOLF-REPELLED>>>

<ROUTINE WOLF-CLOSES ()
	 <SETG WOLF-BEAT <>>
	 <MOVE ,WOLF ,BANK>
	 <TELL CR
"You do nothing, or nothing that counts, and the head withdraws of its
own accord, unhurried, as a caller leaves a card. In the morning the
window is open, the flowers are in the grate, and Lucy is whiter than
the sheet." CR>
	 <LUCY-DECLINE 2>>

<ROUTINE WOLF-REPELLED-NOW ()
	 <SETG WOLF-REPELLED T>
	 <SETG WOLF-BEAT <>>
	 <MOVE ,WOLF ,BANK>
	 <AWARD 3>
	 <TELL
"You hold it up between the thing and the bed, and your hand does not
shake, which surprises you for the rest of your life. The great gaunt
grey head withdraws. Little specks of dust swirl in at the broken pane
and find no way further, and turn back on the air as though the
threshold were a wall of glass. Then the shrubbery is only shrubbery."
CR CR
"You board the pane with the fire-screen and sit by her until morning,
and in the morning Lucy is better, and asks for breakfast, and
complains about the flowers." CR>>

<ROUTINE KEEP-WATCH ()
	 <COND (<NOT <EQUAL? ,HERE ,LUCYS-ROOM>>
		<TELL "There is nothing to watch here." CR>
		<RTRUE>)
	       (,LUCY-RESOLVED
		<TELL
"You sit with her a while. The vigil is over; this is only company." CR>
		<RTRUE>)
	       (T
		;"WATCH LUCY means 'keep this vigil', not 'burn one turn':
		it sets the flag and then runs the clock forward to the
		next dusk, so the player who says it always gets a whole
		guarded night. Without this the wolf night depended on the
		player having typed exactly the right number of WAITs."
		<SETG WATCHING T>
		<TELL
"You draw the chair to the bedside, and take out your notebook, and do
not use it. This is the whole of medicine tonight: to be in the room."
CR>
		<COND (,NIGHT2 <P2-DAWN>)>
		<COND (<NOT ,LUCY-RESOLVED> <P2-DUSK>)>
		<RTRUE>)>>

<ROUTINE LUCY-DECLINE (N)
	 <SETG LUCY-STAGE <+ ,LUCY-STAGE .N>>
	 <COND (<G? ,LUCY-STAGE 2>
		<LUCY-DIES>)>>

;"Lucy is only decided once the wolf night has actually been played,
not merely once the calendar has run out."
<ROUTINE LUCY-DAWN-REPORT ()
	 <COND (<AND ,WOLF-NIGHT-DONE <NOT ,LUCY-RESOLVED>>
		<COND (<L? ,LUCY-STAGE 3>
		       <LUCY-LIVES>)>)>>

<ROUTINE LUCY-LIVES ()
	 <SETG LUCY-SAVED T>
	 <SETG LUCY-RESOLVED T>
	 <AWARD 15>
	 <TELL CR
"Van Helsing comes at eight, and takes her pulse, and looks at her
gums, and sits down rather suddenly on the end of the bed. \"The first
gain is ours!\" he says. \"Check to the King!\" And then, because he is
what he is, he goes out onto the landing and cries like a child, and
comes back in laughing, and calls it King Laugh, and tells you that it
is the only thing that keeps a man from going mad in a house like this."
CR>
	 <MOVE ,WREATH ,LUCY>
	 <COUNCIL-SCENE>>

<ROUTINE LUCY-DIES ()
	 <SETG LUCY-DEAD T>
	 <SETG LUCY-RESOLVED T>
	 <MOVE ,LUCY ,BANK>
	 <MOVE ,MEMORANDUM ,BANK>
	 <TELL CR
"-- From the diary of Dr. Seward, the twentieth of September. --" CR CR
"She dies at daybreak, and there are two voices in the room at the end.
One is Lucy's, and it asks Arthur to kiss her, in a tone soft and
voluptuous that he has never heard from her and never will forget, and
the professor takes him by the neck and hauls him back with a strength
nobody knew he had. Then the other voice, her own, her true one, at the
very last: \"My true friend, and his. Guard him, and give me peace.\""
CR CR
"An hour after, her face is beautiful in a way it never was living, and
the professor stands looking at her with his hands behind his back.
\"It is not the end,\" he says. \"It is only the beginning.\" You think
him monstrous. In four days you will apologise." CR>
	 <COUNCIL-SCENE>>

"---- The council, the kit, the raid ----"

<ROUTINE COUNCIL-SCENE ()
	 <SETG COUNCIL-DONE T>
	 <MOVE ,VAN-HELSING ,BANK>
	 <MOVE ,LUCY ,BANK>
	 <TELL CR
"That evening the professor puts five chairs in your study and lectures
until two in the morning, and no one interrupts him twice." CR CR
"\"The nosferatu do not die like the bee when he sting once. He is
strong of twenty men; he command the wolf and the rat and the bat; he
can grow small, or vanish in the mist; he throw no shadow, and make no
reflect in the mirror. But he cannot enter anywhere at the first,
unless there be some one of the household who bid him come. He cannot
pass running water at the slack or the flood of the tide. He must sleep
in the earth of his own place, in his boxes, and he is powerless in the
day. Garlic he flee; the crucifix and the Sacred Wafer he cannot abide;
and the branch of wild rose on his box he cannot leave it. Sterilise
his earth, and he have nowhere to lay him down, and then we take him at
our leisure -- as a fox in his hole.\"" CR CR
"He opens a case on your desk and issues it out like a sergeant: a
crucifix for each man, a wreath of garlic, a revolver and a knife, an
electric lamp for the breast, and to each an envelope of the Sacred
Wafer, which he has by an Indulgence from Amsterdam and will not
discuss. \"To-night, the house next door. Fifty boxes came from Varna.
Let us see how many are still at home.\"" CR>
	 <SETG RAID-OPEN T>
	 ;"From here the party moves as one: PARTY-FOLLOW keeps the three
	 hunters in whatever room you are in, so ASK GODALMING works
	 anywhere without the room-lister reading a phone book (they stay
	 NDESCBIT and are narrated in prose)."
	 <SETG PARTY-ON T>
	 <PARTY-FOLLOW>
	 <MOVE ,BEER ,WINNER>
	 <MOVE ,SHILLINGS ,WINNER>
	 <MOVE ,NOTEBOOK ,WINNER>
	 ;"Jonathan lends the kukri when the party forms; the design lets
	 the player strike personally at Piccadilly if they carry it."
	 <MOVE ,KUKRI ,WINNER>
	 <MOVE ,CRUCIFIX ,WINNER>
	 <MOVE ,WAFER ,WINNER>
	 <MOVE ,GARLIC ,WINNER>
	 <MOVE ,SKELETON-KEYS ,WINNER>
	 <MOVE ,ELECTRIC-LAMP ,WINNER>
	 <MOVE ,WHISTLE ,WINNER>
	 <MOVE ,WOOD-STAKE ,WINNER>
	 <MOVE ,HAMMER ,WINNER>
	 <MOVE ,TURNSCREW ,WINNER>
	 <MOVE ,MISSAL ,WINNER>
	 <MOVE ,VAN-HELSING ,BANK>>

"---- Carfax ----"

<ROUTINE CARFAX-LAWN-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<TELL
"Twenty acres of black pond and older trees around a house of all
periods, part of it a keep with barred windows high up. Against it
leans a chapel of old times. The place holds its breath. The asylum
wall is west; the front door is north." CR>
		<RTRUE>)
	       (T <ACT2-COMMON .RARG>)>>

<ROUTINE CARFAX-IN ()
	 <COND (,CARFAX-OPEN <RETURN ,CARFAX-HALL>)
	       (T
		<TELL "The front door is locked." CR>
		<RFALSE>)>>

<ROUTINE CARFAX-DOOR-FCN ()
	 <COND (,CARFAX-OPEN
		<COND (<VERB? OPEN EXAMINE>
		       <TELL "It stands open on the dust of the hall." CR>
		       <RTRUE>)>
		<RFALSE>)>
	 <COND (<OR <AND <VERB? UNLOCK OPEN PICK>
			 <OR <NOT ,PRSI> <EQUAL? ,PRSI ,SKELETON-KEYS>>>
		    <AND <VERB? TURN> <EQUAL? ,PRSI ,SKELETON-KEYS>>>
		<COND (<HELD? ,SKELETON-KEYS>
		       <SETG CARFAX-OPEN T>
		       <FSET ,CARFAX-DOOR ,OPENBIT>
		       <AWARD 2>
		       <TELL
"A surgeon's fingers and a burglar's tools. After a little play the
bolt shoots back with a rusty clang, and the door swings in on air that
has not been breathed since the Tudors, and something under that which
has." CR>)
		      (T
		       <TELL
"Massive oak, iron-bound, and older than the Union. Your shoulder is
not the instrument. Something in the way of a key is wanted." CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A great oak door, iron-bound, with an old rusty lock that has not
turned in a generation -- except, plainly, lately." CR>
		<RTRUE>)>>

<ROUTINE CARFAX-HALL-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<TELL
"Dust lies inches deep, torn by hobnailed footprints, and cobwebs hang
like old rags from the beams. On a table lies a great bunch of keys,
every one with a time-yellowed label. The chapel is east, through a low
arched door ribbed with iron." CR>
		<RTRUE>)
	       (T <ACT2-COMMON .RARG>)>>

<ROUTINE KEY-BUNCH-FCN ()
	 <COND (<VERB? READ EXAMINE>
		<COND (<NOT ,LABELS-READ>
		       <SETG LABELS-READ T>
		       <SETG PICCADILLY-KNOWN T>
		       <AWARD 5>)>
		<TELL
"A great bunch of old keys, each with a label in a clerk's hand, all
yellowed but one. Chicksand Street, Mile End New Town. Jamaica Lane,
Bermondsey. And one label newer than the rest, the ink hardly grey: a
house in Piccadilly." CR>
		<RTRUE>)>>

<ROUTINE CARFAX-CHAPEL-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-ENTER>
		<COND (<NOT ,RATS-ROUTED>
		       <SETG RATS-TURNS 1>
		       <FCLEAR ,RATS ,INVISIBLE>
		       <TELL CR
"The smell arrives before the sight of it: earth, and blood, and
something worse, as though corruption had itself become corrupt. You
count the great boxes by the lamp: twenty-nine. Twenty-nine, out of
fifty." CR CR
"Then Morris swings his lamp at the far wall and swears, and the wall
moves. It is not a wall. Along the floor, on the boxes, over the beams,
a mass of phosphorescence twinkles like stars in a black sky: the whole
place is becoming alive with rats, and they are not running away." CR>)>
		<RFALSE>)
	       (<EQUAL? .RARG ,M-LOOK>
		<TELL
"A chapel of old times, high and dark, its floor deep in earth. Great
wooden boxes stand in the gloom. The hall is west; the outer door
south is bolted." CR>
		<RTRUE>)
	       (<EQUAL? .RARG ,M-END>
		<COND (<AND <G? ,RATS-TURNS 0> <NOT ,RATS-ROUTED>>
		       <RATS-ADVANCE>)>
		<RFALSE>)
	       (T <ACT2-COMMON .RARG>)>>

<ROUTINE RATS-ADVANCE ()
	 <SETG RATS-TURNS <+ ,RATS-TURNS 1>>
	 <COND (<EQUAL? ,RATS-TURNS 2>
		<TELL CR
"The rats come on, and the sound of them is the worst part: not
squeaking but a dry rushing, like grain poured out of a sack. Godalming
has his hand in his pocket. \"I brought the dogs up to the wall,\" he
says. \"Someone had better call them.\" He puts a little silver whistle
into your hand." CR>
		<MOVE ,WHISTLE ,WINNER>)
	       (<EQUAL? ,RATS-TURNS 3>
		<TELL CR
"They are on the boxes now, and on the sills, and the light of the
lamps is doubled and doubled again in ten thousand small red eyes.
Nobody in this chapel is going to do any careful work with his hands."
CR>)
	       (T
		<TELL CR
"The rats swarm and turn and do not quite come, as though something
were holding them on a leash and enjoying the length of it. Blow the
whistle." CR>)>>

<ROUTINE RATS-FCN ()
	 <COND (<VERB? EXAMINE COUNT>
		<TELL
"Thousands. Tens of thousands. A living carpet with eyes in it, and
every eye turned one way: at you." CR>
		<RTRUE>)
	       (<VERB? ATTACK SIMPLE-KILL>
		<TELL
"You might as well fight the tide with a walking-stick." CR>
		<RTRUE>)>>

<ROUTINE WHISTLE-FCN ()
	 <COND (<VERB? BLOWOBJ BREATHE>
		<COND (<NOT <EQUAL? ,HERE ,CARFAX-CHAPEL>>
		       <TELL
"You blow the little silver whistle, and somewhere a dog puts its head
on one side, and nothing else happens." CR>
		       <RTRUE>)
		      (,RATS-ROUTED
		       <TELL "The rats are gone. The dogs are pleased." CR>
		       <RTRUE>)
		      (T
		       <SETG RATS-ROUTED T>
		       <MOVE ,RATS ,BANK>
		       <AWARD 2>
		       <TELL
"You blow, and the note is thin and hardly a sound at all, and then
three white shapes come over the sill of the outer door like water over
a weir: the terriers, professional, joyous, entirely without fear. The
carpet of rats breaks and drains away into the walls as though someone
had pulled a plug, and in ten seconds the chapel is only a filthy room
with boxes in it, and three dogs are having the evening of their
lives." CR>)>)
	       (<VERB? EXAMINE>
		<TELL
"Lord Godalming's little silver dog-whistle, which has summoned better
company than most titles." CR>
		<RTRUE>)>>

<ROUTINE CARFAX-BOXES-FCN ()
	 <COND (<VERB? COUNT EXAMINE>
		<COND (,CARFAX-WAFERED
		       <TELL
"Twenty-nine boxes, each with its lid prised back and a portion of the
Host laid in the earth. Whatever else they are now, they are not beds."
CR>)
		      (T
		       <TELL
"Great wooden boxes of new deal, ranked in the dark on the chapel
floor, each filled with earth that came out of a graveyard in
Transylvania. You count them twice, because the number matters:
twenty-nine. Twenty-nine, out of fifty." CR>)>
		<RTRUE>)
	       (<AND <VERB? PUT PUT> <EQUAL? ,PRSO ,WAFER>>
		<WAFER-CARFAX>
		<RTRUE>)
	       (<VERB? OPEN LOOK-INSIDE SEARCH>
		<TELL
"Earth. Common earth, out of a place that is not common, and pressed
smooth in the middle of each as though something had lain there and
would again." CR>
		<RTRUE>)>>

<ROUTINE WAFER-CARFAX ()
	 <COND (,CARFAX-WAFERED
		<TELL "It is done. They are sterile ground for ever." CR>
		<RTRUE>)
	       (<NOT ,RATS-ROUTED>
		<TELL
"Not with ten thousand eyes watching your hands." CR>
		<RTRUE>)
	       (T
		<SETG CARFAX-WAFERED T>
		<AWARD 10>
		<TELL
"It takes the better part of an hour, and it is the strangest hour of
your professional life: lid by lid, the turnscrew and the crowbar, the
sour breath of the earth coming up, and in each box a portion of the
Host laid in the mould, and the professor saying the words over it in
Latin while Morris holds the lamp. Twenty-nine boxes. When the last lid
goes back the chapel feels like an ordinary filthy room, and everyone
notices at once, and nobody says so." CR CR
"\"Twenty-nine,\" says Van Helsing. \"And fifty came. Friend John, we
must find the other twenty-one before he miss these.\"" CR>
		;"The attack on Mina is canon and follows the raid directly;
		hanging it on the next dawn meant a player who went straight
		on to the box trail could skip the act's turning point."
		<MINA-ATTACK-SCENE>)>>

"---- The box trail ----"

<ROUTINE LONDON-ROAD-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<TELL
"A stretch of road with a cab-stand and a railway station in walking
distance, which is to say: from here the day's errands run. North to
the asylum; west to Hillingham; south to the churchyard at Kingstead;
south-east to the mean streets of Walworth">
		<COND (,PICCADILLY-KNOWN
		       <TELL "; and east to Piccadilly">)>
		<TELL "." CR>
		<RTRUE>)
	       (<EQUAL? .RARG ,M-BEG>
		<COND (<AND <VERB? WALK> <EQUAL? ,PRSO ,P?EAST>
			    <NOT ,PICCADILLY-KNOWN>>
		       <TELL
"East is London, and London is four million people. You would need an
address." CR>
		       <RTRUE>)>
		<ACT2-COMMON .RARG>)
	       (T <ACT2-COMMON .RARG>)>>

<ROUTINE BLOXAM-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"A big carrier with a dusty face and a chest like a beer barrel, who
has been asked questions by gentlemen before and did not care for it."
CR>
		<RTRUE>)
	       (<AND <VERB? GIVE> <EQUAL? ,PRSO ,BEER ,SHILLINGS>>
		<BLOXAM-TALKS>
		<RTRUE>)
	       (<VERB? TELL HELLO>
		<COND (,BLOXAM-TOLD
		       <TELL
"\"Arst me again to-morrow and I'll tell yer the same, guv'nor, an'
thirsty too.\"" CR>)
		      (T
		       <TELL
"\"I ain't got nothin' to say to nobody,\" says Mr. Bloxam, with the
air of a man quoting a favourite author. He looks, however, at the
public-house on the corner, and then at you, in a manner that could
fairly be called instructional." CR>)>
		<RTRUE>)>>

<ROUTINE BLOXAM-TALKS ()
	 <COND (,BLOXAM-TOLD
		<TELL "He has told you, and drunk on it." CR>
		<RTRUE>)>
	 <SETG BLOXAM-TOLD T>
	 <SETG PICCADILLY-KNOWN T>
	 <MOVE ,BEER ,BANK>
	 <AWARD 5>
	 <TELL
"The beer goes down in one long professional swallow and Mr. Bloxam
becomes a different and much better man. \"Them boxes? Nine big 'uns to
a 'ouse off Piccadilly -- a 'igh 'un, stone front with a bow, 'igh steps
up. Old gent 'elped me with 'em, an' 'e took 'is end like they was
pounds o' tea, an' me a-puffin' like a grampus. Cold 'ands, cold as a
tomb-'andle. An' the dust in that 'all, guv'nor -- you could ha' slep'
on it.\"" CR>>

<ROUTINE BEER-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"A bottle of beer, purchased on the professor's account and entered in
his book as an item of research." CR>
		<RTRUE>)>>

"---- Piccadilly ----"

<ROUTINE PICC-STEPS-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<TELL
"A high house with a stone bow front and steps up to the door. Dust
crusts the windows, and behind the area railings is the white scar
where a board reading For Sale was torn away. London flows past
without looking. There is a bench in Green Park opposite." CR>
		<RTRUE>)
	       (T <ACT2-COMMON .RARG>)>>

<ROUTINE PICC-IN ()
	 <COND (,PICC-OPEN <RETURN ,PICCADILLY-HOUSE>)
	       (T
		<TELL
"The door is shut, and this is Piccadilly in the forenoon, with a
policeman at the corner and half the clubs of London at the windows.
Whatever is done here must be done as such things are rightly done."
CR>
		<RFALSE>)>>

<ROUTINE PICC-DOOR-FCN ()
	 <COND (<AND <VERB? UNLOCK OPEN PICK>
		     <NOT ,PICC-OPEN>>
		<TELL
"You have the skeleton keys in your pocket and a constable forty yards
off, and you are a respectable physician with a beard. No. This wants
Arthur, and Arthur's name." CR>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A respectable London front door, with a knocker nobody has polished
for a year and a keyhole that has been used lately." CR>
		<RTRUE>)>>

<ROUTINE GODALMING-FCN ()
	 ;"PRSI's action runs before PRSO's, so WOOD-STAKE-FCN never sees
	 GIVE STAKE TO ARTHUR: Arthur has to accept it himself."
	 <COND (<AND <VERB? GIVE SHOW>
		     <EQUAL? ,PRSO ,WOOD-STAKE ,HAMMER>>
		<THE-STAKING>
		<RTRUE>)>
	 <COND (<VERB? EXAMINE>
		<TELL
"Arthur, Lord Godalming: young, sandy, and lately in mourning, holding
himself together with the particular English glue of having something
to do." CR>
		<RTRUE>)
	       (<AND <VERB? TELL SHOW>
		     <OR <EQUAL? ,PRSI ,PICC-DOOR>
			 <EQUAL? ,PRSO ,PICC-DOOR>>>
		<LOCKSMITH-RUSE>
		<RTRUE>)
	       (<AND <VERB? TELL> <EQUAL? ,PRSI ,RATS>>
		<TELL
"\"Rats?\" He pats his waistcoat pocket. \"I brought the terriers up to
the wall. Blow this and they'll come through anything.\"" CR>
		<MOVE ,WHISTLE ,WINNER>
		<RTRUE>)
	       (<VERB? TELL HELLO>
		<COND (<AND <EQUAL? ,HERE ,PICCADILLY-STEPS>
			    <NOT ,PICC-OPEN>>
		       <LOCKSMITH-RUSE>)
		      (T
		       <TELL
"\"Tell me what to do,\" he says, \"and I will do it. I find I am no
good at all at the thinking part any more.\"" CR>)>
		<RTRUE>)>>

<ROUTINE LOCKSMITH-RUSE ()
	 <COND (,PICC-OPEN
		<TELL "The house is open. The key is in your pocket." CR>
		<RTRUE>)
	       (<NOT <EQUAL? ,HERE ,PICCADILLY-STEPS>>
		<TELL
"\"Show me the house,\" says Godalming, \"and I will get us into it.\""
CR>
		<RTRUE>)
	       (T
		<SETG PICC-OPEN T>
		<AWARD 3>
		<TELL
"Godalming looks at the house, and then at the street, and does the one
thing none of the rest of you could have thought of: he strolls off and
comes back in a four-wheeler with a locksmith in it." CR CR
"The man kneels to the door with the calm of a tradesman on a job,
tries three keys, files a fourth, and has it open in ten minutes; a
constable comes by and looks on with approval at a gentleman putting
his own house in order; the professor tips him half a crown, and the
locksmith hands over a new key and drives away. Not a soul takes the
slightest notice. It is done as such things are rightly done, and at
the time such things are rightly done." CR>)>>

<ROUTINE MORRIS-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"Quincey P. Morris of Texas: long, brown, quiet, and carrying more
edged and loaded objects than anybody has yet counted." CR>
		<RTRUE>)
	       (<VERB? TELL HELLO>
		<TELL
"\"I've seen a bat like that down on the Pampas,\" he says
comfortably, \"one of them big ones that used to get at our horses in
the night, and in the morning they was dead, every one of them, from
just the same cause. Nobody believed me then either.\"" CR>
		<RTRUE>)>>

<ROUTINE VAN-HELSING-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"Abraham Van Helsing, M.D., D.Ph., D.Litt., of Amsterdam: a big
red-faced old man with a great head of red-grey hair, a chin like a
prow, and eyes that go from kindness to steel in the space of a
sentence." CR>
		<RTRUE>)
	       (<VERB? TELL HELLO>
		<VH-TOPICS>
		<RTRUE>)
	       (<VERB? GIVE SHOW>
		<TELL
"He turns it over twice, sniffs it, and hands it back. \"Good. Keep
him. Everything is evidence until it is not.\"" CR>
		<RTRUE>)>>

<ROUTINE VH-TOPICS ()
	 <COND (<EQUAL? ,PRSI ,GARLIC ,WREATH>
		<TELL
"\"The garlic. Rub him on the sash, so; and on the door, and on the
fireplace. Every whiff of air that enter, it must pass the flower. And
about her neck the wreath, and she must not take him off.\"" CR>)
	       (<EQUAL? ,PRSI ,LUCY>
		<COND (,LUCY-DEAD
		       <TELL
"\"She is not dead, friend John. She is Un-Dead, which is worse for
her and worse for the children of Hampstead. We must give her peace,
and it is her Arthur who must do it, for love is the only hand that
may hold that hammer.\"" CR>)
		      (T
		       <TELL
"\"There is blood gone out of her and no wound to let it by. Do not
argue with me, argue with the thermometer. To-night, the window shut,
the flower on the sash, the wreath at her throat, and a friend in the
chair.\"" CR>)>)
	       (<EQUAL? ,PRSI ,WAFER>
		<TELL
"\"The Host. I bring him from Amsterdam, and I have an Indulgence, and
we will not discuss it further. Where his earth is, put him, and that
earth is dead ground to the Un-Dead for ever.\"" CR>)
	       (<EQUAL? ,PRSI ,CARFAX-BOXES ,PICC-BOXES ,CASTLE-BOXES>
		<TELL
"\"Fifty boxes come from Varna. Sterilise them all, and he have
nowhere in all England to lay him down in the day, and then we take
him as we take a fox in his hole.\"" CR>)
	       (<EQUAL? ,PRSI ,DRACULA>
		<TELL
"\"He is clever, oh so clever, but he have the child-brain also. He do
one thing, and then he do it again, and by that we shall have him. And
he fear us -- me he fear, and time he fear, and want he fear.\"" CR>)
	       (<EQUAL? ,PRSI ,RENFIELD>
		<TELL
"\"Your madman is a barometer, friend John. When he is calm, He is far;
when he eat his flies, He is near. Keep the notes. The notes are
sanity.\"" CR>)
	       (<EQUAL? ,PRSI ,GT-RIVER ,RIVER-MAP>
		<RIVER-DEDUCTION>)
	       (<EQUAL? ,PRSI ,MINA>
		<TELL
"\"Madam Mina, she is one of God's women, fashioned by His own hand to
show us men there is a heaven where we can enter. And we have shut her
out of our councils to protect her, and see what our protecting has
done. Never again.\"" CR>)
	       (T
		<TELL
"\"Ah, you ask me that. I do not know all, and I will not guess aloud;
a guess said aloud becomes a fact by morning. Ask me a thing I know.\""
CR>)>>

<ROUTINE PICC-HOUSE-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<TELL
"The dining-room of an empty mansion, and it smells like the chapel at
Carfax. Eight great boxes stand about the floor. On the table: a bundle
of title deeds, a clothes brush, and a jug and basin, the water in the
basin reddened as if with blood, and a little heap of keys of all sorts
and sizes. A window looks down into the mews." CR>
		<RTRUE>)
	       (<EQUAL? .RARG ,M-END>
		<COND (<AND ,PICC-WAFERED <NOT <G? ,PICC-SCENE 0>>>
		       <PICC-TRAP-BEGINS>)
		      (<AND <G? ,PICC-SCENE 0> <L? ,PICC-SCENE 4>>
		       <PICC-SCENE-ADVANCE>)>
		<RFALSE>)
	       (T <ACT2-COMMON .RARG>)>>

<ROUTINE PICC-BOXES-FCN ()
	 <COND (<VERB? COUNT EXAMINE>
		<COND (,PICC-WAFERED
		       <TELL
"Eight boxes, opened and sanctified. Twenty-nine and eight is
thirty-seven; six went to Bermondsey and six to Mile End, which
Godalming and Morris are attending to at this hour. That is
forty-nine." CR>)
		      (T
		       <TELL
"Eight great boxes of the same new deal, the same rope handles, the
same graveyard earth. Bloxam carried nine here. There are eight." CR>)>
		<RTRUE>)
	       (<AND <VERB? PUT PUT> <EQUAL? ,PRSO ,WAFER>>
		<WAFER-PICC>
		<RTRUE>)
	       (<VERB? OPEN LOOK-INSIDE SEARCH>
		<TELL
"Earth, and in one of them the earth is pressed and hollowed in the
shape of a long body." CR>
		<RTRUE>)>>

<ROUTINE WAFER-PICC ()
	 <COND (,PICC-WAFERED
		<TELL "It is done." CR>
		<RTRUE>)
	       (T
		<SETG PICC-WAFERED T>
		<AWARD 8>
		<TELL
"Eight lids, eight portions of the Host, eight boxes turned from beds
into holes in the ground. It goes quicker than Carfax; you are getting
professional at it, and that is its own small horror." CR CR
"A boy comes up the steps with a telegram from Mina at Purfleet, and
Van Helsing reads it and goes the colour of paper. It says: LOOK OUT
FOR D. HE HAS JUST NOW, TWELVE FORTY, COME FROM CARFAX HURRIEDLY AND
HASTENED TOWARDS THE SOUTH. HE MAY BE GOING TO LOOK FOR YOU. MINA." CR>)>>

<ROUTINE DEEDS-FCN ()
	 <COND (<VERB? READ EXAMINE>
		<COND (<NOT ,DEEDS-READ>
		       <SETG DEEDS-READ T>
		       <AWARD 3>)>
		<TELL
"The title deeds of the Piccadilly house, and with them, in a bundle
tied with tape, the deeds and conveyances of the others: Mile End New
Town, Bermondsey, and Carfax at Purfleet. Every lair in England, in a
bundle on a table, because he is a landlord now and landlords keep
their papers. Jonathan's own office drew half of them." CR CR
"Godalming and Morris take the Bermondsey and Mile End addresses
between them and are gone down the steps before anyone can argue. Six
boxes and six boxes. That leaves one." CR>
		<RTRUE>)>>

<ROUTINE JUG-BASIN-FCN ()
	 <COND (<VERB? EXAMINE LOOK-INSIDE>
		<TELL
"A jug, a basin, and a clothes brush, laid out as in any gentleman's
dressing-room. The water in the basin is reddened as if with blood. He
washed here, and brushed his coat, and went out to his day like a man
going to the City." CR>
		<RTRUE>)>>

<ROUTINE MEWS-WINDOW-FCN ()
	 <COND (<VERB? EXAMINE LOOK-OUT>
		<TELL
"A tall window over the stable yard, twenty feet down onto cobbles. No
man could take that drop and walk. It stands unlatched." CR>
		<RTRUE>)>>

<ROUTINE PICC-TRAP-BEGINS ()
	 <SETG PICC-SCENE 1>
	 <MOVE ,DRACULA ,PICCADILLY-HOUSE>
	 <FCLEAR ,DRACULA ,NDESCBIT>
	 <PUTP ,DRACULA ,P?LDESC
"The Count stands with his back to the door, and his eyes go over the
opened boxes like a man reading a bill.">
	 <TELL CR
"A key turns softly in the hall door." CR CR
"He comes into the room as smoothly as oil poured, and stops dead, and
his face becomes a thing you will describe in your diary for two pages
and never get right: waxen, hook-nosed, red-eyed, with the parted lips
showing white sharp teeth, and the scar of an old deep gash white on
his forehead. He looks at the open boxes and then at the five of you,
and hisses, and the hiss has laughter in it somewhere." CR>>

<ROUTINE PICC-SCENE-ADVANCE ()
	 <SETG PICC-SCENE <+ ,PICC-SCENE 1>>
	 <COND (<EQUAL? ,PICC-SCENE 4>
		<PICC-ESCAPE>)
	       (T
		<TELL CR
"\"You think to baffle me, you -- with your pale faces all in a row,
like sheep in a butcher's. You shall be sorry yet, each one of you!\""
CR>)>>

<ROUTINE PICC-DRACULA-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"The Count, in an English coat, in an English dining-room, at noon: and
that is the most frightening thing you have seen in your life. On his
forehead, white and old, is a deep gash-scar above the brows." CR>
		<RTRUE>)
	       (<VERB? ATTACK SIMPLE-KILL STAB MUNG CUT>
		<COND (,PICC-STRUCK
		       <TELL
"He is across the room and out of reach, and laughing." CR>)
		      (T
		       <SETG PICC-STRUCK T>
		       <AWARD 2>
		       <TELL
"Jonathan is faster than any of you: the great kukri knife goes up and
comes down with everything Exeter has been storing since May. The Count
sways aside with a movement no living spine could make, and the blade
shears through the breast of his coat -- and out of the rent falls a
stream of banknotes and gold, spilling and rolling on the boards, and
he stoops and claws a handful of it up as he goes, which is somehow
more terrible than the teeth." CR>)>
		<RTRUE>)
	       (<VERB? SHOW>
		<COND (<AND <EQUAL? ,PRSO ,WAFER ,CRUCIFIX> <NOT ,PICC-WARDED>>
		       <SETG PICC-WARDED T>
		       <AWARD 2>
		       <TELL
"The professor is beside you with the envelope held out, and you have
the crucifix up, and the Count goes backward before them across the
room with his face convulsed, the courtly manner gone entirely, a rat
in a corner of a barn. There is nothing noble left in him at all." CR>
		       <RTRUE>)
		      (T
		       <TELL
"He looks at it, and at you, and is not impressed." CR>
		       <RTRUE>)>)
	       (<VERB? TELL HELLO>
		<TELL
"\"You are all of you pale, and you shall be paler yet. My revenge is
just begun. I spread it over centuries, and time is on my side.\"" CR>
		<RTRUE>)>>

<ROUTINE PICC-ESCAPE ()
	 <SETG PICC-SCENE 5>
	 <MOVE ,DRACULA ,BANK>
	 <TELL CR
"He makes for the door, and Morris is in it, so he turns and goes at
the window instead -- a run, and a leap, and the glass goes out in a
shower into the mews below, and he lands on the cobbles twenty feet
down on his feet, and is not hurt at all." CR CR
"From the stable door he looks back up at the five faces in the broken
window. \"You think you have left me without a place to rest; but I
have more. My revenge is just begun! I spread it over centuries, and
time is on my side. Your girls that you all love are mine already; and
through them you and others shall yet be mine.\" And he is gone into
the fog toward the river, and there is no use whatever in following."
CR CR>
	 <ACT2-FINISH>>

"---- Kingstead and the tomb (Lucy-dies branch) ----"

<ROUTINE KINGSTEAD-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<TELL
"Yews and junipers stand black against the sky, and headstones drift in
the long grass, and among them is a lordly death-house of marble: the
Westenra tomb. The road is north.">
		<COND (<AND ,NIGHT2 <IN? ,LUCY ,KINGSTEAD>>
		       <TELL CR
"On the white walk between the yews, coming toward the tomb, there is a
dim white figure that holds something dark at its breast.">)>
		<TELL CR>
		<RTRUE>)
	       (<EQUAL? .RARG ,M-ENTER>
		;"The empty coffin IS the cue: once it has been opened the
		vigil outside begins on the next entry, without also asking
		the player to have arranged for it to be night."
		<COND (<AND ,LUCY-DEAD ,COFFIN-OPENED
			    <NOT ,TOMB-NIGHT-DONE>
			    <NOT <IN? ,LUCY ,KINGSTEAD>>>
		       <BLOOFER-APPEARS>)>
		<RFALSE>)
	       (T <ACT2-COMMON .RARG>)>>

<ROUTINE TOMB-IN ()
	 <COND (,TOMB-UNLOCKED <RETURN ,WESTENRA-TOMB>)
	       (T
		<TELL
"The tomb is locked, and the key is with the undertaker, and the
professor has already been to see the undertaker." CR>
		<RFALSE>)>>

<ROUTINE TOMB-DOOR-FCN ()
	 <COND (<VERB? OPEN UNLOCK>
		<COND (,TOMB-UNLOCKED
		       <TELL "It stands ajar on the dark." CR>)
		      (,LUCY-DEAD
		       <SETG TOMB-UNLOCKED T>
		       <FSET ,TOMB-DOOR ,OPENBIT>
		       <TELL
"Van Helsing produces the key with no explanation at all, and the great
door grinds back, and the smell of a new tomb comes out: stone, and
flowers a week old, and under it the beginning of something else." CR>)
		      (T
		       <TELL
"A locked marble door with the name Westenra on it, and no business of
yours today." CR>)>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"Time-discoloured marble, rusted iron, and the one word Westenra." CR>
		<RTRUE>)>>

<ROUTINE WESTENRA-TOMB-FCN (RARG)
	 <COND (<EQUAL? .RARG ,M-LOOK>
		<TELL
"Candlelight makes it worse: time-discoloured stone, rusted iron,
clouded silver-plate, and dust everywhere. Lucy's coffin rests on the
stone shelf; the others are older and darker." CR>
		<RTRUE>)
	       (T <ACT2-COMMON .RARG>)>>

<ROUTINE LUCY-COFFIN-FCN ()
	 <COND (<VERB? OPEN LOOK-INSIDE SEARCH UNLOCK>
		<COND (,STAKING-DONE
		       <TELL
"Lucy lies as she should: dead, and at peace, and nothing else." CR>
		       <RTRUE>)
		      (,COFFIN-OPENED
		       <TELL
"The lid is off and the lead is cut back, and the coffin is empty." CR>
		       <RTRUE>)
		      (<NOT <HELD? ,TURNSCREW>>
		       <TELL
"Screws, and under the wood a flange of soldered lead. Bare hands will
not do this. There were tools in the professor's bag." CR>
		       <RTRUE>)
		      (T
		       <SETG COFFIN-OPENED T>
		       <AWARD 3>
		       <TELL
"The professor takes out the screws one by one and lifts the wooden lid
aside, and then the fret-saw goes through the lead flange with a small
mean scream, and he turns back the metal like the lid of a tin, and
holds the candle where you can see." CR CR
"The coffin is empty. He looks at you with something like pity. \"And
now, friend John, we go out and we wait, and I am sorry.\"" CR>)>)
	       (<VERB? EXAMINE>
		<TELL
"A coffin of lead and wood, sealed as coffins are, with a plate that
says Lucy Westenra, and a date not a week old." CR>
		<RTRUE>)>>

<ROUTINE BLOOFER-APPEARS ()
	 <MOVE ,LUCY ,KINGSTEAD>
	 <SETG BLOOFER-WARNED T>
	 <TELL CR
"Between the yews, on the white walk, a dim white figure comes toward
the tomb, holding something dark at its breast, and stops, and stoops
over it. There is a low cry, like a child's." CR CR
"\"Hold your crucifix ready,\" says Van Helsing quietly, close to your
ear. \"When she turns, hold it up. Not after. When she turns.\"" CR>>

<ROUTINE BLOOFER-FCN ()
	 <COND (<VERB? EXAMINE>
		<TELL
"It is Lucy, and it is not. The sweetness is turned to adamantine
cruelty, and the purity to voluptuous wantonness, and the eyes are
Lucy's eyes, unclean and full of hell-fire. At her breast is a fair
child, and she flings it to the ground as a dog flings a bone." CR>
		<RTRUE>)
	       (<VERB? SHOW>
		<COND (<EQUAL? ,PRSO ,CRUCIFIX>
		       <BLOOFER-REPELLED>
		       <RTRUE>)>)
	       (<VERB? ATTACK SIMPLE-KILL STAKEV>
		<TELL
"Not here, and not in the open, and not by you. \"It must be in her
tomb,\" says Van Helsing, \"and it must be Arthur.\"" CR>
		<RTRUE>)
	       (<VERB? TELL HELLO>
		<TELL
"\"Come to me, Arthur,\" says the thing with Lucy's mouth, and then, to
you, in a voice of dreadful sweetness: \"Come. My arms are hungry for
you. Come, and we can rest together.\"" CR>
		<RTRUE>)>>

<ROUTINE BLOOFER-REPELLED ()
	 <SETG TOMB-NIGHT-DONE T>
	 <MOVE ,LUCY ,BANK>
	 <AWARD 3>
	 <TELL
"You hold up the crucifix, and the beautiful colour goes out of the
face like a lamp turned down, and she recoils with a look of baffled
malice, and goes past you to the door of the tomb -- and through it,
through the interstice where scarce a knife-blade could have gone. The
professor picks up the child, unhurt, and sends Morris to lay it where
a policeman will find it." CR CR
"\"To-morrow,\" he says. \"By day. And Arthur must be told to-night,
which is a worse thing than any we do to-morrow.\"" CR>>

<ROUTINE WOOD-STAKE-FCN ()
	 <COND (<AND <VERB? GIVE SHOW> <EQUAL? ,PRSI ,GODALMING>>
		<THE-STAKING>
		<RTRUE>)
	       (<VERB? EXAMINE>
		<TELL
"A round wooden stake some three feet long, one end hardened in the
fire and whittled to a point. The professor cut it himself, and would
not let anybody help." CR>
		<RTRUE>)>>

<ROUTINE MISSAL-FCN ()
	 <COND (<VERB? READ>
		<COND (<AND ,WOOD-STAKE-ASKED <NOT ,STAKING-DONE>>
		       <THE-STAKING-FINISH>
		       <RTRUE>)>
		<TELL
"The professor's little missal, in Latin, worn at the office for the
dead. He carries it as another man carries a revolver, and for the same
reason." CR>
		<RTRUE>)>>

<ROUTINE THE-STAKING ()
	 <COND (,STAKING-DONE
		<TELL "It is done, and she is at peace." CR>
		<RTRUE>)
	       (<NOT <EQUAL? ,HERE ,WESTENRA-TOMB>>
		<TELL "Not here. In the tomb, and by day." CR>
		<RTRUE>)
	       (T
		<SETG WOOD-STAKE-ASKED T>
		<MOVE ,WOOD-STAKE ,GODALMING>
		<TELL
"You put the stake into Arthur's hands and the hammer after it, and he
takes them without a word. Van Helsing opens his missal. \"Read with
me, friend John, and when I say, strike, Arthur, and do not stop for
anything you see or hear, for it is not she.\"" CR CR
"He waits for you to begin the prayer." CR>)>>

<ROUTINE THE-STAKING-FINISH ()
	 <SETG STAKING-DONE T>
	 <SETG LUCY-RESOLVED T>
	 <AWARD 15>
	 <TELL
"You read, and the professor reads, and Arthur stands over her looking
like a figure of Thor as his untrembling arm rose and fell." CR CR
"What happens then is in the diary in a shorter hand than usual. The
thing in the coffin writhed, and the sharp white teeth champed
together till the lips were cut, and the mouth smeared with a crimson
foam; and the hammer fell, and fell, and the room shook with the
sound. And then it was still, and Arthur was on his knees, and it was
Lucy in the coffin -- Lucy as we had seen her in life, with her face of
unequalled sweetness and purity, and the holy calm lying over it like
sunshine." CR CR
"Afterwards, and quietly, the rest: the top sawn from the stake, the
head, the mouth filled with garlic, the lid soldered down. \"And now,
my child,\" says Van Helsing to Arthur, \"you may kiss her. She is not
a grinning devil now, but God's true dead.\"" CR>
	 <COUNCIL-SCENE>>

<ROUTINE MEMORANDUM-FCN ()
	 <COND (<VERB? READ EXAMINE>
		<TELL
"Lucy's own account, written the night of the wolf and folded in her
breast where they found it: the flapping at the window, her mother's
hands taking the flowers away, the crash of glass, the grey head, her
mother's heart giving out under her arms, the maids asleep on the
dining-room floor and the smell of laudanum from the sherry. She wrote
it to be found. She wrote it, at the end, for Arthur." CR>
		<RTRUE>)>>

"---- The Mina attack ----"

<ROUTINE MINA-ATTACK-SCENE ()
	 <SETG MINA-ATTACKED T>
	 <SETG RENFIELD-TIER 4>
	 <TELL CR
"-- From the diary of Dr. Seward, the third of October. --" CR CR
"In the evening Renfield asks to be let out, and does it well: sane,
courteous, urgent, a reasonable man reasoning. He will not say why. \"I
am a sane man fighting for his soul,\" he says at last, and you write
that down and refuse him, because you are a doctor and it is a
madhouse, and that refusal is the second-worst thing you ever do." CR CR
"At midnight the attendant's cry brings you to his room, and he is face
down on the floor in his own blood with his back broken. He lives long
enough to tell you the rest: the fog, and the invitation, and the
promised rats with life in their eyes, and how he took hold of the
Master and tried to stop him when he understood, at last, whose life
was being taken out of the house." CR CR
"The Harkers' door is locked. You break it in together." CR CR
"Jonathan lies on the bed insensible, breathing like a man drugged. On
the edge of the bed, in his nightdress, kneels Mina, and standing over
her with her face pressed to his breast is the Count, and one white
hand holds her hands behind her, and the other keeps her head down, and
her white nightdress is smeared with blood, and a thin stream of it
runs down his bare chest where his own nails have opened it. It is like
nothing so much as a child forcing a kitten's nose into a saucer of
milk to make it drink." CR CR
"The professor holds up the envelope of the Host, and the Count's face
goes, and the whole thing is gone in a rush of vapour under the door.
Mina wipes her lips and screams a word into the dark, twice, and it is
the worst sound in this book: \"Unclean! Unclean!\"" CR CR
"At dawn the professor lays the Wafer on her forehead to bless her, and
it sears the skin as if it had been white-hot, and leaves a red scar
there. He drops on his knees. \"We must not despair. Madam Mina, when
that scar go from your forehead, it will be because God has judged
us all.\"" CR>
	 <MOVE ,MINA ,GUEST-ROOM>
	 <MOVE ,JONATHAN ,GUEST-ROOM>
	 <MOVE ,KUKRI ,WINNER>>

"---- Act II ends ----"

<ROUTINE ACT2-FINISH ()
	 <TELL
"Van Helsing gathers you up out of the wreck of the afternoon. \"He is
beaten, and he know it. Sterilise all his earth, and he must go home to
the last of it, by water, for he cannot cross running water but at the
turn of the tide, and a box on a ship is a box he cannot leave. And
Madam Mina -- forgive me, my dear -- Madam Mina is joined to him now,
and what she can hear in her trance, we shall hear also.\"" CR CR
"At dawn she goes under his hands and speaks: \"I hear the lapping of
water. It is level with me, and the creaking of a chain, and the sound
of men running overhead.\" So: a ship, and going out with the tide. The
Czarina Catherine sailed from Doolittle's Wharf for Varna on the tide,
with one great box in her hold." CR CR
"-- From the journal of Mina Harker, aboard the Orient Express. --" CR CR>
	 <SETG ACT 4>
	 <BANK-ALL>
	 <MOVE ,VAN-HELSING ,VARNA-HOTEL>
	 <MOVE ,JONATHAN ,VARNA-HOTEL>
	 <MOVE ,MINA ,BANK>
	 <MOVE ,RIVER-MAP ,VARNA-HOTEL>
	 <MOVE ,TIMETABLE ,VARNA-HOTEL>
	 <MOVE ,KUKRI ,WINNER>
	 <MOVE ,CRUCIFIX ,WINNER>
	 <MOVE ,WAFER ,WINNER>
	 <MOVE ,GARLIC ,WINNER>
	 <MOVE ,WOOD-STAKE ,WINNER>
	 <MOVE ,HAMMER ,WINNER>
	 <MOVE ,WINCHESTER ,WINNER>
	 <MOVE ,WOLF-COAT ,WINNER>
	 <SETG HERE ,VARNA-HOTEL>
	 <MOVE ,WINNER ,HERE>
	 <SETG LIT T>
	 <V-FIRST-LOOK>>
