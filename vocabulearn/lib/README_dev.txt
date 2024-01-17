1_home
    INTER
        create_all_files
            create_file
        filter_list_of_list
            read_list_from_file_name
        create_all_occ
        import_setting_async
        go_to_account
        go_to_settings
        go_to_trouver
        restart_home
    FINAL
        pushTrouver
        pushApprendre
        pushAccount
        pushSettings
    DEBUG
    reintializeAllFiles
        reinitializeFiles

2_trouver
    INTER
        save_data_one
        import_list_async
        save_settings_difficulty
    FINAL
        rightPush
        leftPush
        save_data
        moreDifficulty
        lessDifficulty
        pushApprendre
        _willPopCallback (Home)
    DEBUG
        restart_trouver

2_1_paire
    INTER
        french_or_english
    FINAL
        onPressed
        go_to_quizz
        _willPopCallback (Home)
    DEBUG
        restart_paire

2_2_quizz
    INTER
        get_quizz_words
        go_to_fuzzy
    FINAL
        pushButton
        _willPopCallback (Paire(..))

2_3_fuzzy
    INTER
        go_to_sort
    FINAL
        _fuzzyMatch
        _spoilPush
        _nextPush
        _submitPush
        _willPopCallback (Quizz(..))

2_4_1_sort_multi
    INTER
        export_list
        go_to_home
        list_go_to_end
        list_delete_start
        from_list_to_string
    FINAL
        get_info
        _continuer
        _plus_tard
        _appris
        _willPopCallback (Fuzzy(..))
    DEBUG
        restart_sort

2_account
    FINAL
        _pushLearning
        _pushLearned

2_settings
    FINAL
        liste_deroulantes_batch
        liste_deroulantes_quizz
        liste_deroulantes_fuzzy
        check_box_paire
        check_box_quizz
        check_box_translation
        push_save_settings
        push_set_default_values
    
_global_functions
    go_to_paire
    import_list_sync
    import_setting_sync
        get_default_settings
    import_setting_async
    create_setting
    shuffle
    process
    save_settings
    







