;;; js.el -*- lexical-binding: t; -*-
(provide 'jsconfig)

(use-package js2-mode :ensure t :defer 20
  :mode
  (("\\.js\\'" . js2-mode))
  :custom
  (js2-include-node-externs t)
  (js2-global-externs '("customElements"))
  (js2-highlight-level 3)
  (js2r-prefer-let-over-var t)
  (js2r-prefered-quote-type 2)
  (js-indent-align-list-continuation t)
  (global-auto-highlight-symbol-mode t)
  :config
  (setq js-indent-level 2)
  ;; patch in basic private field support
  (advice-add #'js2-identifier-start-p
            :after-until
            (lambda (c) (eq c ?#)(use-package js2-mode :ensure t :defer 20
  :mode
  (("\\.js\\'" . js2-mode))
  :custom
  (js2-include-node-externs t)
  (js2-global-externs '("customElements"))
  (js2-highlight-level 3)
  (js2r-prefer-let-over-var t)
  (js2r-prefered-quote-type 2)
  (js-indent-align-list-continuation t)
  (global-auto-highlight-symbol-mode t)
  :config
  (setq js-indent-level 2)
  ;; patch in basic private field support
  (advice-add #'js2-identifier-start-p
            :after-until
            (lambda (c) (eq c ?#))))

(use-package projectile :ensure t :defer 1
  :config
  (projectile-mode)
  :config
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (bind-key "C-c p s" 'projectile-ripgrep)
  (setq projectile-sort-order 'modification-time))

(use-package which-key :ensure t
  :config
  (which-key-mode))

(use-package company :ensure t :defer 20
  ;; This is not perfect yet. It completes too quickly outside programming modes, but while programming it is just right.
  :custom
  (company-idle-delay 0.1)
  (global-company-mode t)
  (debug-on-error nil) ;; otherwise this throws lots of errors on completion errors
  :config
  (define-key company-active-map (kbd "TAB") 'company-complete-selection)
  (define-key company-active-map (kbd "<tab>") 'company-complete-selection)
  (define-key company-active-map [return] 'company-complete-selection)
  (define-key company-active-map (kbd "RET") 'company-complete-selection)
  ;; auto-complete compatibility
  (defun my-company-visible-and-explicit-action-p ()
    (and (company-tooltip-visible-p)
         (company-explicit-action-p)))
  (defun company-ac-setup ()
    "Sets up `company-mode' to behave similarly to `auto-complete-mode'."
    (setq company-require-match nil)
    (setq company-auto-complete #'my-company-visible-and-explicit-action-p)
    (setq company-frontends '(company-echo-metadata-frontend
                              company-pseudo-tooltip-unless-just-one-frontend-with-delay
                              company-preview-frontend))
    (define-key company-active-map [tab]
      'company-select-next-if-tooltip-visible-or-complete-selection)
    (define-key company-active-map (kbd "TAB")
      'company-select-next-if-tooltip-visible-or-complete-selection))

  (company-ac-setup)
  (add-hook 'js2-mode-hook (lambda () (company-mode))))

(use-package company-quickhelp :ensure t :defer 30
  :config
  (company-quickhelp-mode t))

(use-package dumb-jump :ensure t :defer 10
  :custom
  (dumb-jump-rg-search-args '())
  :config
  (defun jump-to-mouse-position (event &optional promote-to-region)
    (interactive "e\np")
    (mouse-set-point event promote-to-region)
    (dumb-jump-go))
  (global-unset-key [C-down-mouse-1])
  (define-key global-map [C-mouse-1] 'jump-to-mouse-position))

;; Highlight TODO, FIXME, ... in any programming mode
(require 'fic-mode)
(add-hook 'prog-mode-hook 'fic-mode)

(use-package flymake-eslint :ensure t :defer 10
  :custom ;; add glasses-mode to bolden capitals in CamelCase here. Could also be done elsewhere.
  (glasses-face (quote bold))
  (glasses-original-separator "")
  (glasses-separate-capital-groups t)
  (glasses-separate-parentheses-p nil)
  (glasses-separator "")
  :config
  (add-hook 'js-mode-hook (lambda () (flymake-eslint-enable)(flymake-mode -1)(flycheck-mode 1)(glasses-mode 1)))
  (add-hook 'js2-mode-hook (lambda () (flymake-eslint-enable)(flymake-mode -1)(flycheck-mode 1)(glasses-mode 1)))
  (custom-set-variables
     '(help-at-pt-timer-delay 0.3)
     '(help-at-pt-display-when-idle '(flymake-overlay))))
(use-package flymake-diagnostic-at-point :ensure t :defer 20
  :config
  (flymake-diagnostic-at-point-mode t))

(use-package tern :ensure t :defer 30
  :if (locate-file "tern" exec-path)
  :hook (js2-mode . tern-mode))
(use-package json-mode :ensure t :defer 20
  :custom
  (json-reformat:indent-width 2)
  :mode (("\\.bowerrc$"     . json-mode)
         ("\\.jshintrc$"    . json-mode)
         ("\\.json_schema$" . json-mode)
         ("\\.json\\'" . json-mode))
  :bind (:package json-mode-map
         :map json-mode-map
         ("C-c <tab>" . json-mode-beautify)))

(use-package company-tern :ensure t :defer 30
  :config
  (add-to-list 'company-backends 'company-tern)
  (define-key tern-mode-keymap (kbd "M-.") nil)
  (define-key tern-mode-keymap (kbd "M-,") nil))

(use-package js2-refactor :ensure t :defer 30
  :config
  (add-hook 'js2-mode-hook #'js2-refactor-mode)
  (js2r-add-keybindings-with-prefix "C-c C-m"))
;; context menu for keybindings
(use-package discover :ensure t :defer 30
  :config
  (global-discover-mode 1))

;; ido-preview
(use-package ido-preview ;; no need to ensure: it is part of emacs
  :config
  (add-hook 'ido-setup-hook
            (lambda()
              (define-key ido-completion-map (kbd "C-M-p") (lookup-key ido-completion-map (kbd "C-p")))
              (define-key ido-completion-map (kbd "C-M-n") (lookup-key ido-completion-map (kbd "C-n"))) ; currently, this makes nothing. Maybe they'll make C-n key lately.
              (define-key ido-completion-map (kbd "C-p") 'ido-preview-backward)
              (define-key ido-completion-map (kbd "C-n") 'ido-preview-forward)))
  (defun rebuild-resources (folder)
    "Rebuild resources and generate code in the to-be-selected module."
    (interactive
     (progn
       (list (ido-read-directory-name
              "Select module: " "~/Cadenza/cadenza-master/cadenza"))
       ))
    (async-shell-command (concat "bash -i -c 'cd " folder "; source ~/.bashrc; cd " folder "; Xvfb :3 -screen 0 1024x768x16 & time DISPLAY=:3 LD_LIBRARY_PATH=$HOME/.guix-profile/lib mvn11 generate-sources process-resources install validate -DskipTests=true'")))
  :custom
  (ido-buffer-disable-smart-matches nil)
  (ido-cr+-auto-update-blacklist t)
  (ido-cr+-function-whitelist nil)
  (ido-cr+-max-items 30000)
  (ido-cr+-replace-completely nil)
  (ido-enable-dot-prefix t)
  (ido-enable-flex-matching t)
  (ido-everywhere t)
  (ido-max-work-file-list 10)
  (ido-mode (quote both) nil (ido))
  (ido-ubiquitous-mode t)
  (ido-use-filename-at-point (quote guess))
  (ido-use-url-at-point t))


(use-package tabbar :ensure t)

(use-package rainbow-identifiers :ensure t
  :config
  (defun rainbow-identifiers--bolden-faces ()
    (dotimes (i 15) ;; TODO: use number of faces as customized
      (face-remap-add-relative (intern (format "rainbow-identifiers-identifier-%d" (1+ i))) :weight 'bold)))
  (add-hook 'rainbow-identifiers-mode-hook 'rainbow-identifiers--bolden-faces)
  (rainbow-identifiers--bolden-faces))
)))

(use-package projectile :ensure t :defer 1
  :config
  (projectile-mode)
  :config
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (bind-key "C-c p s" 'projectile-ripgrep)
  (setq projectile-sort-order 'modification-time))

(use-package which-key :ensure t
  :config
  (which-key-mode))

(use-package company :ensure t :defer 20
  ;; This is not perfect yet. It completes too quickly outside programming modes, but while programming it is just right.
  :custom
  (company-idle-delay 0.1)
  (global-company-mode t)
  (debug-on-error nil) ;; otherwise this throws lots of errors on completion errors
  :config
  (define-key company-active-map (kbd "TAB") 'company-complete-selection)
  (define-key company-active-map (kbd "<tab>") 'company-complete-selection)
  (define-key company-active-map [return] 'company-complete-selection)
  (define-key company-active-map (kbd "RET") 'company-complete-selection)
  ;; auto-complete compatibility
  (defun my-company-visible-and-explicit-action-p ()
    (and (company-tooltip-visible-p)
         (company-explicit-action-p)))
  (defun company-ac-setup ()
    "Sets up `company-mode' to behave similarly to `auto-complete-mode'."
    (setq company-require-match nil)
    (setq company-auto-complete #'my-company-visible-and-explicit-action-p)
    (setq company-frontends '(company-echo-metadata-frontend
                              company-pseudo-tooltip-unless-just-one-frontend-with-delay
                              company-preview-frontend))
    (define-key company-active-map [tab]
      'company-select-next-if-tooltip-visible-or-complete-selection)
    (define-key company-active-map (kbd "TAB")
      'company-select-next-if-tooltip-visible-or-complete-selection))

  (company-ac-setup)
  (add-hook 'js2-mode-hook (lambda () (company-mode))))

(use-package company-quickhelp :ensure t :defer 30
  :config
  (company-quickhelp-mode t))

(use-package dumb-jump :ensure t :defer 10
  :custom
  (dumb-jump-rg-search-args '())
  :config
  (defun jump-to-mouse-position (event &optional promote-to-region)
    (interactive "e\np")
    (mouse-set-point event promote-to-region)
    (dumb-jump-go))
  (global-unset-key [C-down-mouse-1])
  (define-key global-map [C-mouse-1] 'jump-to-mouse-position))

;; Highlight TODO, FIXME, ... in any programming mode
(require 'fic-mode)
(add-hook 'prog-mode-hook 'fic-mode)

(use-package flymake-eslint :ensure t :defer 10
  :custom ;; add glasses-mode to bolden capitals in CamelCase here. Could also be done elsewhere.
  (glasses-face (quote bold))
  (glasses-original-separator "")
  (glasses-separate-capital-groups t)
  (glasses-separate-parentheses-p nil)
  (glasses-separator "")
  :config
  (add-hook 'js-mode-hook (lambda () (flymake-eslint-enable)(flymake-mode -1)(flycheck-mode 1)(glasses-mode 1)))
  (add-hook 'js2-mode-hook (lambda () (flymake-eslint-enable)(flymake-mode -1)(flycheck-mode 1)(glasses-mode 1)))
  (custom-set-variables
     '(help-at-pt-timer-delay 0.3)
     '(help-at-pt-display-when-idle '(flymake-overlay))))
(use-package flymake-diagnostic-at-point :ensure t :defer 20
  :config
  (flymake-diagnostic-at-point-mode t))

(use-package tern :ensure t :defer 30
  :if (locate-file "tern" exec-path)
  :hook (js2-mode . tern-mode))
(use-package json-mode :ensure t :defer 20
  :custom
  (json-reformat:indent-width 2)
  :mode (("\\.bowerrc$"     . json-mode)
         ("\\.jshintrc$"    . json-mode)
         ("\\.json_schema$" . json-mode)
         ("\\.json\\'" . json-mode))
  :bind (:package json-mode-map
         :map json-mode-map
         ("C-c <tab>" . json-mode-beautify)))

(use-package company-tern :ensure t :defer 30
  :config
  (add-to-list 'company-backends 'company-tern)
  (define-key tern-mode-keymap (kbd "M-.") nil)
  (define-key tern-mode-keymap (kbd "M-,") nil))

(use-package js2-refactor :ensure t :defer 30
  :config
  (add-hook 'js2-mode-hook #'js2-refactor-mode)
  (js2r-add-keybindings-with-prefix "C-c C-m"))
;; context menu for keybindings
(use-package discover :ensure t :defer 30
  :config
  (global-discover-mode 1))

;; ido-preview
(use-package ido-preview ;; no need to ensure: it is part of emacs
  :config
  (add-hook 'ido-setup-hook
            (lambda()
              (define-key ido-completion-map (kbd "C-M-p") (lookup-key ido-completion-map (kbd "C-p")))
              (define-key ido-completion-map (kbd "C-M-n") (lookup-key ido-completion-map (kbd "C-n"))) ; currently, this makes nothing. Maybe they'll make C-n key lately.
              (define-key ido-completion-map (kbd "C-p") 'ido-preview-backward)
              (define-key ido-completion-map (kbd "C-n") 'ido-preview-forward)))
  (defun rebuild-resources (folder)
    "Rebuild resources and generate code in the to-be-selected module."
    (interactive
     (progn
       (list (ido-read-directory-name
              "Select module: " "~/Cadenza/cadenza-master/cadenza"))
       ))
    (async-shell-command (concat "bash -i -c 'cd " folder "; source ~/.bashrc; cd " folder "; Xvfb :3 -screen 0 1024x768x16 & time DISPLAY=:3 LD_LIBRARY_PATH=$HOME/.guix-profile/lib mvn11 generate-sources process-resources install validate -DskipTests=true'")))
  :custom
  (ido-buffer-disable-smart-matches nil)
  (ido-cr+-auto-update-blacklist t)
  (ido-cr+-function-whitelist nil)
  (ido-cr+-max-items 30000)
  (ido-cr+-replace-completely nil)
  (ido-enable-dot-prefix t)
  (ido-enable-flex-matching t)
  (ido-everywhere t)
  (ido-max-work-file-list 10)
  (ido-mode (quote both) nil (ido))
  (ido-ubiquitous-mode t)
  (ido-use-filename-at-point (quote guess))
  (ido-use-url-at-point t))


(use-package tabbar :ensure t)

(use-package rainbow-identifiers :ensure t
  :config
  (defun rainbow-identifiers--bolden-faces ()
    (dotimes (i 15) ;; TODO: use number of faces as customized
      (face-remap-add-relative (intern (format "rainbow-identifiers-identifier-%d" (1+ i))) :weight 'bold)))
  (add-hook 'rainbow-identifiers-mode-hook 'rainbow-identifiers--bolden-faces)
  (rainbow-identifiers--bolden-faces))
