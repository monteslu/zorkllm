"TDUNGEON - the world of Tiny Quest: rooms, objects, and the GO routine."

<DIRECTIONS NORTH EAST WEST SOUTH NE NW SE SW UP DOWN IN OUT LAND>

<ROOM GARDEN
      (IN ROOMS)
      (DESC "Overgrown Garden")
      (LDESC
"You are standing in a small garden gone wild. Bees drone somewhere in
the tangle of roses. A sagging shed stands to the north.")
      (NORTH TO SHED-INTERIOR IF SHED-DOOR IS OPEN ELSE
"The shed door is closed.")
      (ACTION GARDEN-FCN)
      (FLAGS RLANDBIT ONBIT SACREDBIT)>

<OBJECT FLOWERPOT
	(IN GARDEN)
	(SYNONYM FLOWERPOT POT)
	(ADJECTIVE CRACKED CLAY)
	(DESC "cracked flowerpot")
	(FLAGS TAKEBIT)
	(ACTION FLOWERPOT-FCN)>

<OBJECT BRASS-KEY
	(IN GARDEN)
	(SYNONYM KEY)
	(ADJECTIVE BRASS SMALL)
	(DESC "small brass key")
	(FLAGS TAKEBIT INVISIBLE TOOLBIT)
	(SIZE 2)>

<OBJECT SHED-DOOR
	(IN GARDEN)
	(SYNONYM DOOR SHED)
	(ADJECTIVE SAGGING WOODEN)
	(DESC "shed door")
	(FLAGS DOORBIT NDESCBIT)
	(ACTION SHED-DOOR-FCN)>

<ROOM SHED-INTERIOR
      (IN ROOMS)
      (DESC "Inside the Shed")
      (LDESC
"Dusty light falls through one grimy window. A workbench runs along the
far wall, and a trapdoor in the floor leads down into darkness.")
      (SOUTH TO GARDEN)
      (DOWN TO CELLAR)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT WORKBENCH
	(IN SHED-INTERIOR)
	(SYNONYM WORKBENCH BENCH)
	(ADJECTIVE LONG)
	(DESC "workbench")
	(FLAGS NDESCBIT SURFACEBIT CONTBIT OPENBIT)
	(CAPACITY 50)>

<OBJECT TOOLBOX
	(IN WORKBENCH)
	(SYNONYM TOOLBOX BOX)
	(ADJECTIVE STEEL LOCKED)
	(DESC "steel toolbox")
	(FLAGS CONTBIT LOCKEDBIT)
	(CAPACITY 20)
	(ACTION TOOLBOX-FCN)>

<OBJECT BRASS-GEAR
	(IN TOOLBOX)
	(SYNONYM GEAR COG)
	(ADJECTIVE BRASS POLISHED)
	(DESC "polished brass gear")
	(FLAGS TAKEBIT)
	(VALUE 5)
	(TVALUE 10)
	(SIZE 3)>

<ROOM CELLAR
      (IN ROOMS)
      (DESC "Machine Cellar")
      (LDESC
"A single shaft of light picks out an ancient brass machine, silent and
still. On its side is an empty socket exactly the size of a gear.")
      (UP TO SHED-INTERIOR)
      (FLAGS RLANDBIT ONBIT)>

<OBJECT MACHINE-SOCKET
	(IN CELLAR)
	(SYNONYM SOCKET MACHINE)
	(ADJECTIVE BRASS ANCIENT EMPTY)
	(DESC "empty socket")
	(FLAGS CONTBIT OPENBIT NDESCBIT)
	(CAPACITY 5)
	(ACTION SOCKET-FCN)>

<ROUTINE GO ()
	<SETG HERE ,GARDEN>
	<COND (<NOT <FSET? ,HERE ,TOUCHBIT>>
	       <TELL "TINY QUEST" CR>
	       <TELL "An example adventure for the zorkllm toolchain." CR CR>)>
	<SETG LIT T>
	<SETG WINNER ,ADVENTURER>
	<SETG PLAYER ,WINNER>
	<MOVE ,WINNER ,HERE>
	<V-LOOK>
	<MAIN-LOOP>
	<AGAIN>>

"Stub objects the generic engine verbs reference (never placed in the
world; PRE-BOARD and V-DRINK check them, FIRSTER checks the case)."

<OBJECT WATER
	(SYNONYM WATER)
	(DESC "quantity of water")
	(FLAGS TRYTAKEBIT TAKEBIT DRINKBIT)>

<OBJECT GLOBAL-WATER
	(IN GLOBAL-OBJECTS)
	(SYNONYM WATER)
	(ADJECTIVE GLOBAL)
	(DESC "water")
	(FLAGS DRINKBIT)>

<OBJECT WALL
	(IN GLOBAL-OBJECTS)
	(SYNONYM WALL WALLS)
	(DESC "wall")>

<PROPDEF TEXT 0>

"Unreachable stub room: the generic (ZORK-NUMBER fallback) branches of a
few engine verbs compare HERE against it."

<ROOM ON-LAKE
      (IN ROOMS)
      (DESC "On the Lake")
      (FLAGS RLANDBIT)>

<ROOM IN-LAKE
      (IN ROOMS)
      (DESC "In the Lake")
      (FLAGS RLANDBIT)>

"Unplaced stub carrying engine-referenced flags no real object uses."

<OBJECT FLAG-CARRIER
	(DESC "flag carrier")
	(FLAGS NONLANDBIT)>
