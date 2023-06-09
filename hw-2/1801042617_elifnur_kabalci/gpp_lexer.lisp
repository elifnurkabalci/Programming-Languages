(defun IsSpace(c) 
	(char= c #\Space)
)
(defun IsZero(chr)
	(eq (char-code (coerce chr 'character)) 48);; ->0
)
(defun IsSemicolon(chr)
	(eq (char-code (coerce chr 'character)) 59);; ->;
)
(defun IsQuomark(chr)
	(eq (char-code (coerce chr 'character)) 34);; ->"
)
(defun IsNumeric(chr)
    (let ((c (char-int (coerce chr 'character))))
		(and (>= c (char-int #\0)) (<= c (char-int #\9)))
    )    
)
(defun IsAlpha(chr)
    (let ((c (char-int (coerce chr 'character))))
		(and (>= c (char-int #\A)) (<= c (char-int #\z)))
    )
)
(defun IsBrackets(chr)
	(let ((c (char-int (coerce chr 'character))))
		(or (= c 40) (= c 41)) 
    )
)
(defun ErrorPrint(token c)
	(format nil "SYNTAX ERROR: '~a' : '~a'" token c)
)
(defun ListoString (lst)
    (format nil "~{~A~}" lst)
)

(defun DivideSeq (string &key (IsSpace #'IsSpace))
    (loop :for start = (position-if-not IsSpace string)
    :then (position-if-not IsSpace string :start (1+ end))
    :for end = (and start (position-if IsSpace string :start start))
    :when start :collect (subseq string start end)
    :while end)
)
(defun cleanup (str)
	(let ((trim-lst '(#\Space #\Newline #\Backspace #\Tab #\Return )))
	    (string-trim trim-lst str)
    )
)
(defun InputoList (str)
	(setq str (ListoString (map 'list #'(lambda (c) 
		(if (IsBrackets c) (concatenate 'string " " (string c) " ") 
		(string c))) (cleanup str)))
    )
	(let ((lst (loop for iden from 0 to (- (length str) 1) when (char= (aref str iden) #\") collect iden)) (iden1 '()) (iden2 '()) (space-iden '()))
	(loop while lst do (setq iden1 (car lst)) 
					do (setq iden2 (car (cdr lst)))
					do (setq lst (cdr (cdr lst)))
					do (setq space-iden (loop for iden from 0 to (- (length str) 1) when (and (> iden iden1) (< iden iden2) (char= (aref str iden) #\Space)) collect iden))
    )
	(DivideSeq (ListoString (loop for iden from 0 to (- (length str) 1) if (member iden space-iden) collect #\. else collect (aref str iden))))
    )
)
(defun TokenList()
    (let((token-key '("and" "or" "not" "equal" "less" "nil" "list" "append" "concat" "set" "deffun" "for" "if" "exit" "load" "disp" "true" "false" "+" "-" "/" "*" "(" ")" "**" ","))
		(token-value '("KW_AND" "KW_OR" "KW_ NOT" "KW_EQUAL" "KW_LESS" "KW_NIL" "KW_LIST" "KW_APPEND" "KW_CONCAT" "KW_SET" "KW_DEFFUN" "KW_FOR" "KW_IF" "KW_EXIT" "KW_LOAD" 
					   "KW_DISP" "KW_TRUE" " KW_FALSE" "OP_PLUS" "OP_MINUS" "OP_DIV" "OP_MULT" "OP_OP" "OP_CP" "OP_DBLMULT" "OP_COMMA"))
        )
		(pairlis token-key token-value)
    )
)
(defun TokenizeOp (token lst)
	(let ((value (assoc token lst :test #'string=)))
		(if value (format nil "~a" (cdr value)) nil)
    )    
)
(defun TokenizeString (token)
	(assert (IsQuomark(string (char token 0))))
	(format nil "STRING")
)
(defun TokenizeValue (token)
	(assert (IsNumeric (string (char token 0)))) 
	(if (and (> (length token) 1) (IsZero (substring token 0 1))) 
		(return-from TokenizeValue (ErrorPrint token (substring token 0 1)))
    )
	(loop for c across token do (if (not (IsNumeric c))
		(return-from TokenizeValue (ErrorPrint token c)))
    )
	(format nil "VALUE")
)
(defun TokenizeKw (token lst)
	(let ((value (assoc token lst :test #'string=)))
		(if value (format nil "~a" (cdr value)) nil)
    )
)
(defun TokenizeIdentifier (token lst)
	(assert (IsAlpha (string (char token 0)))
    )
	(loop for c across token do (if (not (or (IsAlpha c) (IsNumeric c))) 
		(return-from TokenizeIdentifier (ErrorPrint token c)))
    )
	(let ((kw (TokenizeKw token lst)))
		(if (null kw) (format nil "IDENTIFIER") kw)
    )
)
(defun Tokenize (token lst)
    (let ((c (string (char token 0)))) 
	    (cond ((IsAlpha c) (TokenizeIdentifier token lst))  ;; [a-zA-z] identifier and kw
	 	   ((IsNumeric c) (TokenizeValue token))			;; [0-9] value
	 	   ((IsQuomark c) (TokenizeString token))
	 	   (t (if (TokenizeOp token lst) 					;; operator
	 	   (TokenizeOp token lst) (ErrorPrint token c)))   	;; else, syntax error.
        )       
    )   
)
(defun gppinterpreter (&optional filename)
	(if filename (InterpreterFile filename) (InterpreterShell))
)
(defun Interpreter(seq)
	(let ((lst (InputoList seq)))
		(if (string= (car lst) ";;") (print "COMMENT")  
		(map nil #'(lambda (token) (print (Tokenize token (TokenList)))) lst))
	)
)
(defun InterpreterShell()
	(loop (format t "~%>>> ") (Interpreter(read-line)))
)
(defun InterpreterFile (filename)
	(let ((in (open filename :if-does-not-exist nil)))		
	  (when in (loop for line = (read-line in nil)
	         	while line do (Interpreter line)) (close in))
	  (unless in (format t "ERROR: No such file: '~a'" filename))))

(if *args* (gppinterpreter (car *args*)) (gppinterpreter)
)