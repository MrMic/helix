(require "helix/misc.scm")
(require (prefix-in helix. "helix/commands.scm"))
(require (prefix-in helix.static. "helix/static.scm"))

(provide hello-steel open-helix-scm)

;;@doc
;; Test : affiche un message dans le statusline
(define (hello-steel)
  (set-error! "Steel est vivant"))

;;@doc
;; Ouvre le fichier helix.scm
(define (open-helix-scm)
  (helix.open (helix.static.get-helix-scm-path)))
