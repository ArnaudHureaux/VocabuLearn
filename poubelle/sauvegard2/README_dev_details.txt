1_home
    INTER
        create_all_files
            create_file
        read_list_from_file_name
        filter_list_of_list
            read_list_from_file_name x3
        create_all_occ
        import_setting_async

        go_to_paire
            restart
            create_setting
        go_to_account
            restart
            create_setting
        go_to_settings
            restart
            create_all_files
        go_to_trouver
            create_setting
        restart
    FINAL
        pushTrouver
            create_all_files
            go_to_trouver
        pushApprendre
            create_all_files
            go_to_paire
        pushAccount
            create_all_files
            go_to_account
        pushSettings
            go_to_settings
    DEBUG
    reintializeAllFiles
        reinitializeFiles

2_trouver
    INTER
        save_data_one
        go_to_paire
        import_list_sync
        import_list_async
        import_setting_sync
        import_list_async
        save_settings_difficulty
            save_settings
    FINAL
        rightPush
        leftPush
        save_data
            save_data_one
            save_settings_difficulty
        moreDifficulty
        lessDifficulty
        _willPopCallback (Home)
    DEBUG
        restart_trouver

2_1_paire
    INTER
        import_setting
        process
        shuffle
        import_list_sync
        french_or_english
    FINAL
        onPressed
        go_to_quizz
        _willPopCallback (Home)
    DEBUG
        restart_paire

2_2_quizz
    INTER
        import_setting_sync
        process
        shuffle
        import_list_sync
        get_quizz_words
        go_to_fuzzy
    FINAL
        pushButton
        _willPopCallback (Paire(..))

2_3_fuzzy
    INTER
        import_setting_sync
        process
        shuffle
        import_list_sync
        go_to_sort
    FINAL
        _fuzzyMatch
        _spoilPush
        _nextPush
        _submitPush
        _willPopCallback (Quizz(..))

2_4_sort
    INTER
        import_setting
        process
        shuffle
        import_list_sync
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
    INTER
        import_list_sync
    FINAL
        _pushLearning
        _pushLearned

2_settings
    INTER
        create_setting
        import_setting_sync
        save_settings
    FINAL
        liste_deroulantes_batch
        liste_deroulantes_quizz
        liste_deroulantes_fuzzy
        check_box_paire
        check_box_quizz
        check_box_translation
        push_save_settings
        push_set_default_values
    








