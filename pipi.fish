function pipi
    set pkg_name (string split "=" $argv)[1]
    set pkg_version (string split "=" $argv)[2]
    if test -n "$VIRTUAL_ENV"
        if not test -e requirements.txt
            touch requirements.txt
        end
        if not grep -iq $pkg_name requirements.txt
            pip install $pkg_name
            and pip freeze | grep -i $pkg_name >> requirements.txt
        else
            set installed_version (pip freeze | grep -i $pkg_name | string split "=")[2]
            if test "$installed_version" != "$pkg_version"
                pip install $pkg_name
                and sed -i "/$pkg_name/d" requirements.txt
                and pip freeze | grep -i $pkg_name >> requirements.txt
            else
                echo "Package $argv is already in requirements.txt with the same version"
            end
        end
    else
        echo "Not in a virtual environment. Installing the package without updating requirements.txt"
        pip install $argv
    end
end

