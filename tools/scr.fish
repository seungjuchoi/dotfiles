#!/usr/bin/env fish

# 필요한 패키지:
# Linux: python3-pip scrot xclip libnotify-bin
# macOS: uv tool install easyocr

# 필요한 디렉토리 생성
mkdir -p ~/screenshots

# 현재 날짜와 시간으로 파일명 생성
set FILENAME "screenshot_"(date +%Y%m%d_%H%M%S)
set SCREENSHOT_PATH ~/screenshots/$FILENAME.png
set OUTPUT_PATH ~/screenshots/$FILENAME.txt

# OS 확인
set OS (uname)

# 스크린샷 촬영 (선택 영역) - OS별
if test "$OS" = "Linux"
    scrot -s $SCREENSHOT_PATH
    
    # 스크린샷 촬영 성공 확인
    if not test -f "$SCREENSHOT_PATH"
        notify-send "OCR 실패" "스크린샷이 촬영되지 않았습니다."
        exit 1
    end
else if test "$OS" = "Darwin" # macOS
    screencapture -i $SCREENSHOT_PATH
    
    # 스크린샷 촬영 성공 확인
    if not test -f "$SCREENSHOT_PATH"
        osascript -e 'display notification "스크린샷이 촬영되지 않았습니다." with title "OCR 실패"'
        exit 1
    end
end

# OCR 실행 (한국어와 영어 둘 다 인식) - EasyOCR 사용
easyocr -f "$SCREENSHOT_PATH" -l en ko --detail 0 > "$OUTPUT_PATH"

# OCR 결과를 클립보드에 복사 - OS별
if test -f "$OUTPUT_PATH" && test -s "$OUTPUT_PATH"
    # 추출된 텍스트 읽기
    set EXTRACTED_TEXT (cat "$OUTPUT_PATH")
    
    # 알림에 표시할 텍스트 (너무 길면 잘라냄)
    set NOTIFICATION_TEXT (string sub -l 100 "$EXTRACTED_TEXT")
    if test (string length "$EXTRACTED_TEXT") -gt 100
        set NOTIFICATION_TEXT "$NOTIFICATION_TEXT..."
    end
    
    if test "$OS" = "Linux"
        xclip -selection clipboard < "$OUTPUT_PATH"
        notify-send "OCR 완료" "텍스트: $NOTIFICATION_TEXT"
    else if test "$OS" = "Darwin" # macOS
        pbcopy < "$OUTPUT_PATH"
        osascript -e "display notification \"텍스트: $NOTIFICATION_TEXT\" with title \"OCR 완료\""
    end
else
    if test "$OS" = "Linux"
        notify-send "OCR 실패" "텍스트 추출에 실패했습니다."
    else if test "$OS" = "Darwin" # macOS
        osascript -e 'display notification "텍스트 추출에 실패했습니다." with title "OCR 실패"'
    end
end

