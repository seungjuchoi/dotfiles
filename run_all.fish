#!/usr/bin/env fish

set scripts \
    1_install_packages.fish \
    2_install_plugins.fish \
    3_set_config.fish

set script_dir (status dirname)

for script in $scripts
    echo "==> $script 실행 중..."
    fish $script_dir/$script
    if test $status -ne 0
        echo "❌ $script 실패. 중단합니다."
        exit 1
    end
    echo "✅ $script 완료"
end

echo "🎉 모든 스크립트 완료"
