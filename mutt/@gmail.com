# SPDX-License-Identifier: LicenseRef-MDM-2.1

source ~/.mutt/auth.oauth2

set smtp_url = "smtp://$imap_user@smtp.gmail.com:587/"

set folder    = 'imaps://imap.gmail.com/'
set spoolfile = +INBOX
set record    = ''
set postponed = '+[Gmail]/Drafts'
set trash     = '+[Gmail]/Trash'
