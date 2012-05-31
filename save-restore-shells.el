;; save-restore-shells.el
;; Functions for saving and restoring shell running inside emacs.
;; Supports just shell-mode for now.
;; Saves buffer names and shell paths to ~/.emacs.d/savedshells.el

(defun save-shells () 
  "Saves all current shell's buffer names and default directories"
  (interactive)
  (with-temp-buffer
    (let (saved-shells '())
      (dolist (buffer (buffer-list))
        (save-excursion 
          (set-buffer buffer)
          (if (eq major-mode 'shell-mode)
              (setq saved-shells 
                    (cons (buffer-name) 
                          (cons default-directory saved-shells))))))
      (prin1 saved-shells (get-buffer (buffer-name)))
      (write-region nil nil "~/.emacs.d/savedshells.el"))))

(defun restore-shells ()
  "Restores all saved shell-buffers"
  (interactive)
  (defun invoke-shells (saved-shells)
    (cond ((eq saved-shells '()) t)
          (:else
           (let ((buffer-name (first saved-shells))
                 (path (second saved-shells)))
             (shell (first saved-shells))
             (process-send-string buffer-name (concat "cd " path "\n"))
             (restore-saved-shells-helper (cddr saved-shells))))))
  (defun read-file (file)
    (with-temp-buffer
      (insert-file-contents-literally file)
      (read (buffer-string))))
  (invoke-shells (read-file "~/.emacs.d/savedshells.el")))
