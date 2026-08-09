# czil stage-3 evaluator tests.
# Format: DIRECTIVE <TAB> expr [<TAB> expected]
#   OK   - all top-level objects evaluate; printed final result must match
#   ERR  - evaluation must fail (or control flow must escape)
#   OUT  - accumulated PRINC/CRLF output must match (\n = newline)
# Each line runs in a fresh context.
# Sources: assertions converted from zilf test/Zilf.Tests/Interpreter/
# (ArithmeticTests, AtomTests, FunctionTests, StructureTests, FlowControlTests)
# plus czil-specific additions.

# ---- self-evaluation ----
OK	42	42
OK	-7	-7
OK	FOO	FOO
OK	"hello"	"hello"
OK	!\A	!\A
OK	<>	#FALSE ()
OK	T	T

# ---- arithmetic (ArithmeticTests) ----
OK	<+ 1 2>	3
OK	<+ 1 2 3 4>	10
OK	<+>	0
OK	<+ 5>	5
OK	<->	0
OK	<- 7>	-7
OK	<- 10 3 2>	5
OK	<*>	1
OK	<* 2 3 4>	24
OK	</ 10 2>	5
OK	</ 2>	0
OK	</ 100 2 5>	10
OK	</>	1
OK	<MOD 7 3>	1
OK	<MOD -7 3>	-1
OK	<LSH 1 3>	8
OK	<LSH 16 -2>	4
OK	<LSH -1 -28>	15
OK	<LSH 1 40>	0
OK	<MIN 3 1 2>	1
OK	<MAX 3 1 2>	3
OK	<MIN -5>	-5
OK	<ABS -5>	5
OK	<ABS 5>	5
ERR	</ 1 0>
ERR	</ 0>
ERR	<MOD 1 0>
ERR	<+ 1 "a">
ERR	<- FOO>
ERR	<MIN>

# ---- predicates ----
OK	<==? 1 1>	T
OK	<==? 1 2>	#FALSE ()
OK	<==? FOO FOO>	T
OK	<==? (1) (1)>	#FALSE ()
OK	<N==? 1 2>	T
OK	<=? (1 2) (1 2)>	T
OK	<=? (1 2) (1 3)>	#FALSE ()
OK	<=? "ab" "ab">	T
OK	<N=? 1 2>	T
OK	<G? 2 1>	T
OK	<G? 1 2>	#FALSE ()
OK	<L? 1 2>	T
OK	<G=? 2 2>	T
OK	<L=? 3 2>	#FALSE ()
OK	<0? 0>	T
OK	<0? 1>	#FALSE ()
OK	<1? 1>	T
OK	<NOT <>>	T
OK	<NOT 1>	#FALSE ()
ERR	<G? 1 "a">

# ---- TYPE ----
OK	<TYPE 1>	FIX
OK	<TYPE FOO>	ATOM
OK	<TYPE "x">	STRING
OK	<TYPE (1)>	LIST
OK	<TYPE '<+>>	FORM
OK	<TYPE [1]>	VECTOR
OK	<TYPE <>>	FALSE
OK	<TYPE !\x>	CHARACTER
OK	<TYPE? 1 FIX LIST>	FIX
OK	<TYPE? 1 LIST>	#FALSE ()

# ---- atoms and values (AtomTests) ----
OK	<SET X 5> .X	5
OK	<SETG G 7> ,G	7
OK	<SET X 1> <SET X 2> .X	2
OK	<SPNAME FOO>	"FOO"
OK	<GASSIGNED? NOSUCHGLOBAL>	#FALSE ()
OK	<SETG G 1> <GASSIGNED? G>	T
OK	<ASSIGNED? NOSUCHLOCAL>	#FALSE ()
OK	<SET X 1> <ASSIGNED? X>	T
OK	<SET X 1> <UNASSIGN X> <ASSIGNED? X>	#FALSE ()
OK	<SETG G 1> <GUNASSIGN G> <GASSIGNED? G>	#FALSE ()
OK	<SET X 5> <VALUE X>	5
OK	<SETG X 6> <VALUE X>	6
ERR	<GVAL NOSUCHGLOBAL>
ERR	<LVAL NOSUCHLOCAL>
ERR	.NOSUCHLOCAL
ERR	,NOSUCHGLOBAL
ERR	<SET X 1> <UNASSIGN X> .X
ERR	<SPNAME 1>
ERR	<SET 1 2>
ERR	<SETG "X" 2>

# ---- QUOTE / EVAL / APPLY (FunctionTests) ----
OK	<QUOTE FOO>	FOO
OK	'<+ 1 2>	<+ 1 2>
OK	<EVAL '<+ 1 2>>	3
OK	<APPLY ,+ 1 2>	3
OK	<APPLY 2 (100 <+ 199 1> 300)>	200
OK	<EXPAND 5>	5
ERR	<APPLY 1>
ERR	<APPLY "x" 1>

# ---- FORM application ----
OK	<2 (100 200 300)>	200
OK	<<GVAL +> 1 2>	3
ERR	<1 2>
ERR	<4 (1 2 3)>
ERR	<NOSUCHFN 1>
ERR	<"string" 1>

# ---- COND / AND / OR (FlowControl) ----
OK	<COND (<G? 1 2> 10) (T 20)>	20
OK	<COND (<G? 2 1> 10) (T 20)>	10
OK	<COND (<G? 1 2> 10)>	#FALSE ()
OK	<COND>	#FALSE ()
OK	<COND (5)>	5
OK	<COND (T 1 2 3)>	3
OK	<AND>	T
OK	<AND 1 2>	2
OK	<AND <> <NOSUCHFN>>	#FALSE ()
OK	<OR>	#FALSE ()
OK	<OR <> 5>	5
OK	<OR 1 <NOSUCHFN>>	1
ERR	<COND 5>

# ---- PROG / REPEAT / RETURN / AGAIN / BIND ----
OK	<PROG () 1 2 3>	3
OK	<PROG ((A 5)) .A>	5
OK	<PROG (A) <SET A 9> .A>	9
OK	<PROG () <RETURN 42> <NOSUCHFN>>	42
OK	<PROG () <RETURN>>	T
OK	<REPEAT ((N 0)) <SET N <+ .N 1>> <COND (<G? .N 4> <RETURN .N>)>>	5
OK	<PROG ((N 0)) <SET N <+ .N 1>> <COND (<L? .N 3> <AGAIN>)> .N>	3
OK	<BIND ((X 1)) .X>	1
OK	<SET X 1> <PROG ((X 2)) .X>	2
OK	<SET X 1> <PROG ((X 2)) T> .X	1
ERR	<PROG ()>
ERR	<RETURN 1>

# ---- DEFINE / DEFMAC / FUNCTION ----
OK	<DEFINE SQ (X) <* .X .X>> <SQ 5>	25
OK	<DEFINE SQ (X) <* .X .X>>	SQ
OK	<DEFINE F (A B) <- .A .B>> <F 10 3>	7
OK	<DEFINE F (A "OPT" (B 10)) <+ .A .B>> <F 1>	11
OK	<DEFINE F (A "OPT" (B 10)) <+ .A .B>> <F 1 2>	3
OK	<DEFINE F (A "OPTIONAL" B) <COND (<ASSIGNED? B> .B) (T .A)>> <F 1>	1
OK	<DEFINE F (A "AUX" (B 2)) <+ .A .B>> <F 1>	3
OK	<DEFINE F ("ARGS" L) .L> <F 1 <+ 1 1> 3>	(1 <+ 1 1> 3)
OK	<DEFINE F ("TUPLE" TT) .TT> <F 1 <+ 1 1> 3>	(1 2 3)
OK	<DEFINE F ('A) .A> <F <+ 1 2>>	<+ 1 2>
OK	<DEFINE F (X) <COND (<0? .X> DONE) (T <F <- .X 1>>)>> <F 5>	DONE
OK	<FUNCTION (X) .X>	#FUNCTION ((X) .X)
OK	<APPLY <FUNCTION (X) <* .X 2>> 21>	42
OK	<SET REDEFINE T> <DEFINE F (X) .X> <DEFINE F (X) <+ .X 1>> <F 1>	2
OK	<DEFMAC INC (A) <FORM SET .A <FORM + 1 <FORM LVAL .A>>>> <SET X 1> <INC X> .X	2
OK	<DEFMAC M ('A) <FORM QUOTE .A>> <M <+ 1 2>>	<+ 1 2>
ERR	<DEFINE F (X) .X> <DEFINE F (X) .X>
ERR	<DEFINE SQ (X) <* .X .X>> <SQ>
ERR	<DEFINE SQ (X) <* .X .X>> <SQ 1 2>
ERR	<DEFINE F ()>
ERR	<DEFINE 1 (X) .X>

# ---- structures (StructureTests) ----
OK	<LIST 1 2 3>	(1 2 3)
OK	<LIST>	()
OK	<VECTOR 1 <+ 1 1>>	[1 2]
OK	<FORM + 1 2>	<+ 1 2>
OK	<CONS 1 (2 3)>	(1 2 3)
OK	<CONS 1 ()>	(1)
OK	<LENGTH (1 2 3)>	3
OK	<LENGTH "abc">	3
OK	<LENGTH []>	0
OK	<LENGTH? (1 2) 3>	2
OK	<LENGTH? (1 2) 1>	#FALSE ()
OK	<EMPTY? ()>	T
OK	<EMPTY? (1)>	#FALSE ()
OK	<EMPTY? "">	T
OK	<NTH (A B C) 2>	B
OK	<NTH (A B C)>	A
OK	<NTH "abc" 2>	!\b
OK	<REST (1 2 3)>	(2 3)
OK	<REST (1 2 3) 2>	(3)
OK	<REST "x">	""
OK	<REST "abc" 1>	"bc"
OK	<REST (1) 1>	()
OK	<PUT [1 2 3] 2 9>	[1 9 3]
OK	<SET L (1 2 3)> <PUT .L 1 9> .L	(9 2 3)
OK	<SET L (1 2 3)> <PUTREST .L (9)> .L	(1 9)
OK	<MEMQ 2 (1 2 3)>	(2 3)
OK	<MEMQ 9 (1 2)>	#FALSE ()
OK	<MEMQ B (A B C)>	(B C)
OK	<MEMBER (2) ((1) (2) (3))>	((2) (3))
OK	<MEMBER "b" ("a" "b")>	("b")
ERR	<NTH (A B) 3>
ERR	<NTH (A B) 0>
ERR	<REST (1) 2>
ERR	<PUT (1) 5 9>
ERR	<PUT (1) 0 9>
ERR	<PUTREST [1] (2)>
ERR	<LENGTH 5>
ERR	<CONS 1 2>

# ---- element evaluation and segments ----
OK	(1 <+ 1 2>)	(1 3)
OK	[<+ 1 2> 4]	[3 4]
OK	<SET L (1 2 3)> (0 !.L 4)	(0 1 2 3 4)
OK	<SET L (1 2 3)> <+ !.L>	6
OK	<SET L (2 3)> [!.L !.L]	[2 3 2 3]
OK	<SET V [5 6]> (!.V)	(5 6)
ERR	<SET X 5> (!.X)
ERR	!.X

# ---- strings and atoms ----
OK	<STRING "ab" !\c>	"abc"
OK	<STRING>	""
OK	<PARSE "FOO">	FOO
OK	<==? <PARSE "FOO"> FOO>	T
OK	<PARSE "42">	42
ERR	<STRING 1>
ERR	<PARSE 1>

# ---- CHTYPE ----
OK	<CHTYPE (1 2) VECTOR>	[1 2]
OK	<CHTYPE [1 2] LIST>	(1 2)
OK	<CHTYPE (+ 1 2) FORM>	<+ 1 2>
OK	<EVAL <CHTYPE (+ 1 2) FORM>>	3
OK	<CHTYPE (1) FALSE>	#FALSE (1)
OK	<NOT <CHTYPE (1) FALSE>>	T
ERR	<CHTYPE 1 LIST>
ERR	<CHTYPE (1) NOSUCHTYPE>

# ---- MAPF / MAPR / MAPRET / MAPSTOP ----
OK	<MAPF ,LIST <FUNCTION (X) <* .X .X>> (1 2 3)>	(1 4 9)
OK	<MAPF ,VECTOR <FUNCTION (X) .X> (1 2)>	[1 2]
OK	<MAPF ,+ <FUNCTION (X) .X> (1 2 3)>	6
OK	<MAPF <> <FUNCTION (X) .X> (1 2 3)>	3
OK	<MAPF ,LIST <FUNCTION (A B) <+ .A .B>> (1 2) (10 20)>	(11 22)
OK	<MAPF ,LIST <FUNCTION (A B) .B> (1 2 3) (10 20)>	(10 20)
OK	<MAPF ,LIST <FUNCTION (X) <MAPRET .X .X>> (1 2)>	(1 1 2 2)
OK	<MAPF ,LIST <FUNCTION (X) <COND (<G? .X 2> <MAPSTOP 99>) (T .X)>> (1 2 3 4)>	(1 2 99)
OK	<MAPF ,LIST <FUNCTION (X) <COND (<0? <MOD .X 2>> <MAPRET>) (T .X)>> (1 2 3 4)>	(1 3)
OK	<MAPR ,LIST <FUNCTION (L) <LENGTH .L>> (A B C)>	(3 2 1)
OK	<MAPF ,STRING <FUNCTION (CH) .CH> "ab">	"ab"
ERR	<MAPF ,LIST <FUNCTION (X) .X> 5>

# ---- output ----
OUT	<PRINC "hi">	hi
OUT	<PRINC "a"> <CRLF> <PRINC "b">	a\nb
OUT	<PRINC 42>	42
OUT	<PRINC !\x>	x
OUT	<PRINC (1 2)>	(1 2)

# ---- READEVAL (%) and deferred CHTYPE ----
OK	%<+ 1 2>	3
OK	<+ 1 %<* 2 3>>	7
OK	%%<SETG A 1> ,A	1
OK	<SETG ZORK-NUMBER 1> %<COND (<==? ,ZORK-NUMBER 1> '(FOO) ) (T '(BAR))>	(FOO)
OK	<SETG ZORK-NUMBER 2> %<COND (<==? ,ZORK-NUMBER 1> '(FOO)) (T '(BAR))>	(BAR)
OK	<SETG ZORK-NUMBER 1> (A %<COND (<==? ,ZORK-NUMBER 1> 'X) (T 'Y)> B)	(A X B)
OK	%<COND (<GASSIGNED? NOSUCH> 1) (T 2)>	2
OK	#FALSE ()	#FALSE ()
OK	<SET X 5> .X:FIX	5
OK	<GDECL (X) FIX>	T

# ---- trilogy-shaped smoke: the actual macro pattern from gverbs.zil ----
OK	<SETG ZORK-NUMBER 1> %<COND (<OR <==? ,ZORK-NUMBER 1> <==? ,ZORK-NUMBER 2>> '(SWIM)) (T '(NOSWIM))>	(SWIM)
OK	<SETG ZORK-NUMBER 3> %<COND (<OR <==? ,ZORK-NUMBER 1> <==? ,ZORK-NUMBER 2>> '(SWIM)) (T '(NOSWIM))>	(NOSWIM)
OK	<DEFINE AP ("AUX" (OO (X)) (O .OO)) <SET O <REST <PUTREST .O (1)>>> <SET O <REST <PUTREST .O (2)>>> <SET O <REST <PUTREST .O (3)>>> .OO> <AP>	(X 1 2 3)
OK	<SET L (1 2 3)> <SET V <REST .L>> <PUTREST .V (9)> .L	(1 2 9)
