--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-LAWMAN — Locale: English (canonical)
     Developer   : iBoss21 | Brand : LXRCore | https://www.lxrcore.com
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

Locale.Register('en', {
    error = {
        rate = 'Slow down.', invalid = 'That request is not valid.', too_far = 'Get closer.', not_law = 'You are not the law here.', no_cuffs = 'You have no handcuffs.',
        not_cuffed = 'They are not cuffed.', bad_amount = 'That amount is not lawful.', cannot_pay = 'They cannot pay.', bad_sentence = 'That sentence is not lawful.',
        no_armoury = 'Your grade has no armoury key.', no_such_name = 'No such name on the county rolls.', no_bounty = 'No bounty on that name.', nobody_cuffed = 'Nobody in cuffs nearby.',
    },
    info = {
        on_duty = 'On duty.', off_duty = 'Off duty.', cuffed = '%{name} is in irons.', uncuffed = '%{name} is free.', you_cuffed = 'You are in irons.', you_uncuffed = 'The irons come off.',
        seized = 'Seized %{n} items into evidence.', fined = 'Fined %{name} $%{amount}.', you_fined = 'Fined $%{amount}: %{reason}', jailed = '%{name} sent to Sisika for %{minutes} minutes.',
        you_jailed = 'Sisika, %{minutes} minutes: %{reason}', released = '%{name} released.', served = 'You have served your time.', walked_back = 'The guards walk you back.',
        bounty_paid = 'The county pays $%{amount}.',
    },
    call = { backup = '%{name} needs help' },
    ui = {
        citizen = 'Stranger', cuff = 'Cuff', uncuff = 'Uncuff', escort = 'Escort / let go', search = 'Search', seize = 'Seize contraband', fine = 'Fine', jail = 'Send to Sisika', release = 'Release',
        amount = 'Amount ($)', reason = 'Reason', minutes = 'Minutes', desk = 'The desk', turnin = 'Turn in a bounty', armoury = 'Armoury', evidence = 'Evidence locker', open = 'Open',
        desk_kicker = 'Station desk', hint_close = 'leave', close = 'Leave', badge = 'Badge', on_duty = 'On duty now', nobody_on_duty = 'Nobody on duty.', go_on_duty = 'Go on duty', go_off_duty = 'Go off duty',
        board = 'Bounty board', citizen_id = 'Citizen id', for_what = 'For what', post = 'Post', pull = 'Pull', posted_by = 'posted by', board_empty = 'No names on the board.',
    },
})
