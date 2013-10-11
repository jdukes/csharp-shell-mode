;; www.masteringemacs.org/articles/2013/07/31/comint-writing-command-interpreter/

;; todo:
;; make csharp-shell-pkg-path variable work
;; Figure out how to autoload assemblies based on projects/build files??
;; Add introspection
;; Add completion based on introspection
;; Add ability to execute region in csharp repl
;; Add error parsing 



(require 'csharp-mode)
(require 'comint)

(autoload 'comint-mode "comint")

(defvar csharp-executable "csharp"
  "Path to the program used by `csharp-shell'.")
 
(defvar csharp-shell-arguments '()
  "Commandline arguments to pass to `csharp-shell'")

(defvar csharp-shell-preload '()
  "List of assemblies to load when `csharp-shell' starts.")

;; (defvar csharp-shell-pkg-path '()
;;   "Where to load assemblies from when the full path isn't
;;   given. This is equivelent to defining the PKG_CONFIG_PATH
;;   environment variable.")
 
(defvar csharp-shell-mode-map
  (let ((map (nconc (make-sparse-keymap) comint-mode-map)))
    ;; example definition
    (define-key map "\t" 'completion-at-point)
    map)
  "Basic mode map for `csharp-shell'")
 
(defvar csharp-shell-prompt-regexp "^\\(?:csharp> \\)"
  "Prompt for `csharp-shell'.")

;; (defun csharp-shell ()
;;   "Run an inferior instance of `csharp-shell' inside Emacs."
;;   (interactive)
;;   (let ((buf (get-buffer "*csharp*")))
;;     (if buf
;;         (pop-to-buffer buf)
;;         (progn
;;           (split-window)
;;           (other-window 1)
;;           (comint-run "csharp")
;; 	  ))))

(defun inferior-csharp-shell ()
  "Run an inferior instance of `csharp' inside Emacs."
  (interactive)
  (let* ((csharp-program csharp-executable)
         (buffer (comint-check-proc "csharp")))
    ;; pop to the "*Csharp*" buffer if the process is dead, the
    ;; buffer is missing or it's got the wrong mode.
    (pop-to-buffer-same-window
     (if (or buffer (not (derived-mode-p 'csharp-shell-mode))
             (comint-check-proc (current-buffer)))
         (get-buffer-create (or buffer "*csharp*"))
       (current-buffer)))
    ;; create the comint process if there is no buffer.
    (unless buffer
      (apply 'make-comint-in-buffer "csharp" buffer
             csharp-program csharp-shell-arguments)
      )))

(defun inferior-csharp-shell--initialize ()
  "Helper function to initialize csharp-shell"
  (setq comint-process-echoes t)
  (setq comint-use-prompt-regexp t)
  (csharp-shell-mode))
 
(define-derived-mode csharp-shell-mode comint-mode "csharp"
  "Major mode for `csharp-shell'.
 
\\<csharp-shell-mode-map>"
  nil "csharp"
  (setq comint-prompt-regexp csharp-shell-prompt-regexp)
  ;; this makes it read only; a contentious subject as some prefer the
  ;; buffer to be overwritable.
  (setq comint-prompt-read-only t)
  (set (make-local-variable 'font-lock-defaults) '(csharp-font-lock-keywords t))
  (set (make-local-variable 'paragraph-start) csharp-shell-prompt-regexp))

 
;; this has to be done in a hook. grumble grumble.
(add-hook 'csharp-shell-mode-hook 'inferior-csharp-shell--initialize)
;; need to add a loop that sends 
;; LoadAssembly("<assembly>"); with comint 
;;(comint-simple-send "csharp" "1 + 1;")
;; comint-send-inputcomint-send-input

;; comint-dynamic-complete-filename <- for LoadAssembly and functions that take file names

