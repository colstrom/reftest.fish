function reftest --argument path
    switch "$path"
        case -- --help -h
            echo 'usage: reftest <path>' >&2
            false
        case ''
            reftest (fish_realpath .)
        case '*'
            use (fish_realpath $path/functions)
            set failed 0
            for function in $path/functions/*.fish
                set unit (basename -s .fish $function)
                if test -f reference/$unit
                    for case in test/cases/*
                        set test (cat $case)
                        set scenario (string replace --all --regex '[-_]' ' ' (basename $case))

                        if test (eval $unit $test | base64) = (eval reference/$unit $test | base64)
                            echo ok - $unit $scenario
                        else
                            echo not ok - $unit $scenario
                            set failed 1
                            diff (eval $unit $test | psub) (eval reference/$unit $test | psub) | string replace --regex '^' '#  '
                        end
                    end
                else
                    echo not ok - $unit has no reference implementation
                    set failed 1
                end
            end
    end
end
