--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-LAWMAN — Locale: Georgian (ქართული)
     Developer   : iBoss21 | Brand : LXRCore | https://www.lxrcore.com
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

Locale.Register('ka', {
    error = {
        nothing_owed = 'არაფერი გმართებს.',
        rate = 'შენელდი.', invalid = 'მოთხოვნა არასწორია.', too_far = 'მიუახლოვდი.', not_law = 'აქ შენ კანონი არ ხარ.', no_cuffs = 'ხელბორკილი არ გაქვს.',
        not_cuffed = 'ხელბორკილი არ ადევს.', bad_amount = 'ეს თანხა კანონიერი არ არის.', cannot_pay = 'გადახდა არ შეუძლია.', bad_sentence = 'ეს სასჯელი კანონიერი არ არის.',
        no_armoury = 'შენს რანგს საიარაღოს გასაღები არ აქვს.', no_such_name = 'ასეთი სახელი საოლქო სიაში არ არის.', no_bounty = 'ამ სახელზე ჯილდო არ არის.', nobody_cuffed = 'ახლოს ხელბორკილიანი არავინაა.',
    },
    info = {
        fine_owed = '%{name}-ს არ შეუძლია გადახდა — $%{amount} ჩაიწერა ვალად.', you_owe = 'გმართებს $%{amount} (%{reason}). გადაიხადე სამმართველოს მაგიდასთან.', fines_paid = 'ჯარიმები გადახდილია: $%{amount}.',
        on_duty = 'მორიგეობაზე ხარ.', off_duty = 'მორიგეობა დამთავრდა.', cuffed = '%{name} ბორკილშია.', uncuffed = '%{name} თავისუფალია.', you_cuffed = 'ბორკილში ხარ.', you_uncuffed = 'ბორკილი მოგეხსნა.',
        seized = 'ამოღებულია %{n} ნივთი ნივთმტკიცებაში.', fined = '%{name} დაჯარიმდა $%{amount}-ით.', you_fined = 'ჯარიმა $%{amount}: %{reason}', jailed = '%{name} გაგზავნილია სისიკაში %{minutes} წუთით.',
        you_jailed = 'სისიკა, %{minutes} წუთი: %{reason}', released = '%{name} გათავისუფლდა.', served = 'სასჯელი მოიხადე.', walked_back = 'მცველები უკან გაბრუნებენ.',
        bounty_paid = 'ოლქი იხდის $%{amount}-ს.',
    },
    call = { backup = '%{name}-ს დახმარება სჭირდება' },
    ui = {
        warrants = 'ღია ორდერები', records = 'ჩანაწერების წიგნი', look_up = 'მოძებნა', write = 'ჩაწერა', no_warrants = 'ღია ორდერი არ არის', no_records = 'ჩანაწერი არ არის — მოძებნე სახელით ან ID-ით',
        serve = 'შესრულდა', kind_note = 'შენიშვნა', kind_warrant = 'ორდერი', kind_fine = 'ჯარიმა', kind_sentence = 'სასჯელი', kind_seizure = 'ამოღება', status_open = 'ღია', status_paid = 'გადახდილი', status_served = 'შესრულებული', status_expired = 'ვადაგასული',
        what_happened = 'რა მოხდა', name_or_id = 'სახელი ან ID', pay_fines = 'ჯარიმების გადახდა',
        citizen = 'უცნობი', cuff = 'ბორკილის დადება', uncuff = 'ბორკილის მოხსნა', escort = 'წაყვანა / გაშვება', search = 'გაჩხრეკა', seize = 'კონტრაბანდის ამოღება', fine = 'ჯარიმა', jail = 'სისიკაში გაგზავნა', release = 'გათავისუფლება',
        amount = 'თანხა ($)', reason = 'მიზეზი', minutes = 'წუთი', desk = 'მაგიდა', turnin = 'ჯილდოს ჩაბარება', armoury = 'საიარაღო', evidence = 'ნივთმტკიცების საცავი', open = 'გახსნა',
        desk_kicker = 'უბნის მაგიდა', hint_close = 'წასვლა', close = 'წასვლა', badge = 'სამკერდე ნიშანი', on_duty = 'ახლა მორიგეობაზე', nobody_on_duty = 'მორიგეობაზე არავინაა.', go_on_duty = 'მორიგეობის დაწყება', go_off_duty = 'მორიგეობის დამთავრება',
        board = 'ჯილდოების დაფა', citizen_id = 'მოქალაქის ID', for_what = 'რისთვის', post = 'გამოცხადება', pull = 'მოხსნა', posted_by = 'გამოაცხადა', board_empty = 'დაფაზე სახელები არ არის.',
    },
})
