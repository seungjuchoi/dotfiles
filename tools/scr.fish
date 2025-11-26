#!/usr/bin/env fish

# 필요한 패키지:
# Linux: scrot xclip libnotify-bin surya-ocr
# macOS: surya-ocr

# 임시 디렉토리 설정
set SURYA_OUTPUT_DIR /tmp/surya

# 현재 날짜와 시간으로 파일명 생성
set FILENAME "screenshot_"(date +%Y%m%d_%H%M%S)
set SCREENSHOT_PATH /tmp/$FILENAME.png

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

# OCR 실행 - surya_ocr 사용
surya_ocr "$SCREENSHOT_PATH" --output_dir "$SURYA_OUTPUT_DIR" 2>/dev/null

# JSON에서 텍스트 추출
set JSON_FILE "$SURYA_OUTPUT_DIR/$FILENAME/results.json"

if test -f "$JSON_FILE"
    set EXTRACTED_TEXT (jq -r --arg key "$FILENAME" '.[$key][].text_lines[].text' "$JSON_FILE" | string collect)

    if test -n "$EXTRACTED_TEXT"
        # 알림에 표시할 텍스트 (너무 길면 잘라냄)
        set NOTIFICATION_TEXT (string sub -l 100 "$EXTRACTED_TEXT")
        if test (string length "$EXTRACTED_TEXT") -gt 100
            set NOTIFICATION_TEXT "$NOTIFICATION_TEXT..."
        end

        if test "$OS" = "Linux"
            echo -n "$EXTRACTED_TEXT" | xclip -selection clipboard
            notify-send "OCR 완료" "텍스트: $NOTIFICATION_TEXT"
        else if test "$OS" = "Darwin" # macOS
            echo -n "$EXTRACTED_TEXT" | pbcopy
            osascript -e "display notification \"텍스트: $NOTIFICATION_TEXT\" with title \"OCR 완료\""
        end
    else
        if test "$OS" = "Linux"
            notify-send "OCR 실패" "텍스트 추출에 실패했습니다."
        else if test "$OS" = "Darwin" # macOS
            osascript -e 'display notification "텍스트 추출에 실패했습니다." with title "OCR 실패"'
        end
    end
else
    if test "$OS" = "Linux"
        notify-send "OCR 실패" "결과 파일을 찾을 수 없습니다."
    else if test "$OS" = "Darwin" # macOS
        osascript -e 'display notification "결과 파일을 찾을 수 없습니다." with title "OCR 실패"'
    end
end

# 임시 파일 정리
rm -f "$SCREENSHOT_PATH"
rm -rf "$SURYA_OUTPUT_DIR/$FILENAME"
