function pipi
    if test (count $argv) -eq 0
        echo "Error: No package provided. Please provide at least one package to install."
        return 1
    end
    for pkg in $argv
        set pkg_name (string split "=" $pkg)[1]
        set pkg_version (string split "=" $pkg)[2]
        if test -n "$VIRTUAL_ENV"
            if not test -e requirements.txt
                touch requirements.txt
            end
            if not grep -iq $pkg_name requirements.txt
                echo "Installing and adding $pkg to requirements.txt"
                pip install $pkg_name
                and pip freeze | grep -i $pkg_name >> requirements.txt
            else
                set installed_version (pip freeze | grep -i $pkg_name | string split "=")[2]
                if test "$installed_version" != "$pkg_version"
                    echo "Updating $pkg in requirements.txt"
                    pip install $pkg_name
                    and sed -i "/$pkg_name/d" requirements.txt
                    and pip freeze | grep -i $pkg_name >> requirements.txt
                else
                    echo "Package $pkg is already in requirements.txt with the same version"
                end
            end
        else
            echo "Not in a virtual environment. Installing $pkg without updating requirements.txt"
            pip install $pkg
        end
    end
end
