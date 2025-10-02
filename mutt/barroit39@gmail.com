# SPDX-License-Identifier: LicenseRef-MDM-2.1

set imap_user = 'barroit39@gmail.com'
set from      = $imap_user

source ~/.mutt/@gmail.com
