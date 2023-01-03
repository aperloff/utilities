; make file name and computer title
(set-default 'frame-title-format 
             (list "" "emacs" " : %f" ))

(setq font-lock-maximum-decoration t)
(setq-default tab-width 4)
;; Turn off use of tabs for indentation in many modes
(setq indent-tabs-mode nil)
;; LaTeX mode
(add-hook 'latex-mode-hook '(lambda()
                              (setq indent-tabs-mode nil)
                              )
	  )

;; C mode
(add-hook 'c-mode-hook '(lambda()
                          (setq indent-tabs-mode nil)
                          )
	  )

;; C++ mode
(add-hook 'c++-mode-hook '(lambda()
                            (setq indent-tabs-mode nil)
                            )
	  )

;; Fortran mode
(add-hook 'fortran-mode-hook '(lambda()
				(setq indent-tabs-mode nil)
				)
	  )

;; perl mode
(add-hook 'perl-mode-hook '(lambda()
                             (setq indent-tabs-mode nil)
                             )
	  )

;; Lisp mode
(add-hook 'lisp-mode-hook '(lambda()
                             (setq indent-tabs-mode nil)
                             )
	  )

              (set-background-color "Black")
              (set-foreground-color "snow")
              (set-mouse-color "orchid")
              (set-cursor-color "orchid")
              (set-face-background 'region "darkred")
              (set-face-foreground 'region "white")
              (setq w3-node-style 'font-lock-keyword-face)
              (setq w3-address-style 'font-lock-comment-face)
              (setq w3-bold-style 'font-lock-keyword-face)
              (setq w3-italic-style 'font-lock-comment-face)

(if (eq window-system 'x)
    (progn
      (transient-mark-mode t)
      
      (if (fboundp 'what\ line) (fmakunbound 'what\ line))
      (if (fboundp 'set\ cursor\ free) (fmakunbound 'set\ cursor\ free))
      (if (fboundp 'set\ cursor\ bound)
          (fmakunbound 'set\ cursor\ bound))
      (if (fboundp 'set\ scroll\ margins)
          (fmakunbound 'set\ scroll\ margins))
      (if (fboundp 'what\ line) (fmakunbound 'what\ line))
      
      (if (x-display-color-p)
          (progn
            (eval-after-load
             "font-lock"
             '(progn
                (setq c-font-lock-keywords    c-font-lock-keywords-2
                      c++-font-lock-keywords  c++-font-lock-keywords-2
                      lisp-font-lock-keywords lisp-font-lock-keywords-2)))

            (global-font-lock-mode t)
            
            (mapcar (function
                     (lambda (flist)
                       (copy-face (car (cdr flist)) (car flist))
                       (set-face-foreground (car flist) (car (cdr (cdr flist))))
))
                          
                    '((comment-color            italic          "orange")
                      (doc-string-color         italic          "turquoise")
                      (string-color             italic          "green")
                      (function-name-color      default         "yellow")
                      (keyword-color            default         "greenyellow")
                      (variable-color           default         "cyan" )
                      (type-color               default         "skyblue")
                      (italic-blue              default         "skyblue")
                      )
                    )
            
            (setq font-lock-comment-face       `comment-color
                  font-lock-doc-string-face    `doc-string-color
                  font-lock-string-face        `string-color
                  font-lock-function-name-face `function-name-color
                  font-lock-keyword-face       `keyword-color
                  font-lock-variable-name-face `variable-color
                  font-lock-type-face          `type-color
                  )
            
    
;            (set-face-foreground 'font-lock-comment-face "saddle brown")
;            (set-face-foreground 'font-lock-doc-string-face "chocolate")
;            (set-face-foreground 'font-lock-string-face "firebrick")
;            (set-face-foreground 'font-lock-function-name-face "blue")
;            (set-face-foreground 'font-lock-keyword-face "slate blue")
;            (set-face-foreground 'font-lock-type-face "steel blue")
            (set-face-foreground 'modeline "black")
            (set-face-background 'modeline "lavender")
;           (set-face-foreground 'font-lock-type-face `type-color)

;;;;;;;;;; Background color
;            (set-background-color "\#0D0A28")
            (set-background-color "Black")
            (set-foreground-color "snow")
            (set-mouse-color "orchid")
            (set-cursor-color "orchid")
            (set-face-background 'region "darkred")
            (set-face-foreground 'region "white")
            (setq w3-node-style 'font-lock-keyword-face)
            (setq w3-address-style 'font-lock-comment-face)
            (setq w3-bold-style 'font-lock-keyword-face)
            (setq w3-italic-style 'font-lock-comment-face)
            )
                                        ; else x-display-color-p
        (if (eq 'gray-scale (x-display-visual-class))
            (progn
              (set-face-background 'region "DarkSlateGrey")
              )
          (progn
            (set-face-background 'region "White")
            (set-face-foreground 'region "Black")
            (setq hilit-background-mode 'mono)
            )
          )
        )
      )
  )


(mapcar (function
        (lambda (flist)
                (copy-face (car (cdr flist)) (car flist))
                (set-face-foreground (car flist) (car (cdr (cdr flist))))
))
         '((comment-color             default		   "orange")
            (doc-string-color         default		   "turquoise")
            (string-color             default		   "green")
            (function-name-color      default         "yellow")
            (keyword-color            default         "greenyellow")
            (variable-color           default         "cyan" )
            (type-color               default         "skyblue")
            (italic-blue              default         "skyblue")
            )
          )


(setq auto-mode-alist
      (append
    '(("\\.ftn$"  . fortran-mode)
      ("\\.for$"  . fortran-mode)
      ("\\.F$"    . fortran-mode)
      ("\\.inc$"  . fortran-mode)
      ("\\.pfp$"  . fortran-mode)
      ("\\.car$"  . fortran-mode)
      ("\\.edt$"  . fortran-mode)
      ("\\.temp$" . fortran-mode)
      ("\\.lex$"  . c-mode)
      ("\\.C$"    . c++-mode)
      ("\\.cc$"   . c++-mode)
      ("\\.icc$"   . c++-mode)
      ("\\.c$"    . c++-mode)
      ("\\.h$"    . c++-mode)
      ("\\.cxx$"  . c++-mode)
;      ("\\.html$" . html-mode)
      ("\\.py$"   . python-mode)
        )
    auto-mode-alist))

(setq c++-indent-level 4
      c++-continued-statement-offset 4
      c++-brace-offset -4
      c++-argdecl-indent 4
      c++-label-offset -4)

;(setq fortran-do-indent 4
;      fortran-if-indent 4
;      fortran-comment-indent-style nil
;      fortran-continuation-char 38)

; some interesting modes:
(add-hook 'c++-mode-hook (function (lambda () (setq indent-tabs-mode nil) (c-set-style "Ellemtel"))))
                            (setq indent-tabs-mode nil)



;;; Tramp stuff

;(add-to-list 'load-path "~/emacs/tramp/lisp/")
;(require 'tramp)
;(setq tramp-default-method "scpx")


(global-font-lock-mode t)
(global-set-key "\M-g" 'goto-line)
(global-set-key "\M-$" 'ispell-complete-word)
(global-set-key "\C-z" 'undo)
(global-set-key [f1]     'revert-buffer)
(global-set-key [f2]     'font-lock-fontify-buffer)
(global-set-key [f11]    'auto-save-mode)
(global-set-key [f12]    'tool-bar-mode)

( if (string-match "^21" emacs-version)
	(progn
	  ; Emacs 21 only stuff here
	  ;(global-set-key (kbd "<home>") 'beginning-of-buffer)
	  ;(global-set-key (kbd "<end>") 'end-of-buffer)
	  (tool-bar-mode)
      (mouse-wheel-mode) 
)
)

;; Enable wheelmouse support by default
;(if (not running-xemacs)
    (require 'mwheel) ; Emacs
;  (mwheel-install) ; XEmacs
;)

;(require 'mwheel)
;(require 'mouse)
;(xterm-mouse-mode t)
;(mouse-wheel-mode t)
;(global-set-key [mouse-5] 'next-line)
;(global-set-key [mouse-4] 'previous-line)

;; auto fill
(add-hook 'text-mode-hook 'turn-on-auto-fill)
(custom-set-variables
  ;; custom-set-variables was added by Custom -- don't edit or cut/paste it!
  ;; Your init file should contain only one such instance.
 '(auto-compression-mode t nil (jka-compr))
 '(case-fold-search t)
 '(current-language-environment "English")
 '(global-font-lock-mode t nil (font-lock))
 '(show-paren-mode t nil (paren))
 '(text-mode-hook (quote (turn-on-auto-fill text-mode-hook-identify)))
 '(transient-mark-mode t))
(custom-set-faces
  ;; custom-set-faces was added by Custom -- don't edit or cut/paste it!
  ;; Your init file should contain only one such instance.
 )
