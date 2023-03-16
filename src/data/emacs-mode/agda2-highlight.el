;;; agda2-highlight.el --- Syntax highlighting for Agda -*- lexical-binding: t; -*-

;; URL: https://github.com/agda/agda/tree/master/src/data/emacs-mode
;; SPDX-License-Identifier: MIT License

;;; Commentary:

;; Code to apply syntactic highlighting to Agda source code.  This
;; uses Agda's own annotations to figure out what is what, so the
;; parsing is always done correctly, but highlighting is not done on
;; the fly.

;;; Code:

(eval-when-compile (require 'inline))
(require 'font-lock)
(require 'agda2)

(defgroup agda2-highlight nil
  "Syntax highlighting for Agda."
  :group 'agda2)

(defcustom agda2-highlight-level 'non-interactive
  "How much syntax highlighting should be produced?
Interactive highlighting includes highlighting of the expression
that is currently being type-checked."
  :type '(choice
          (const :tag "None"            none)
          (const :tag "Non-interactive" non-interactive)
          (const :tag "Interactive"     interactive))
  :group 'agda2-highlight)

(defun agda2-highlight-level nil
  "Formats the highlighting level in a Haskelly way."
  (cond ((eq agda2-highlight-level 'none)            "None")
        ((eq agda2-highlight-level 'non-interactive) "NonInteractive")
        ((eq agda2-highlight-level 'interactive)     "Interactive")
        (t                                           "None")))

;;;; Functions for setting faces

(defun agda2-highlight-set-face-attribute (face attrs)
  "Reset (globally) all attributes of the face FACE according to ATTRS.
If the face does not exist, then it is created first."
  (make-face face)
  (set-face-attribute face nil
                      :family         'unspecified
                      :width          'unspecified
                      :height         'unspecified
                      :weight         'unspecified
                      :slant          'unspecified
                      :foreground     'unspecified
                      :background     'unspecified
                      :inverse-video  'unspecified
                      :stipple        'unspecified
                      :underline      'unspecified
                      :overline       'unspecified
                      :strike-through 'unspecified
                      :inherit        'unspecified
                      :box            'unspecified
                      :font           'unspecified)
  (apply #'set-face-attribute face nil attrs))

(defun agda2-highlight-set-faces (variable group)
  "Set all Agda faces according to the value of GROUP.
Also sets the default value of VARIABLE to GROUP."
  (set-default variable group)
  (mapc (lambda (face-and-attrs)
          (agda2-highlight-set-face-attribute
           (car face-and-attrs) (cdr face-and-attrs)))
        (cond
         ((equal group 'conor)
          '((agda2-highlight-keyword-face
             :bold t)
            (agda2-highlight-string-face
             :foreground "firebrick3")
            (agda2-highlight-number-face
             :foreground "firebrick3")
            (agda2-highlight-symbol-face
             :foreground "grey25")
            (agda2-highlight-primitive-type-face
             :foreground "medium blue")
            (agda2-highlight-bound-variable-face
             :foreground "purple")
            (agda2-highlight-generalizable-variable-face
             :foreground "purple")
            (agda2-highlight-inductive-constructor-face
             :foreground "firebrick3")
            (agda2-highlight-coinductive-constructor-face
             :foreground "firebrick3")
            (agda2-highlight-datatype-face
             :foreground "medium blue")
            (agda2-highlight-field-face
             :foreground "deeppink")
            (agda2-highlight-function-face
             :foreground "darkgreen")
            (agda2-highlight-module-face
             :foreground "medium blue")
            (agda2-highlight-postulate-face
             :foreground "darkgreen")
            (agda2-highlight-primitive-face
             :foreground "darkgreen")
            (agda2-highlight-macro-face
             :foreground "aquamarine4")
            (agda2-highlight-record-face
             :foreground "medium blue")
            (agda2-highlight-dotted-face)
            (agda2-highlight-error-face
             :foreground "red"
             :underline t)
            (agda2-highlight-error-warning-face
             :background "light coral"
             :underline t)
            (agda2-highlight-unsolved-meta-face
             :foreground "black"
             :background "yellow")
            (agda2-highlight-unsolved-constraint-face
             :foreground "black"
             :background "yellow")
            (agda2-highlight-termination-problem-face
             :foreground "black"
             :background "light salmon")
            (agda2-highlight-positivity-problem-face
             :foreground "black"
             :background "peru")
            (agda2-highlight-incomplete-pattern-face
             :foreground "black"
             :background "purple")
            (agda2-highlight-typechecks-face
             :foreground "black"
             :background "light blue")))
         ((equal group 'default-faces)
          (list (cons 'agda2-highlight-keyword-face
                      (list :inherit font-lock-keyword-face))
                (cons 'agda2-highlight-string-face
                      (list :inherit font-lock-string-face))
                (cons 'agda2-highlight-number-face
                      (list :inherit font-lock-constant-face))
                (cons 'agda2-highlight-symbol-face
                      (list :inherit font-lock-keyword-face))
                (cons 'agda2-highlight-primitive-type-face
                      (list :inherit font-lock-keyword-face))
                (cons 'agda2-highlight-bound-variable-face
                      (list :inherit font-lock-variable-name-face))
                (cons 'agda2-highlight-generalizable-variable-face
                      (list :inherit font-lock-variable-name-face))
                (cons 'agda2-highlight-inductive-constructor-face
                      (list :inherit font-lock-type-face))
                (cons 'agda2-highlight-coinductive-constructor-face
                      (list :inherit font-lock-type-face))
                (cons 'agda2-highlight-datatype-face
                      (list :inherit font-lock-type-face))
                (cons 'agda2-highlight-field-face
                      (list :inherit font-lock-variable-name-face))
                (cons 'agda2-highlight-function-face
                      (list :inherit font-lock-function-name-face))
                (cons 'agda2-highlight-module-face
                      (list :inherit font-lock-type-face))
                (cons 'agda2-highlight-postulate-face
                      (list :inherit font-lock-type-face))
                (cons 'agda2-highlight-primitive-face
                      (list :inherit font-lock-constant-face))
                (cons 'agda2-highlight-macro-face
                      (list :inherit font-lock-function-name-face))
                (cons 'agda2-highlight-record-face
                      (list :inherit font-lock-variable-name-face))
                (cons 'agda2-highlight-dotted-face
                      (list :inherit font-lock-variable-name-face))
                (cons 'agda2-highlight-operator-face
                      (list :inherit font-lock-function-name-face))
                (cons 'agda2-highlight-error-face
                      (list :inherit font-lock-warning-face))
                (cons 'agda2-highlight-typechecks-face
                      (list :inherit font-lock-type-face))
                (cons 'agda2-highlight-typechecking-face
                      (list :inherit font-lock-preprocessor-face)))))))

;;;; Faces

(defcustom agda2-highlight-face-groups nil
  "Colour scheme used in Agda buffers.
Changes to this variable may not take full effect until you have
restarted Emacs. Note also that if you are using the
default-faces option and change your colour theme, then the
changes may not take effect in Agda buffers until you have
restarted Emacs."
  :type '(choice
          (const :tag "Use the settings in the \"Agda2 Highlight Faces\" subgroup." nil)
          (const :tag "Use an approximation of Conor McBride's colour scheme."
                 conor)
          (const :tag "Use simplified highlighting and default font-lock faces."
                 default-faces))
  :group 'agda2-highlight
  :set 'agda2-highlight-set-faces)

(defgroup agda2-highlight-faces nil
  "Faces used to highlight Agda code.
If `agda2-highlight-face-groups' is nil."
  :group 'agda2-highlight)

(defface agda2-highlight-keyword-face
  '((((background light))
     (:foreground "DarkOrange3"))
    (((background dark))
     (:foreground "#FF9932")))
  "The face used for keywords."
  :group 'agda2-highlight-faces)

(defface agda2-highlight-string-face
  '((((background light))
     (:foreground "firebrick"))
    (((background dark))
     (:foreground "#DD4D4D")))
  "The face used for strings."
  :group 'agda2-highlight-faces)

(defface agda2-highlight-number-face
  '((((background light))
     (:foreground "purple"))
    (((background dark))
     (:foreground "#9010E0")))
  "The face used for numbers."
  :group 'agda2-highlight-faces)

(defface agda2-highlight-symbol-face
  '((((background light))
     (:foreground "gray25"))
    (((background dark))
     (:foreground "gray75")))
  "The face used for symbols like forall, =, ->, etc."
  :group 'agda2-highlight-faces)

(defface agda2-highlight-primitive-type-face
  '((((background light))
     (:foreground "medium blue"))
    (((background dark))
     (:foreground "#8080FF")))
  "The face used for primitive types (like Set and Prop)."
  :group 'agda2-highlight-faces)

(defface agda2-highlight-bound-variable-face
  '((t nil))
  "The face used for bound variables."
  :group 'agda2-highlight-faces)

(defface agda2-highlight-generalizable-variable-face
  '((t nil))
  "The face used for generalizable variables."
  :group 'agda2-highlight-faces)

(defface agda2-highlight-inductive-constructor-face
  '((((background light))
     :foreground "green4")
    (((background dark))
     :foreground "#29CC29"))
  "The face used for inductive constructors."
  :group 'agda2-highlight-faces)

(defface agda2-highlight-coinductive-constructor-face
  '((((background light))
     :foreground "gold4")
    (((background dark))
     :foreground "#FFEA75"))
  "The face used for coinductive constructors."
  :group 'agda2-highlight-faces)

(defface agda2-highlight-datatype-face
  '((((background light))
     (:foreground "medium blue"))
    (((background dark))
     (:foreground "#8080FF")))
  "The face used for datatypes."
  :group 'agda2-highlight-faces)

(defface agda2-highlight-field-face
  '((((background light))
     (:foreground "DeepPink2"))
    (((background dark))
     (:foreground "#F570B7")))
  "The face used for record fields."
  :group 'agda2-highlight-faces)

(defface agda2-highlight-function-face
  '((((background light))
     (:foreground "medium blue"))
    (((background dark))
     (:foreground "#8080FF")))
  "The face used for functions."
  :group 'agda2-highlight-faces)

(defface agda2-highlight-module-face
  '((((background light))
     (:foreground "purple"))
    (((background dark))
     (:foreground "#CD80FF")))
  "The face used for module names."
  :group 'agda2-highlight-faces)

(defface agda2-highlight-postulate-face
  '((((background light))
     (:foreground "medium blue"))
    (((background dark))
     (:foreground "#8080FF")))
  "The face used for postulates."
  :group 'agda2-highlight-faces)

(defface agda2-highlight-pragma-face
  '((t nil))
  "The face used for (some text in) pragmas."
  :group 'agda2-highlight-faces)

(defface agda2-highlight-primitive-face
  '((((background light))
     (:foreground "medium blue"))
    (((background dark))
     (:foreground "#8080FF")))
  "The face used for primitive functions."
  :group 'agda2-highlight-faces)

(defface agda2-highlight-macro-face
  '((((background light))
     (:foreground "aquamarine4"))
    (((background dark))
     (:foreground "#73BAA2")))
  "The face used for macros."
  :group 'agda2-highlight-faces)

(defface agda2-highlight-record-face
  '((((background light))
     (:foreground "medium blue"))
    (((background dark))
     (:foreground "#8080FF")))
  "The face used for record types."
  :group 'agda2-highlight-faces)

(defface agda2-highlight-dotted-face
  '((t nil))
  "The face used for dotted patterns."
  :group 'agda2-highlight-faces)

(defface agda2-highlight-operator-face
  '((t nil))
  "The face used for operators."
  :group 'agda2-highlight-faces)

(defface agda2-highlight-error-face
  '((((background light))
     (:foreground "red" :underline t))
    (((background dark))
     (:foreground "#FF0000" :underline t)))
  "The face used for errors."
  :group 'agda2-highlight-faces)

(defface agda2-highlight-error-warning-face
  '((((background light))
     (:background "light coral" :underline t))
    (((background dark))
     (:background "#802400" :underline t)))
  "The face used for fatal warnings."
  :group 'agda2-highlight-faces)

(defface agda2-highlight-unsolved-meta-face
  '((((background light))
     (:background "yellow"))
    (((background dark))
     (:background "#806B00")))
  "The face used for unsolved meta variables."
  :group 'agda2-highlight-faces)

(defface agda2-highlight-unsolved-constraint-face
  '((((background light))
     (:background "yellow"))
    (((background dark))
     (:background "#806B00")))
  "The face used for unsolved constraints which are not connected to metas."
  :group 'agda2-highlight-faces)

(defface agda2-highlight-termination-problem-face
  '((((background light))
     (:background "light salmon"))
    (((background dark))
     (:background "#802400")))
  "The face used for termination problems."
  :group 'agda2-highlight-faces)

(defface agda2-highlight-positivity-problem-face
  '((((background light))
     (:background "peru"))
    (((background dark))
     (:background "#803F00")))
  "The face used for positivity problems."
  :group 'agda2-highlight-faces)

(defface agda2-highlight-deadcode-face
  '((((background light))
     (:background "dark gray"))
    (((background dark))
     (:background "#808080")))
  "The face used for dead code (unreachable clauses, etc.)."
  :group 'agda2-highlight-faces)

(defface agda2-highlight-shadowing-in-telescope-face
  '((((background light))
     (:background "dark gray"))
    (((background dark))
     (:background "#808080")))
  "The face used for shadowed repeated variable names in telescopes."
  :group 'agda2-highlight-faces)

(defface agda2-highlight-coverage-problem-face
  '((((background light))
     (:background "wheat"))
    (((background dark))
     (:background "#805300")))
  "The face used for coverage problems."
  :group 'agda2-highlight-faces)

(defface agda2-highlight-catchall-clause-face
  '((((background light))
     (:background "white smoke"))
    (((background dark))
     (:background "#404040")))
  "The face used for catchall clauses."
  :group 'agda2-highlight-faces)

(defface agda2-highlight-confluence-problem-face
  '((((background light))
     (:background "pink"))
    (((background dark))
     (:background "#800080")))
  "The face used for confluence problems."
  :group 'agda2-highlight-faces)

(defface agda2-highlight-missing-definition-face
  '((((background light))
     (:background "orange"))
    (((background dark))
     (:background "#804040")))
  "The face used for type declarations with missing definitions."
  :group 'agda2-highlight-faces)

(defface agda2-highlight-typechecks-face
  '((((background light))
     (:background "light blue" :foreground "black"))
    (((background dark))
     (:background "#006080" :foreground "white")))
  "The face used for code which is being type-checked."
  :group 'agda2-highlight-faces)

(defvar agda2-highlight-faces
  '((keyword                . agda2-highlight-keyword-face)
    (comment                . font-lock-comment-face)
    (background             . default)
    (markup                 . font-lock-comment-delimiter-face)
    (string                 . agda2-highlight-string-face)
    (number                 . agda2-highlight-number-face)
    (symbol                 . agda2-highlight-symbol-face)
    (primitivetype          . agda2-highlight-primitive-type-face)
    (bound                  . agda2-highlight-bound-variable-face)
    (generalizable          . agda2-highlight-generalizable-variable-face)
    (inductiveconstructor   . agda2-highlight-inductive-constructor-face)
    (coinductiveconstructor . agda2-highlight-coinductive-constructor-face)
    (datatype               . agda2-highlight-datatype-face)
    (field                  . agda2-highlight-field-face)
    (function               . agda2-highlight-function-face)
    (module                 . agda2-highlight-module-face)
    (postulate              . agda2-highlight-postulate-face)
    (pragma                 . agda2-highlight-pragma-face)
    (primitive              . agda2-highlight-primitive-face)
    (macro                  . agda2-highlight-macro-face)
    (record                 . agda2-highlight-record-face)
    (dotted                 . agda2-highlight-dotted-face)
    (operator               . agda2-highlight-operator-face)
    (error                  . agda2-highlight-error-face)
    (errorwarning           . agda2-highlight-error-warning-face)
    (unsolvedmeta           . agda2-highlight-unsolved-meta-face)
    (unsolvedconstraint     . agda2-highlight-unsolved-constraint-face)
    (terminationproblem     . agda2-highlight-termination-problem-face)
    (deadcode               . agda2-highlight-deadcode-face)
    (shadowingintelescope   . agda2-highlight-shadowing-in-telescope-face)
    (coverageproblem        . agda2-highlight-coverage-problem-face)
    (positivityproblem      . agda2-highlight-positivity-problem-face)
    (incompletepattern      . agda2-highlight-incomplete-pattern-face)
    (catchallclause         . agda2-highlight-catchall-clause-face)
    (confluenceproblem      . agda2-highlight-confluence-problem-face)
    (missingdefinition      . agda2-highlight-missing-definition-face)
    (typechecks             . agda2-highlight-typechecks-face))
  "Alist mapping code aspects to the face used when displaying them.

The aspects currently recognised are the following:

`background'             Non-Agda code contents in literate mode.
`bound'                  Bound variables.
`catchallclause'         Clause not holding definitionally.
`coinductiveconstructor' Coinductive constructors.
`comment'                Comments.
`coverageproblem'        Coverage problems.
`datatype'               Data types.
`deadcode'               Deadcode (like unreachable clauses or RHS).
`dotted'                 Dotted patterns.
`error'                  Errors.
`errorwarning'           Fatal warnings.
`field'                  Record fields.
`function'               Functions.
`generalizable'          Generalizable variables.
`incompletepattern'      Incomplete patterns.
`inductiveconstructor'   Inductive constructors.
`keyword'                Keywords.
`macro'                  Macros.
`markup'                 Delimiters to separate the Agda code blocks
                           from other contents.
`module'                 Module names.
`number'                 Numbers.
`operator'               Operators.
`positivityproblem'      Positivity problems.
`postulate'              Postulates.
`pragma'                 Text occurring in pragmas that does not have
                           a more specific (syntactic) aspect.
`primitive'              Primitive functions.
`primitivetype'          Primitive types (like Set and Prop).
`record'                 Record types.
`shadowingintelescope'   Shadowed repeated variable names in telescopes.
`string'                 Strings.
`symbol'                 Symbols like forall, =, ->, etc.
`terminationproblem'     Termination problems.
`typechecks'             Code which is being type-checked.
`unsolvedconstraint'     Unsolved constraints, not connected to meta
                           variables.
`unsolvedmeta'           Unsolved meta variables.")

;;;; Variables

(defvar agda2-highlight-in-progress nil
  "If nil, then highlighting annotations are not applied.")
(make-variable-buffer-local 'agda2-highlight-in-progress)

;;;; Functions

(defvar-local agda2-highlight-annotation-bindings nil
  "An association list mapping symbols to faces.")

(defun agda2-highlight-setup ()
  "Set up the `annotation' library for use with `agda2-mode'."
  (agda2-highlight-set-faces 'agda2-highlight-face-groups agda2-highlight-face-groups))

(define-inline agda2-highlight-annotate (start end anns token-based info goto)
  "Annotate text between START and END in the current buffer.

Nothing happens if either START or END are out of bounds for the
current (possibly narrowed) buffer, or (<= END START).

If ANNS is nil, then those text properties between START and END
that have been set by this function are deleted.  Otherwise the
following happens.

All the symbols in ANNS are looked up in `agda2-highlight-faces',
and the resulting list of faces is used to set the face text
property.  For each position in the range the faces are merged
with the current value of the `agda2-highlight-faces' text
property, and both the face and the `agda2-highlight-faces' text
properties are set to the resulting list of faces.

If TOKEN-BASED is non-nil, then the agda2-highlight-token-based
property is set to t. This means that all text properties set by
`agda2-highlight-annotate' in this range are interpreted as being
token-based, including those set by previous calls to this
procedure.

If the string INFO is non-nil, the mouse-face
property is set to highlight, and INFO is used as the help-echo
string.  If GOTO has the form (FILENAME . POSITION), then the
mouse-face property is set to highlight, and the given
filename/position will be used by `agda2-highlight-goto-indirect' when
it is invoked with a position in the given range.

Note that if a given attribute is defined by several faces, then
the first face's setting takes precedence.

All characters whose text properties get set also have the
agda2-highlight-annotated property set to t, and
agda2-highlight-annotations is set to a list with all the properties
that have been set; this ensures that the text properties can
later be removed (if the agda2-highlight-* properties are not tampered
with)."
  (inline-letevals (start end anns token-based info goto)
    (inline-quote
     (when (and (<= (point-min) ,start)
                (< ,start ,end)
                (<= ,end (point-max)))
       (if (null ,anns)
           (agda2-highlight-clean-up nil ,start ,end)
         (let (faces props)
           (dolist (ann ,anns)
             (let ((face (cdr (assoc ann agda2-highlight-faces))))
               (when face (push face faces))))
           (when faces
             (save-excursion
               (save-restriction
                 (narrow-to-region ,start ,end)
                 (goto-char (point-min))
                 (while (not (eobp))
                   (let ((next (or (next-single-property-change (point) 'agda2-highlight-faces)
                                   (point-max))))
                     ;; THINKME: Why do we need `agda2-highlight-faces'?
                     (let* ((old-faces (get-text-property (point) 'agda2-highlight-faces))
                            (all-faces (delete-dups (append faces old-faces))))
                       (put-text-property (point) next 'agda2-highlight-faces all-faces)
                       (put-text-property (point) next 'face all-faces))
                     (goto-char next)))))
             (push 'face props)
             (push 'agda2-highlight-faces props))
           (when ,token-based
             (add-text-properties ,start ,end
                                  (list 'agda2-highlight-token-based t))
             (push 'agda2-highlight-token-based props))
           (when (consp ,goto)
             (add-text-properties
              ,start ,end
              (list 'agda2-xref-info ,goto))
             (push 'agda2-highlight-goto props)
             (push 'mouse-face props))
           (when ,info
             (add-text-properties ,start ,end
                                  (list 'mouse-face 'highlight
                                        'help-echo ,info))
             (push 'mouse-face props)
             (push 'help-echo props))
           (when props
             (push 'agda2-highlight-annotated props)
             (save-excursion
               (save-restriction
                 (narrow-to-region ,start ,end)
                 (while (not (eobp))
                   (let* ((next (or (next-single-property-change
                                     (point) 'agda2-highlight-annotations)
                                    (point-max)))
                          (old-props (get-text-property (point) 'agda2-highlight-annotations))
                          (all-props (delete-dups (append props old-props))))
                     (add-text-properties
                      (point) next
                      (list 'agda2-highlight-annotated t
                            'agda2-highlight-annotations all-props))
                     (goto-char next))))))))))))

(define-inline agda2-highlight-clean-up (token-based start end)
  "Remove highlighting between START and END.
TOKEN-BASED is non-nil, then only token-based properties are
removed."
  (inline-letevals (token-based start end)
    (inline-quote
     (with-silent-modifications
       (save-excursion
         (save-restriction
           (narrow-to-region ,start ,end)
           (goto-char (point-min))
           (let ((tag (if ,token-based
                          'agda2-highlight-token-based
                        'agda2-highlight-annotated)))
             (while (not (eobp))
               (let ((props (get-text-property (point) 'agda2-highlight-annotations))
                     (next (next-single-property-change (point) tag nil ,end)))
                 (when (or (not ,token-based)
                           (member 'agda2-highlight-token-based props))
                   (remove-text-properties
                    (point) next
                    (mapcan (lambda (p) (list p nil)) ;intersperse nils in the list
                            (cons 'agda2-highlight-annotations props))))
                 (when next (goto-char next)))))))))))

(defun agda2-highlight-apply (remove cmds)
  "Add the syntax highlighting information in the annotation list CMDS.

If REMOVE is nil, then old syntax highlighting information is not
removed.  Otherwise all token-based syntax highlighting is removed."
  (declare (speed 3))
  (with-silent-modifications
    (save-excursion
      (goto-char (point-min))
      (dolist (cmd (if (listp (car cmds)) cmds (list cmds)))
        (let* ((start       (pop cmd))
               (end         (pop cmd))
               (anns        (pop cmd))
               (token-based (pop cmd))
               (info        (pop cmd))
               (goto        (pop cmd)))
          (when remove
            (agda2-highlight-clean-up t (point) end)
            (goto-char end))
          (let ((info (if (and (not info) (consp goto))
                          ;; Fall back to a generic message:
                          "Click mouse-2 to jump to definition"
                        info)))
            (agda2-highlight-annotate start end anns token-based info goto))))
      (when remove
        (agda2-highlight-clean-up t (point) (point-max))))))

(defun agda2-highlight-add-annotations (remove &rest cmds)
  "Like `agda2-highlight-apply'.
But only if `agda2-highlight-in-progress' is non-nil.  See
`agda2-highlight-apply' for details on REMOVE and CMDS."
  (declare (agda2-command boolean &repeat list))
  (when agda2-highlight-in-progress
    (agda2-highlight-apply remove cmds)))

(defun agda2-highlight-load (file)
  "Load syntax highlighting information from FILE.
Old syntax highlighting information is not removed."
  (let* ((coding-system-for-read 'utf-8)
         (expr (with-temp-buffer
                 (insert-file-contents file)
                 (goto-char (point-min))
                 (read (current-buffer)))))
    (agda2-highlight-apply (car expr) (cdr expr))))

(defun agda2-highlight-load-and-delete-action (file)
  "Like `agda2-highlight-load', but deletes FILE when done.
And highlighting is only updated if `agda2-highlight-in-progress'
is non-nil."
  (declare (agda2-command string))
  (unwind-protect
      (when agda2-highlight-in-progress
        (agda2-highlight-load file))
    ;; (delete-file file)
    ))

(defun agda2-highlight-clear (&optional token-based)
  "Remove all syntax highlighting.

If TOKEN-BASED is non-nil, then only token-based highlighting is
removed."
  (declare (agda2-command boolean))
  (interactive)
  (agda2-highlight-clean-up token-based (point-min) (point-max)))

(provide 'agda2-highlight)
;;; agda2-highlight.el ends here
