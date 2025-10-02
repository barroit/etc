# SPDX-License-Identifier: LicenseRef-MDM-2.1

set imap_user = 'barroit@naver.com'
set from      = $imap_user

source ~/.mutt/@naver.com
