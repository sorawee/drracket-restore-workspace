#lang scribble/manual
@require[@for-label[racket/base]]

@title{drracket-restore-workspace: Restore workspace for DrRacket}
@author[@author+email["Sorawee Porncharoenwase" "sorawee.pwase@gmail.com"]]

When a DrRacket window with at least one tab that corresponds to a file is closed
(potentially due to DrRacket exit),
the menu @menuitem["View" "Restore tabs in the last closed window"]
will be enabled. Clicking it will restore tabs in the last closed window.
