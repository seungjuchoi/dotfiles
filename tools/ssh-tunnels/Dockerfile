FROM alpine

# 필요한 패키지 설치
RUN apk add --no-cache openssh autossh

# 스크립트 파일 복사
COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh

# SSH 키 파일 복사 (로컬 머신의 SSH 키를 복사)
COPY .ssh/ /root/.ssh/

# 컨테이너 시작 시 실행할 명령어
ENTRYPOINT ["/root/entrypoint.sh"]

